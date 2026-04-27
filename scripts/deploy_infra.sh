#!/bin/bash
set -e

cd infrastructure

terraform fmt
terraform init
terraform plan
terraform apply