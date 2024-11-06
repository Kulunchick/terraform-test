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

resource "hcloud_server" "server" {
  name        = "server-${count.index}"
  server_type = "cx22"
  image       = "ubuntu-20.04"
  location    = "fsn1"
  count       = 1

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.${100 + count.index}"
  }

  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
}

resource "hcloud_server" "small-agent" {
  name        = "small-agent-${count.index}"
  server_type = "cx22"
  image       = "ubuntu-20.04"
  location    = "fsn1"
  count       = 1

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.network.id
  }

  depends_on = [
    hcloud_network_subnet.network-subnet
  ]
}

resource "ansible_group" "k3s_cluster" {
  name     = "k3s_cluster"
  children = ["server", "agent"]
  variables = {
    ansible_user                 = "root",
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519",
    k3s_version                  = "v1.30.6+k3s1",
    token                        = "changeme!",
    extra_server_args            = "--prefer-bundled-bin",
    extra_agent_args             = "",
    api_endpoint                 = hcloud_server.server[0].ipv4_address,
    UserKnownHostsFile           = "/dev/null",
    StrictHostKeyChecking        = "no",
    ansible_python_interpreter   = "/usr/bin/python3"
  }
}

resource "ansible_host" "server" {
  for_each = {
    for idx, server in hcloud_server.server :
    idx => { ipv4_address : server.ipv4_address }
  }

  name   = each.value.ipv4_address
  groups = ["server"]

  depends_on = [
    hcloud_server.server
  ]
}

resource "ansible_host" "worker" {
  for_each = {
    for idx, worker in hcloud_server.small-agent :
    idx => { ipv4_address : worker.ipv4_address }
  }

  name   = each.value.ipv4_address
  groups = ["agent"]

  depends_on = [
    hcloud_server.small-agent
  ]
}
