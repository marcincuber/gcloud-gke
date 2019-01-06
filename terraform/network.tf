resource "google_compute_network" "network" {
  name                    = "${var.name}-network"
  project                 = "${var.project}"
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "allow-internal" {
  name    = "${var.name}-allow-internal"
  project = "${var.project}"
  network = "${var.name}-network"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    "${module.public_subnet.ip_range}",
    "${module.private_subnet.ip_range}",
  ]
}

resource "google_compute_firewall" "allow-ssh-from-everywhere-to-bastion" {
  name    = "${var.name}-allow-ssh-from-everywhere-to-bastion"
  project = "${var.project}"
  network = "${var.name}-network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["bastion"]
}

resource "google_compute_firewall" "allow-ssh-from-bastion-to-priv-inst" {
  name      = "${var.name}-allow-ssh-from-bastion-to-priv-inst"
  project   = "${var.project}"
  network   = "${var.name}-network"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}

resource "google_compute_firewall" "allow-ssh-to-priv-from-bastion" {
  name      = "${var.name}-allow-ssh-to-private-network-from-bastion"
  project   = "${var.project}"
  network   = "${var.name}-network"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["bastion"]
}

resource "google_compute_firewall" "allow-http-https" {
  name    = "${var.name}-allow-http-https"
  project = "${var.project}"
  network = "${var.name}-network"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]

  source_tags = ["http", "https"]
}

module "public_subnet" {
  source                          = "./modules/network/subnet"
  project                         = "${var.project}"
  region                          = "${var.region}"
  name                            = "${var.public_subnet_name}-${var.environment}"
  network                         = "${google_compute_network.network.self_link}"
  ip_range                        = "${var.public_subnet_ip_range}"
  enable_flow_logs                = "${var.enable_flow_logs_pub}"
  enable_private_ip_google_access = "${var.enable_private_ip_google_access_pub}"
  pod_cidr_range                  = "${var.pod_cidr_range_pub}"
  service_cidr_range              = "${var.service_cidr_range_pub}"
}

module "private_subnet" {
  source                          = "./modules/network/subnet"
  project                         = "${var.project}"
  region                          = "${var.region}"
  name                            = "${var.private_subnet_name}-${var.environment}"
  network                         = "${google_compute_network.network.self_link}"
  ip_range                        = "${var.private_subnet_ip_range}"
  enable_flow_logs                = "${var.enable_flow_logs_priv}"
  enable_private_ip_google_access = "${var.enable_private_ip_google_access_priv}"
  pod_cidr_range                  = "${var.pod_cidr_range_priv}"
  service_cidr_range              = "${var.service_cidr_range_priv}"
}

module "bastion" {
  source        = "./modules/network/bastion"
  name          = "${var.name}-bastion"
  project       = "${var.project}"
  zones         = "${var.zones}"
  subnet_name   = "${module.public_subnet.self_link}"
  image         = "${var.bastion_image}"
  instance_type = "${var.bastion_instance_type}"

  # user          = "${var.user}"
  # ssh_key       = "${var.ssh_key}"
}
