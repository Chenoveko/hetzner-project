output "nat_gateway_public_ipv4" {
  description = "Public IPv4 of the NAT gateway — use this as SSH jump host"
  value       = hcloud_server.nat.ipv4_address
}
