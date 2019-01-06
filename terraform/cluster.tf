provider "google-beta" {
  #credentials = "${file("~/.gcloud/mc-project.json")}"  # export GOOGLE_APPLICATION_CREDENTIALS="/Users/mcuber/.gcloud/marcincuber-iam-role.json"
  project = "${var.project}" # change to google later
  region  = "${var.region}"
}

terraform {
  backend "gcs" {
    bucket = "tf-state-mc-project"
    prefix = "state"
  }
}

// Provides access to available Google Container Engine versions in a zone for a given project.
// https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "zonal" {
  zone    = "${var.zones[0]}"
  project = "${var.project}"
}

# resource "google_container_cluster" "public_cluster" {
#   name               = "${var.cluster_name}"
#   description        = "GKE kubernetes cluster ${var.environment}"
#   initial_node_count = "${var.initial_node_count}"
#   project            = "${var.project}"

#   network    = "${google_compute_network.network.self_link}"
#   subnetwork = "${module.private_subnet.self_link}"
#   zone       = "${var.zones[0]}"

#   additional_zones = [
#     "${var.zones[1]}",
#     "${var.zones[2]}",
#   ]

#   min_master_version = "${data.google_container_engine_versions.zonal.latest_master_version}"

#   master_auth {
#     username = "marcincuber"
#     password = "marcincuber123456789"
#   }

#   node_config {
#     machine_type = "g1-small"
#     image_type   = "COS"

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/compute",
#       "https://www.googleapis.com/auth/devstorage.read_only",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]

#     labels {
#       owner   = "marcin-cuber"
#       project = "mc-project-219813"
#     }

#     tags = ["project", "mc-project-219813"]
#   }

#   addons_config {
#     http_load_balancing {
#       disabled = false
#     }

#     horizontal_pod_autoscaling {
#       disabled = false
#     }

#     kubernetes_dashboard {
#       disabled = false
#     }
#   }

#   maintenance_policy {
#     daily_maintenance_window {
#       start_time = "03:00"
#     }
#   }
# }

# Update in-place will happen tp network and subnetwork when you apply.
# https://github.com/terraform-providers/terraform-provider-google/issues/1382
# https://github.com/terraform-providers/terraform-provider-google/issues/1566
resource "google_container_cluster" "private_cluster" {
  provider    = "google-beta"
  name        = "${var.cluster_name}-${var.environment}"
  description = "GKE kubernetes PRIVATE cluster ${var.environment}"

  # initial_node_count = "${var.initial_node_count}"
  project = "${var.project}"

  network    = "${google_compute_network.network.self_link}"
  subnetwork = "${module.private_subnet.self_link}"
  zone       = "${var.zones[0]}"

  additional_zones = [
    "${var.zones[1]}",
    "${var.zones[2]}",
  ]

  # remove_default_node_pool = "true"
  lifecycle {
    ignore_changes = ["initial_node_count", "node_pool"]
  }

  node_pool {}

  min_master_version = "${data.google_container_engine_versions.zonal.latest_master_version}"

  master_auth {
    username = "marcincuber"
    password = "marcincuber123456789"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.private_subnet_name}-${var.environment}-pods"
    services_secondary_range_name = "${var.private_subnet_name}-${var.environment}-services"
  }

  private_cluster_config {
    master_ipv4_cidr_block  = "${var.master_ipv4_cidr_block}"
    enable_private_endpoint = "false"
    enable_private_nodes    = "true"
  }

  master_authorized_networks_config {
    cidr_blocks = [
      {
        cidr_block   = "81.141.10.249/32"
        display_name = "Marcin Home"
      },
    ]
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }
  }

  timeouts {
    create = "10m"
    delete = "30m"
    update = "2h"
  }

  # lifecycle {
  #   ignore_changes = ["initial_node_count", "network_policy", "node_config", "addons_config"]
  # }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

# Additional node pools
resource "google_container_node_pool" "np_ubuntu" {
  name    = "np-${var.environment}-ubuntu"
  zone    = "${var.zones[0]}"
  project = "${var.project}"
  cluster = "${google_container_cluster.private_cluster.name}"

  initial_node_count = "${var.initial_node_count}"
  version            = "${data.google_container_engine_versions.zonal.latest_master_version}"

  node_config {
    machine_type = "n1-standard-1"
    image_type   = "UBUNTU"

    service_account = ""

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      owner   = "marcin-cuber"
      project = "mc-project-219813"
    }

    tags = ["project", "mc-project-219813"]
  }

  autoscaling {
    min_node_count = "1"
    max_node_count = "10"
  }

  # not supported on ubuntu
  # management {
  #   auto_repair  = "true"
  #   auto_upgrade = "false"
  # }
}

resource "google_container_node_pool" "np_cos" {
  name    = "np-${var.environment}-cos"
  zone    = "${var.zones[0]}"
  project = "${var.project}"
  cluster = "${google_container_cluster.private_cluster.name}"

  initial_node_count = "${var.initial_node_count}"
  version            = "${data.google_container_engine_versions.zonal.latest_master_version}"

  node_config {
    machine_type = "n1-standard-2"
    image_type   = "COS"

    service_account = ""

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      owner   = "marcin-cuber"
      project = "mc-project-219813"
    }

    tags = ["project", "mc-project-219813"]
  }

  autoscaling {
    min_node_count = "1"
    max_node_count = "10"
  }

  management {
    auto_repair  = "true"
    auto_upgrade = "false"
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster.
# output "endpoint-public-cluster" {
#   value = "${google_container_cluster.cluster.endpoint}"
# }

# output "client_certificate-public-cluster" {
#   value = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
# }

# output "client_key-public-cluster" {
#   value = "${google_container_cluster.cluster.master_auth.0.client_key}"
# }

# output "cluster_ca_certificate-public-cluster" {
#   value = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
# }

output "endpoint-private-cluster" {
  value = "${google_container_cluster.private_cluster.endpoint}"
}

output "client_certificate-private-cluster" {
  value = "${google_container_cluster.private_cluster.master_auth.0.client_certificate}"
}

output "client_key-private-cluster" {
  value = "${google_container_cluster.private_cluster.master_auth.0.client_key}"
}

output "cluster_ca_certificate-private-cluster" {
  value = "${google_container_cluster.private_cluster.master_auth.0.cluster_ca_certificate}"
}
