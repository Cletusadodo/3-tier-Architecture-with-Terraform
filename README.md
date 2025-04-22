# 🚀 AWS 3-Tier Architecture with Terraform

This project provisions a **highly available, fault-tolerant 3-tier architecture** on AWS using **Terraform**. 

The setup includes public and private subnets across multiple availability zones, designed for scalability, maintainability, and security.

====================================================================================================================================================

## 📊 Architecture Overview

The infrastructure consists of:

- **VPC** spanning **3 Availability Zones**
- **Public subnets** with EC2 instances (Web Tier)
- **Private subnets** with EC2 instances and Auto Scaling (Application Tier)
- **Private subnets** with RDS databases (Database Tier)
- **Security Groups** for each tier
- **CloudTrail**, **CloudWatch**, and **S3** integration for logging and monitoring

=====================================================================================================================================================

### 📌 Visual Overview

![Cloud Architecture](./Cloud%20Architecture.png)

======================================================================================================================================================

## 📁 Project Structure

```bash
├── main.tf            # Core infrastructure logic
├── variables.tf       # All configurable input variables
├── provider.tf        # Cloud provider configuration (AWS)
├── outputs.tf         # Output values
├── Cloud Architecture.png  # Architecture diagram

========================================================================================================================================================
✅ Prerequisites
Terraform ≥ 1.0.0
AWS CLI configured with appropriate credentials (aws configure)
========================================================================================================================================================
🛠️ Usage: Step-by-Step Guide
1. Clone the Repository
git clone https://github.com/Cletusadodo/3-tier-Architecture-with-Terraform.git
cd terraform-aws-3tier-architecture

2. Initialize Terraform
terraform init  [This command sets up the backend and downloads required provider plugins]

3. Customize Your Variables
Edit variables.tf or create a terraform.tfvars file to override default values. Example:
region = "us-east-1"
vpc_cidr = "10.0.0.0/16"

4. Review the Execution Plan
terraform plan

5. Apply the Configuration
terraform apply  [When prompted, type yes to confirm.]

6. Validate the resource were provisioned correctly
go to you AWS console to verify all resources has been provisioned correctly

7. Destroy the Infrastructure 
terraform destroy  [ If you are not using the infrastructure, apply the terraform destroy command so you don't incur bills]

=====================================================================================================================================================

🧰 Features
1. Modular & reusable code with input variables
2. Designed across 3 Availability Zones for HA
3. Layered security via security groups
4. Monitoring and auditing with CloudWatch and CloudTrail
5. Easily customizable for different environments (Dev/Test/Prod)

=======================================================================================================================================================
🙌 Contributions
Contributions, improvements, and suggestions are welcome. Feel free to fork and PR!

✍️ Author
Cletus Adodo
Site Reliability | Cloud & DevOps Engineer

