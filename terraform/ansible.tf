resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = <<-EOT
    [servers]
    korp ansible_host=${aws_eip.korp.public_ip} ansible_ssh_private_key_file=~/.ssh/korpkey.pem

    [servers:vars]
    ansible_user=admin
    ansible_python_interpreter=/usr/bin/python3
  EOT
}