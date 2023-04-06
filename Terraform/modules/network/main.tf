resource "google_compute_network" "net" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-subnet-eu-central2"
  ip_cidr_range = var.ip_range
  region        = var.region
  network       = google_compute_network.net.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.net.id
  service                 = var.connect_name
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name}-private-ip"
  purpose       = var.purpose
  address_type  = var.addr_type
  prefix_length = var.preffix
  network       = google_compute_network.net.id
}

resource "google_compute_firewall" "rule" {
  name          = "${var.name}-rule"
  network       = google_compute_network.net.name
  source_ranges = [var.source_range]


  allow {
    protocol = var.protocol
    ports    = var.port
  }

  target_tags = [var.tag]
}



resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.net.id

}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-gateway"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = var.allocation
  source_subnetwork_ip_ranges_to_nat = var.source_subnet
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = [var.subnet_ip_range]
  }


  log_config {
    enable = true
    filter = var.log_filter
  }
}