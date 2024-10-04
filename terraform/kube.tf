module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }

  hcloud_token = var.hcloud_token

  source = "kube-hetzner/kube-hetzner/hcloud"

  ssh_public_key = file("~/.ssh/id_ed25519.pub")
  ssh_private_key = file("~/.ssh/id_ed25519")

  network_region = "eu-central" # change to `us-east` if location is ash

  control_plane_nodepools = [
    {
      name        = "control-plane-fsn1",
      server_type = "cx22",
      location    = "fsn1",
      labels = [],
      taints = [],
      count       = 1
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-small",
      server_type = "cx22",
      location    = "fsn1",
      labels = [],
      taints = [],
      count       = 1
    }
  ]

  microos_arm_snapshot_id = "191091760"
  microos_x86_snapshot_id = "191091671"

#   load_balancer_type     = "lb11"
#   load_balancer_location = "fsn1"

  ingress_controller = "nginx"

  automatically_upgrade_k3s = false
  automatically_upgrade_os = false

  extra_firewall_rules = [
    {
      description = "To Allow ArgoCD access to resources via SSH"
      direction   = "out"
      protocol    = "tcp"
      port        = "22"
      source_ips = [] # Won't be used for this rule
      destination_ips = ["0.0.0.0/0", "::/0"]
    }
  ]

  dns_servers = [
    "1.1.1.1",
    "8.8.8.8",
    "2606:4700:4700::1111",
  ]

  enable_rancher = true
  enable_klipper_metal_lb = true

  create_kubeconfig = true
  export_values     = true
}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig
  sensitive = true
}