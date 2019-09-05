package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

type NotFoundRedirectRespWr struct {
	http.ResponseWriter
	status int
}

func (w *NotFoundRedirectRespWr) WriteHeader(status int) {
	w.status = status
	if status != http.StatusNotFound {
		w.ResponseWriter.WriteHeader(status)
	}
}

func (w *NotFoundRedirectRespWr) Write(p []byte) (int, error) {
	if w.status != http.StatusNotFound {
		return w.ResponseWriter.Write(p)
	}
	return len(p), nil
}

func Wrap(h http.Handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		rw := &NotFoundRedirectRespWr{ResponseWriter: w}
		h.ServeHTTP(rw, r)
		if rw.status == 404 {
			_, _ = fmt.Fprintf(w, "No secrets found!")
		}
	}
}

func main() {
	path := os.Getenv("VAULT_SECRET_PATH")
	if path == "" {
		path = "/vault/secrets"
	}

	fs := Wrap(http.FileServer(http.Dir(path)))
	http.HandleFunc("/", fs)
	log.Println("Starting web server at 0.0.0.0:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
