resource "hcloud_firewall" "nat" {
  name = "${var.project_name}-nat-fw"

  dynamic "rule" {
    for_each = var.ssh_allowed_cidrs
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "22"
      source_ips = [rule.value]
    }
  }

  labels = merge(local.common_labels, { role = "nat" })
}

resource "hcloud_server" "nat" {
  name         = "${var.project_name}-nat"
  server_type  = var.nat_gateway_server_type
  image        = var.nat_gateway_image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.master_key.id]
  firewall_ids = [hcloud_firewall.nat.id]

  network {
    network_id = hcloud_network.main.id
    ip         = var.nat_gateway_private_ip
  }

  public_net {
    ipv4_enabled = true # required for outbound internet egress
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/nat-cloud-init.yml.tpl", {
    private_subnet_cidr = var.private_subnet_cidr
  })

  labels     = merge(local.common_labels, { role = "nat" })
  depends_on = [hcloud_network_subnet.private]
}

# Tell Hetzner's SDN to route all internet-bound traffic through the NAT gateway
resource "hcloud_network_route" "private_default_egress" {
  network_id  = hcloud_network.main.id
  destination = "0.0.0.0/0"
  gateway     = var.nat_gateway_private_ip
  depends_on  = [hcloud_server.nat]
}
