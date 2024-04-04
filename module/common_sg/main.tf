locals {
  vpc_id       = var.vpc_id == "" ? data.aws_vpc.default.id : var.vpc_id
  public_ports = var.public_ports
  #   rules = [{
  #     port             = "23"
  #     from_port        = "0"
  #     to_port          = "0"
  #     protocol         = "tcp"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #     description      = ""
  #   }]
  rules       = var.rules
  name_suffix = var.name_suffix
  common_tags = merge(var.tags,
    tomap({
      Name = "allow_public"
  }))
}

data "aws_vpc" "default" {
  id = "vpc-0fbca6495b3ae09ff"
}

resource "aws_security_group_rule" "public_rules" {
  for_each = toset(local.public_ports)
  type = "ingress"
  description = "Public access inbound for port ${each.value}"
  from_port = each.value
  to_port = each.value
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_public.id
}

resource "aws_security_group" "allow_public" {
  name = "${local.name_suffix}_allow_public"
  description = "Allow public access"
  vpc_id = local.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.common_tags, tomap({
    Name = "allow_public"
  }))
}

resource "aws_security_group_rule" "rules" {
  for_each = {for rule in local.rules : (rule.port != null ? rule.port : "${rule.from_port}_${rule.to_port}") => rule }
  type = "ingress"
  description = "Ingress security group"
  from_port = each.value.from_port != null ? each.value.port : each.value.from_port
  to_port = each.value.to_port != null ? each.value.port : each.value.to_port
  protocol = each.value.protocol != null ? each.value.protocol : "tcp"
  cidr_blocks = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks = try(each.value.ipv6_cidr_blocks, null)
  security_group_id = aws_security_group.allow_specific.id
}

resource "aws_security_group" "allow_specific" {
  name = "${local.name_suffix}_allow_specific_port"
  description = "Allow inbound traffic from a specific port"
  vpc_id = local.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.common_tags, tomap({
    Name = "allow_specific"
  }))
}