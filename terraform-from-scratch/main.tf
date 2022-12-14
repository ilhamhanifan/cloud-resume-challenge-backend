# CLOUD PROVIDER
provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# PROJECT
data "google_billing_account" "account" {
  display_name = var.billing_account
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project
  billing_account = data.google_billing_account.account.id
}

resource "google_project_iam_member" "owner" {
  project = var.project
  role    = "roles/owner"
  member  = "user:${var.user}"

  depends_on = [google_project.project]
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "user:${var.user}"

  depends_on = [google_project.project]
}

# ENABLE APIs
resource "google_project_service" "app_engine" {
  service    = "appengine.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "billing" {
  service    = "cloudbilling.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "compute" {
  service    = "compute.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "container_registry" {
  service    = "containerregistry.googleapis.com"
  depends_on = [google_project.project]
  disable_dependent_services = true
}

resource "google_project_service" "cloud_run" {
  service    = "run.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "firestore" {
  service    = "firestore.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "apigateway" {
  service    = "apigateway.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "servicemanagement" {
  service    = "servicemanagement.googleapis.com"
  depends_on = [google_project.project]
}

resource "google_project_service" "servicecontrol" {
  service    = "servicecontrol.googleapis.com"
  depends_on = [google_project.project]
}


# service account


# SERVICE ACCOUNT
# resource "google_service_account" "owner_sa" {
#   account_id = "owner-sa"
#   display_name = "owner sa"
#   depends_on = [google_project.project]
# }

# resource "google_service_account_iam_member" "firestore_owner" {
#   service_account_id = google_service_account.owner_sa.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "user:${var.user}"
# }

# resource "google_service_account_key" "firestore_owner_key" {
#   service_account_id = google_service_account.owner_sa.name
#   public_key_type    = "TYPE_X509_PEM_FILE"
#   depends_on = [google_service_account.owner_sa]

# }


# resource "google_compute_global_address" "static_ip" {
#   name = "crc-static-ip"
# }

# resource "google_storage_bucket" "backend_bucket_static_site" {
#   name          = "crc-backend-bucket-static-site"
#   location      = "ASIA"
#   force_destroy = true
#   enable_cdn    = true

#   uniform_bucket_level_access = true

#   website {
#     main_page_suffix = "index.html"
#   }
# }
