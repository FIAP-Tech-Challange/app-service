# Deployment
resource "kubernetes_deployment" "tech_challenge_app" {
  metadata {
    name      = "tech-challenge-app"
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "tech-challenge"
      }
    }

    template {
      metadata {
        labels = {
          app         = "tech-challenge"
          environment = "production"
        }
      }

      spec {
        container {
          name              = "tech-challenge"
          image             = "${var.ecr_repository_url}:latest"
          image_pull_policy = "Always"

          port {
            container_port = 3000
          }

          # Variáveis do ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map.tech_challenge_config.metadata[0].name
            }
          }

          # Variáveis do Secret
          env_from {
            secret_ref {
              name = kubernetes_secret.tech_challenge_secrets.metadata[0].name
            }
          }

          # Health checks
          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          # Resource limits
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
