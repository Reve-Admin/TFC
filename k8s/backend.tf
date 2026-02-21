terraform {
  cloud {
    organization = "your-tfc-organization"

    workspaces {
      name = "k8s-infrastructure-workspace"
    }
  }
}