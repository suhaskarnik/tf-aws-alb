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
  vpc_id = var.vpc
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

resource "aws_launch_template" "this" {
  instance_type = "t2.micro"
  image_id = data.aws_ssm_parameter.ami.value
  key_name = aws_key_pair.this.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.this.id]
  }
  
  user_data = "${base64encode(file("${path.module}/user-data.sh"))}"
  tags = merge(
      var.addl_tags,
      {
          Name = "test-template"
      }
  )
}


resource "aws_lb" "this" {
  name = "webserver-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.this.id]
  subnets = var.subnet_ids

  tags = var.addl_tags
}


resource "aws_lb_target_group" "this" {
  name = "webserver-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc
}

resource "aws_autoscaling_group" "this" {
  max_size = 5
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 3
  name_prefix = "webserver-"
  
  # availability_zones = var.azs
  
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.this.arn]

  tags =[
      var.addl_tags,
      {
          Name = "webserver-asg"
      }
  ]
}

# ========================


# resource "aws_autoscaling_attachment" "this" {
#   autoscaling_group_name = module.asg.id
#   alb_target_group_arn = aws_lb_target_group.this.id
# }

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}