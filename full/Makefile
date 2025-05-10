PROFILE ?= eu-central-1
STACK_NAME ?= my-stack
ENVIRONMENT ?= dev

.PHONY: validate create-iam create-vpc create-db create-ch create-eks destroy-iam destroy-vpc destroy-db destroy-ch destroy-eks destroy status outputs all

validate:
	@echo "Validating CloudFormation templates..."
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://vpc.yaml
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://iam.yaml
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://db.yaml
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://ch.yaml
	aws --profile $(PROFILE) cloudformation validate-template --template-body file://aws-eks.yaml
	@echo "All templates are valid!"

create-iam:
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file iam.yaml \
		--stack-name $(STACK_NAME)-iam \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			Environment=$(ENVIRONMENT) \
			ClusterName=$(STACK_NAME)

create-vpc:
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file vpc.yaml \
		--stack-name $(STACK_NAME)-vpc \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			Environment=$(ENVIRONMENT) \
			ClusterName=$(STACK_NAME)

create-db: create-vpc
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file db.yaml \
		--stack-name $(STACK_NAME)-db \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			Environment=$(ENVIRONMENT) \
			ClusterName=$(STACK_NAME)

create-ch: create-vpc create-iam
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file ch.yaml \
		--stack-name $(STACK_NAME)-ch \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			Environment=$(ENVIRONMENT) \
			ClusterName=$(STACK_NAME)

create-eks: create-vpc create-iam
	aws --profile $(PROFILE) cloudformation deploy \
		--template-file aws-eks.yaml \
		--stack-name $(STACK_NAME)-eks \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			Environment=$(ENVIRONMENT) \
			ClusterName=$(STACK_NAME)

destroy-eks:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-eks

destroy-iam:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-iam

destroy-vpc:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-vpc

destroy-db:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-db

destroy-ch:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-ch

destroy: destroy-db destroy-ch destroy-eks destroy-iam destroy-vpc
	@echo "All stacks have been deleted or deletion has been initiated."

status:
	@for stack in vpc iam db ch eks; do \
	  echo "Status of $(STACK_NAME)-$${stack}:"; \
	  aws --profile $(PROFILE) cloudformation describe-stacks --stack-name $(STACK_NAME)-$${stack} --query "Stacks[0].StackStatus" --output text || echo "Not found"; \
	done

outputs:
	@for stack in vpc iam db ch eks; do \
	  echo "Outputs from $(STACK_NAME)-$${stack}:"; \
	  aws --profile $(PROFILE) cloudformation describe-stacks --stack-name $(STACK_NAME)-$${stack} --query "Stacks[0].Outputs" --output table || echo "No outputs"; \
	done

all: validate create-vpc create-iam create-db create-ch create-eks
	@echo "All stacks have been deployed!"

update-eks-config:
	@echo "Updating kubeconfig for EKS cluster..."
	aws --profile $(PROFILE) eks update-kubeconfig --name $(STACK_NAME)-$(ENVIRONMENT) --region $(PROFILE)
	@echo "Kubeconfig updated. You can now use kubectl to interact with your EKS cluster."

get-db-password:
	@echo "Retrieving database password from SSM Parameter Store..."
	aws --profile $(PROFILE) ssm get-parameter --name "/database/$(STACK_NAME)/$(ENVIRONMENT)/password" --with-decryption --query "Parameter.Value" --output text

get-clickhouse-password:
	@echo "Retrieving ClickHouse password from SSM Parameter Store..."
	aws --profile $(PROFILE) ssm get-parameter --name "/clickhouse/$(STACK_NAME)/$(ENVIRONMENT)/admin-password" --with-decryption --query "Parameter.Value" --output text