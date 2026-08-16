resource "aws_network_interface" "korp" {
  subnet_id       = aws_subnet.public.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.korp.id]

  tags = {
    Name = "korp-eni"
  }
}

resource "aws_instance" "korp" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.korp.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "korp-devops-server"
  }
}

resource "aws_eip" "korp" {
  domain = "vpc"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name = "korp-elastic-ip"
  }
}

resource "aws_eip_association" "korp" {
  allocation_id        = aws_eip.korp.id
  network_interface_id = aws_network_interface.korp.id
}