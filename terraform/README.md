# Steps
1. To retrieve a credentials file, see this link: https://console.cloud.google.com/apis/credentials/serviceaccountkey
2. Have Google Cloud SDK installed
3. Set GOOGLE_CREDENTIALS env variable to path of credentials file
4. Run `terraform init -backend-config=perform2020.tfbackend`
5. Define variables in terraform.tfvars file
6. Run `terraform plan` to validate, then `terraform apply` to deploy
