resource "google_compute_instance_template" "instance_template" {
  name_prefix  = "${var.name}-template"
  machine_type = var.type
  region       = var.region

  disk {
    source_image = var.image
  }

  tags = [var.tag]

  network_interface {
    network    = var.network_id
    subnetwork = var.subnetwork_id
  }

  metadata = {
    SQL     = var.coname
    BUCKET  = var.bucket
    DB_NAME = var.db_name
    DB_USER = var.db_user
    DB_PASS = var.pass

  }

  metadata_startup_script = file("startup-script.sh")

  service_account {
    email  = google_service_account.service_account.email
    scopes = [var.scopes]
  }
}


resource "google_service_account" "service_account" {
  account_id = "${var.name}-sa"
}
resource "google_project_iam_member" "sa_user" {
  project  = var.project
  for_each = toset(var.roles)
  role     = each.value
  member   = "serviceAccount:${google_service_account.service_account.email}"
}


resource "google_compute_instance_group_manager" "instance_group" {
  name               = "${var.name}-group"
  base_instance_name = var.name
  zone               = var.zone


  version {
    instance_template = google_compute_instance_template.instance_template.id
  }

  named_port {
    name = var.port_name
    port = var.port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = var.delay
  }
}


resource "google_compute_autoscaler" "autoscaler" {
  name   = "${var.name}-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.instance_group.id

  autoscaling_policy {
    max_replicas    = var.max
    min_replicas    = var.min
    cooldown_period = var.cooldown
  }
}


resource "google_compute_health_check" "autohealing" {
  name = "${var.name}-health-check"

  log_config {
    enable = true
  }

  tcp_health_check {
    port = var.port
  }
}


resource "google_compute_backend_service" "backend" {
  name          = "${var.name}-backend"
  health_checks = [google_compute_health_check.autohealing.id]

  backend {
    group = google_compute_instance_group_manager.instance_group.instance_group
  }
  log_config {
    enable = true
  }
}


resource "google_compute_global_address" "default" {
  name = "${var.name}-static-ip"
}


resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "${var.name}-frontend"
  ip_protocol           = var.protocol
  load_balancing_scheme = var.lb_scheme
  port_range            = var.port_lb
  target                = google_compute_target_http_proxy.target_http_proxy.id
  ip_address            = google_compute_global_address.default.id
}


resource "google_compute_target_http_proxy" "target_http_proxy" {
  name    = "${var.name}-target-http-proxy"
  url_map = google_compute_url_map.url_map.id
}


resource "google_compute_url_map" "url_map" {
  name            = "${var.name}-lb"
  default_service = google_compute_backend_service.backend.id
}

