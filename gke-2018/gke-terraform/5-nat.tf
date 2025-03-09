# Give it a name and reference to the CLoud Router. Then the region us-central1.
# YOu can decide to advertise this CLoudNAT to all subnets in that VPC, or you can select specific ones. In this example, I will choose 
# th private subnet only. The next option is very important, specially if you have external clients. You can let google to allocate 
# and assing and IP address for your NAT, or you can choose to manage yourself. In case you have a weebhook and a client that need to whitelist
# your public IP address (allow your IP adrees to access their network by opening up a firewall), that's the only way to go. Then the list of 
# subnetworks to advertise the NAT. The first one is for the private subnet. You can also choose to advsertise to only the main CIDR 
# range or both, including secondary IP ranges. Since we will allocate External IP address ourserlves, we need to provide them in the nat_ips field.
# You can allocate more than one IP adress for NAT.
# The following resource is to allocate IP. Give it a name and a type External. Also, you ned tto select the network_tier. It can be premium or a standard.
# Since we create VPC from scratch , we need to make sure that compute API is enabled before allocating IP.

resource "google_compute_router_nat" "nat" {
    name = "nat"
    router = google_compute_router.router.name
    region = "us-central"

    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    nat_ip_allocate_option = "MANUAL_ONLY"


    subnetwork{
        name =  google_compute_subnetwork.private.id
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }

    nat_ips = [google_compute_address.nat.self_link]
}


resource "google_compute_address" "nat"{
    name = "nat"
    address_type = "EXTERNAL"
    network_tier = "PREMIUM"

    depends_on = [google_project_service.compute]
}