resource "random_string" "role_suffix" {
  length  = 8
  special = false
}

/*
Define a read-only role for API access
See https://www.terraform.io/docs/providers/google/r/google_project_iam_custom_role.html
*/
resource "google_project_iam_custom_role" "kube-api-ro" {
  project = "${var.project}"
  role_id = "kube_api_ro_${random_string.role_suffix.result}"

  title       = "Kubernetes API (RO)"
  description = "Grants read-only API access that can be further restricted with RBAC"

  permissions = [
    "container.apiServices.get",
    "container.apiServices.list",
    "container.clusters.get",
    "container.clusters.getCredentials",
  ]
}

resource "google_service_account" "owner" {
  project      = "${var.project}"
  account_id   = "gke-owner"
  display_name = "GKE Owner"
}

resource "google_service_account" "auditor" {
  project      = "${var.project}"
  account_id   = "gke-auditor"
  display_name = "GKE Auditor"
}

# resource "google_service_account" "admin" {
#   account_id   = "gke-admin"
#   display_name = "GKE Container Admin"
# }

resource "google_project_iam_binding" "kube-api-ro" {
  project = "${var.project}"
  role    = "projects/${var.project}/roles/${google_project_iam_custom_role.kube-api-ro.role_id}"

  members = [
    "serviceAccount:${google_service_account.owner.email}",
    "serviceAccount:${google_service_account.auditor.email}",
  ]
}

# resource "google_project_iam_member" "kube-api-admin" {
#   project = "${var.project}"
#   role    = "roles/container.admin"
#   member  = "serviceAccount:${google_service_account.admin.email}"
# }

