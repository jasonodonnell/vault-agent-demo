package main

import (
	"errors"

	"github.com/kelseyhightower/envconfig"
)

type Specification struct {
	Listen       string
	DatabasePath string `envconfig:"db_path"`
	TLSPath      string `envconfig:"tls_path"`
}

func (a *App) parseEnvs() error {
	var envs Specification

	err := envconfig.Process("app", &envs)
	if err != nil {
		return err
	}

	a.Listen = ":8080"
	if envs.Listen != "" {
		a.Listen = envs.Listen
	}

	if envs.DatabasePath != "" {
		a.DatabasePath = envs.DatabasePath
	}

	if a.DatabasePath == "" {
		return errors.New("database path not set")
	}

	return nil
}
