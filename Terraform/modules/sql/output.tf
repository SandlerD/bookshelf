output "coname" {
  value = google_sql_database_instance.main.connection_name
}

output "db_name" {
  value = google_sql_database.database.name
}

output "db_user" {
  value = google_sql_user.users.name
}

output "pass" {
  value = random_password.password.result
}