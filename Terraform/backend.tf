terraform {
  backend "gcs" {
    bucket = "tf-bookshelf-sandler"
    prefix = "terraform/state"
  }
}