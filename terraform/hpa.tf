# HPA - Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "tech_challenge_hpa" {
  metadata {
    name      = "tech-challenge-app-hpa"
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
  }

  spec {
    min_replicas = 2
    max_replicas = 8

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.tech_challenge_app.metadata[0].name
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        policy {
          type          = "Percent"
          value         = 50
          period_seconds = 60
        }
      }

      scale_up {
        stabilization_window_seconds = 60
        policy {
          type          = "Percent"
          value         = 100
          period_seconds = 60
        }
        policy {
          type          = "Pods"
          value         = 2
          period_seconds = 60
        }
        select_policy = "Max"
      }
    }
  }
}
