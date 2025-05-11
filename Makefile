PROFILE ?= eu-central-1
STACK_NAME ?= demo-eks

.PHONY: validate deploy-demo destroy-demo status update-kubeconfig get-db-password get-clickhouse-password

validate:
	@echo "Validating CloudFormation templates..."
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://vpc-simple.yaml --output json > /dev/null
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://iam-simple.yaml --output json > /dev/null
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://db-simple.yaml --output json > /dev/null
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://ch-simple.yaml --output json > /dev/null
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://eks-simple.yaml --output json > /dev/null
	@echo "All templates are valid!"

deploy-demo: validate
	@echo "Deploying VPC..."
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file vpc-simple.yaml \
		--stack-name $(STACK_NAME)-vpc \
		--parameter-overrides \
			ClusterName=$(STACK_NAME)
	
	@echo "Deploying IAM roles..."
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file iam-simple.yaml \
		--stack-name $(STACK_NAME)-iam \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			ClusterName=$(STACK_NAME)
	
	@echo "Deploying RDS database..."
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file db-simple.yaml \
		--stack-name $(STACK_NAME)-db \
		--parameter-overrides \
			ClusterName=$(STACK_NAME)
	
	@echo "Deploying ClickHouse..."
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file ch-simple.yaml \
		--stack-name $(STACK_NAME)-ch \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			ClusterName=$(STACK_NAME)
	
	@echo "Deploying EKS cluster..."
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file eks-simple.yaml \
		--stack-name $(STACK_NAME)-eks \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			ClusterName=$(STACK_NAME)
	
	@echo "Updating kubeconfig..."
	aws --profile $(PROFILE) eks update-kubeconfig --name $(STACK_NAME) --region $(PROFILE)
	
	@echo "Demo environment deployed successfully!"

destroy-demo:
	@echo "Destroying EKS cluster..."
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-eks
	@echo "Waiting for EKS stack deletion..."
	aws --profile $(PROFILE) cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)-eks
	
	@echo "Destroying ClickHouse..."
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-ch
	@echo "Waiting for ClickHouse stack deletion..."
	aws --profile $(PROFILE) cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)-ch
	
	@echo "Destroying RDS database..."
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-db
	@echo "Waiting for DB stack deletion..."
	aws --profile $(PROFILE) cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)-db
	
	@echo "Destroying IAM roles..."
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-iam
	@echo "Waiting for IAM stack deletion..."
	aws --profile $(PROFILE) cloudformation wait stack-delete-complete --stack-name $(STACK_NAME)-iam
	
	@echo "Destroying VPC..."
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-vpc
	
	@echo "Demo environment destruction initiated. Check AWS Console for completion status."

status:
	@for stack in vpc iam db ch eks; do \
	  echo "Status of $(STACK_NAME)-${stack}:"; \
	  aws --profile $(PROFILE) cloudformation describe-stacks --stack-name $(STACK_NAME)-${stack} --query "Stacks[0].StackStatus" --output text || echo "Not found"; \
	done

update-kubeconfig:
	@echo "Updating kubeconfig for EKS cluster..."
	aws --profile $(PROFILE) eks update-kubeconfig --name $(STACK_NAME) --region $(PROFILE)
	@echo "Kubeconfig updated. You can now use kubectl to interact with your EKS cluster."

get-db-password:
	@echo "Retrieving database password from SSM Parameter Store..."
	aws --profile $(PROFILE) ssm get-parameter --name "/database/$(STACK_NAME)/demo/password" --with-decryption --query "Parameter.Value" --output text

get-clickhouse-password:
	@echo "Retrieving ClickHouse password from SSM Parameter Store..."
	aws --profile $(PROFILE) ssm get-parameter --name "/clickhouse/$(STACK_NAME)/demo/admin-password" --with-decryption --query "Parameter.Value" --output text