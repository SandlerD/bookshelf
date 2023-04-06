resource "google_storage_bucket" "bucket" {
  name          = "${var.name}-app-storage"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "binding_viewer" {
  bucket   = google_storage_bucket.bucket.name
  for_each = toset(var.storage)
  role     = each.value
  members  = [var.members]
}

