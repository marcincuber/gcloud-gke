resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}"
  project       = "${var.project}"
  region        = "${var.region}"
  network       = "${var.network}"
  ip_cidr_range = "${var.ip_range}"
  enable_flow_logs = "${var.enable_flow_logs}"
  private_ip_google_access = "${var.enable_private_ip_google_access}"
  secondary_ip_range = {
    range_name = "${var.name}-pods"
    ip_cidr_range = "${var.pod_cidr_range}"
  }
  secondary_ip_range = {
    range_name = "${var.name}-services"
    ip_cidr_range = "${var.service_cidr_range}"
  }
}
