resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "network-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_ssh_key" "default" {
  name       = "Public SSH Key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "hcloud_server" "control-plane" {
  name        = "control-plane"
  server_type = "cx22"

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.0"

    depends_on = [
      hcloud_network_subnet.network-subnet
    ]
  }
}

resource "hcloud_server" "worker-node" {
  name        = "worker-node-${count.index}"
  server_type = "cx22"
  count = 1

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.network.id

    depends_on = [
      hcloud_network_subnet.network-subnet
    ]
  }
}