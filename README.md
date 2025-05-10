# AWS EKS Demo Environment

This repository contains simplified CloudFormation templates for deploying a demo EKS environment with supporting infrastructure.

## Architecture

The demo environment consists of:

1. **VPC** - A simple VPC with one public and one private subnet in a single AZ
2. **IAM** - Minimal IAM roles required for EKS and ClickHouse
3. **RDS** - A small PostgreSQL database for application data
4. **ClickHouse** - A ClickHouse database on EC2 for analytics (accessible only from EKS)
5. **EKS** - A basic EKS cluster with a single node

## Prerequisites

- AWS CLI installed and configured with appropriate permissions
- kubectl installed (for interacting with the EKS cluster)
- AWS account with permissions to create the required resources

## Deployment

To deploy the entire demo environment:

```bash
make -f Makefile-simple deploy-demo PROFILE=your-aws-profile STACK_NAME=your-stack-name
```

This will:
1. Validate all templates
2. Deploy the VPC
3. Deploy IAM roles
4. Deploy the RDS database
5. Deploy the ClickHouse instance
6. Deploy the EKS cluster
7. Configure kubectl to connect to your cluster

## Cleanup

To delete all resources:

```bash
make -f Makefile-simple destroy-demo PROFILE=your-aws-profile STACK_NAME=your-stack-name
```

## Useful Commands

Check the status of all stacks:
```bash
make -f Makefile-simple status PROFILE=your-aws-profile STACK_NAME=your-stack-name
```

Update your kubeconfig to connect to the cluster:
```bash
make -f Makefile-simple update-kubeconfig PROFILE=your-aws-profile STACK_NAME=your-stack-name
```

Get the database password:
```bash
make -f Makefile-simple get-db-password PROFILE=your-aws-profile STACK_NAME=your-stack-name
```

Get the ClickHouse password:
```bash
make -f Makefile-simple get-clickhouse-password PROFILE=your-aws-profile STACK_NAME=your-stack-name
```

## Accessing ClickHouse

ClickHouse is deployed in the private subnet and is only accessible from the EKS cluster. To connect to ClickHouse from your applications running in EKS, use:

- HTTP endpoint: http://<private-ip>:8123
- Client endpoint: <private-ip>:9000

The private IP address is available in the CloudFormation outputs:
```bash
aws --profile your-aws-profile cloudformation describe-stacks --stack-name your-stack-name-ch --query "Stacks[0].Outputs[?OutputKey=='ClickHousePrivateIP'].OutputValue" --output text
```

To access ClickHouse for testing or administration, you can:
1. Create a pod in the EKS cluster with the ClickHouse client
2. Use kubectl port-forwarding to access the ClickHouse interface
3. Set up a bastion host or AWS Systems Manager Session Manager for direct access

## Differences from Production Setup

This demo environment has been simplified in several ways:

1. **Single Availability Zone** - Production would use multiple AZs for high availability
2. **Minimal Monitoring** - Production would include CloudWatch dashboards and alarms
3. **Smaller Instances** - Production would use appropriately sized instances
4. **No Multi-AZ for RDS** - Production would enable Multi-AZ for database high availability
5. **Simplified ClickHouse** - Reduced storage and no monitoring
6. **Simplified Security** - Some security measures are relaxed for demo purposes
7. **Single Node EKS** - Production would have multiple nodes across AZs

## Next Steps

After deploying the demo environment, you can:

1. Deploy sample applications to the EKS cluster
2. Connect applications to the RDS database
3. Use ClickHouse for analytics workloads from your EKS applications
4. Explore the AWS Console to see the created resources
5. Experiment with scaling the node group

## Security Note

This demo environment is not suitable for production use. It has been simplified for demonstration and learning purposes.