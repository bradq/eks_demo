variable "cluster-name" {
  default = "bquellhorst-eks-demo"
  type    = "string"
}

variable "region" {
  default = "us-east-1"
  type = "string"
}

variable "source-ip" {
  description = "IPv4 address to allow inbound access, expressed in CIDR format"
  type = "string"
  default = "0.0.0.0/0"
}

variable "worker-node-type" {
  description = "AWS instance type to use for worker node provisioning"
  type = "string"
  default = "t2.small"
}