# Create service roles. These names should be variables given the namespace is both enforced-unique and global at the account level.

resource "aws_iam_role" "demo-cluster" {
  name = "terraform-eks-demo-cluster"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-demo-node"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# The odd DescribeAccountAttributes requirement is a new one. It's been fixed in Kube itself, but that
# necessity doesn't yet seem to be reflected in the default IAM policies for EKS. Reference:
# https://github.com/terraform-aws-modules/terraform-aws-eks/issues/183 (amongst others)
# Here we just lazily slap an inline policy into our role, as it seems likely to not be needed long-term.
resource "aws_iam_role_policy" "eks_cluster_ingress_loadbalancer_creation" {
  name   = "eks-cluster-ingress-loadbalancer-creation"
  role       = "${aws_iam_role.demo-cluster.name}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeAddresses",
        "ec2:DescribeInternetGateways"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

# This policy is granted to the worker nodes so as to allow the external-dns container appropriate rights to
# alter DNS. Ideally we'd be distributing these to an individual container role but I'm not certain that's
# available for EKS at the moment.
resource "aws_iam_role_policy" "eks_cluster_node_dns_management" {
  name   = "eks_cluster_node_dns_management"
  role       = "${aws_iam_role.demo-node.name}"
  policy = <<POLICY
{
  "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "${var.dns-arn}"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
  ]
}
POLICY
}

# Attach prefab AWS Kubernetes service policies. Convenient but hardly appropriate for any multitenant production account.
# Note that the use of aws_iam_role_policy_attachment is quite important; the similar aws_iam_policy_attachment
# manages *all* attachments of a role; destruction or recreation will remove the policy from all roles.

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.demo-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "demo-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.demo-cluster.name}"
}

# Again we see Amazon following their design device of "Resource '*' is nearly always ill-advised" with
# generic policies doing exactly that. These should either be pared, restricted with conditions, or the ideally,
# restricted to their own accounts.
resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.demo-node.name}"
}

# Omitted adding this to scope, but this manifest *should* be modified to pull the application
# from a locally controlled repository. Tags in public repositories are both revokable and replaceable,
# so some assurance should be made that your immutable application container stays...immutable.
resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_instance_profile" "demo-node" {
  name = "terraform-eks-demo"
  role = "${aws_iam_role.demo-node.name}"
}
