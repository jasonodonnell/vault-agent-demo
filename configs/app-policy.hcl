path "database/creds/db-app" {
  capabilities = ["read"]
}

path "pki/issue/hashicorp-com" {
  capabilities = ["create", "read", "update"] 
}
