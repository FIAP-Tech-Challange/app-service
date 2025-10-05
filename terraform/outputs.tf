# Outputs úteis

output "namespace" {
  description = "Nome do namespace criado"
  value       = kubernetes_namespace.tech_challenge.metadata[0].name
}

output "deployment_name" {
  description = "Nome do deployment"
  value       = kubernetes_deployment.tech_challenge_app.metadata[0].name
}

output "service_name" {
  description = "Nome do service interno"
  value       = kubernetes_service.tech_challenge_service.metadata[0].name
}

output "loadbalancer_name" {
  description = "Nome do LoadBalancer"
  value       = kubernetes_service.tech_challenge_loadbalancer.metadata[0].name
}

output "hpa_name" {
  description = "Nome do HPA"
  value       = kubernetes_horizontal_pod_autoscaler_v2.tech_challenge_hpa.metadata[0].name
}
