path "secret/hashiconf" {
  capabilities = ["read"]
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
