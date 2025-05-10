# AWS EKS CloudFormation Infrastructure

This repository contains CloudFormation templates for deploying a complete AWS infrastructure with EKS, RDS PostgreSQL, and ClickHouse.

## Architecture Overview

![Architecture Diagram](https://via.placeholder.com/800x600.png?text=EKS+Architecture+Diagram)

The infrastructure consists of the following components:

- **VPC** with public and private subnets across two availability zones
- **EKS Cluster** with managed node groups
- **RDS PostgreSQL** database in a private subnet
- **ClickHouse** database on EC2 in a private subnet
- **IAM Roles** for EKS, RDS, and ClickHouse access
- **CloudWatch** monitoring and logging for all components

## Prerequisites

- AWS CLI installed and configured
- AWS account with appropriate permissions
- Make utility installed

## Deployment Instructions

### 1. Configure AWS Profile

Ensure your AWS CLI is configured with the appropriate credentials:

```bash
aws configure --profile your-profile-name
```

### 2. Deploy the Infrastructure

You can deploy the entire infrastructure with a single command:

```bash
make all PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev
```

Or deploy individual components:

```bash
# Deploy VPC
make create-vpc PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev

# Deploy IAM roles
make create-iam PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev

# Deploy RDS
make create-db PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev

# Deploy ClickHouse
make create-ch PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev

# Deploy EKS
make create-eks PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev
```

### 3. Access the EKS Cluster

After deployment, update your kubeconfig to access the EKS cluster:

```bash
make update-eks-config PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev
```

### 4. Get Database Credentials

Retrieve the database passwords from SSM Parameter Store:

```bash
# Get RDS password
make get-db-password PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev

# Get ClickHouse password
make get-clickhouse-password PROFILE=your-profile-name STACK_NAME=your-stack-name ENVIRONMENT=dev
```

## Stack Outputs

To view the outputs from all stacks:

```bash
make outputs PROFILE=your-profile-name STACK_NAME=your-stack-name
```

## Monitoring and Logging

All components are configured with CloudWatch monitoring and logging:

- **EKS Cluster**: Control plane logs and node metrics
- **RDS**: Performance metrics and database logs
- **ClickHouse**: Server logs and instance metrics

Access the CloudWatch dashboards in the AWS Console to view metrics and logs.

## Security Features

- Private subnets for databases and internal services
- Security groups with least privilege access
- IAM roles with specific permissions
- Encrypted storage for all components
- VPC Flow Logs for network traffic monitoring

## Cleanup

To delete all resources:

```bash
make destroy PROFILE=your-profile-name STACK_NAME=your-stack-name
```

Or delete individual components:

```bash
make destroy-eks PROFILE=your-profile-name STACK_NAME=your-stack-name
make destroy-ch PROFILE=your-profile-name STACK_NAME=your-stack-name
make destroy-db PROFILE=your-profile-name STACK_NAME=your-stack-name
make destroy-iam PROFILE=your-profile-name STACK_NAME=your-stack-name
make destroy-vpc PROFILE=your-profile-name STACK_NAME=your-stack-name
```

## Template Details

- **vpc.yaml**: VPC with public and private subnets, NAT gateway, and security groups
- **iam.yaml**: IAM roles for EKS, RDS, and ClickHouse
- **db.yaml**: RDS PostgreSQL instance with monitoring
- **ch.yaml**: ClickHouse on EC2 with monitoring
- **aws-eks.yaml**: EKS cluster with managed node groups

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.