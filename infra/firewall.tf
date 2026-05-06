resource "hcloud_firewall" "app" {
  name = "${var.project_name}-app-fw"

  # Allow HTTP from Load Balancer only
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = [var.lb_private_ip]
  }

  # Allow SSH from NAT gateway (jump host access)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "222"
    source_ips = [var.nat_gateway_private_ip]
  }

  labels = merge(local.common_labels, { role = "app" })
}
