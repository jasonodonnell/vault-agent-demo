project = "agent-injector-demo"

app "demo" {
    build {
      use "docker" {}
      registry {
        use "docker" {
          image = "gcr.io/vault-helm-dev/hashicorp/transit-app"
          tag = "2.0.0"
        }
       }
    }

   deploy {
      use "kubernetes" {
          probe_path = "/"
          service_port = "8080"
          static_environment = {
            "CI" = "true"
            "PG_SCHEMA" = "app"
            "APP_DB_PATH" = "/vault/secrets/db-creds"
          }
          annotations = {
            "vault.hashicorp.com/agent-inject" = "true"
            "vault.hashicorp.com/agent-inject-status" = "update"
            "vault.hashicorp.com/agent-cache-enable" = "true"
            "vault.hashicorp.com/agent-cache-use-auto-auth-token" = "force"
            "vault.hashicorp.com/agent-inject-secret-db-creds" = "database/creds/db-app"
            "vault.hashicorp.com/agent-inject-template-db-creds" = <<EOF
              {{- with secret "database/creds/db-app" -}}
              postgres://{{ .Data.username }}:{{ .Data.password }}@postgres.postgres.svc:5432/wizard?sslmode=disable
              {{- end }}
            EOF
            "vault.hashicorp.com/role" = "app"
            "vault.hashicorp.com/tls-secret" = "tls-test-client"
            "vault.hashicorp.com/ca-cert" = "/vault/tls/ca.crt"
          }
          service_account = "app"
      }
    }

    release {
        use "kubernetes" {
            load_balancer = true
            port = 80
        }
    }
}
