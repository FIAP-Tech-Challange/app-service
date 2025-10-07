# Variáveis do Terraform

variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL do repositório ECR"
  type        = string
}

variable "image_tag" {
  description = "Tag da imagem Docker"
  type        = string
}

variable "jwt_secret" {
  description = "Secret para JWT"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "Chave da API"
  type        = string
  sensitive   = true
}

variable "db_pg_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_pg_port" {
  description = "Porta do banco de dados"
  type        = string
}

variable "db_pg_user" {
  description = "Usuário do banco de dados"
  type        = string
}

variable "db_pg_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_pg_host" {
  description = "Host do banco de dados"
  type        = string
}

variable "jwt_access_token_expiration_time" {
  description = "Tempo de expiração do access token JWT"
  type        = string
}

variable "jwt_refresh_token_expiration_time" {
  description = "Tempo de expiração do refresh token JWT"
  type        = string
}
