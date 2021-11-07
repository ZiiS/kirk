terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
    }
    kubectl = {
     source = "gavinbunney/kubectl"
    }
  }
}

terraform {
  required_version = ">= 1"
}
