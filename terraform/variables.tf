variable "region" {
  description = "AWS region para o RDS"
  type        = string
  default     = "us-east-1"
}

variable "db_username" {
  description = "Usuário do Postgres"
  type        = string
  default     = "soat"
}

variable "db_password" {
  description = "Senha do Postgres"
  type        = string
  sensitive   = true
}
