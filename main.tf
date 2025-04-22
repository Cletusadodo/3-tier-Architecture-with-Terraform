#Create VPC
resource "aws_vpc" "capstone_vpc" {
  cidr_block       = var.vpc_cider_block
  instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

  tags = {
    Name = "capstone_vpc"
  }
}
#Create Internet Gateway
resource "aws_internet_gateway" "capstone_igw" {
  vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name = "capstone_igw"
  }
}
#Create Public Subnet1"
resource "aws_subnet" "capstone_publc_subnet1" {
  vpc_id     = aws_vpc.capstone_vpc.id
  cidr_block =  var.capstone_publc_subnet1_cidr_block
    availability_zone = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = "capstone_public_subnet1"
  }
}
#Create Public Subnet 2
resource "aws_subnet" "capstone_publc_subnet2" {
  vpc_id     = aws_vpc.capstone_vpc.id
  cidr_block =  var.capstone_public_subnet2_cidr_block
    availability_zone = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "capstone_public_subnet2"
  }
}
#Create Public Subnet 3
resource "aws_subnet" "capstone_publc_subnet3" {
  vpc_id     = aws_vpc.capstone_vpc.id
  cidr_block =  var.capstone_public_subnet3_cidr_block
    availability_zone = var.az_3
  map_public_ip_on_launch = true

  tags = {
    Name = "capstone_public_subnet3"
  }
}
#Create public route table
resource "aws_route_table" "capstone_public_route_table" {
  vpc_id = aws_vpc.capstone_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # The internet gateway ID is used to route traffic to the internet
    gateway_id = aws_internet_gateway.capstone_igw.id
  }
}
#Create public route table association for public subnet 1
resource "aws_route_table_association" "capstone_public_subnet1_association" {
  subnet_id      = aws_subnet.capstone_publc_subnet1.id
  route_table_id = aws_route_table.capstone_public_route_table.id
}
#Create public route table association for public subnet 2
resource "aws_route_table_association" "capstone_public_subnet2_association" {
  subnet_id      = aws_subnet.capstone_publc_subnet2.id
  route_table_id = aws_route_table.capstone_public_route_table.id
}       
#Create public route table association for public subnet 3
resource "aws_route_table_association" "capstone_public_subnet3_association" {
  subnet_id      = aws_subnet.capstone_publc_subnet3.id
  route_table_id = aws_route_table.capstone_public_route_table.id
}
# Create security group for first tier
resource "aws_security_group" "first_tier_sg" {
  name        = "first-tier-pubsg"
  description = "Access to SSH and RDP from a single IP address & https from anywhere"
  vpc_id      = aws_vpc.capstone_vpc.id

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "first-tier-pubsg"
  }
}
# Create EC2 instance in public subnet 1
resource "aws_instance" "first_tier_instance" {
  ami           = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.capstone_publc_subnet1.id
  security_groups = [aws_security_group.first_tier_sg.id]
  
  tags = {
    Name = "first-tier-instance"
  }
}
# Create EC2 instance in public subnet 2
resource "aws_instance" "first_tier_instance2" {
  ami           = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.capstone_publc_subnet2.id
  security_groups = [aws_security_group.first_tier_sg.id]
  tags = {
    Name = "first-tier-instance2"
  }
}
# Create EC2 instance in public subnet 3      
resource "aws_instance" "first_tier_instance3" {
  ami           =var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.capstone_publc_subnet3.id
  security_groups = [aws_security_group.first_tier_sg.id]
  tags = {
    Name = "first-tier-instance3"
  }
}
# create autoscaling group
resource "aws_autoscaling_group" "first_tier_asg" {
  desired_capacity     = 3
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier = [aws_subnet.capstone_publc_subnet1.id, aws_subnet.capstone_publc_subnet2.id, aws_subnet.capstone_publc_subnet3.id]
  launch_template {
    id      = aws_launch_template.first_tier_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "first-tier-asg-instance"
    propagate_at_launch = true
  }
}
# Create launch configuration for autoscaling group 
resource "aws_launch_template" "first_tier_launch_template" {
  name          = "first-tier-launch-config"
  image_id      = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.first_tier_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}
# Create an Elastic Load Balancer (ELB) for the first tier
resource "aws_elb" "first_tier_elb" {
  name       = "first-tier-elb"
  subnets = [aws_subnet.capstone_publc_subnet1.id, aws_subnet.capstone_publc_subnet2.id, aws_subnet.capstone_publc_subnet3.id]
  security_groups  = [aws_security_group.first_tier_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
# Attach the ELB to the Auto Scaling Group
resource "aws_autoscaling_attachment" "first_tier_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.first_tier_asg.name
  elb                   = aws_elb.first_tier_elb.id
}    
# Create a CloudWatch alarm for the Auto Scaling Group
resource "aws_cloudwatch_metric_alarm" "first_tier_asg_alarm" {
  alarm_name          = "first-tier-asg-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupDesiredCapacity"
  namespace           = "AWS/AutoScaling"
  period             = 60
  statistic          = "Average"
  threshold          = 4
  alarm_description   = "Alarm when the desired capacity of the first tier ASG is greater than or equal to 4"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.first_tier_asg.name
  }

    alarm_actions = [aws_autoscaling_policy.first_tier_scale_out_policy.arn]
  }
  
  # Define the autoscaling policy separately
  resource "aws_autoscaling_policy" "first_tier_scale_out_policy" {
    name                   = "first-tier-scale-out-policy"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    cooldown               = 300
    autoscaling_group_name = aws_autoscaling_group.first_tier_asg.name
  }

# Define the scale-in policy
resource "aws_autoscaling_policy" "first_tier_scale_in_policy" {
  name                   = "first-tier-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.first_tier_asg.name
}
# Create a CloudWatch alarm for the scale-in policy
resource "aws_cloudwatch_metric_alarm" "first_tier_asg_scale_in_alarm" {
  alarm_name          = "first-tier-asg-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupDesiredCapacity"
  namespace           = "AWS/AutoScaling"
  period             = 60
  statistic          = "Average"
  threshold          = 2
  alarm_description   = "Alarm when the desired capacity of the first tier ASG is less than or equal to 2"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.first_tier_asg.name
  }

    alarm_actions = [aws_autoscaling_policy.first_tier_scale_in_policy.arn]
}
# Create a CloudWatch alarm for the ELB
resource "aws_cloudwatch_metric_alarm" "first_tier_elb_alarm" {
  alarm_name          = "first-tier-elb-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ELB"
  period             = 60
  statistic          = "Average"
  threshold          = 1
  alarm_description   = "Alarm when the unhealthy host count of the first tier ELB is greater than or equal to 1"

  dimensions = {
    LoadBalancerName = aws_elb.first_tier_elb.name
  }

    alarm_actions = [aws_autoscaling_policy.first_tier_scale_out_policy.arn]
}
# Create private subnet 1
resource "aws_subnet" "capstone_private_subnet1" {
  vpc_id     = aws_vpc.capstone_vpc.id
  cidr_block =  var.capstone_private_subnet1_cidr_block
    availability_zone = var.az_1
  map_public_ip_on_launch = false
  tags = {
    Name = "capstone_private_subnet1"
  }
}
#Create private subnet 2    
resource "aws_subnet" "capstone_private_subnet2" {
  vpc_id     = aws_vpc.capstone_vpc.id
  cidr_block =  var.capstone_private_subnet2_cidr_block
    availability_zone = var.az_2
  map_public_ip_on_launch = false

  tags = {
    Name = "capstone_private_subnet2"
  }
}
#Create private subnet 3
resource "aws_subnet" "capstone_private_subnet3" {
  vpc_id     = aws_vpc.capstone_vpc.id
  cidr_block =  var.capstone_private_subnet3_cidr_block
    availability_zone = var.az_3
  map_public_ip_on_launch = false

  tags = {
    Name = "capstone_private_subnet3"
  }
}
# Create NAT Gateway for private subnets
resource "aws_nat_gateway" "capstone_nat_gateway" {
  allocation_id = aws_eip.capstone_nat_eip.id
  subnet_id     = aws_subnet.capstone_publc_subnet1.id

  tags = {
    Name = "capstone_nat_gateway"
  }
}
# Create Elastic IP for NAT Gateway
resource "aws_eip" "capstone_nat_eip" {
  tags = {
    Name = "capstone_nat_eip"
  }
}
# Create route table for private subnets
resource "aws_route_table" "capstone_private_route_table" {
    vpc_id = aws_vpc.capstone_vpc.id
    route {
        cidr_block = var.capstone_publc_subnet1_cidr_block
        nat_gateway_id = aws_nat_gateway.capstone_nat_gateway.id


}
}
# Create route table association for private subnet 1
resource "aws_route_table_association" "capstone_private_subnet1_association" {
  subnet_id      = aws_subnet.capstone_private_subnet1.id
  route_table_id = aws_route_table.capstone_private_route_table.id
}   
# Create route table association for private subnet 2
resource "aws_route_table_association" "capstone_private_subnet2_association" {
  subnet_id      = aws_subnet.capstone_private_subnet2.id
  route_table_id = aws_route_table.capstone_private_route_table.id
}
# Create route table association for private subnet 3
resource "aws_route_table_association" "capstone_private_subnet3_association" {
  subnet_id      = aws_subnet.capstone_private_subnet3.id
  route_table_id = aws_route_table.capstone_private_route_table.id
}
# Create security group for second tier
resource "aws_security_group" "second_tier_sg" {
  name        = "second-tier-privsg"
  description = "Allow SSH, HTTP & HTTPS from tier 1 and all outbound traffic"
  vpc_id      = aws_vpc.capstone_vpc.id

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # This allows SSH access from the first tier security group
    security_groups  = [aws_security_group.first_tier_sg.id]
    }

    ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.first_tier_sg.id]
    }

    ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
  security_groups  = [aws_security_group.first_tier_sg.id]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "second-tier-privsg"
  }
}
# Create EC2 instance in private subnet 1
resource "aws_instance" "second_tier_instance" {
  ami           = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.capstone_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.second_tier_sg.id]
  tags = {
    Name = "second-tier-instance1"
  }
}
# Create EC2 instance in private subnet 2
resource "aws_instance" "second_tier_instance2" {
  ami           = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.capstone_private_subnet2.id
  vpc_security_group_ids = [aws_security_group.second_tier_sg.id]
  tags = {
    Name = "second-tier-instance2"
  }
}
# Create EC2 instance in private subnet 3
resource "aws_instance" "second_tier_instance3" {
  ami           = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.capstone_private_subnet3.id
  vpc_security_group_ids = [aws_security_group.second_tier_sg.id]
  tags = {
    Name = "second-tier-instance3"
  }
}
#Create autoscaling group for second tier
resource "aws_autoscaling_group" "second_tier_asg" {
  desired_capacity     = 3
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier = [aws_subnet.capstone_private_subnet1.id, aws_subnet.capstone_private_subnet2.id, aws_subnet.capstone_private_subnet3.id]
  launch_template {
    id      = aws_launch_template.second_tier_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "second-tier-asg-instance"
    propagate_at_launch = true
  }
}
# Create launch configuration for second tier autoscaling group
resource "aws_launch_template" "second_tier_launch_template" {
  name          = "second-tier-launch-template"
  image_id      = var.ec2_instance_ami # Amazon Linux 2 AMI
  instance_type = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.second_tier_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}
# tier third-database security group
resource "aws_security_group" "third_tier_sg" {
  name        = "third-tier-dbsg"
  description = "Allow SSH, HTTP & HTTPS from tier 2 and all outbound traffic"
  vpc_id      = aws_vpc.capstone_vpc.id

    ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # This allows SSH access from the second tier security group
    security_groups  = [aws_security_group.second_tier_sg.id]
    }

    ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.second_tier_sg.id]
    }

    ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.second_tier_sg.id]
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks = ["0.0.0.0/0"]   
    }
  tags = {
    Name = "third-tier-dbsg"
  }
}
# create RDS instance in private subnet 1
resource "aws_db_instance" "capstone_rds_instance" {
  identifier         = "capstone-rds-instance"
  engine             = var.db_engine
  engine_version     = "8.0"
  instance_class     = var.db_instance_class
  allocated_storage   = 20
  storage_type       = "gp2"
  db_subnet_group_name = aws_db_subnet_group.capstone_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.third_tier_sg.id]
  username           = var.db_username
  password           = var.db_password
  skip_final_snapshot = true

  tags = {
    Name = "capstone-rds-instance"
  }
}
# Create DB subnet group for RDS instance
resource "aws_db_subnet_group" "capstone_db_subnet_group" {
  name       = "capstone-db-subnet-group"
  subnet_ids = [aws_subnet.capstone_private_subnet1.id, aws_subnet.capstone_private_subnet2.id, aws_subnet.capstone_private_subnet3.id]

  tags = {
    Name = "capstone-db-subnet-group"
  }
}
# Create CloudWatch alarm for RDS instance
resource "aws_cloudwatch_metric_alarm" "capstone_rds_alarm" {
  alarm_name          = "capstone-rds-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = 60
  statistic          = "Average"
  threshold          = 80
  alarm_description   = "Alarm when CPU utilization exceeds 80% for the RDS instance"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.capstone_rds_instance.id
  }

  alarm_actions = [aws_autoscaling_policy.second_tier_scale_out_policy.arn]
}
# Create CloudWatch alarm for RDS instance scale-in
resource "aws_cloudwatch_metric_alarm" "capstone_rds_scale_in_alarm" {
  alarm_name          = "capstone-rds-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = 60
  statistic          = "Average"
  threshold          = 20
  alarm_description   = "Alarm when CPU utilization is less than or equal to 20% for the RDS instance"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.capstone_rds_instance.id
  }

    alarm_actions = [aws_autoscaling_policy.second_tier_scale_in_policy.arn]
}

# Create CloudWatch alarm for RDS instance scale-out
resource "aws_cloudwatch_metric_alarm" "capstone_rds_scale_out_alarm" {
  alarm_name          = "capstone-rds-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period             = 60
  statistic          = "Average"
  threshold          = 80
  alarm_description   = "Alarm when CPU utilization exceeds 80% for the RDS instance"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.capstone_rds_instance.id
  }

    alarm_actions = [aws_autoscaling_policy.second_tier_scale_out_policy.arn]
}
# auto sclaing policy for second tier 
resource "aws_autoscaling_policy" "second_tier_scale_out_policy" {
  name                   = "second-tier-scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.second_tier_asg.name
}
# Define the scale-in policy for second tier
resource "aws_autoscaling_policy" "second_tier_scale_in_policy" {
  name                   = "second-tier-scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.second_tier_asg.name
}



