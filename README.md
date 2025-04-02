# Food Delivery App - AWS with Terraform

## Table of Contents

<ol>
  <li><a href="#about">About</a></li>
  <li><a href="#Architecture Overview">Architecture Overview</a></li>
  <li><a href="#Advanced Implementation">Deployment</a></li>
</ol>

## About
An end-to-end deployment of a scalable and secure Food Delivery application using AWS infrastructure, managed and automated with Terraform.

## Architecture Overview

The infrastructure includes the following components:

- **Networking**: VPC with public and private subnets across multiple availability zones
- **Security**: Security groups following the principle of least privilege
- **Compute**: Auto Scaling Groups with launch templates for EC2 instances
- **Load Balancing**: Application Load Balancer with HTTPS support
- **Database**: Amazon RDS for MySQL with backups and optional multi-AZ deployment
- **DNS Management**: Route 53 for domain management and routing
- **Content Delivery**: CloudFront and S3 for static asset delivery
- **Monitoring**: CloudWatch for logs and metrics

## Advanced Implementation

While this portfolio project demonstrates a cost-effective setup, I'm also familiar with designing more robust AWS architectures including:
* VPC with public/private subnets for enhanced security
* RDS for managed database services
* Route53 for DNS management
* Load balancing with ELB/ALB
* Auto-scaling groups for high availability
* S3 for static assets and backups
* CloudFront for content delivery
* IAM for fine-grained access control
* AWS WAF for web application firewall protection
* CloudWatch for comprehensive monitoring and alerting
* AWS KMS for encryption key management
* AWS Certificate Manager for SSL/TLS certificates
