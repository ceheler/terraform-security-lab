variable "instance_type" {
  type        = string
  description = "The size of the EC2 instance to deploy"
  default     = "t3.micro"
}

variable "region" {
  type        = string
  description = "The AWS region in which to deploy resources"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR address block to allocate for the VPC"
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The CIDR values for the public subnet"
  default     = "10.10.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The CIDR values for the private subnet"
  default     = "10.10.2.0/24"
}

variable "terraform_execution_role_arn" {
  type        = string
  description = "ARN of the IAM role Terraform assumes to deploy resources"
}