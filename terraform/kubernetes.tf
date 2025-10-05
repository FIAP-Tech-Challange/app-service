# Namespace
resource "kubernetes_namespace" "tech_challenge" {
  metadata {
    name = "tech-challenge"
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
  }
}

# ConfigMap
resource "kubernetes_config_map" "tech_challenge_config" {
  metadata {
    name      = "tech-challenge-config"
    namespace = kubernetes_namespace.tech_challenge.metadata[0].name
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
  }

  data = {
    NODE_ENV                            = "production"
    DB_PG_PORT                         = var.db_pg_port
    DB_PG_NAME                         = var.db_pg_name
    DB_PG_LOGGING                      = "false"
    JWT_ACCESS_TOKEN_EXPIRATION_TIME   = var.jwt_access_token_expiration_time
    JWT_REFRESH_TOKEN_EXPIRATION_TIME  = var.jwt_refresh_token_expiration_time
  }
}

# Secret
resource "kubernetes_secret" "tech_challenge_secrets" {
  metadata {
    name      = "tech-challenge-secrets"
    namespace = kubernetes_namespace.tech_challenge.metadata[0].name
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
  }

  data = {
    DB_PG_HOST     = var.db_pg_host
    DB_PG_USER     = var.db_pg_user
    DB_PG_PASSWORD = var.db_pg_password
    API_KEY        = var.api_key
    JWT_SECRET     = var.jwt_secret
  }

  type = "Opaque"
}
