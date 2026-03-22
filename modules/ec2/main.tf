data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  ami_id = var.os == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.amazon_linux.id
}

locals {
  ubuntu_script = <<-EOF
#!/bin/bash
apt update -y
apt install -y git nginx
systemctl enable --now nginx
git clone ${var.repo_url} /app
cp -r /app/* /var/www/html/
EOF

  amazon_script = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y git nginx
systemctl enable --now nginx
git clone ${var.repo_url} /app
cp -r /app/* /usr/share/nginx/html/
EOF
}

resource "aws_security_group" "ec2_sg" {
  name   = "ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name_prefix = "ec2-key-"
  public_key      = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = "$${path.root}/ec2_key.pem"
  file_permission = "0400"
}

resource "aws_instance" "app" {
  ami           = local.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name      = aws_key_pair.generated_key.key_name

  user_data = var.os == "ubuntu" ? local.ubuntu_script : local.amazon_script
}