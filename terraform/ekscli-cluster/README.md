# Terraform Module for EKS (using eksctl)

A reusable module to create an EKS cluster using the `eksctl` as local provisioner. So make sure you have the latest `eksctl` available locally.

## Development

If you want to make changes to this module, proceed as follows to format and validate the module sources:

```bash
$ terraform init
$ export AWS_DEFAULT_REGION=eu-central-1

$ terraform fmt
$ terraform validate
``` 

## Usage

```
module "ekscli-cluster" {
    source = git::https://github.com/qaware/cloud-native-explab.git//terraform/ekscli-cluster

    # specify input variables for this module
    cluster_name = "demo-eks-dev"
    cluster_vpc_id = "vpc-1234567890"
    cluster_tags = {
        Creator = "Terraform"
        Environment = terraform.workspace
    }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14.0 |
| aws       | >= 3.0    |

## Providers

| Name | Version |
|------|---------|
| aws  | >= 3.0  |
| null |         |
| local |        |
| template |     |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name for the EKS cluster | `string` |  | yes |
| cluster_region | Region for the EKS cluster | `string` | `eu-central-1` | no |
| cluster_version | Version of Kubernetes to use for the EKS cluster | `string` | `1.19` | no |
| cluster_tags | Tags to set on the EKS cluster | `map(string)` | `{}` | no |
| cluster_vpc_id | VPC ID for the EKS cluster | `string` |  | yes |
| cluster_private_subnets | Mapping of AZs to private subnet IDs | `map(string)` | `{}` | no |
| cluster_public_subnets | Mapping of AZs to public subnet IDs | `map(string)` | `{}` | no |
| cluster_endpoints_private_access | Enable private access for the EKS cluster | `bool` | `true` | no |
| cluster_endpoints_public_access | Enable public access for the EKS cluster | `bool` | `false` | no |
| cluster_template_file | A custom config template file to use instead of default template | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| eks_cluster_endpoint | The endpoint URL of the EKS cluster |
| eks_cluster_auth_token | The IAM authentication token for the EKS cluster |
| kubeconfig_ca_data | The kubeconfig certificate authority data for the EKS cluster |
| kubeconfig_content | The kubeconfig file content for the EKS cluster |
