#--------------------------------------------------------------------------------------------
#| Script: init.sh                                                                 						   
#| Author: Soham Roy                                                       					           
#| Version: 1.0                                                                             						
#| Date: 14.06.2022                                                                        						   
#| Schedule run: On demand                                                                  					   
#| Dependent file: None                                                          						   
#| Purpose: This script creates the infrastructure to deploy the eks cluster (including networking components) 	   
#| Example Run: bash init.sh
#| Dependencies: terraform should be present                                                          					   
#--------------------------------------------------------------------------------------------
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