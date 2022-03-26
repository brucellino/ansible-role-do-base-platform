# Create test instance on digital ocean in AMS3
terraform {
  required_version = ">= 1.1.0"
  # require vault and digital ocean providers
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.18.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.4.0"
    }
  }
  backend "consul" {
    path = "do/test/ansible-role-do-base-platform"
  }
}

data "vault_generic_secret" "do_token" {
  path = "digitalocean/tokens"
}

provider "digitalocean" {
  token = data.vault_generic_secret.do_token.data["terraform"]
}

data "digitalocean_vpc" "vpc" {
  name = "terraform-vpc-hah"
}

data "digitalocean_ssh_key" "test_instances" {
  name = "test-instances"

}

data "digitalocean_image" "base_image" {
  slug = "ubuntu-21-10-x64"
}

resource "digitalocean_droplet" "test" {
  name          = format("ansible-role-do-base-platform-test-instance-%s", formatdate("YYYY-MM-DD-hh-mm-ss", timestamp()))
  image         = data.digitalocean_image.base_image.id
  size          = "s-1vcpu-1gb"
  vpc_uuid      = data.digitalocean_vpc.vpc.id
  region        = "ams3"
  tags          = ["ansible-role-do-base-platform-test"]
  backups       = false
  monitoring    = false
  droplet_agent = true
  ssh_keys      = [data.digitalocean_ssh_key.test_instances.id]

}

output "droplet_output" {
  value = digitalocean_droplet.test.ipv4_address
}
