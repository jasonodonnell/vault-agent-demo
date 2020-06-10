package main

import (
	"io/ioutil"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"github.com/hashicorp/go-hclog"
)

type App struct {
	Listen         string
	SecretPath     string
	Logger         hclog.Logger
}

func main() {
	appLogger := hclog.New(&hclog.LoggerOptions{
		Name:  "app",
		Level: hclog.LevelFromString("INFO"),
	})

	app := App{
		Logger: appLogger,
	}

	if err := app.parseEnvs(); err != nil {
		app.Logger.Error("error parsing envs", "error", err)
		os.Exit(1)
	}

	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var results struct {
			Key string
			Value string
		}

		secret, err := app.getSecret()
		if err != nil {
			app.Logger.Error("error reading secret", "error", err)
			os.Exit(1)
		}

		secret = strings.Replace(secret," ", "", -1)
		secret = strings.Replace(secret,"{", "", -1)
		secret = strings.Replace(secret,"}", "", -1)
		secret = strings.Replace(secret,"\"", "", -1)

		kv := strings.Split(strings.Replace(secret," ", "", -1), ":")
		if len(kv) != 2 {
			app.Logger.Error("error splitting secret", "error", "split string does not have a key/value pair")
			os.Exit(1)
		}

		results.Key = kv[0]
		results.Value = kv[1]

		err = tmpl.Execute(w, results)
		if err != nil {
			app.Logger.Error("error with template", "error", err)
			os.Exit(1)
		}
	})
	r.PathPrefix("/").Handler(http.FileServer(http.Dir("/tmp/static/")))
	http.Handle("/", r)

	srv := &http.Server{
		Handler:      r,
		Addr:         app.Listen,
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
	}

	app.Logger.Info("Listening on:", "address", app.Listen)

	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGHUP)

	err := srv.ListenAndServe()
	if err != nil {
		app.Logger.Error("error with webserver", "error", err)
		os.Exit(1)
	}
}

func fileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

func (a *App) getSecret() (string, error) {
	for !fileExists(a.SecretPath) {
		a.Logger.Error("error reading secret: file does not exist", "file", a.SecretPath)
		time.Sleep(1 * time.Second)
	}

	secret, err := ioutil.ReadFile(a.SecretPath)
	if err != nil {
		a.Logger.Error("error reading database secret", "error", err)
		return "", err
	}

	return string(secret), nil
}