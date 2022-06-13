## Create backend for tfstate
echo "Create backend"
cd ../terraform/backend/
terraform init
terraform apply --auto-approve

# Create vpc-module and eks cluster
echo "Create vpc-module and eks cluster"
cd ../network-components/
terraform init
terraform apply --auto-approve