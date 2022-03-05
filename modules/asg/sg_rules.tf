resource "aws_security_group_rule" "alb_1" {
  type              = "ingress"
  description = "Allow inbound HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       =  ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_2" {
  type              = "egress"
  description = "Allow outbound HTTP from ASG"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.asg.id
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "asg_1" {
  type              = "ingress"
  description       = "Allow inbound HTTP to ASG"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id = aws_security_group.asg.id
}

resource "aws_security_group_rule" "asg_2" {
  type              = "ingress"
  description       = "Allow inbound SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg.id
}

resource "aws_security_group_rule" "asg_3" {
  type              = "egress"
  description       = "Allow outbound HTTPS from ASG"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg.id
}

resource "aws_security_group_rule" "asg_4" {
  type              = "egress"
  description       = "Allow outbound HTTP from ASG"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg.id
}