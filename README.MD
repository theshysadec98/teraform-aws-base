**TheShy sa đéc**

- B1: Chuyển file terraform.tfvars.docs -> terraform.tfvars để sử dụng variable cho control-plane và worker
- B2: Thay đổi các value trong file terraform.tfvars để sử dụng region, keypair, instance, .. sao cho phù hợp
tải keypair trên aws về và dùng keypair đúng với region đang muốn taọ
- B3: Sử dụng cmd: `terraform init` để tạo terraform config file trên local
- B4: Sử dụng cmd: `terraform plan` để kiếm tra xem có lỗi nào trong terraform không

- B5: Sử dụng cmd: `terraform apply --auto-approve` tại folder ec2-base để build ec2

