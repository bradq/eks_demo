variable "cluster-name" {
  default = "bquellhorst-eks-demo"
  type    = "string"
}

variable "region" {
  default = "us-east-1"
  type = "string"
}

variable "subnet-count" {
  default = 2
  description = "Subnets to construct in our VPC. Limited to the number of available AZs in your chosen region"
  type = "string"
}

variable "source-ip" {
  description = "IPv4 address to allow inbound access, expressed in CIDR format"
  type = "string"
  default = "0.0.0.0/0"
}

variable "worker-node-type" {
  description = "AWS instance type to use for worker node instances"
  type = "string"
  default = "t2.small"
}