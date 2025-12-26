terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "registry.terraform.io/Telmate/proxmox"
      version = "3.0.2-rc07"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
