data "aws_ssm_parameter" "ami" {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_key_pair" "this" {
  key_name = "deployer-key"
  public_key = "${file("${pathexpand("~")}/.ssh/id_rsa.pub")}"

  tags = merge(
    var.addl_tags,{})
}


# Security Group for the ALB
resource "aws_security_group" "alb" {
  vpc_id = var.vpc    
  description = "SG for ALB, allows ingress from the internet"
  tags = merge(
    var.addl_tags,  
    {
      Name = "alb-sg"
  })
}

# Security Group for the ASG
resource "aws_security_group" "asg" {
  vpc_id = var.vpc
  description = "SG for ASG, allows ingress from the ALBs SG and SSH"
  tags = merge(
    var.addl_tags,  
    {
      Name = "scaling-group-sg"
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
    security_groups = [aws_security_group.asg.id]
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
  security_groups = [aws_security_group.alb.id]
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
  max_size = 3
  min_size = 1
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  name_prefix = "webserver-"
  
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

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}