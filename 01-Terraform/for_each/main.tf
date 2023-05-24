provider "aws" {
	region = "ap-northeast-2"
}

resource "aws_iam_user" "example" {
	for_each = toset(var.user_names)
	name  = each.value
}

variable "user_names" {
	description = "Create IAM with these names"
	type	  		= list(string)
	default	   	= ["aws14-neo", "aws14-trinity", "aws14-morpheus"]
}

output "all_user" {
  value       = values(aws_iam_user.example).arn
	description = "The Name for all user"
}
