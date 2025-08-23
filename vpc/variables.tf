variable "public_subnet_cidr" {
  default     = "10.0.1.0/24"
  description = "CIDR for public subnet"
}

variable "private_subnet_cidr" {
  default     = "10.0.2.0/24"
  description = "CIDR for private subnet"
}

variable "availability_zone" {
  default     = "us-east-1a"
  description = "Availability Zone для сабнетів"
}
