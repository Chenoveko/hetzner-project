#cloud-config

users:
  - name: ansible
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: "$6$kmOnMk2fKWTrQgrd$fAN.celI2/ofFrEiCCt5WEQb0DENALCsD3fF3h7yW9SKRaP29Q06B3/EEe4fqZbuLmxL4Vqs/2Vt6RKcZpcS6."
    ssh_authorized_keys:
      - ${master_public_key}

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

  - path: /tmp/ansible_key.b64
    permissions: '0600'
    owner: root:root
    content: ${base64encode(ansible_private_key)}
  
  - path: /tmp/ansible_key.pub
    permissions: '0644'
    owner: root:root
    content: ${ansible_public_key}

runcmd:
  # 1) Add default route
  - ip route add default via 10.42.0.1 dev enp7s0 || true
  # 2) DNS
  - systemctl restart systemd-resolved
  # 3) Set up SSH keys
  - mkdir -p /home/ansible/.ssh
  - chmod 700 /home/ansible/.ssh
  - base64 -d /tmp/ansible_key.b64 > /home/ansible/.ssh/ansible_key
  - mv /tmp/ansible_key.pub /home/ansible/.ssh/ansible_key.pub   # ← ESTO FALTABA
  - chmod 600 /home/ansible/.ssh/ansible_key
  - chmod 644 /home/ansible/.ssh/ansible_key.pub
  - chown -R ansible:ansible /home/ansible/.ssh
  - rm -f /tmp/ansible_key.b64
  # 4) Update and install packages
  - apt-get update && apt-get install -y git python3 fail2ban ufw pipx python3-kubernetes
  - chown -R ansible:ansible /home/ansible/
  - su - ansible -c "pipx install --include-deps ansible"
  - su - ansible -c "pipx ensurepath"
  # 5) Hardening
  - printf "[sshd]\nenabled = true\nport = ssh, 2222\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
  - systemctl enable fail2ban
  - ufw allow 2222
  - ufw enable
  # 6) Restart SSH server
  - systemctl restart ssh
  # 7) Clone project
  - git clone https://github.com/Chenoveko/hetzner-project.git /home/ansible/project
  - chown -R ansible:ansible /home/ansible/project
