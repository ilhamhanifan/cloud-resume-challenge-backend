## CONTAINER REGISTRY
resource "google_container_registry" "registry" {
  project  = var.project
  location = var.reg
}

# FIRESTORE
resource "google_app_engine_application" "firestore_backend" {
  project     = var.project
  location_id = var.region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_firestore_document" "firestore_doc" {
  project     = var.project
  collection  = "counter_collection"
  document_id = "counter_doc"
  fields      = jsonencode(
    {
      counter = {
        integerValue = "0"
      }
    }
  )
  depends_on = [google_app_engine_application.firestore_backend]
}

# CLOUD RUN
resource "google_cloud_run_service" "cloud_run_backend" {
  name     = var.cr_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/crc-backend:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.cloud_run_backend.location
  project     = google_cloud_run_service.cloud_run_backend.project
  service     = google_cloud_run_service.cloud_run_backend.name

  policy_data = data.google_iam_policy.noauth.policy_data
  depends_on = [google_cloud_run_service.cloud_run_backend]
}

## API GATEWAY
resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  api_id       = var.api_id
  project      = var.project
  display_name = var.api_id
}

resource "null_resource" "init_openapi_conf" {
  provisioner "local-exec" {
    command = <<-EOT

      sed -i 's|https.*app|${google_cloud_run_service.cloud_run_backend.status[0].url}|' openapi2.yml
    EOT    
  }
  triggers = { always_run = timestamp() }
  depends_on = [google_api_gateway_api.api_gw]
}

resource "google_api_gateway_api_config" "api_gw_cfg" {
  provider             = google-beta
  api                  = google_api_gateway_api.api_gw.api_id
  project              = var.project
  display_name         = var.api_id

  openapi_documents {
    document {
      path     = "terraform/openapi2.yaml"
      contents = filebase64("openapi2.yml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [null_resource.init_openapi_conf]

}

resource "google_api_gateway_gateway" "api_gw_gw" {
  provider = google-beta
  region   = var.api_gateway_location
  project  = var.project
  gateway_id   = var.api_gateway_id
  display_name = var.api_gateway_id

  api_config   = google_api_gateway_api_config.api_gw_cfg.id

  depends_on   = [google_api_gateway_api_config.api_gw_cfg]
}


