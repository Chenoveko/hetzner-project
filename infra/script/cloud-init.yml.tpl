#cloud-config

users:
  - name: ansible
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: "$6$kmOnMk2fKWTrQgrd$fAN.celI2/ofFrEiCCt5WEQb0DENALCsD3fF3h7yW9SKRaP29Q06B3/EEe4fqZbuLmxL4Vqs/2Vt6RKcZpcS6."
    ssh_authorized_keys:
      - ${ansible_public_key}

timezone: Europe/Madrid
locale: es_ES.UTF-8

write_files:
  - path: /etc/systemd/network/10-hetzner-private.network
    permissions: '0644'
    owner: root:root
    content: |
      [Match]
      Name=enp7s0

      [Network]
      DHCP=yes

      [Route]
      Gateway=${network_gateway_ip}
      Destination=0.0.0.0/0
  
  - path: /etc/systemd/resolved.conf
    content: |
      [Resolve]
      DNS=185.12.64.2 185.12.64.1
      FallbackDNS=8.8.8.8
    append: true

  - path: /etc/ssh/sshd_config.d/ssh-hardening.conf
    permissions: '0640'
    owner: root:root
    content: |
      PermitRootLogin no
      PasswordAuthentication no
      Port 2222
      KbdInteractiveAuthentication no
      ChallengeResponseAuthentication no
      MaxAuthTries 2
      AllowTcpForwarding no
      X11Forwarding no
      AllowAgentForwarding no
      AuthorizedKeysFile .ssh/authorized_keys
      AllowUsers ansible

runcmd:
  # 1) Add default route
  - ip route add default via 10.42.0.1 dev enp7s0 || true
  # 2) DNS
  - systemctl restart systemd-resolved
  # 3) Hardening
  - printf "[sshd]\nenabled = true\nport = ssh, 2222\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
  - systemctl enable fail2ban
  - ufw allow 2222
  - ufw enable
  # 4) Restart SSH server
  - systemctl restart ssh
