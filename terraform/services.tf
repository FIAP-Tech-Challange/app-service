# Service interno (ClusterIP)
resource "kubernetes_service" "tech_challenge_service" {
  metadata {
    name      = "tech-challenge-service"
    namespace = kubernetes_namespace.tech_challenge.metadata[0].name
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
  }

  spec {
    selector = {
      app = "tech-challenge"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# LoadBalancer para acesso externo
resource "kubernetes_service" "tech_challenge_loadbalancer" {
  metadata {
    name      = "tech-challenge-loadbalancer"
    namespace = kubernetes_namespace.tech_challenge.metadata[0].name
    labels = {
      app         = "tech-challenge"
      environment = "production"
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
    }
  }

  spec {
    selector = {
      app = "tech-challenge"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}
