# SSH Key to access cms from master
resource "hcloud_ssh_key" "master_key" {
  name       = "master-ssh-key"
  public_key = file(".ssh/master_key.pub")
}

# SSH Key to access machines from cms
resource "tls_private_key" "ansible" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "ansible" {
  name       = "ansible-ssh-key"
  public_key = tls_private_key.ansible.public_key_openssh
}

# Network
resource "hcloud_network" "dev_network" {
  name     = "dev-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "dev_network_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.dev_network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# VPS
resource "hcloud_server" "cms" {
  name        = "cms"
  server_type = "cax11"
  image       = "ubuntu-24.04"
  location    = "hel1"
  ssh_keys = [
    hcloud_ssh_key.master_key.id,
    hcloud_ssh_key.ansible.id
  ]
user_data = templatefile("cloud-init-cms.yml", {
  ansible_private_key = tls_private_key.ansible.private_key_openssh
  master_public_key   = file(".ssh/master_key.pub")
})  
network {
    network_id = hcloud_network.dev_network.id
    ip         = "10.0.1.5"
  }
  depends_on = [hcloud_network_subnet.dev_network_subnet]
}
