resource "aws_vpc" "this" {
  cidr_block = var.address_space
  
  tags = merge(
  var.addl_tags,{
    Name = "lb-testing"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
  var.addl_tags,{
    Name = "IGW"
  })
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(
  var.addl_tags,{
    Name = "public-route-table"
  })
}

resource "aws_subnet" "this" {
  count = length(var.subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = element(concat(var.subnets,[""]),count.index)
  availability_zone = element(concat(var.azs,[""]),count.index)
  map_public_ip_on_launch = true  

  tags = merge(
  var.addl_tags,{
      Name = format("subnet - %s",regexall("[0-9][a-z]$",element(concat(var.azs,[""]),count.index))[0])
  })
}

resource "aws_route_table_association" "this" {
  count = length(var.subnets)

  subnet_id = element(aws_subnet.this.*.id, count.index)
  route_table_id = aws_route_table.this.id
}