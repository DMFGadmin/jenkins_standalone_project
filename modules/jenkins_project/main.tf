data "terraform_remote_state" "folder-info" {
  backend = "remote"
  config = {
    organization = "AFRLDigitalMFG"
    workspaces = {
      name = "folders"
    }
  }
}

data "terraform_remote_state" "shared-vpc-info" {
  backend = "remote"
  config = {
    organization = "AFRLDigitalMFG"
    workspaces = {
      name = "shared_vpc_projects"
    }
  }
}

# A project which will not use the VPC
resource "google_project" "standalone_project" {
  name            = "afrl-jenkins-01"
  project_id      = "afrl-jenkins-01"
  folder_id         = data.terraform_remote_state.folder-info.outputs.afrl-bd-folder
  billing_account = var.billing_account_id
}

resource "google_project" "monitoring_project" {
  name            = "afrl-monitoring-01"
  project_id      = "afrl-monitoring-01"
  folder_id         = data.terraform_remote_state.folder-info.outputs.afrl-bd-folder
  billing_account = var.billing_account_id
}

resource "google_project_service" "standalone_project" {
  project = google_project.standalone_project.project_id
  service = "compute.googleapis.com"
}

# Create a standalone network.
resource "google_compute_network" "standalone_network" {
  name                    = "standalone-network"
  auto_create_subnetworks = "false"
  project                 = google_project.standalone_project.project_id
  depends_on              = [google_project_service.standalone_project]
}

resource "google_compute_subnetwork" "afrl-jenkins-subnet" {
  project = google_project.standalone_project.name
  name = "afrl-jenkins-subnet-01"
  network = google_compute_network.standalone_network.name
  region = "us-central1"
  description = "standalone network for jenkins project"
  ip_cidr_range = "10.10.0.0/24"
  private_ip_google_access = true

}

resource "google_compute_firewall" "allow-traffic-from-shared-host" {
  name = "allow-traffic-from-shared-vpc-host"
  description = "Allow shared-vpc-host-traffic"
  network =   google_compute_network.standalone_network.self_link
  direction = "INGRESS"
  project = google_project.standalone_project.project_id
  disabled = "false"
  priority = 1000
  enable_logging = "true"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["${data.terraform_remote_state.shared-vpc-info.outputs.afrl-shared-vpc-subnet-cidr_block}"]
}