PROFILE ?= us-west-2
STACK_NAME ?= dremio

create-iam:
	aws --profile $(PROFILE) cloudformation deploy --template-file iam.yaml --stack-name $(STACK_NAME)-iam --capabilities CAPABILITY_NAMED_IAM

create-vpc:
	aws --profile $(PROFILE) cloudformation deploy --template-file vpc.yaml --stack-name $(STACK_NAME)-vpc --capabilities CAPABILITY_NAMED_IAM

create-db:
	aws --profile $(PROFILE) cloudformation deploy --template-file db.yaml --stack-name $(STACK_NAME)-db --capabilities CAPABILITY_NAMED_IAM

create-ch:
	aws --profile $(PROFILE) cloudformation deploy --template-file ch.yaml --stack-name $(STACK_NAME)-ch --capabilities CAPABILITY_NAMED_IAM

destroy-iam:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-iam

destroy-vpc:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-vpc

destroy-db:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-db

destroy-ch:
	aws --profile $(PROFILE) cloudformation delete-stack --stack-name $(STACK_NAME)-ch

destroy: destroy-db destroy-ch destroy-iam destroy-vpc

status:
	@for stack in vpc iam db ch; do \
	  echo "Status of $(STACK_NAME)-$stack:"; \
	  aws --profile $(PROFILE) cloudformation describe-stacks --stack-name $(STACK_NAME)-$stack --query "Stacks[0].StackStatus" --output text || echo "Not found"; \
	done

outputs:
	@for stack in vpc iam db ch; do \
	  echo "Outputs from $(STACK_NAME)-$stack:"; \
	  aws --profile $(PROFILE) cloudformation describe-stacks --stack-name $(STACK_NAME)-$stack --query "Stacks[0].Outputs" --output table || echo "No outputs"; \
	done

all: create-vpc create-iam create-db create-ch