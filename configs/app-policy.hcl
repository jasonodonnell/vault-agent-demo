path "secret/hashiconf" {
  capabilities = ["read"]
}

path "secret/test" {
  capabilities = ["read", "list"]
}

path "secret/test/*" {
  capabilities = ["read", "list"]
}

path "database/creds/db-app" {
  capabilities = ["read"]
}

path "transit/encrypt/app" {
  capabilities = ["create", "read", "update"] 
}

path "transit/decrypt/app" {
  capabilities = ["create", "read", "update"] 
}
