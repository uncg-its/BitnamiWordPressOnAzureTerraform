# WordPress Foundation Deployment

This Terraform code will deploy the foundation for deploying multiple instances of WordPress in multiple App Services that share an App Service Plan, Storage Account, and Azure Database for MySQL Flexible Server.

After deploying the foundation, you can deploy one or more site deployments (from /src/split-deployment/site) to deploy the instance-specific resources, such as the App Service, file share, and database.
