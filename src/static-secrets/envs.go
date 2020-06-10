package main

import (
	"errors"
	"github.com/kelseyhightower/envconfig"
)

type Specification struct {
	Listen       string
	SecretPath   string `envconfig:"secret_path"`
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

	if envs.SecretPath != "" {
		a.SecretPath = envs.SecretPath
	}

	if a.SecretPath == "" {
		return errors.New("secret path not set")
	}

	return nil
}
