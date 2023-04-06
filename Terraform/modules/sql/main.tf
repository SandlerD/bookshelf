resource "google_sql_database_instance" "main" {
  name                = "${var.name}-db"
  database_version    = var.db_version
  region              = var.region
  deletion_protection = false

  settings {
    availability_type = var.availability
    tier              = var.tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_connection
    }
  }
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = random_password.password.result
}

resource "random_password" "password" {
  length           = var.length
  special          = true
  override_special = var.characters
}



