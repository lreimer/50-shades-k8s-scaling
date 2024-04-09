terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local    = {}
    template = {}
  }
}

locals {
  cluster_template_file   = length(var.cluster_template_file) == 0 ? "${path.module}/eksctl_cluster.tpl" : var.cluster_template_file
  cluster_config_filename = "${path.module}/${var.cluster_name}-config-rendered.yaml"

  cluster_tags = <<EOF
  %{~for key, value in var.cluster_tags}
    ${key}: "${value}"
  %{~endfor}
  EOF

  private_subnets = <<EOF
  %{~for name, subnet in var.cluster_private_subnets}
      ${name}: 
        id: "${subnet}"
  %{~endfor}
  EOF

  public_subnets = <<EOF
  %{~for name, subnet in var.cluster_public_subnets}
      ${name}: 
        id: "${subnet}"
  %{~endfor}
  EOF
}

data "template_file" "cluster_config_template" {
  template = file(local.cluster_template_file)
  vars = {
    cluster_name                     = var.cluster_name
    cluster_region                   = var.cluster_region
    cluster_version                  = var.cluster_version
    cluster_tags                     = local.cluster_tags
    cluster_endpoints_private_access = var.cluster_endpoints_private_access
    cluster_endpoints_public_access  = var.cluster_endpoints_public_access
    cluster_vpc_id                   = var.cluster_vpc_id
    private_subnets                  = local.private_subnets
    public_subnets                   = local.public_subnets
  }
}

resource "local_file" "cluster_config_file" {
  content  = data.template_file.cluster_config_template.rendered
  filename = local.cluster_config_filename
}

resource "null_resource" "eksctl_cluster" {
  # Changes of the cluster requires re-provisioning
  triggers = {
    cluster_name    = var.cluster_name
    cluster_version = var.cluster_version
  }

  provisioner "local-exec" {
    command     = "eksctl create cluster --config-file=${local.cluster_config_filename} --auto-kubeconfig >> eksctl_cluster.txt"
    working_dir = path.module
  }

  depends_on = [local_file.cluster_config_file]
}

data "local_file" "ekscli_output" {
  filename   = "${path.module}/eksctl_cluster.txt"
  depends_on = [null_resource.eksctl_cluster]
}

data "local_file" "kubeconfig_output" {
  filename   = pathexpand("~/.kube/eksctl/clusters/${var.cluster_name}")
  depends_on = [null_resource.eksctl_cluster]
}

data "aws_eks_cluster" "eks_cluster" {
  name       = var.cluster_name
  depends_on = [null_resource.eksctl_cluster]
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name       = var.cluster_name
  depends_on = [null_resource.eksctl_cluster]
}
