provider "aws" {
  region = var.aws_region
}

locals {
  tags         = { cluster = random_id.unique.hex }
  cluster_name = "k8s-${random_id.unique.hex}"
}
resource "random_id" "unique" {
  byte_length = 4
}

data "aws_eks_cluster" "k8s" {
  name = module.k8s.cluster_id
}

data "aws_eks_cluster_auth" "k8s" {
  name = module.k8s.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.k8s.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8s.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.k8s.token
}

module "k8s" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "15.2.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = aws_subnet.main.*.id
  vpc_id          = aws_vpc.main.id
  tags            = local.tags
  kubeconfig_name = "kubeconfig_tf"
  worker_groups = [
    {
      instance_type    = "t3.small"
      asg_max_size     = 4
      asg_min_size     = 0
      asg_desired_size = 3
      public_ip        = true # need a NAT Gateway in VPC if this is False
    }
  ]
}

resource "tls_private_key" "this" {
  count = 0
  algorithm = "RSA"
}

module "key_pair" {
  count = 0
  source = "terraform-aws-modules/key-pair/aws"
  version = "1.0.0"
  key_name   = local.cluster_name
  public_key = tls_private_key.this[0].public_key_openssh
}

module "bootstrap" {
  source = "../k8s/"

  k8s_host  = data.aws_eks_cluster.k8s.endpoint
  k8s_cert  = base64decode(data.aws_eks_cluster.k8s.certificate_authority.0.data)
  k8s_token = data.aws_eks_cluster_auth.k8s.token
}
