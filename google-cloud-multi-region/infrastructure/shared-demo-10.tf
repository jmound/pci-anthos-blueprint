terraform {
  backend "gcs" {
    bucket = "tfbase-ababab"
    prefix = "terraform/state/infrastructure/i000"
  }
}


locals {
  project-prefix  = "i000"
  project-app     = "${local.project-prefix}-app"
  project-network = "${local.project-prefix}-network"
  #  infrastructure-folder-id  = 
  cluster-1                        = "gke-west-priv"
  cluster-2                        = "gke-central-priv"
  cluster-1-zone                   = "us-west2-a"
  cluster-1-region                 = "us-west2"
  cluster-1-master-ipv4-cidr       = "172.16.0.0/28"
  cluster-2-zone                   = "us-central1-a"
  cluster-2-region                 = "us-central1"
  cluster-2-master-ipv4-cidr       = "172.16.1.0/28"
  cluster-ingress                  = "gke-ingress"
  cluster-ingress-zone             = "us-west1-a"
  cluster-ingress-region           = "us-west1"
  cluster-ingress-master-ipv4-cidr = "172.16.2.0/28"
  healthcheck_ip_ranges            = ["130.211.0.0/22", "35.191.0.0/16"]
}

locals {
  firewall-all-source-ranges = [
    var.subnetworks.r1-1.instance_cidr,
    var.subnetworks.r1-1.pods_cidr,
    var.subnetworks.r1-1.services_cidr,

    var.subnetworks.r1-2.instance_cidr,
    var.subnetworks.r1-2.pods_cidr,
    var.subnetworks.r1-2.services_cidr,

    var.subnetworks.r2-1.instance_cidr,
    var.subnetworks.r2-1.pods_cidr,
    var.subnetworks.r2-1.services_cidr,

    var.subnetworks.r2-2.instance_cidr,
    var.subnetworks.r2-2.pods_cidr,
    var.subnetworks.r2-2.services_cidr,

    var.subnetworks.r3-1.instance_cidr,
    var.subnetworks.r3-1.pods_cidr,
    var.subnetworks.r3-1.services_cidr,
  ]

  firewall-all-control-planes = [
    var.subnetworks.r1-1.control_plane_cidr,
    var.subnetworks.r1-2.control_plane_cidr,
    var.subnetworks.r2-1.control_plane_cidr,
    var.subnetworks.r2-2.control_plane_cidr,
    var.subnetworks.r3-1.control_plane_cidr,
  ]
  in_scope_tag       = "in-scope"
  out_of_scope_tag   = "out-of-scope"
  config_cluster_tag = "config-cluster"
}

variable "subnetworks" {
  default = {
    "r1-1" = {
      "name" : "r1-1"
      "region" : "us-west1"
      "instance_cidr" : "192.168.0.0/22"
      "pods_cidr" : "10.0.0.0/14"
      "pods_range_name" : "r1-1-pods"
      "services_cidr" : "172.16.0.0/20"
      "services_range_name" : "r1-1-services"
      "control_plane_cidr" : "192.168.255.0/28"
      "control_plane_authorized_networks_cidr" : "0.0.0.0/0"
    },
    "r1-2" = {
      "name" : "r1-2"
      "region" : "us-west1"
      "instance_cidr" : "192.168.4.0/22"
      "pods_cidr" : "10.4.0.0/14"
      "pods_range_name" : "r1-2-pods"
      "services_cidr" : "172.16.16.0/20"
      "services_range_name" : "r1-2-services"
      "control_plane_cidr" : "192.168.255.16/28"
      "control_plane_authorized_networks_cidr" : "0.0.0.0/0"
    },
    "r2-1" = {
      "name" : "r2-1"
      "region" : "us-west2"
      "instance_cidr" : "192.168.8.0/22"
      "pods_cidr" : "10.8.0.0/14"
      "pods_range_name" : "r2-1-pods"
      "services_cidr" : "172.16.32.0/20"
      "services_range_name" : "r2-1-services"
      "control_plane_cidr" : "192.168.255.32/28"
      "control_plane_authorized_networks_cidr" : "0.0.0.0/0"
    },
    "r2-2" = {
      "name" : "r2-2"
      "region" : "us-west2"
      "instance_cidr" : "192.168.16.0/22"
      "pods_cidr" : "10.12.0.0/14"
      "pods_range_name" : "r2-2-pods"
      "services_cidr" : "172.16.48.0/20"
      "services_range_name" : "r2-2-services"
      "control_plane_cidr" : "192.168.255.48/28"
      "control_plane_authorized_networks_cidr" : "0.0.0.0/0"
    },
    "r3-1" = {
      "name" : "r3-1"
      "region" : "us-central1"
      "instance_cidr" : "192.168.32.0/22"
      "pods_cidr" : "10.16.0.0/14"
      "pods_range_name" : "r3-1-pods"
      "services_cidr" : "172.16.64.0/20"
      "services_range_name" : "r3-1-services"
      "control_plane_cidr" : "192.168.255.64/28"
      "control_plane_authorized_networks_cidr" : "0.0.0.0/0"
    },
  }
}

locals {
  vpc_network_name             = "default"
  cluster-1-machine-type       = "e2-standard-4"
  cluster-2-machine-type       = "e2-standard-4"
  cluster-ingress-machine-type = "e2-standard-4"
  mesh_id                      = "proj-${google_project.app.number}"
  project_root_path            = "/Users/jmound/Documents/virtualenvs/anthos/src/pci-anthos/google-cloud-multi-region"
}

# "0154F9-B397B3-8A877C": "Ann's Credit Card" in gcpsecurity.solutions
# "01A865-FEFFAE-D9C1D9": "Ann's Google Billing Account" in google.com
variable "billing_account" {
  description = "The ID of the associated billing account"
  default     = "0154F9-B397B3-8A877C"
  #   default = "01A865-FEFFAE-D9C1D9"
}

variable "application_services" {
  type = list(string)
  default = [
    "anthos.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "meshca.googleapis.com",
    "meshconfig.googleapis.com",
    "meshtelemetry.googleapis.com",
    "monitoring.googleapis.com",
    "multiclusteringress.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}

variable "api_enabled_services_project_network" {
  type = list(string)
  default = [
    "container.googleapis.com",
    "dns.googleapis.com",
    "compute.googleapis.com"
  ]
}

variable "config_sync_sync_repo" {
  default = "git@github.com:Atmospherical/anthos-acm-ci.git"
}
variable "config_sync_sync_branch" {
  default = "multi-region"
}
variable "config_sync_sync_policy_dir_root" {
  default = "google-cloud-multi-region"
}
locals {
  config_sync_ssh_auth_key_path = file("${local.project_root_path}/private/d13")
}

locals {
  in_scope_node_pool_oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/cloud_debugger",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly"
  ]
  out_of_scope_node_pool_oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/cloud_debugger",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly"
  ]
  config_cluster_node_pool_oauth_scopes = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}