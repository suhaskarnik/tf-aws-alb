resource "aws_iam_role" "this" {  
  name = "alb-role"
  assume_role_policy = "${file("${path.module}/trust_rel.json")}"
  tags = merge(
    var.addl_tags,  
    {
      Name = "alb-role"
  })
}

resource "aws_iam_role_policy" "this" {
  name = "ec2-describe"
  role = aws_iam_role.this.id
  policy = "${file("${path.module}/policy.json")}"

}

resource "aws_iam_instance_profile" "this" {
  role = aws_iam_role.this.name

  tags = merge(
    var.addl_tags,  
    {
      Name = "webserver-profile"
  })
}

