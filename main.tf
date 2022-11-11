# create vpc
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/24"
}

# creat 2 public subnets
module "public-subnets" {
  source = "./modules/public-subnets"
  cidr_block = ["10.0.0.0/26", "10.0.0.64/26"]
  vpc_id = module.vpc.vpc_id
}

# creat 2 private subnets
module "private-subnets" {
  source = "./modules/private-subnets"
  cidr_block = ["10.0.0.128/26", "10.0.0.192/26"]
  vpc_id = module.vpc.vpc_id
}

#create igw:
module "hw1_igw" {
  source = "./module.igw"
  vpc_id = module.vpc.vpc_id
}

# create nat_gtw:
module "hw1_natgtw" {
  source = "./modules/nat_gtw"
  subnet_id = module.public-subnets.public_subnet_id[0]
}

# create public route table:
module "public_rtb" {
  source = "./modules/public_rtb"
  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
}

# associate public rtb with public subnets
module "rtb_public_subnet_association" {
  source = "./module/rtb_assoc"
  subnet_id = [module.public-subnets.public_subnet_id[0], module.public-subnets.public_subnet_id[1]]
  route_table_id = module.public_rtb.public_rtb_id
}

# create route table for private subnets route www traffic to natgtw:
module "private_route_table" {
  source = "./modules/private_rtb"
  vpc_id = module.vpc.vpc_id
  natgtw_id = module.nat_gtw.natgtw_id
}

# associate private rtb with private subnets
module "rtb_private_subnet_association" {
  source = "./module/rtb_assoc"
  subnet_id = [module.private-subnets.private_subnet_id[0], module.private-subnets.private_subnet_id[1]]
  route_table_id = module.private_rtb.private_rtb_id
}

#create sg1
module "sg-1" {
  source  = "./modules/sg"
  sg_name = "sg1"
  vpc_id  = module.vpc.vpc_id
}

# add ingress and egress rules for EC2 security group:
module "ec2_sg_ingress_rules" {
  source = "./modules/rule_simple"
  rules = {
    "0" = ["ingress", "0.0.0.0/0", "22", "22", "TCP", "allow ssh from www"]
    "1" = ["egress", "0.0.0.0/0", "0", "65535", "TCP", "allow ssh traffic to www"]
  }
  security_group_id = module.sg-1.sg_id
}

#create sg2
module "sg-2" {
  source  = "./modules/sg"
  sg_name = "sg2"
  vpc_id  = module.vpc.vpc_id
}

# add ingress rules for EC2 sg to allow http traffic from ALB sg:
module "sg2_open_ssh_sg1" {
  source = "./modules/rule_with_id"
  type   = "ingress"
  rules = {
    "0" = [module.sg-1.sg_id, "22", "22", "TCP", "allow 22 ssh from sg1"]
  }
  security_group_id = module.sg-2.sg_id
}

# create db subnet group 
module "db_subnet_group" {
  source = "./modules/subnet_group"
  subnet_id = [module.private-subnets.private_subnet_id[0], module.private-subnets.private_subnet_id[1]]
}

