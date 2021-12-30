data "aws_ssm_parameter" "ami" {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_key_pair" "this" {
  key_name = "deployer-key"
  public_key = "${file("${pathexpand("~")}/.ssh/id_rsa.pub")}"

  tags = merge(
    var.addl_tags,{})
}

resource "aws_security_group" "this" {
  vpc_id = var.vpc_id
  ingress {
    protocol = "tcp"
    description = "Allow inbound HTTP"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    description = "Allow inbound SSH"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "tcp"
    description = "Allow outbound HTTP"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    description = "Allow inbound HTTPS"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "tcp"
    description = "Allow outbound HTTPS"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.addl_tags,  
    {
      Name = "public-sg"
  })
}

resource "aws_instance" "this" {
  count = length(var.subnet_ids)

  subnet_id = var.subnet_ids[count.index]
  instance_type = "t3.micro" 
  ami = data.aws_ssm_parameter.ami.value
  iam_instance_profile = var.iam_instance_profile_id

  user_data = "${file("${path.module}/user-data.sh")}"
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name = aws_key_pair.this.key_name

  tags = merge(
    var.addl_tags,  
    {
      Name = "webserver-${count.index+1}"
  })
}

# resource "aws_iam_role" "this" {
#   name = "ec2-read"

#   assume_role_policy = "${file("${path.module}/role.json")}"
# }

# resource "aws_iam_instance_profile" "this" {
#   name = "test-profile"
#   role = aws_iam_role.this
# }

# resource "aws_iam_role_policy" "this" {
#   name = "test-policy"
#   role = aws_iam_role.this.id
#   policy = "${file("${path.module}/policy.json")}"
# }
