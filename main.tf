terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "ap-south-1"
}


resource "aws_vpc" "project2-vpc" {
  cidr_block = "10.0.0.0/16"
  

  tags = {
    Name = "Project2-vpc"
  }
}


resource "aws_subnet" "project2-pub-subnet1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.project2-vpc.id
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true


  tags = {
    Name = "project2-pub-subnet1"
  }
}


resource "aws_subnet" "project2-pri-subnet2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.project2-vpc.id
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = false


  tags = {
    Name = "project2-pri-subnet2" 
  }
}
 
resource "aws_subnet" "project2-pub-subnet11" {
  cidr_block = "10.0.11.0/24"
  vpc_id = aws_vpc.project2-vpc.id
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true


  tags = {
    Name = "project2-pub-subnet11"
  }
}  

resource "aws_subnet" "project2-pri-subnet12" {
  cidr_block = "10.0.12.0/24"
  vpc_id = aws_vpc.project2-vpc.id
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = false


  tags = {
    Name = "project2-pri-subnet12"
  }
}  

resource "aws_internet_gateway" "project2-IGW"{
  vpc_id = aws_vpc.project2-vpc.id


  tags = {
    Name = "project2-IGW"
  }
}

resource "aws_route_table" "project2-rt"{
  vpc_id = aws_vpc.project2-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project2-IGW.id
  }


  tags = {
    Name = "project2-rt"
  }
}

resource "aws_route_table_association" "project2-ass1-pub"{
  subnet_id = aws_subnet.project2-pub-subnet1.id
  route_table_id = aws_route_table.project2-rt.id

}

resource "aws_route_table_association" "project2-ass2-pub"{
  subnet_id = aws_subnet.project2-pub-subnet11.id
  route_table_id = aws_route_table.project2-rt.id

}

resource "aws_eip" "project2-eip"{
  domain = "vpc"
}

resource "aws_nat_gateway" "project2-nat"{
  allocation_id = aws_eip.project2-eip.id
  subnet_id = aws_subnet.project2-pub-subnet1.id

  tags = {
    Name = "project2-nat"  
  }
}

resource "aws_route_table" "project2-pri_rt"{
  vpc_id = aws_vpc.project2-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.project2-nat.id
  }

  tags = {
    Name = "private-rt"
  }

}

resource "aws_route_table_association" "project2-ass1-pri"{
  subnet_id = aws_subnet.project2-pri-subnet2.id
  route_table_id = aws_route_table.project2-pri_rt.id
}

resource "aws_route_table_association" "project2-ass2-pri"{
  subnet_id = aws_subnet.project2-pri-subnet12.id
  route_table_id = aws_route_table.project2-pri_rt.id
}

resource "aws_security_group" "project2-alb-sg"{
  vpc_id = aws_vpc.project2-vpc.id
  name = "project2-alb-sg"

  ingress {
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
    Name = "project2-alb-sg"
  }
}



resource "aws_security_group" "project2-ec2-sg"{
  vpc_id = aws_vpc.project2-vpc.id
  name = "project2-ec2-sg"

  ingress {
     from_port = 80
     to_port = 80
     protocol = "tcp" 
     security_groups = [aws_security_group.project2-alb-sg.id]
  }
  egress {
     from_port = 0
     to_port = 0
     protocol = "-1"
     cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "project2-ec2-sg"
  }
}

resource "aws_lb_target_group" "project2-lb-tg"{
  name = "project2-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.project2-vpc.id


  health_check {
    path = "/"
    interval = 30
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"
  }


  tags = {
    Name = "project2-lb-tg"
  }
}


resource "aws_lb" "project2-lb"{
  name = "project2-lb"
  load_balancer_type = "application"


  subnets = [
    aws_subnet.project2-pub-subnet1.id,
    aws_subnet.project2-pub-subnet11.id
  ]


  security_groups = [aws_security_group.project2-alb-sg.id]
  

  tags = {
    Name = "project2-lb"
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.project2-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.project2-lb-tg.arn
  }
}

resource "aws_launch_template" "project2-ec2-template"{
  name = "project2-ec2-template"
  image_id = "ami-0f5ee92e2d63afc18"
  instance_type = "t3.micro"


  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.project2-ec2-sg.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
echo "Hello from $(hostname)" > /var/www/html/index.html
systemctl enable httpd
systemctl start httpd
EOF
)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "project2-asg-ec2"
    }
  }
}


resource "aws_autoscaling_group" "project2-asg"{
  name = "project2-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.project2-pri-subnet2.id,
    aws_subnet.project2-pri-subnet12.id
  ]

  target_group_arns = [aws_lb_target_group.project2-lb-tg.arn]

  launch_template {
    id      = aws_launch_template.project2-ec2-template.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 180
}













































