output "control_plane_ip" {
  value = module.control_plane.instance[*].public_ip
}


output "worker_node_ip" {
  value = module.workers.instance[*].public_ip
}

