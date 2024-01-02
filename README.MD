**TheShy sa đéc**

chuyển file terraform.tfvars.docs -> terraform.tfvars để sử dụng variable cho control-plane và worker
thay đổi các value trong file terraform.tfvars để sử dụng region, keypair, instance, .. sao cho phù hợp
tải keypair trên aws về và dùng keypair đúng với region đang muốn taọ

sử dụng lệnh `terraform apply --auto-approve` tại folder ec2-base để build 

