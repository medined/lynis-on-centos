# When a profile is specified, tf will try to use 
# ~/.aws/credentials.

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  version = "~> 2.66"
}

resource "aws_key_pair" "centos" {
  public_key = file(var.pki_public_key)
}

resource "aws_instance" "centos" {
  ami           = data.aws_ami.centos.id
  associate_public_ip_address = "true"
  instance_type = var.instance_type
  key_name      = aws_key_pair.centos.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [ 
    aws_security_group.centos_allow_ssh.id,
    aws_security_group.centos_allow_any_outbound.id
  ]
  tags = {
    Name = "centos"
  }
}

resource "aws_eip" "centos" {
  instance = aws_instance.centos.id
  vpc      = true
  tags = {
    Name = "centos"
  }
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.pki_private_key)
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python3"
    ]  
  }
  provisioner "local-exec" {
    command = "ansible-playbook -u ${var.ssh_user} -i '${self.public_ip},' --private-key ${var.pki_private_key} playbook.01-setup.yml" 
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

#
# We need to export the EIP ip address, not the instance's.
#
resource "local_file" "inventory" {
  content = "[all]\n${aws_eip.centos.public_ip}"
  filename = "${path.module}/inventory"
}
