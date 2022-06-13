data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "bastion-key" {
  key_name   = "hello-world-key"
  public_key = file("id_rsa_interview.pub")
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.bastion-key.key_name

  tags = {
    Name = "HelloWorld"
  }
  subnet_id                   = aws_subnet.public_1.id
  associate_public_ip_address = true

}
