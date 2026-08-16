variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "sa-east-1"
}

variable "ami_id" {
  description = "AMI Debian 13 x86_64"
  type        = string
  default     = "ami-076d7953890752f25"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Nome da Key Pair SSH da AWS"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "IP público autorizado para SSH/Ansible"
  type        = string
}

variable "allowed_monitoring_cidr" {
  description = "IP público autorizado para Grafana e Prometheus"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR da subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_ip" {
  description = "IP privado fixo da EC2"
  type        = string
  default     = "10.0.1.10"
}

variable "root_volume_size" {
  description = "Tamanho do disco em GB"
  type        = number
  default     = 40
}