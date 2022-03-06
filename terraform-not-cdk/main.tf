# 1. Create VPC
resource "aws_vpc" "vpc-demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-demo"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw-demo" {
  vpc_id = aws_vpc.vpc-demo.id

  tags = {
    Name = "gw-demo"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "rt-demo" {
  vpc_id = aws_vpc.vpc-demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-demo.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw-demo.id
  }

  tags = {
    Name = "rt-demo"
  }
}

# 4. Create Subnet
resource "aws_subnet" "sub-demo" {
  vpc_id = aws_vpc.vpc-demo.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.aws-region}a"

  tags = {
    Name = "sub-demo"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "rt-demo" {
  route_table_id = aws_route_table.rt-demo.id
  subnet_id = aws_subnet.sub-demo.id
}

# 6. Create Security Group to allow ports 22, 80, 443
resource "aws_security_group" "sg-demo" {
  name = "security-group-demo"
  vpc_id = aws_vpc.vpc-demo.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-demo"
  }
}

# 7. Create a network interface with an IP in the subnet that was created in step 4
resource "aws_network_interface" "ni-demo" {
  subnet_id       = aws_subnet.sub-demo.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.sg-demo.id]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "eip-demo" {
  depends_on = [aws_internet_gateway.gw-demo]
  vpc = true
  network_interface = aws_network_interface.ni-demo.id
  associate_with_private_ip = "10.0.1.50"
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "ec2-demo" {
  ami = "ami-0015a39e4b7c0966f" # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  availability_zone = "${var.aws-region}a"
  key_name = aws_key_pair.key-pair.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.ni-demo.id
  }

  user_data = <<-EOT
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c "echo Your first web server > /var/www/html/index.html"
  EOT

  tags = {
    Name = "ec2-demo"
  }
}

# 10. Outputs
resource "null_resource" "ssh-command" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo SSH = ssh -i ${local_file.pem-file.filename} ubuntu@${aws_instance.ec2-demo.public_ip}
    EOT
  }
}