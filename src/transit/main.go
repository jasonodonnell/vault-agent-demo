package main

import (
	"encoding/base64"
	"io/ioutil"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	pg "github.com/hashicorp/agent-inject-demo-app/data"
	"github.com/hashicorp/go-hclog"
	"github.com/hashicorp/vault/api"
)

type App struct {
	Listen         string
	DatabasePath   string
	DatabaseSecret string
	TLSPath        string
	Logger         hclog.Logger
}

var db *pg.DB

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

	var err error
	db, err = app.newDBConnection()
	if err != nil {
		app.Logger.Error("error creating database connection: %s", err)
		os.Exit(1)
	}
	defer db.Close()

	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var results struct {
			Connected bool
			UsersEncrypted []pg.User
			UsersDecrypted []pg.User
			Username pg.Username
			Version pg.Version
		}

		usersRaw, err := db.AllUsers()
		if err != nil {
			app.Logger.Error("error parsing database", "error", err)
			os.Exit(1)
		}

		var httpClient = &http.Client{Timeout: 10 * time.Second}
		client, err := api.NewClient(&api.Config{Address: "http://127.0.0.1:8200", HttpClient: httpClient})
		if err != nil {
			app.Logger.Error("error creating Vault client", "error", err)
			os.Exit(1)
		}

		var usersEncrypted []pg.User
		for _, user := range usersRaw {
			encodedPass := base64.StdEncoding.EncodeToString([]byte(user.Password))
			encrypt := make(map[string]interface{})
			encrypt["plaintext"] = encodedPass

			secret, err := client.Logical().Write("transit/encrypt/app", encrypt)
			if err != nil {
				app.Logger.Error("error encrypting secret", "error", err)
				os.Exit(1)
			}
			encrypted := pg.User{
				Username: user.Username,
				Password: secret.Data["ciphertext"].(string),
			}
			usersEncrypted = append(usersEncrypted, encrypted)
		}
		results.UsersEncrypted = usersEncrypted

		var usersDecrypted []pg.User
		for _, user := range usersEncrypted {
			decrypt := make(map[string]interface{})
			decrypt["ciphertext"] = user.Password
			secret, err := client.Logical().Write("transit/decrypt/app", decrypt)
			if err != nil {
				app.Logger.Error("error decrypting secret", "error", err)
				os.Exit(1)
			}

			decodedPass, err := base64.StdEncoding.DecodeString(secret.Data["plaintext"].(string))
			if err != nil {
				app.Logger.Error("error decoding secret", "error", err)
				os.Exit(1)
			}

			decrypted := pg.User{
				Username: user.Username,
				Password: string(decodedPass),
			}
			usersDecrypted = append(usersDecrypted, decrypted)
		}
		results.UsersDecrypted = usersDecrypted

		results.Username, err = db.User()
		if err != nil {
			app.Logger.Error("error parsing database", "error", err)
			os.Exit(1)
		}

		results.Version, err = db.Version()
		if err != nil {
			app.Logger.Error("error parsing database", "error", err)
			os.Exit(1)
		}

		results.Connected = true

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

	go func(){
		for range c {
			app.Logger.Info("SIGHUP received. Reloading configuration..")
			db, err = app.newDBConnection()
			if err != nil {
				app.Logger.Error("error creating database connection: %s", err)
				os.Exit(1)
			}
		}
	}()

	err = srv.ListenAndServe()
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

func (a *App) newDBConnection() (*pg.DB, error) {
	for !fileExists(a.DatabasePath) {
		a.Logger.Error("error reading database secret: file does not exist", "file", a.DatabasePath)
		time.Sleep(1 * time.Second)
	}

	dbSecret, err := ioutil.ReadFile(a.DatabasePath)
	if err != nil {
		a.Logger.Error("error reading database secret", "error", err)
		return nil, err
	}

	a.DatabaseSecret = strings.Replace(strings.TrimSpace(string(dbSecret)), "\n", "", -1)
	return pg.NewDB(a.DatabaseSecret)
}