#!/bin/bash

PROJECT=$(gcloud config get-value project 2>/dev/null)
LOCATION=asia-northeast1
REPOSITORY=cloudrun
IMAGE_URL="${LOCATION}-docker.pkg.dev/${PROJECT}/${REPOSITORY}/helloworld"
IMAGE_TAG=latest
IMAGE="${IMAGE_URL}:${IMAGE_TAG}"

# Docker Imageをデプロイするための設定
# 初回だけ実行すればOK
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud artifacts repositories create "${REPOSITORY}" --repository-format=docker --location $LOCATION

set -e

# Docker ImageのBuild&Push
gcloud builds submit --tag "${IMAGE}"

# terraformの変数の設定
cat > terraform.tfvars <<EOF
image = "${IMAGE}"
location = "${LOCATION}"
EOF

# terraformの適用
terraform init
terraform plan
terraform apply --auto-approve
