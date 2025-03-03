# kommando

[![Latest Release](https://img.shields.io/github/v/tag/kalisio/kommando?sort=semver&label=latest)](https://github.com/kalisio/kommando/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Download Status](https://img.shields.io/npm/dm/@kalisio/kommando.svg?style=flat-square)](https://www.npmjs.com/package/@kalisio/kommando)

> A Terraform solution for provisioning an AWS EC2 instance running Ubuntu for load testing.

![Load Testing Pipeline](./load-testing-pipeline.png)

## Prerequisites

### 1. Install Terraform

- **Guide**: Follow the official [Terraform Installation](https://developer.hashicorp.com/terraform/install) instructions.
- **Verification**: Run `terraform -v` to confirm installation.

### 2. Configure AWS CLI

- **Installation**: Install the AWS CLI by following the [AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- **Configuration**: Execute the following command and provide your credentials:
  ```bash
  aws configure
  AWS Access Key ID: [Your IAM Access Key]
  AWS Secret Access Key: [Your IAM Secret Key]
  Default region name: eu-west-3
  Default output format: json
  ```

### 3. Create an SSH key pair

```bash
aws ec2 create-key-pair --key-name load_testing_keypair --query "KeyMaterial" --output text > "$(pwd)/load_testing_keypair.pem"
chmod 400 ./load_testing_keypair.pem
```

## Setup

### 1. Set environment variables

Export the required variables in your shell to configure the deployment:

```bash
export TF_VAR_development_repo_url="https://oauth2:$GITLAB_IRSN_TOKEN@gitlab.extra.irsn.fr/webteleray/development.git"
export TF_VAR_rclone_config_repo_url="https://oauth2:$GITLAB_IRSN_TOKEN@gitlab.extra.irsn.fr/webteleray/deployment/teleray-staging.git"
export TF_VAR_sops_age_key=$(grep '^AGE-SECRET-KEY-' "$DEVELOPMENT_DIR/age/keys.txt")
export TF_VAR_admin_jwt_access_token="your-jwt-token"
```

### 2. Deploy the infrastructure

Initialize and apply the Terraform configuration:

```bash
terraform init && terraform plan && terraform apply --auto-approve
```

> [!IMPORTANT]
> Check the public IP with: `terraform output instance_ip`

### 3. Verify execution

- **SSH Access**: Connect to the instance using:
  ```bash
  ssh -i ./load_testing_keypair.pem ubuntu@<PUBLIC_IP>
  ```
- **Check Logs**:
  - **Setup Script**: View the provisioning logs:
    ```bash
    sudo cat /var/log/setup_script.log
    ```
  - **Docker Container**: List running containers and inspect logs:
    ```bash
    sudo docker ps
    sudo docker logs <CONTAINER_ID>
    ```
  
## Cleanup

Remove all provisioned resources when testing is complete:
   
```bash
terraform destroy --auto-approve
```

## License

Copyright (c) 2017-20xx Kalisio

Licensed under the [MIT license](LICENSE).

## Authors

This project is sponsored by 

[![Kalisio](https://s3.eu-central-1.amazonaws.com/kalisioscope/kalisio/kalisio-logo-black-256x84.png)](https://kalisio.com)