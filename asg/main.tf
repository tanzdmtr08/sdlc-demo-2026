# Find AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "tfm-april-2026-tnzdmtr"
    key    = "path/to/my/sdlc-vpc"
    region = "us-east-2"
  }
}


# Create ASG
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "example-asg"

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.terraform_remote_state.network.outputs.private_subnets

  # Launch template
  launch_template_name        = "example-asg"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = data.aws_ami.ubuntu.id
  instance_type     = "t3.micro"
  ebs_optimized     = false
  enable_monitoring = false

  tags = {
    Environment = "dev"
    Project     = "megasecret"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "allow_tls"
  }
}
