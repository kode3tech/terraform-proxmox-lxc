terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "~> 3.0"
    }
  }
}

# Provider configuration
# Set these environment variables:
# - PM_API_URL (e.g., https://proxmox.example.com:8006/api2/json)
# - PM_API_TOKEN_ID (e.g., terraform@pam!token_id)
# - PM_API_TOKEN_SECRET
provider "proxmox" {
  pm_tls_insecure = true # Set to false in production with valid certificates
}
