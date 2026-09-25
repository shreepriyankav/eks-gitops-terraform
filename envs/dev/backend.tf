terraform {
  backend "s3" {
    bucket       = "shreepriyanka-eks-tfstate-2026"
    key          = "dev/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}