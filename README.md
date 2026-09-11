# Terraform Security Lab

This project uses Terraform to deploy a small AWS security lab consisting of a VPC, public and private subnets, route tables, an Internet Gateway, a security group, an IAM instance profile, and a single EC2 instance.

The EC2 instance is managed through AWS Systems Manager Session Manager rather than direct SSH. This avoids storing SSH private keys in Terraform state and eliminates the need to expose an inbound management port.

Terraform authenticates using an assumed execution role rather than static AWS credentials. Environment-specific values, such as the execution-role ARN, are supplied through a local `terraform.tfvars` file that is excluded from source control.

## Architecture

The lab creates a VPC with a configurable CIDR block that defaults to `10.10.0.0/16`.

Two configurable subnets are created:

- A public subnet, which is associated with a route table containing a default route `(0.0.0.0/0)` through an Internet Gateway attached to the VPC.
- A private subnet, which has its own route table and no route to the public Internet.

A single EC2 instance is deployed into the public subnet. The instance type is configurable and defaults to `t3.micro`. The current configuration uses an Ubuntu AMI in `us-west-2`.

The EC2 instance receives a public IPv4 address and uses the public subnet’s route to the Internet Gateway for outbound Internet connectivity. The security group contains no inbound management rules. Administrative access is provided through AWS Systems Manager Session Manager.

## Security Design

This lab was designed to avoid several common security issues in small AWS environments:

- Terraform assumes a dedicated execution role instead of using static AWS credentials.
- The Terraform execution role is granted only the permissions required to manage the lab resources.
- `iam:PassRole` is restricted to the EC2 role required by this environment.
- EC2 administrative access uses AWS Systems Manager Session Manager instead of direct SSH.
- No SSH private keys are generated or stored in Terraform state.
- The EC2 security group does not expose an inbound SSH management port.
- Terraform state files and environment-specific `.tfvars` files are excluded from source control.
- The AWS account-specific execution-role ARN is supplied locally through `terraform.tfvars` rather than being committed to the repository.

## Prerequisites

This project was developed and tested with:

- Terraform CLI 1.16.2
- AWS CLI v2
- AWS Provider 6.64.0
- An AWS account with an IAM identity capable of assuming the Terraform execution role
- A Terraform execution role with permissions to create, read, modify, and delete the AWS resources used by this lab

AWS CLI authentication must be configured before running Terraform. This lab was tested using `aws login` with a local AWS profile that is permitted to assume the Terraform execution role.

Create a local `terraform.tfvars` file using `terraform.tfvars.example` as a template:

`terraform_execution_role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/TerraformExecutionRole"`

The real `terraform.tfvars` file is intentionally excluded from source control.

## Deployment
Initialize Terraform and download the required provider:
`terraform init`

Review the proposed infrastructure changes:
`terraform plan`

Deploy the environment:
`terraform apply`

After deployment, Terraform outputs the VPC ID, subnet IDs, Internet Gateway ID, EC2 instance ID, and EC2 public IP address.

## Connecting to the EC2 Instance

The instance is administered through AWS Systems Manager Session Manager rather than SSH.

Once the instance appears as a managed node in Systems Manager, a session can be started from the AWS console or AWS CLI.

No inbound SSH rule or locally stored private key is required.

## Destroying the Environment

The complete environment can be removed with:

`terraform destroy`

The lab was tested through a full lifecycle of deployment, destruction, and recreation to verify that the infrastructure can be reproduced entirely from Terraform.

## Terraform Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.64.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.64.0 |


## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The size of the EC2 instance to deploy | `string` | `"t3.micro"` | no |
| <a name="input_private_subnet_cidr"></a> [private\_subnet\_cidr](#input\_private\_subnet\_cidr) | The CIDR values for the private subnet | `string` | `"10.10.2.0/24"` | no |
| <a name="input_public_subnet_cidr"></a> [public\_subnet\_cidr](#input\_public\_subnet\_cidr) | The CIDR values for the public subnet | `string` | `"10.10.1.0/24"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which to deploy resources | `string` | `"us-west-2"` | no |
| <a name="input_terraform_execution_role_arn"></a> [terraform\_execution\_role\_arn](#input\_terraform\_execution\_role\_arn) | ARN of the IAM role Terraform assumes to deploy resources | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR address block to allocate for the VPC | `string` | `"10.10.0.0/16"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The ID of the internet gateway |
| <a name="output_lab_server_1_id"></a> [lab\_server\_1\_id](#output\_lab\_server\_1\_id) | Instance ID of EC2 Lab Server |
| <a name="output_lab_server_1_public_ip"></a> [lab\_server\_1\_public\_ip](#output\_lab\_server\_1\_public\_ip) | Public IP of EC2 Lab Server |
| <a name="output_private_subnet_id"></a> [private\_subnet\_id](#output\_private\_subnet\_id) | The ID of the private subnet |
| <a name="output_public_subnet_id"></a> [public\_subnet\_id](#output\_public\_subnet\_id) | The ID of the public subnet |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->