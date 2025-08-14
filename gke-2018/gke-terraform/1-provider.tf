# https://www.youtube.com/watch?v=X_IK0GBbBTw
# How to Create GKE Cluster Using TERRAFORM? (Google Kubernetes Engine & Workload Identity)

# https://antonputra.com/GCP/gke/


provider "google" {
    project = "devops-v4"
    region= "us-central1"
}


terraform{
    backend "gcs"{
        bucket = "antonputra-tf-state-staging"
        prefix = "terraform/state"
    }
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 4.0"
        }
    }
}

# VPC
# subnet
# bucket? separete terraform workspaces by environment yo reduce risk. Will be used to manage infrasstructure in the staging enviroment. Multiregion



