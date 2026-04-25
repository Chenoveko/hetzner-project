resource "hcloud_network" "dev-network" {
  name     = "dev-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "dev-network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.dev-network.id  
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_server" "server" {
  name        = "server"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  user_data   = file("cloud-init.yaml")

  network {
    network_id = hcloud_network.dev-network.id
    ip         = "10.0.1.5"
    alias_ips  = [
      "10.0.1.6",
      "10.0.1.7"
    ]
  }

  depends_on = [
    hcloud_network_subnet.dev-network-subnet     
  ]
}
