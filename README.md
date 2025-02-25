# Terraform Infrastructure for Backstage on AWS EC2

This repository provides Terraform code to deploy [Backstage](https://backstage.io/) on an AWS EC2 instance.

## Overview
- **Purpose**: Automates the deployment of Backstage, an open-source platform for building developer portals, on a single EC2 instance in AWS.
- **Components**:
  - AWS EC2 instance configured to run Backstage.
  - Necessary networking and security settings.

## Getting Started
1. **Prerequisites**:
   - Terraform installed.
   - AWS credentials configured.
2. **Deployment**:
   - Clone this repository.
   - Run `terraform init` to initialize the project.
   - Run `terraform apply` to deploy the infrastructure.
3. **Backstage Installation**:
   - Follow the installation instructions for Backstage on the EC2 instance located in the [`docs`](./docs) folder.
4. **Access Backstage**:
   - Once deployed and installed, access the Backstage instance via the EC2 public IP or DNS.
