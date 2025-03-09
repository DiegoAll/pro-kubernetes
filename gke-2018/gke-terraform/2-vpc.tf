
resource "google_project_service" "compute" {
    service = "compute.googleapis.com"
}

resource "google_project_service" "container"{
        service = "container.googleapis.com"
}

// Create VPC
resource "google_compute_network" "main"{
    name = "main"
    routing_mode = "REGIONAL"  // Regional and global
    auto_create_subnetworks = false
    mtu = 1460
    delete_default_routes_on_create = false

    depends_on = [ 
        google_project_service.compute,
        google_project_service.container 
    ]
}
// En Google Cloud, una VPC en GCP siempre es global, pero las subredes son regionales.
// Para un clúster zonal en GKE, debes crear una VPC global y una subred regional en la misma región




