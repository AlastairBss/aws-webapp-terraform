Project - Highly Available AWS Web App using ALB + Auto Scaling + Terraform
-----------
Designed a production-style AWS infrastructure using Terraform featuring Application Load Balancer, Auto Scaling Group, private EC2 instances, NAT gateway networking, and multi-AZ high availability with secure architecture.

--------------------------------------------------------------------------
Overview:

Production-style AWS infrastructure deployed using Terraform demonstrating:

    -High availability across multiple AZs

    -Private EC2 instances behind ALB

    -Auto scaling based on demand

    -Secure VPC architecture

    -Infrastructure as Code deployment

This replicates real-world cloud architecture patterns.

-------------------------------------------------------------

Architecture Highlights:

    -Custom VPC (10.0.0.0/16)

    -Public subnets → ALB + NAT Gateway

    -Private subnets → EC2 instances

    -Application Load Balancer with health checks
 
    -Auto Scaling Group (min: 2, max: 4)

    -NAT gateway for outbound-only internet

    -Security groups enforcing ALB → EC2 traffic onlyArchitecture Highlights

-------------------------------------------------------------

Tech Stack

    -AWS (EC2, ALB, ASG, VPC, NAT Gateway)

    -Terraform

    -Apache HTTP Server (demo app)

--------------------------------------------------------------

Deployment Steps

    -terraform init
    -terraform plan
    -terraform apply

Access the ALB DNS after deployment.

-----------------------------------------------------------------

Testing Done

    -Load balancing validation

    -Auto-scaling behavior

    -Fault tolerance testing

    -Security validation (no direct EC2 access)

------------------------------------------------------------------

Lessons / Challenges

    -Syntax Errors

    -Debugging unhealthy target group issues

    -Security group misconfiguration

    -Listener configuration fixes

    -Instance bootstrap timing problems
