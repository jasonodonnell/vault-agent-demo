path "foo/secret/hashiconf" {
  capabilities = ["read"]
}

path "foo/database/creds/db-app" {
  capabilities = ["read"]
}

path "foo/transit/encrypt/app" {
  capabilities = ["create", "read", "update"]
}

path "foo/transit/decrypt/app" {
  capabilities = ["create", "read", "update"]
}
