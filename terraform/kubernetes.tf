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

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "tech-challenge"
    namespace = kubernetes_namespace.tech_challenge.metadata[0].name
  }

  # Força a sobrescrita de quaisquer alterações manuais
  force = true

  data = {
    NODE_ENV                            = "production"
    DB_PG_PORT                         = var.db_pg_port
    DB_PG_NAME                         = var.db_pg_name
    DB_PG_LOGGING                      = "false"
    JWT_ACCESS_TOKEN_EXPIRATION_TIME   = var.jwt_access_token_expiration_time
    JWT_REFRESH_TOKEN_EXPIRATION_TIME  = var.jwt_refresh_token_expiration_time
    # Mapeia as roles do IAM para grupos do Kubernetes
    mapRoles = yamlencode([
      {
        # Mapeia os nós do EKS para que possam se juntar ao cluster
        rolearn  = module.eks.worker_iam_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      {
        # IMPORTANTE: Mapeia a sua role do AWS Academy para o grupo de administradores
        rolearn  = data.aws_caller_identity.current.arn # Usa o ARN da role que está executando o Terraform
        username = "terraform-admin" # Um nome de usuário para logs
        groups   = [
          "system:masters"
        ]
      }
    ])
    # mapUsers e mapAccounts podem ficar vazios se não forem necessários
    mapUsers    = yamlencode([])
    mapAccounts = yamlencode([])
  }

  # Garante que o ConfigMap seja criado/atualizado somente após o cluster estar pronto
  depends_on = [
    module.eks.cluster
  ]
}

# ConfigMap
# resource "kubernetes_config_map" "tech_challenge_config" {
#   metadata {
#     name      = "tech-challenge-config"
#     namespace = kubernetes_namespace.tech_challenge.metadata[0].name
#     labels = {
#       app         = "tech-challenge"
#       environment = "production"
#     }
#   }

#   data = {
#     NODE_ENV                            = "production"
#     DB_PG_PORT                         = var.db_pg_port
#     DB_PG_NAME                         = var.db_pg_name
#     DB_PG_LOGGING                      = "false"
#     JWT_ACCESS_TOKEN_EXPIRATION_TIME   = var.jwt_access_token_expiration_time
#     JWT_REFRESH_TOKEN_EXPIRATION_TIME  = var.jwt_refresh_token_expiration_time
#   }
# }

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
