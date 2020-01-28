variable "gcloud_project" {
  description = "Google Cloud Project where resources will be created"
  default = "perform-vegas-hd-2020"
}

variable "gcloud_zone" {
  description = "Google Cloud Zone where resources will be created"
}

variable "name_prefix" {
  description = "Prefix to distinguish resources created for multiple, simultaneous labs; should include shortened location and month (e.g., det-nov)"
}

variable "bastion_size" {
  description = "Size (machine type) of the bastion instance"
  default     = "n1-standard-4"
}

variable "bastion_user" {
  description = "Initial user when bastion is created"
  default     = "dynatrace"
}

variable "ssh_keys" {
  description = "Paths to public and private SSH keys for bastion user"
  default     = {
    private = "./key"
    public  = "./key.pub"
  }
}

variable "hub_release" {
  description = "Release/version of hub command-line tool"
  default     = "2.14.1"
}

variable "keptn_release" {
  description = "Release/version of keptn"
  default     = "0.6.0"
}

variable "cluster_version_prefix" {
  description = "String prefix that matches appropriate GKE-specific K8s version"
  default     = "1.12."
}

variable "number_of_users" {
  description = "Number of users participating in the ACL"
  default     = 2
}

variable "attendee_user" {
  description = "Root username created for each attendee/participant"
  default     = "hotuser"
}

variable "attendee_password" {
  description = "Standard password for users on the bastion host"
  default     = "dynatraceperform"
}

variable "cluster_name" {
  description = "Root name given to GKE clusters"
  default     = "hot-acintro"
}

variable "cluster_node_count" {
  description = "Number of nodes in GKE cluster default node pool"
  default     = 1
}

variable "cluster_username" {
  description = "Username for K8s basic authentication"
  default     = "admin"
}

variable "cluster_node_config" {
  description = "Parameters for creating GKE cluster default node pool"
  default     = {
    size      = "n1-standard-8"
    image     = "UBUNTU"
    disk_type = "pd-ssd"
    disk_size = 100
  }
}
