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
    DB_PG_HOST    = data.aws_ssm_parameter.rds_host.value
    DB_PG_USER    = data.aws_ssm_parameter.rds_user.value
    DB_PG_PASSWORD = data.aws_ssm_parameter.rds_password.value
    API_KEY       = var.api_key
    JWT_SECRET    = var.jwt_secret
  }

  type = "Opaque"
}
