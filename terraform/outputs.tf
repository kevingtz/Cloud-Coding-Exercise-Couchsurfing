output "load_balancer_ip" {
  description = "The IP address of the load balancer"
  value       = google_compute_global_forwarding_rule.main.ip_address
} 