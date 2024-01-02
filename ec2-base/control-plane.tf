terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" #which is shorthand for registry.terraform.io/hashicorp/aws.
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = local.region
}

## To use template_file, you will need to use template provider

locals {
  region                        = var.region
  keypair_name                  = var.keypair_name
  instance_type_master          = var.instance_type_master
  control_plane_instance_name   = var.control_plane_instance_name
  include_policy_ebs_csi_driver = var.include_policy_ebs_csi_driver
  include_component             = var.include
  virtual_machine               = var.virtual_machine
  virtualization_type           = var.virtualization_type
  canonical                     = var.canonical
  include_ebs_csi_driver_policy = var.include_ebs_csi_driver_policy
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [local.virtual_machine]
  }

  filter {
    name   = "virtualization-type"
    values = [local.virtualization_type]
  }

  owners = [local.canonical] # Users can verify that an AMI was published by Canonical by ensuring the OwnerId field of an image is 099720109477 (in the default partition)
}

module "control_plane" {
  source = "../module/ec2_bootstrap"
  ami    = data.aws_ami.ubuntu.id
  bootstrap_script = templatefile("../script/templatescript.tftpl", {
    script_list : [
      templatefile("../script/common/awscli.sh", {})
    ]
  })
  role               = aws_iam_role.control_plane_role.name
  security_group_ids = [module.public_ssh_http.public_sg_id]
  keypair_name       = local.keypair_name
}

module "public_ssh_http" {
  source       = "../module/common_sg"
  name_suffix  = "control_plane_sg"
  public_ports = ["80", "22"]
}

resource "aws_iam_role" "control_plane_role" {
  name = "role_${local.control_plane_instance_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "access_parameter_store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ssm:PutParameter",
            "ssm:LabelParameterVersion",
            "ssm:DeleteParameter",
            "ssm:UnlabelParameterVersion",
            "ssm:DescribeParameters",
            "ssm:RemoveTagsFromResource",
            "ssm:GetParameterHistory",
            "ssm:AddTagsToResource",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:DeleteParameters"
          ],
          "Resource" : "*" // TODO: This will need to be more specific to secure, but just keep it simple for now
        },
      ]
    })
  }

  tags = {
    Name = "control-plane-role"
  }
}

data "aws_iam_policy" "EBSCSIDriver" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "EBSCSIDriver-role-policy-attach" {
  count      = local.include_ebs_csi_driver_policy ? 1 : 0
  role       = aws_iam_role.control_plane_role.name
  policy_arn = data.aws_iam_policy.EBSCSIDriver.arn
}
