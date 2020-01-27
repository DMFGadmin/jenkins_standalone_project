output "jenkins-standalone-project-id" {
  value = google_project.standalone_project.id
}

output "monitoring-project-id" {
  value = google_project.monitoring_project.id
}

output "jenkins-standalone-project-network-name" {
  value = google_compute_network.standalone_network.name
}

output "jenkins-standalone-project-subnetwork-name" {
  value = google_compute_subnetwork.afrl-jenkins-subnet.name
}

output "jenkins-standalone-project-cidr-block" {
  value = google_compute_subnetwork.afrl-jenkins-subnet.ip_cidr_range
}

