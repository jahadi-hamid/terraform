terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "ubuntu-kube" {
  name = "ubuntu-k8s"
  type = "dir"
  path = "/home/h.jahadi/tmp-terraform-pool-ubuntu"

}


resource "libvirt_volume" "ubuntu_qvol" {
  name   = "ubuntu_qvol"
  pool   = libvirt_pool.ubuntu-kube.name
  source = "/home/h.jahadi/images/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  format = "qcow2"
}

data "template_file" "user_data" {
    template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config"{
    template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.ubuntu-kube.name
}

resource "libvirt_domain" "k8s" {
    name = "ubuntu-k8s-01"
    memory = "2048"
    vcpu = 2

    cloudinit = libvirt_cloudinit_disk.commoninit.id

    network_interface {
      network_name = "NAT"
    }

    console {
        type = "pty"
        target_port = "0"
        target_type = "serial"
    }
    console {
        type        = "pty"
        target_type = "virtio"
        target_port = "1"
    }
    disk {
        volume_id = libvirt_volume.ubuntu_qvol.id
    }
    graphics {
        type        = "spice"
        listen_type = "address"
        autoport    = true
    }
}    

terraform {
  required_version = ">= 0.12"
}