# SSH Key to access cms from master
resource "tls_private_key" "master" {
  algorithm = "ED25519"
}

# SSH Key to access machines from cms
resource "tls_private_key" "ansible" {
  algorithm = "ED25519"
}

# Save master SSH key in Hetzner Cloud
resource "hcloud_ssh_key" "master_key" {
  name       = "master-ssh-key"
  public_key = tls_private_key.master.public_key_openssh
}

# Save ansible SSH key in Hetzner Cloud
resource "hcloud_ssh_key" "ansible_key" {
  name       = "ansible-ssh-key"
  public_key = tls_private_key.ansible.public_key_openssh
}

# Save master key in local machine
resource "local_file" "master_private_key" {
  content         = tls_private_key.master.private_key_openssh
  filename        = "${path.module}/.ssh/master_key"
  file_permission = "0600"
}

resource "local_file" "master_public_key" {
  content         = tls_private_key.master.public_key_openssh
  filename        = "${path.module}/.ssh/master_key.pub"
  file_permission = "0644"
}

# Config NAT jump host -> ssh -F ~/hetzner/infra/.ssh/config cms
resource "local_file" "ssh_config" {
  filename        = "${path.module}/.ssh/config"
  file_permission = "0600"
  content         = <<-EOF
    Host nat
      HostName ${hcloud_server.nat.ipv4_address}
      User root
      Port 22
      IdentityFile ${path.module}/.ssh/master_key

    Host cms
      HostName ${var.cms_private_ip}
      User ansible
      Port 2222
      IdentityFile ${path.module}/.ssh/master_key
      ProxyJump nat
  EOF
}
