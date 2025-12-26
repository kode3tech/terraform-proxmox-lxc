terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "registry.terraform.io/Telmate/proxmox"
      version = "3.0.2-rc07"
    }
  }
}

# Provider configuration via environment variables
# The provider will automatically read these environment variables:
# - PM_API_URL
# - PM_API_TOKEN_ID
# - PM_API_TOKEN_SECRET
# - PM_TLS_INSECURE (optional, defaults to false)
#
# Set them in .env file and use asdf-dotenv plugin to load automatically
# Reference: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
provider "proxmox" {
  # Configuration via environment variables - no explicit values needed
}
