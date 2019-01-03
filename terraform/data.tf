# AMI filter for the latest Amazon-provided AMI. Also likely production-unworthy; one would typically like at least
# some degree of software installation and ownership at this stage.
# At a bare minimum we should be pinning our Kubernetes version. Here we naively install latest version of the
# Amazon Linux 2 with Kubernetes baked in via https://github.com/awslabs/amazon-eks-ami

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

# Rely on local settings for region.
data "aws_region" "current" {}