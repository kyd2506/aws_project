# 디폴트 보안 그룹
#resource "aws_default_security_group" "aws14_default_sg" {
#    vpc_id = data.terraform_remote_state.aws14_vpc.outputs.vpc_id

#   ingress {
#       protocol    = "tcp"
#       from_port = 0
#       to_port   = 65535
#       cidr_blocks = [data.terraform_remote_state.aws14_vpc.outputs.vpc_cidr]
#    }

#    egress {
#       protocol    = "tcp"
#       from_port = 0
#       to_port   = 65535 
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#       Name = "aws14_default_sg"
#       Description = "default_security_group"
#   }
# }

#SSH Security_group
#resource "aws_security_group" "aws14_ssh_sg" {
#   name            = "aws14_ssh_sg"
#   description     = "security group for ssh server"
#   vpc_id          = data.terraform_remote_state.aws14_vpc.outputs.vpc_id

#   ingress {
#       description = "For ssh port"
#       from_port = 22
#       to_port   = 22
#       protocol  = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#       protocol    = "-1"
#       from_port = 0
#       to_port   = 0
#       cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#       Name = "aws14_ssh_sg"
#   }
#}

#WEB Security_group
#resource "aws_security_group" "aws14_web_sg" {
#   name            = "aws14_web_sg"
#   description     = "security group for web server"
#   vpc_id          = data.terraform_remote_state.aws14_vpc.outputs.vpc_id

#   ingress {
#       description = "For web port"
#        from_port = 80
#        to_port   = 80
#        protocol  = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol    = "-1"
        from_port = 0
        to_port   = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "aws14_web_sg"
    }
}