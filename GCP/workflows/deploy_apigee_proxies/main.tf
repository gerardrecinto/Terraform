# NOTE: Published as supporting evidence for skills on resume.
# All company-specific values (account IDs, hostnames, ARNs, CIDRs, resource names)
# have been replaced with generic placeholders to preserve company CCI.
# Apigee proxy deployment workflow
# Deploys three API proxies: DeviceCloud, SoftwareHub (Software Center), and ModelHub
# Each proxy uses JS policies for token validation and path-based backend routing
# Mirrors the production setup built at ExampleCorp on GCP Apigee

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "example-terraform-state"
    prefix = "apigee"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "apigee" {
  source = "../../modules/apigee"

  project_id                = var.project_id
  org_id                    = var.project_id
  environment               = var.environment
  region                    = var.region
  apigee_env_name           = var.environment
  apigee_env_group_hostname = var.api_hostname
  vpc_network_name          = var.vpc_network
  vpc_peering_cidr          = var.vpc_peering_cidr
  token_validation_url      = var.token_validation_url

  api_proxies = {
    # DeviceCloud (ExampleCorp Developer Cloud) -- primary developer portal API
    # Handles device auth tokens and routes to different DeviceCloud backend services
    devicecloud = {
      display_name       = "DeviceCloud API"
      description        = "ExampleCorp Developer Cloud API proxy -- token auth, path routing to device management and SSH gateway services"
      base_path          = "/devicecloud/v2"
      target_url         = "https://${var.devicecloud_backend_host}"
      token_auth_enabled = true
      path_routes = {
        "/devices"    = "https://${var.devicecloud_backend_host}/api/devices"
        "/ssh"        = "https://${var.devicecloud_backend_host}/api/ssh-gateway"
        "/workspaces" = "https://${var.devicecloud_backend_host}/api/workspaces"
        "/builds"     = "https://${var.devicecloud_backend_host}/api/builds"
      }
    }

    # SoftwareHub (ExampleCorp Software Center) -- software package delivery
    # Pre-signed URL generation is handled by a Python Flask service behind this proxy
    softwarehub = {
      display_name       = "SoftwareHub Software Center API"
      description        = "Software Center API proxy -- validates customer tokens and routes to package delivery service (Flask pre-signed URL generator)"
      base_path          = "/softwarehub/v2"
      target_url         = "https://${var.softwarehub_backend_host}"
      token_auth_enabled = true
      path_routes = {
        "/packages" = "https://${var.softwarehub_backend_host}/api/packages"
        "/download" = "https://${var.softwarehub_backend_host}/api/presigned"
        "/catalog"  = "https://${var.softwarehub_backend_host}/api/catalog"
        "/releases" = "https://${var.softwarehub_backend_host}/api/releases"
      }
    }

    # ModelHub -- public AI model and API access
    # Routes to different model serving endpoints based on path
    modelhub = {
      display_name       = "ModelHub API"
      description        = "ExampleCorp AI Hub API proxy -- model inference, deployment, and benchmark routing with token auth"
      base_path          = "/modelhub/v2"
      target_url         = "https://${var.modelhub_backend_host}"
      token_auth_enabled = true
      path_routes = {
        "/models"     = "https://${var.modelhub_backend_host}/api/models"
        "/inference"  = "https://${var.modelhub_backend_host}/api/inference"
        "/benchmarks" = "https://${var.modelhub_backend_host}/api/benchmarks"
        "/compile"    = "https://${var.modelhub_backend_host}/api/compile"
        "/profile"    = "https://${var.modelhub_backend_host}/api/profile"
      }
    }
  }

  tags = local.tags
}

locals {
  tags = {
    environment = var.environment
    project     = "saga"
    terraform   = "true"
  }
}

# GCS bucket for Apigee proxy bundle artifacts and Terraform state
module "apigee_artifacts" {
  source = "../../modules/gcs_lifecycle"

  project_id                  = var.project_id
  bucket_name                 = "${var.project_id}-apigee-artifacts-${var.environment}"
  location                    = "US"
  environment                 = var.environment
  object_prefix               = "bundles/"
  transition_to_nearline_days = 30
  transition_to_coldline_days = 90
  transition_to_archive_days  = 365
  labels                      = local.tags
}
