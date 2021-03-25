package main

import (
	"errors"
	"fmt"

	"github.com/kelseyhightower/envconfig"
)

type Specification struct {
	Listen          string
	DatabasePath    string `envconfig:"db_path"`
	TLSPath         string `envconfig:"tls_path"`
	CSI             string
	CSIUsernamePath string `envconfig:"csi_username_path"`
	CSIPasswordPath string `envconfig:"csi_password_path"`
	CSIPGService    string `envconfig:"csi_pg_service"`
}

func (a *App) parseEnvs() error {
	var envs Specification

	err := envconfig.Process("app", &envs)
	if err != nil {
		return err
	}

	if envs.CSI != "" && envs.CSI == "true" {
		a.CSI = true

		if envs.CSIUsernamePath != "" {
			a.CSIUsernamePath = envs.CSIUsernamePath
		}

		if envs.CSIPasswordPath != "" {
			a.CSIPasswordPath = envs.CSIPasswordPath
		}

		if envs.CSIPGService != "" {
			a.CSIPGService = envs.CSIPGService
		}

		if a.CSIUsernamePath == "" || a.CSIPasswordPath == "" || a.CSIPGService == "" {
			return fmt.Errorf("CIS enabled but missing APP_CSI_USERNAME_PATH, APP_CSI_PASSWORD_PATH, or APP_CSI_PG_SERVICE")
		}
	} else {
		if envs.DatabasePath != "" {
			a.DatabasePath = envs.DatabasePath
		}

		if a.DatabasePath == "" {
			return errors.New("database path not set")
		}
	}

	a.Listen = ":8080"
	if envs.Listen != "" {
		a.Listen = envs.Listen
	}

	return nil
}
