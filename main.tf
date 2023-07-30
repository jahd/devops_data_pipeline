provider "google" {
  credentials = file("/Users/jahdou/devops/devops-394313-e6b57e60f442.json")
  project     = var.project
  region      = var.region
}

resource "google_storage_bucket" "bucket" {
  name     = "my-bucket-devops_2"
  location = "EU"
}

resource "google_storage_bucket_object" "archive" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "/Users/jahdou/devops/mon_zip/function-source.zip"
}

resource "google_cloudfunctions_function" "hello_world" {
  name        = "hello-world-function"
  description = "My Hello World Cloud Function"
  runtime     = "python39"
  
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http = true
  entry_point = "hello_world"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project
  region         = var.region
  cloud_function = google_cloudfunctions_function.hello_world.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
