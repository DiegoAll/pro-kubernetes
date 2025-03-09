# The nex resource is a firewall, We dont need to create any firewalls manually for GKE, it's just to give you an example.
# This firewall will allow sshing to the compute instances within VPC. The name is allow-ssh . Reference to the main network Ports
# and protocols to allow. For ssh, we need TCP protocol and a standar port 22. For the sourcem we restrict to certain service accounts
# network tags, or we can use CIDR 0.0.0/0 will allow any IP to acesss port 22 on our VMs. 

resource "google_compute_firewall" "allow-ssh"{
name = "allow-ssh"
network = google_compute_network.main.name 


allow{
    protocol = "tcp"
    ports = ["22"]
}

    source_ranges = ["0.0.0.0/0"]
}


