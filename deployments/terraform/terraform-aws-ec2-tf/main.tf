# Terraform provision AWS EC2 instance with Terraform Cloud Management

variable "awsprops" {
  type = map(any)
  default = {
    region       = "eu-west-3"
    vpc          = "vpc-0759ef1af4fd12b2b"
    ami          = "ami-0cd59ecaf368e5ccf"
    itype        = "t2.micro"
    subnet       = "subnet-0cf9e70abb6d7d27a"
    publicip     = true
    keyname      = "prodxsecure"
    secgroupname = "sg-017c1a1e28c8967fd"
  }
}


// AMI Security group setting using HashiCorp Configuration Language (HCL)
resource "aws_security_group" "prod-sec-sg" {
  name        = var.instance_secgroupname
  description = var.instance_secgroupname
  vpc_id      = var.instance_vpc_id

  // To Allow SSH Transport

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = lookup(ingress.value, "description", null)
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow_tls"
  }

  lifecycle {
    create_before_destroy = false
  }
}


# instance identity
resource "aws_instance" "iteamxcloud" {
  ami                         = "ami-0326f9264af7e51e2"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-0cf9e70abb6d7d27a"
  associate_public_ip_address = true
  key_name                    = "prodxsecure"

  vpc_security_group_ids = [
    aws_security_group.prod-sec-sg.id
  ]

  root_block_device {
    delete_on_termination = true
    volume_size           = 40
    volume_type           = "gp2"
  }

  tags = {
    Name        = "Devops"
    Environment = "DEV"
    OS          = "UBUNTU"
    Managed     = "Farouk"
  }

  provisioner "file" {
    source      = "installer.sh"
    destination = "/home/ubuntu/installer.sh"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./prodxsecure.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/installer.sh",
      "sudo /home/ubuntu/installer.sh"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./prodxsecure.pem")
    }
  }

  depends_on = [aws_security_group.prod-sec-sg]
}

output "ec2instance" {
  value = aws_instance.iteamxcloud.public_ip
}





