output "instance_ip_addr" {
  value = "http://${google_compute_global_address.default.address}:${google_compute_global_forwarding_rule.forwarding_rule.port_range}"
}