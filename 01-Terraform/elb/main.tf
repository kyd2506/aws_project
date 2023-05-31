provider "aws" {
  region = "ap-northeast-2"
}
# AWS 인스턴스 생성
# AWS launch configuration create
resource "aws_launch_template" "example" {
	name					  = "aws14-examaple"
  image_id        = "ami-0c6e5afdd23291f73"
  instance_type   = "t2.micro"
	key_name			  = "aws14-key"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = "${base64encode(data.template_file.web_output.rendered)}"
           
             
        
             

  # AWS에서 시작 구성을 사용할때 필요
  lifecycle {
    create_before_destroy = true
  }
}

# AWS 오토스케일링 그룹 생성
resource "aws_autoscaling_group" "example" {
	availability_zones	 = ["ap-northeast-2a", "ap-northeast-2c"]

  name						 = "aws14-terraform-asg-example"
	desired_capacity = 1
	min_size 				 = 1
	max_size			   = 2

  target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.example.id
		version = "$Latest"
	}

  tag {
    key                 = "Name"
    value               = "aws14-terraform_asg-example"
    propagate_at_launch = true
  }
}

resource "aws_lb" "example" {
	name 								= "aws14-terraform-alb-example"
	load_balancer_type	= "application"
	subnets							= data.aws_subnets.default.ids
	security_groups 		= [aws_security_group.alb.id]
}
resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.example.arn
	port							= 80
  protocol 					= "HTTP"
	
	default_action {
	  type = "fixed-response"

	  fixed_response {
			content_type = "text/plain"
			message_body = "404: page not found"
			status_code  = 404
		}
	}
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
	priority	 = 100

	condition {
		path_pattern {
			values = ["*"]

    }
}

  action {
		type    						= "forward"
	  target_group_arn    = aws_lb_target_group.asg.arn
	}
}

resource "aws_lb_target_group" "asg" {
	name = "aws14-terraform-asg-example"
	port = var.server_port
	protocol = "HTTP"
	vpc_id = data.aws_vpc.default.id

	health_check {
		path 								  	=  "/"
		protocol							  = "HTTP"
		matcher									= "200"
		interval 								= 15
		timeout									= 3
		healthy_threshold				= 2
		unhealthy_threshold			= 2
	}
}

resource "aws_security_group" "alb" {
  name   = "aws14-terraform-alb-example"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

	egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

 
resource "aws_security_group" "instance" {
  name   = "aws14-terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
data "aws_vpc" "default" {
  default = true
  }

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "template_file" "web_output" {
  template = file("${path.module}/web.sh")
	vars = {
		server_port = "$(var.server_port)"
  }
}

variable "server_port" {
  description = "The port will use for HTTP requests"
  type        = number
  default     = 8080
}
