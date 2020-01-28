## Bastion requires public IP address
resource "google_compute_address" "bastion" {
  name       = "${var.name_prefix}-bastion-ipv4-addr-${random_id.uuid.hex}"
}

## Allow access to bastion via HTTPS
resource "google_compute_firewall" "bastion" {
  name        = "${var.name_prefix}-allow-https-${random_id.uuid.hex}"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = [ "443" ]
  }

  target_tags = [ "${var.name_prefix}-bastion-${random_id.uuid.hex}" ]
}

## Create bastion host
resource "google_compute_instance" "bastion" {
  name         = "${var.name_prefix}-bastion-${random_id.uuid.hex}"
  machine_type = var.bastion_size
  zone         = var.gcloud_zone
  depends_on   = [
    google_container_cluster.perform,
    local_file.perform_user_key
  ]

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-1804-lts"
      size  = "40"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.bastion.address
    }
  }

  metadata = {
    sshKeys = "${var.bastion_user}:${file(var.ssh_keys["public"])}"
  }

  tags = [ "${var.name_prefix}-bastion-${random_id.uuid.hex}" ]

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    user        = var.bastion_user
    private_key = file(var.ssh_keys["private"])
  }

  provisioner "remote-exec" {
    inline = [ "sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y" ]
  }

  provisioner "file" {
    destination = "~/provision_bastion.sh"
    content     = templatefile(
      "${path.module}/templates/provision_bastion.sh.tmpl",
      {
        hub_release       = var.hub_release,
        keptn_release     = var.keptn_release
        public_ip         = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod a+x ~/provision_bastion.sh",
      "sudo ~/provision_bastion.sh"
    ]
  }

  ## Install shellinabox and secure with apache
  provisioner "file" {
    source      = "${path.module}/files/ssl-params.conf"
    destination = "~/ssl-params.conf"
  }

  provisioner "file" {
    destination = "~/default-ssl.conf"
    content     = templatefile(
      "${path.module}/templates/default-ssl.conf.tmpl",
      {
        PUBLIC_IP = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
      }
    )
  }

  provisioner "file" {
    destination = "~/000-default.conf"
    content     = templatefile(
      "${path.module}/templates/000-default.conf.tmpl",
      {
        PUBLIC_IP = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
      }
    )
  }

  provisioner "file" {
    source      = "${path.module}/files/shellinabox"
    destination = "~/shellinabox"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv ~/ssl-params.conf /etc/apache2/conf-available/",
      "sudo mv ~/default-ssl.conf ~/000-default.conf /etc/apache2/sites-available/",
      "sudo chown -R root:root /etc/apache2/",
      "sudo mv ~/shellinabox /etc/default/",
      "sudo chown -R root:root /etc/default/"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_shellinabox.sh"
    destination = "~/install_shellinabox.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod a+x ~/install_shellinabox.sh",
      "sudo ~/install_shellinabox.sh"
    ]
  }

  ## Create users and enable access to corresponding GKE clusters
  provisioner "file" {
    source      = "./gcloud-keys"
    destination = "~/"
  }

  provisioner "file" {
    destination = "~/create_users.sh"
    content     = templatefile(
      "${path.module}/templates/create_users.sh.tmpl",
      {
        num     = var.number_of_users
        name    = var.attendee_user
        prefix  = var.name_prefix
        uuid    = random_id.uuid.hex
        pass    = var.attendee_password
        cluster = var.cluster_name
        zone    = var.gcloud_zone
        project = var.gcloud_project
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod a+x ~/create_users.sh",
      "sudo ~/create_users.sh"
    ]
  }
}
