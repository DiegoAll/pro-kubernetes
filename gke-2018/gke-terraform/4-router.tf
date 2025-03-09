# For example, Kubernetes nodes will be able to pull docker images from the dockerhub. Give it a name router. Then the region, us-central1,
# is the same region where ew created the subnet. Then the reference to the VPC, where you want to place this router 
# Now lets create CloudNAT

resource "google_compute_router" "router" {
    name = "router"
    region = "us-central1"
    network = google_compute_network.main.id
  
}