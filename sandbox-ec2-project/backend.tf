terraform {
  cloud {
    organization = "your-tfc-organization"

    workspaces {
      name = "hardened-ec2-workspace"
    }
  }
}