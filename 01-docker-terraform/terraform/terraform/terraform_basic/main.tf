terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.41.0"
    }
  }
}

provider "google" {
  # Credentials only needs to be set if you do not have the GOOGLE_APPLICATION_CREDENTIALS set
  #  credentials = ""
  project = "my-project-260414-493307"
  region  = "us-central1"
}



resource "google_storage_bucket" "demo-bucket" {
  name     = "my-project-260414-493307-terra-bucket"
  location = "US"
  

  # Optional, but recommended settings:
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 2 // days
    }
  }

  force_destroy = true
}


resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = "demo_dataset"
  # project    = "<Your Project ID>"
  location   = "US"
}