
locals {
  worker_instance_type = var.instance_type
  worker_keypair       = var.keypair_name
  worker_name          = "worker"
  number_of_workers    = var.number_of_workers
}

#   # You can put some variable here to render
# }

module "workers" {
  source = "../module/ec2_bootstrap"
  # bootstrap_script = data.template_file.woker_user_data.rendered
  # bootstrap_script = templatefile("../external/${local.cp_engine}/ubuntu20-k8s-worker.sh", {})
  ami = data.aws_ami.ubuntu.id
  bootstrap_script = templatefile("../script/templatescript.tftpl", {
    script_list : [
      templatefile("../script/common/awscli.sh", {}),
    ]
  })

  # security_group_ids = setunion(module.common_sg.public_sg_ids, module.common_sg.specific_sg_ids)
  security_group_ids  = [module.public_ssh_http.public_sg_id]
  keypair_name        = local.worker_keypair
  instance_type       = local.worker_instance_type
  name                = local.worker_name
  number_of_instances = local.number_of_workers

  // TODO: This will need to be more specific, but keep it simple for now
  role = aws_iam_role.control_plane_role.name
}
