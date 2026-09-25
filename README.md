# EKS GitOps Terraform

A production-style DevOps and GitOps project that provisions AWS infrastructure using Terraform, deploys a Spring Boot application on Amazon EKS, and automates application delivery using GitHub Actions, Amazon ECR, and Argo CD.

## Architecture

```text
Developer
    |
    v
GitHub Repository
    |
    +----------------------+
    |                      |
    v                      v
GitHub Actions          Argo CD
    |                      |
    | OIDC                 | GitOps Sync
    v                      v
AWS IAM              Amazon EKS Cluster
    |                      |
    v                      v
Terraform              Kubernetes
    |                      |
    v                      v
AWS VPC                  Service
    |                      |
    v                      v
EKS + Networking       LoadBalancer
                           |
                           v
                     Spring Boot App
```

## Project Flow

```text
Code Change
    ↓
GitHub
    ↓
GitHub Actions
    ↓
AWS Authentication using OIDC
    ↓
Terraform Plan / Apply
    ↓
Docker Image
    ↓
Amazon ECR
    ↓
Argo CD detects Git change
    ↓
Amazon EKS
    ↓
Kubernetes Deployment
    ↓
AWS LoadBalancer
    ↓
Application
```

## Technologies Used

| Category               | Technologies          |
| ---------------------- | --------------------- |
| Cloud                  | AWS                   |
| Infrastructure as Code | Terraform             |
| Containerization       | Docker                |
| Container Registry     | Amazon ECR            |
| Kubernetes             | Amazon EKS            |
| GitOps                 | Argo CD               |
| CI/CD                  | GitHub Actions        |
| Authentication         | GitHub OIDC + AWS IAM |
| Application            | Spring Boot           |
| Language               | Java 21               |
| Build Tool             | Maven                 |
| Version Control        | Git / GitHub          |

## AWS Infrastructure

The infrastructure is provisioned using Terraform.

### VPC

* VPC CIDR: `10.0.0.0/16`
* 2 Public Subnets
* 2 Private Subnets
* Internet Gateway
* NAT Gateways
* Public and Private Route Tables

### Amazon EKS

* Cluster: `dev-eks-cluster`
* Kubernetes version: `1.34`
* 2 managed worker nodes
* Node type: `t3.small`
* Worker nodes deployed in private subnets

### Application

The Spring Boot application exposes:

```text
GET /api/hello
```

Example response:

```text
Hello from EKS GitOps v2!
```

## Terraform Structure

```text
eks-gitops-terraform/
│
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       └── terraform-apply.yml
│
├── app/
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
│
├── envs/
│   └── dev/
│       ├── backend.tf
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── terraform.tfvars
│
├── modules/
│   ├── vpc/
│   └── eks/
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── argocd-app.yaml
├── .gitignore
└── README.md
```

## Terraform Backend

Terraform state is stored remotely in Amazon S3.

```text
S3 Bucket:
shreepriyanka-eks-tfstate-2026

State:
dev/terraform.tfstate
```

S3 state locking is enabled using Terraform's native S3 lockfile mechanism.

## GitHub Actions

### Terraform CI

The CI workflow performs:

```text
Checkout
   ↓
Configure AWS Credentials
   ↓
Terraform Format Check
   ↓
Terraform Init
   ↓
Terraform Validate
   ↓
Terraform Plan
```

### Terraform Apply

Infrastructure deployment can be manually triggered through GitHub Actions.

```text
GitHub Actions
      ↓
AWS OIDC
      ↓
IAM Role
      ↓
Terraform Init
      ↓
Terraform Validate
      ↓
Terraform Apply
```

No long-lived AWS access keys are stored in GitHub.

## GitHub OIDC

GitHub Actions authenticates with AWS using OpenID Connect.

```text
GitHub Actions
      |
      | OIDC Token
      v
AWS IAM OIDC Provider
      |
      v
GitHubActionsEKSDeployRole
      |
      v
AWS Resources
```

This removes the need to store permanent AWS access keys inside GitHub Actions.

## Amazon ECR

Docker images are stored in Amazon ECR.

Example image:

```text
825276341358.dkr.ecr.us-east-2.amazonaws.com/eks-gitops-app:2.0
```

## Argo CD GitOps

Argo CD monitors the Kubernetes manifests in the GitHub repository.

```text
GitHub
  |
  | k8s/deployment.yaml
  v
Argo CD
  |
  | Automated Sync
  v
Amazon EKS
```

The Argo CD application uses:

```text
Repository:
https://github.com/shreepriyankav/eks-gitops-terraform.git

Branch:
main

Path:
k8s
```

Automated sync and self-healing are enabled.

## GitOps Deployment Test

A version change was tested successfully.

### Version 1

```text
Hello from EKS GitOps!
```

### Version 2

The application was changed to:

```text
Hello from EKS GitOps v2!
```

The Docker image was rebuilt and pushed as:

```text
eks-gitops-app:2.0
```

Then the Kubernetes manifest was updated from:

```text
eks-gitops-app:1.0
```

to:

```text
eks-gitops-app:2.0
```

After the Git change was pushed:

```text
GitHub
   ↓
Argo CD
   ↓
EKS
   ↓
New Application Version
```

Argo CD reported:

```text
SYNC STATUS: Synced
HEALTH STATUS: Healthy
```

The live application was verified through the AWS LoadBalancer and returned:

```text
Hello from EKS GitOps v2!
```

## Key DevOps Concepts Demonstrated

* Infrastructure as Code
* Remote Terraform State
* AWS VPC Networking
* Amazon EKS
* Kubernetes Deployments and Services
* Docker Containerization
* Amazon ECR
* GitHub Actions CI/CD
* GitHub OIDC Authentication
* AWS IAM
* GitOps
* Argo CD Automated Sync
* Kubernetes LoadBalancer
* Spring Boot Deployment

## How to Run Locally

### Build the application

```bash
cd app
mvn clean package -DskipTests
```

### Build Docker image

```bash
docker build -t eks-gitops-app:2.0 .
```

### Push image to ECR

Authenticate Docker with Amazon ECR and push the image:

```bash
docker push <ECR_REPOSITORY_URI>:2.0
```

### Deploy infrastructure

```bash
cd envs/dev
terraform init
terraform validate
terraform plan
terraform apply
```

### Verify EKS

```bash
aws eks update-kubeconfig \
  --region us-east-2 \
  --name dev-eks-cluster
```

```bash
kubectl get nodes
```

### Verify Argo CD

```bash
kubectl get pods -n argocd
kubectl get application -n argocd
```

### Verify application

```bash
kubectl get pods
kubectl get svc eks-gitops-app
```

## Result

This project demonstrates an end-to-end GitOps deployment workflow on AWS:

```text
Terraform
   ↓
AWS VPC
   ↓
Amazon EKS
   ↓
Docker + ECR
   ↓
GitHub Actions
   ↓
Argo CD
   ↓
Kubernetes
   ↓
LoadBalancer
   ↓
Spring Boot Application
```

The infrastructure is managed using Terraform, CI/CD authentication uses GitHub OIDC, and application deployments are synchronized from Git using Argo CD.
