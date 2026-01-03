# Threat Composer AWS ECS Deployment

Production deployment of AWS Threat Composer using Terraform with automated CI CD.

## Infrastructure Status

Infrastructure is currently offline. Deployment takes approximately five minutes using terraform apply.

## Overview

This project deploys AWS Threat Composer to production using:

Terraform for infrastructure as code  
ECS Fargate for container orchestration  
GitHub Actions for automated deployments  
Multi AZ architecture for availability

## Local Development

Install dependencies.

yarn install

Build the application.

yarn build

Serve locally.

yarn global add serve  
serve -s build

Access the application at  
http://localhost:3000/workspaces/default/dashboard

Alternative method.

yarn install  
yarn start

## Infrastructure

### AWS Resources

VPC with public and private subnets  
Application Load Balancer with HTTPS and HTTP redirect  
ECS Fargate service running in private subnets  
Route 53 for DNS  
ACM for SSL certificates  
ECR for Docker images  
NAT Gateway for outbound access

### Security

Containers run in private subnets with no public IPs  
Security groups restrict traffic from ALB to ECS  
HTTPS enforced with TLS 1.3  
IAM roles follow least privilege

## Deployment

### Infrastructure

terraform init  
terraform plan  
terraform apply

### Application

Build and push the Docker image.

aws ecr get login password region eu west 2 | docker login username AWS password stdin ECR_URL  
docker buildx build platform linux amd64 tag ECR_URL latest push .

Force ECS redeployment.

aws ecs update service cluster threat composer cluster service threat composer service force new deployment region eu west 2

### CI CD

Create an IAM user for GitHub Actions  
Add AWS credentials to GitHub Secrets  
Push to main branch to deploy automatically

## CI CD Pipeline

On every push to main:

Build Docker image  
Push to ECR  
Deploy to ECS

## Project Structure

.
├── .github
│ └── workflows
├── config
├── images
├── modules
│ ├── acm
│ ├── alb
│ ├── ecs
│ ├── route53
│ ├── security-groups
│ └── vpc
├── public
├── src
├── .dockerignore
├── .eslintignore
├── .eslintrc.json
├── .gitignore
├── .npmignore
├── babel.config.json
├── cicd-policy.json
├── Dockerfile
├── main.tf
├── package.json
├── project.json
├── README.md
├── renovate.json
├── tsconfig.dev.json
├── tsconfig.json
├── variables.tf
└── yarn.lock
