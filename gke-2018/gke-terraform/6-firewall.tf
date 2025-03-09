# The nex resource is a firewall, We dont need to create any firewalls manually for GKE, it's just to give you an example.
# This firewall will allow sshing to the compute instances within VPC. The name is 



resource "google_compute_firewall" "allow-ssh"{

    
}