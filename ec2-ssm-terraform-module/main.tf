###########################################################################################################
# Root Module
###########################################################################################################

# Local variables to be used in the module
locals {
  tags = var.tags
}

# EC2 Module
module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name                   = var.ec2_id
  ami                    = var.ami_type
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.platform_sg.id]
  count                  = 1
  subnet_id              = module.network.private_subnets.id

  iam_instance_profile = module.ssm.instance_profile.id

   ebs_block_device = [
    {
      device_name = "/dev/xvda"
      volume_type = "gp3"
      volume_size = 50 # 50GB
      throughput  = 150
      encrypted   = true
    }
  ]

  tags = merge(local.tags, { Name = "SSM-Instance" }) # Update Name accordingly
}

resource "aws_security_group" "main" {
  name        = "SSM-SG"
  description = "Security group allowing all inbound traffic from your IP address and all outbound traffic"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [""] # Update to your current IP Address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Calls the network module, used to add the necessary infrastructure to an existing VPC to support the platform infrastructure
module "network" {
  source             = "./modules/network"
  vpc_id             = var.vpc_id
  vpc_cidr           = var.vpc_cidr
  cidr_block         = var.cidr_block
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  instance_id        = var.ec2_id
  availability_zone  = var.availability_zone
  tags               = local.tags
}
