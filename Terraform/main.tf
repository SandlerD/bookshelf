
module "network" {
  source = "./modules/network"

  name            = "bookshelf"
  region          = "europe-central2"
  source_range    = "0.0.0.0/0"
  port            = ["8080", "22"]
  tag             = "web"
  protocol        = "tcp"
  ip_range        = "10.24.2.0/24"
  connect_name    = "servicenetworking.googleapis.com"
  purpose         = "VPC_PEERING"
  addr_type       = "INTERNAL"
  preffix         = 16
  allocation      = "AUTO_ONLY"
  source_subnet   = "LIST_OF_SUBNETWORKS"
  subnet_ip_range = "ALL_IP_RANGES"
  log_filter      = "ALL"

}

module "sql" {
  source = "./modules/sql"

  name         = "bookshelf"
  db_name      = "bookshelf"
  db_user      = "bookshelf"
  region       = "europe-central2"
  tier         = "db-custom-12-61440"
  db_version   = "MYSQL_5_7"
  availability = "ZONAL"
  characters   = "!#$%&*()-_=+[]{}<>:?"
  length       = 10

  private_connection = module.network.network_id

  depends_on = [module.network]
}

module "backend" {
  source = "./modules/backend"

  project   = "gcp-2022-bookshelf-sandlerr"
  name      = "bookshelf"
  region    = "europe-central2"
  zone      = "europe-central2-c"
  type      = "e2-medium"
  port      = "8080"
  port_name = "http"
  tag       = "web"
  image     = "debian-cloud/debian-10"
  protocol  = "TCP"
  lb_scheme = "EXTERNAL"
  scopes    = "cloud-platform"
  max       = 3
  min       = 1
  port_lb   = 80
  delay     = 300
  cooldown  = 180
  roles     = ["roles/pubsub.admin", "roles/cloudsql.client", "roles/source.reader", "roles/logging.logWriter"]


  network_id    = module.network.network_id
  subnetwork_id = module.network.subnetwork_id
  coname        = module.sql.coname
  db_name       = module.sql.db_name
  db_user       = module.sql.db_user
  pass          = module.sql.pass
  bucket        = module.bucket.bucket

  depends_on = [module.sql]
}


module "bucket" {
  source = "./modules/bucket"

  name    = "bookshelf"
  members = "allUsers"
  region  = "EUROPE-CENTRAL2"
  storage = ["roles/storage.objectViewer", "roles/storage.objectCreator"]
}

