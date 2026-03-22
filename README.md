# AWS Multi-Tier Infrastructure with Terraform

A professional and dynamic Terraform project to provision and manage highly-available AWS infrastructure. This project supports deploying 1-Tier, 2-Tier, and 3-Tier architectures on AWS with just a few variables or an interactive Bash script.

## 🌟 Features

*   **Multi-Tier Architectures:** Seamlessly choose between 1-Tier (EC2), 2-Tier (EC2 + RDS), or 3-Tier (ALB + ASG + RDS) setups.
*   **Dynamic Resource Allocation:** Provision resources based on your preference (`performance`, `cost`, or `intelligence`), automatically configuring EC2 instances sizes (`t3.small` / `t3.micro`).
*   **OS Flexibility:** Choose either `Ubuntu` or `Amazon Linux` right out of the box. User data scripts automatically handle initial server setup, including Git repository cloning and Nginx configuration.
*   **Interactive Deployment:** An optional `user-inputs.sh` script is provided to dynamically capture deployment preferences and execute `terraform apply` seamlessly.
*   **Modular Design:** Built with Terraform best practices. Resources like VPC, Security Groups, EC2, RDS, ALB, and Auto Scaling target separate modules.

---

## 🏗️ Architecture Options

### 1-Tier Setup
*   **VPC & Networking:** Custom VPC, public subnets, and internet gateway.
*   **Compute:** Single EC2 instance automatically configured via User Data to host your web application.

### 2-Tier Setup
*   **Compute:** Single EC2 instance in a public subnet.
*   **Database:** Amazon RDS instance placed securely in private subnets, enabling a classic web-to-DB flow.

### 3-Tier Setup *(High Availability)*
*   **Compute:** Auto Scaling Group (ASG) across multiple availability zones for high availability. 
*   **Load Balancing:** Application Load Balancer (ALB) routing traffic to the ASG instances.
*   **Database:** Amazon RDS instance in private subnets.

---

## 🚀 Quick Start

### Prerequisites
*   [Terraform](https://developer.hashicorp.com/terraform/downloads) installed (`>= 1.0.0`)
*   [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured (`aws configure`)
*   An active AWS Account.

### Interactive Deployment (Recommended)
You can easily provision your desired tier by running the included helper bash script:

```bash
chmod +x scripts/user-inputs.sh
./scripts/user-inputs.sh
```

The script will ask for:
1. **Architecture Tier** (1-Tier, 2-Tier, 3-Tier)
2. **GitHub Repository URL** (To automatically deploy code to the servers)
3. **Instance Preference** (Performance, Cost, Intelligence)
4. **Operating System** (Ubuntu, Amazon Linux)

### Manual Deployment
If you prefer running Terraform commands manually:

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the Plan:**
   ```bash
   terraform plan -var="tier=3-tier" -var="repo_url=https://github.com/your/repo.git" -var="preference=cost" -var="os=ubuntu"
   ```

3. **Apply the Infrastructure:**
   ```bash
   terraform apply -var="tier=3-tier" -var="repo_url=https://github.com/your/repo.git" -var="preference=cost" -var="os=ubuntu"
   ```

*(Adjust the variable values according to your needs!)*

---

## 📂 Project Structure

```text
.
├── main.tf                 # Main orchestration calling all necessary modules based on tier
├── variables.tf            # Input variables definitions
├── outputs.tf              # Outputs the infrastructure details
├── modules/                # Reusable Terraform Modules
│   ├── alb/                # Application Load Balancer
│   ├── autoscaling/        # Auto Scaling Group & Launch Templates
│   ├── ec2/                # EC2 Instances, Key Pairs, and User Data logic
│   ├── rds/                # Amazon Relational Database Service
│   ├── security_group/     # Security Groups logic
│   └── vpc/                # Custom VPC, Subnets, and Gateways
└── scripts/
    └── user-inputs.sh      # Interactive deployment bash script
```

## 🔒 Security
- **SSH Keys:** The `ec2` module dynamically generates an RSA private key (saved locally as `ec2_key.pem`) to ensure secure access to instances without hardcoding existing keys.
- **Network Isolation:** RDS databases are strictly placed into private subnets, ensuring they are only accessible from your deployed compute instances.

## 🧹 Cleanup
To avoid unexpected AWS charges, remember to destroy the infrastructure when you're done:
```bash
terraform destroy
```
*(You must pass the exact variables you used for creation so Terraform evaluates the configuration correctly during destroy).*
