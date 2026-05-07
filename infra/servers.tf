############################
#           CMS            #
############################

resource "hcloud_server" "cms" {
  name         = "${var.project_name}-cms"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.master_key.id]
  firewall_ids = [hcloud_firewall.app.id]

  network {
    network_id = hcloud_network.main.id
    ip         = var.cms_private_ip
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/cms-cloud-init.yml.tpl", {
    master_public_key   = tls_private_key.master.public_key_openssh
    ansible_private_key = tls_private_key.ansible.private_key_openssh
    ansible_public_key  = tls_private_key.ansible.public_key_openssh
    network_gateway_ip  = var.network_gateway_ip
  })

  depends_on = [hcloud_network_subnet.private]
}

############################
#        kubeadmin         #
############################

/*
resource "hcloud_server" "kubeadmin" {
  name         = "${var.project_name}-kubeadmin"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.master_key.id]
  firewall_ids = [hcloud_firewall.app.id]

  network {
    network_id = hcloud_network.main.id
    ip         = var.kubeadmin_private_ip
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/cloud-init.yml.tpl", {
    ansible_public_key  = tls_private_key.ansible.public_key_openssh
    network_gateway_ip  = var.network_gateway_ip
  })

  depends_on = [hcloud_network_subnet.private]
}
*/

############################
#      Cluster 1 k3s       #
############################
/*
resource "hcloud_server" "controlplanes-clt-1" {
  for_each = var.controlplanes_clt_1_private_ip

  name         = "${var.project_name}-${each.key}"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  firewall_ids = [hcloud_firewall.nat.id]

  network {
    network_id = hcloud_network.main.id
    ip         = each.value.private_ip
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/cloud-init.yml.tpl", {
    ansible_public_key  = tls_private_key.ansible.public_key_openssh  
    network_gateway_ip = var.network_gateway_ip
  })

  depends_on = [hcloud_network_subnet.private]
}

resource "hcloud_server" "workers-clt-1" {
  for_each = var.workers_clt_1_private_ip

  name         = "${var.project_name}-${each.key}"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  firewall_ids = [hcloud_firewall.nat.id]

  network {
    network_id = hcloud_network.main.id
    ip         = each.value.private_ip
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/cloud-init.yml.tpl", {
    ansible_public_key  = tls_private_key.ansible.public_key_openssh
    network_gateway_ip  = var.network_gateway_ip
  })

  depends_on = [hcloud_network_subnet.private]
}

############################
#      Cluster 2 k3s       #
############################

/*
resource "hcloud_server" "controlplanes-clt-2" {
  for_each = var.controlplanes_clt_2_private_ip

  name         = "${var.project_name}-${each.key}"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  firewall_ids = [hcloud_firewall.nat.id]

  network {
    network_id = hcloud_network.main.id
    ip         = each.value.private_ip
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/cloud-init.yml.tpl", {
    ansible_public_key  = tls_private_key.ansible.public_key_openssh
    network_gateway_ip = var.network_gateway_ip
  })

  depends_on = [hcloud_network_subnet.private]
}

resource "hcloud_server" "workers-clt-2" {
  for_each = var.workers_clt_2_private_ip

  name         = "${var.project_name}-${each.key}"
  server_type  = var.server_type
  image        = var.server_image
  location     = var.location
  firewall_ids = [hcloud_firewall.nat.id]

  network {
    network_id = hcloud_network.main.id
    ip         = each.value.private_ip
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  user_data = templatefile("${path.module}/script/cloud-init.yml.tpl", {
    ansible_public_key  = tls_private_key.ansible.public_key_openssh
    network_gateway_ip  = var.network_gateway_ip
  })

  depends_on = [hcloud_network_subnet.private]
}
*/
