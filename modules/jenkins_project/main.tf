# A project which will not use the VPC
resource "google_project" "standalone_project" {
  name            = "afrl-jenkins-cicd-001"
  project_id      = "afrl-jenkins-cicd-001"
  folder_id         = var.folder_id
  billing_account = var.billing_account_id
  auto_create_network = false
}

resource "google_project_service" "standalone_project" {
  project = google_project.standalone_project.project_id
  service = "compute.googleapis.com"
}

# Create a standalone network with the same firewall rules.
resource "google_compute_network" "standalone_network" {
  name                    = "standalone-network"
  auto_create_subnetworks = "false"
  project                 = google_project.standalone_project.project_id
  depends_on              = [google_project_service.standalone_project]
}

resource "google_compute_subnetwork" "afrl-jenkins-subnet" {
  project = google_project.standalone_project.name
  name = "afrl-jenkins-subnet-001"
  network = google_compute_network.standalone_network.name
  region = "us-central1"
  description = "standalone network for jenkins project"
  ip_cidr_range = "10.10.0.0/24"
  private_ip_google_access = true

}