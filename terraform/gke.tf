## Find the latest compatible GKE-specific K8s version
data "google_container_engine_versions" "perform" {
  location       = var.gcloud_zone
  version_prefix = var.cluster_version_prefix
}

## Create a service account for each user
resource "google_service_account" "perform_user" {
  count        = var.number_of_users
  account_id   = "${var.name_prefix}-${var.attendee_user}-${count.index + 1}-${random_id.uuid.hex}"
  display_name = "${var.name_prefix}-${var.attendee_user}-${count.index + 1}-${random_id.uuid.hex}"
  description  = "Created automatically by Terraform"
}

resource "google_service_account_key" "perform_user" {
  count              = var.number_of_users

  service_account_id = google_service_account.perform_user[count.index].email
}

resource "local_file" "perform_user_key" {
  count              = var.number_of_users

  sensitive_content  = base64decode(google_service_account_key.perform_user[count.index].private_key)
  filename           = "gcloud-keys/${var.name_prefix}-${var.attendee_user}-${count.index + 1}-${random_id.uuid.hex}-key.json"
}

resource "google_project_iam_member" "perform_user" {
  count = length(google_service_account.perform_user.*.email)

  role     = "roles/container.admin"
  member   = "serviceAccount:${google_service_account.perform_user[count.index].email}"
}

## Deploy a GKE cluster for each user
resource "google_container_cluster" "perform" {
  count              = var.number_of_users

  name               = "${var.name_prefix}-${var.cluster_name}-${count.index + 1}-${random_id.uuid.hex}"
  location           = var.gcloud_zone

  initial_node_count = var.cluster_node_count
  min_master_version = data.google_container_engine_versions.perform.latest_master_version

  logging_service    = "logging.googleapis.com"
  monitoring_service = "monitoring.googleapis.com"

  master_auth {
    username = var.cluster_username

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  node_config {

    machine_type = var.cluster_node_config["size"]
    image_type   = var.cluster_node_config["image"]
    disk_type    = var.cluster_node_config["disk_type"]
    disk_size_gb = var.cluster_node_config["disk_size"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]

    metadata = {
      disable-legacy-endpoints = true
    }

    labels = {
      perform = var.name_prefix
    }

    tags = [
      var.name_prefix,
      var.cluster_name
    ]
  }
}
