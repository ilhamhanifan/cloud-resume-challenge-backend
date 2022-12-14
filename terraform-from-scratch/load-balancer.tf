## STORAGE BUCKET
resource "google_storage_bucket" "gcs_bucket" {
  name          = var.gcs_bucket
  location      = var.reg
  force_destroy = true
  
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
  }
  depends_on = [google_project_iam_member.storage_admin]
}

data "google_iam_policy" "viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
        "allUsers",
    ] 
  }
}

resource "google_storage_bucket_iam_policy" "editor" {
  bucket = "${google_storage_bucket.gcs_bucket.name}"
  policy_data = "${data.google_iam_policy.viewer.policy_data}"
}

resource "null_resource" "upload_folder_content" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = <<-EOT
      sed -i 's|https.*dev|https://${google_api_gateway_gateway.api_gw_gw.default_hostname}|' ${var.frontend_folder_path}/script.js
      gsutil cp -r ${var.frontend_folder_path}/* gs://${var.gcs_bucket}/
    EOT
  }

}
 

# LOAD BALANCER
resource "google_compute_backend_bucket" "gcs_backend" {
  name        = "crc-backend-bucket"
  bucket_name = google_storage_bucket.gcs_bucket.name
  enable_cdn  = true
}


resource "google_compute_url_map" "url_map" {
  name            = "crc-url-map"
  default_service = google_compute_backend_bucket.gcs_backend.self_link
}

resource "google_compute_managed_ssl_certificate" "certs" {
  name = "crc-cert"
  managed {
    domains = ["ilhamhanifan.dev.","www.ilhamhanifan.dev."]
  }
}
 
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "crc-https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.certs.self_link]
}

resource "google_compute_global_address" "static_ip" {
  name         = "crc-static-ip"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "crc-lb-forwarding-rule"
  provider              = google
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_proxy.self_link
  ip_address            = google_compute_global_address.static_ip.address
}

