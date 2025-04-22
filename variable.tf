variable "vpc_cider_block" {
    type = string
    default = "10.0.0.0/16"

}

#FIRST TIER VARIABLES
variable "capstone_publc_subnet1_cidr_block" {
    type = string
    default = "10.0.1.0/24"
  
}
variable "az_1" {
    type = string
    default = "us-east-1a"
  
}
variable "az_2" {
    type = string
    default = "us-east-1b"
}
variable "az_3" {
    type = string
    default = "us-east-1c"
}
variable "capstone_public_subnet2_cidr_block" {
    type = string
    default = "10.0.2.0/24"
  
}
variable "capstone_public_subnet3_cidr_block" {
    type = string
    default = "10.0.3.0/24"
  
}
variable "ec2_instance_type" {
    type = string
    default = "t2.micro"
  
}
variable "ec2_instance_ami" {
    type = string
    default = "ami-00a929b66ed6e0de6"
  
}

# SECOND TIER VARIABLES 
variable "capstone_private_subnet1_cidr_block" {
    type = string
    default = "10.0.4.0/24"
}
variable "capstone_private_subnet2_cidr_block" {
    type = string
    default = "10.0.5.0/24"
}
variable "capstone_private_subnet3_cidr_block" {
    type = string
    default = "10.0.6.0/24"
}

# DATABASE VARIABLES (Third Tier)
variable "db_engine" {
    type = string
    default = "mysql"
  
}
variable "db_instance_class" {
    type = string
    default = "db.t3.micro"
  
}
variable "db_username" {
    type = string
    default = "admin"
  
}   
variable "db_password" {
    type = string
    default = "password123"
  
}