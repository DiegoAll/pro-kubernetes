terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  zone    = var.zone
}

# ---------------------------
# Variables
# ---------------------------

variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
  default     = "project-f50a094d-d02b-40c5-b0d"
}

variable "zone" {
  description = "Zona donde se despliega el cluster (zonal, no regional -> cubierto por el free tier de GKE)"
  type        = string
  default     = "us-east1-b"
}

variable "cluster_name" {
  description = "Nombre del cluster GKE"
  type        = string
  default     = "diego-cluster"
}

variable "machine_type" {
  description = "Tipo de máquina para los nodos"
  type        = string
  default     = "e2-small"
}

variable "num_nodes" {
  description = "Número de nodos del cluster"
  type        = number
  default     = 3
}

variable "disk_size_gb" {
  description = "Tamaño del disco de arranque por nodo (GB)"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Tipo de disco de arranque"
  type        = string
  default     = "pd-standard"
}

# ---------------------------
# Cluster (sin node pool por defecto)
# ---------------------------

resource "google_container_cluster" "diego_cluster" {
  name     = var.cluster_name
  location = var.zone # zonal
  project  = var.project_id

  # Quitamos el node pool default que GKE crea automáticamente,
  # porque vamos a administrar el nuestro explícitamente abajo.
  remove_default_node_pool = true
  initial_node_count       = 1 # requerido por el provider aunque se borre enseguida

  release_channel {
    channel = "REGULAR" # default de GKE
  }
}

# ---------------------------
# Node pool (equivalente exacto al comando gcloud)
# ---------------------------

resource "google_container_node_pool" "default_pool" {
  name     = "default-pool"
  cluster  = google_container_cluster.diego_cluster.name
  location = var.zone
  project  = var.project_id
  node_count = var.num_nodes

  management {
    auto_repair  = true  # default de GKE
    auto_upgrade = false # equivalente a --no-enable-autoupgrade
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type
    image_type   = "COS_CONTAINERD" # default de GKE
    spot         = true             # equivalente a --spot

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

# ---------------------------
# Outputs
# ---------------------------

output "cluster_name" {
  value = google_container_cluster.diego_cluster.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.diego_cluster.endpoint
  sensitive = true
}

output "get_credentials_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.diego_cluster.name} --zone=${var.zone} --project=${var.project_id}"
}