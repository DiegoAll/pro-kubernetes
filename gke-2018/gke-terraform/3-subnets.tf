


resource "google_compute_subnetwork" "private" {
    name = "private"
    ip_cidr_range = "10.0.0.0/18"
    region = "us-central1"
    network = google_compute_network.main.id
    private_ip_google_access = true

    secondary_ip_range {
        range_name = "k8s-pod-range"
        ip_cidr_range = "10.48.0.0/14"
    }



}


# VPC en Google cloud is a global concept


# Private subnet to place KUbernetes nodes
# The kubernetes control plane is manged by Google

# In AWS VPC belongs to a scpecifc region

# Kubernets nodes will use IPs from the main CIDR rang, butthe Kubernetes pods will use IPs from the secondary ranges.
# In case you need to open a firewall to access other VMs in your VPC from Kubernetes you would need to use this secondary ip range 
# as a source and optionally service account of the Kuberntes nodes. Each secondary OP range has a name associated with it which
# we will use in the GKE configuration. The second secondary range will be used to asign IP addresses for clusterIPS in Kuberntes. When 
# yo create a regular service in Kubernetes, an IP  address will be taken from that range. 
# NExt, we need to create Cloud Router to advertise routes. It will be used with the NAT gateway to allow  VMs without public IP address to access the Internet.

