package data

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

// DB returns a pointer to a sql.DB entity.
type DB struct {
	*sql.DB
}

// ConnURL creates a connection string URL for connecting to postgres.
type ConnURL struct {
	DBName   string
	Host     string
	Password string
	Port     int
	SSL      string
	User     string
}

// NewDB returns a new database entity.
func NewDB(connURL string) (*DB, error) {
	db, err := sql.Open("postgres", connURL)
	if err != nil {
		return nil, err
	}
	if err = db.Ping(); err != nil {
		return nil, err
	}
	return &DB{db}, nil
}

// URL returns a connection string URL.
func (c *ConnURL) URL() string {
	return fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=%s",
		c.User, c.Password, c.Host, c.Port, c.DBName, c.SSL)
}

type User struct {
	Username string
	Password string
}

func (db *DB) AllUsers() ([]User, error) {
	statement := "SELECT * FROM app.users"

	rows, err := db.Query(statement)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []User
	for rows.Next() {
		var username, password sql.NullString
		if err := rows.Scan(&username, &password); err != nil {
			return nil, err
		}
		c := User{
			Username: username.String,
			Password: password.String,
		}
		users = append(users, c)
	}
	return users, nil
}

type Username string

func (db *DB) User() (Username, error) {
	rows, err := db.Query("SELECT current_user")
	if err != nil {
		return "", err
	}
	defer rows.Close()

	var username Username
	for rows.Next() {
		if err := rows.Scan(&username); err != nil {
			return "", err
		}
	}
	return username, nil
}

type Version string

func (db *DB) Version() (Version, error) {
	rows, err := db.Query("SHOW server_version")
	if err != nil {
		return "", err
	}
	defer rows.Close()

	var version Version
	for rows.Next() {
		if err := rows.Scan(&version); err != nil {
			return "", err
		}
	}
	return version, nil
}