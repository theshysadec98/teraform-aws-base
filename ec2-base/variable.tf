variable "keypair_name" {
  type        = string
  description = "Key pair name you wanted to assign to both control plane and worker node"
}

variable "instance_type_master" {
  type        = string
  description = "Instance type master"
}

variable "instance_type" {
  type        = string
  description = "Instance type for worker"
}

variable "region" {
  type        = string
  description = "Specific region for your account"
}


variable "control_plane_instance_name" {
  type        = string
  description = "Control Plane instance name"
}


variable "number_of_workers" {
  type        = number
  description = "Number of worker nodes that you want to create"
  default     = 1
}


variable "include_policy_ebs_csi_driver" {
  type        = bool
  description = "This setting will add EBS CSI Policy. This is not recommend for learning Storage"
  default     = false
}


variable "include" {
  type        = list(any)
  description = "This setting will install things at bootstrap. Allowed Values are: helm, etcd, ebs-csi"
  default     = []
}

variable "virtual_machine" {
  type        = string
  description = "value"
}

variable "virtualization_type" {
  type        = string
  description = "value"
}

variable "canonical" {
  type        = string
  description = "Users can verify that an AMI was published by Canonical by ensuring the OwnerId field of an image is 099720109477 (in the default partition)"
}

variable "include_ebs_csi_driver_policy" {
  type        = bool
  description = "This setting will add EBS CSI Policy. This is not recommend for learning Storage"
  default     = false
}