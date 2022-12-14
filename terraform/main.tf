terraform {
 backend "gcs" {
   bucket  = "tf-bucket-crc"
   prefix  = "terraform/state"
 }
}

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

resource "random_id" "bucket_prefix" {
  byte_length = 8
}