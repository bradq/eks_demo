provider "aws" {
  region     = "${var.region}"
}

#terraform {
#  backend "s3" {
#    bucket = "bquellhorst-tfstate"
#    key    = "tfstate/eks-demo"
#    region = "${var.region}"
#  }
#}