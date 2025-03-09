# Finally, we got to Kubernetes resource. First we need to configure the control plane of the cluster itself. Primary will be cluster name. 
# Now for location, you can either select s rgiopn or an availability zone.

# If you choose a region, GKE will create a highly available cluster for you multiple availability zones of that region. 
# No doubt that it is a prefered setup, but it will cost you more money. If you are a budget ssensitive, you may want to select a zonal cluster 
# and deploy your kubernetes nodes in different availability zones. If you go with that approach, as we will in this video, if something 
# happens with your control plane, all your applications will continue running with interruptions. You only won't beable to acccess the 
# master itself, for example, deploy a new application or a service. But I would highly recommend choosing at least two availability zones from
# Kubernetes nodes. In my experience , availability zones go down often. This cluster will have a single NOT higly available control plane 
# in the us-central-a zone. 

# Then choose to destroy the default node pool since we will create additional instance groups for the Kuberntes cluster. Initial node cont does 
# not matter since it will be destroyed anyway. Provide a link to the main VPC and subnet. In this case, it's a private subnet. Noe be very careful
# with services that you enable for kubernetes. Obviously, you want logging for your applications.


# This option will deploy a fluent bit agent on each node and scrape all the logs that your application period of time in one of my enviroments, 
# the cost of logging exceeded the cost of infraestructure.  

# Because the developer enabled debug logs. Be very careful and constantly monitor the cost. Next is monitoring; the same thing here it's not free. 


# If you plan to deploy Prometheus, you may want to disable it. All cloud providers will try to sell you as many managed services as possible, which
# are very easily scalable and convenient. But It may lead to a huge bill at the end of the month. 
# The networking mode is VPC_NATIVE. Available options are VPC_NATIVE or ROUTES. VPC-native clusters have several benefits; you can about them here.
# As I mentioned before, if we create a zonal cluster, we want to add at least one availability zone.  We already have us-central1-a zone; let's add b zone. 
# There are many different addons you can enable and disable. For example, you can depploy istio service mesh or disable http_load_balancing if you're
# planing to use nginx ingress or plain load balancers to expose your service from kubernetes.

# Later I will deploy the nginx ingress controlle anyway, so let's disable this addon. The second is horizontal pod autoscaling; I want to keep this 
# addon enabled. The release channel will manage your kuiberntes cluster upgrades. Keep in mind that you never be able to completely disable upgrades for 
# the kubernetes control plane.  However, you can disable it for nodes.

# Then I want to enable workload identity. You can substitute this with variables and data and data objects. 
# You need to replace devops-v4 with your project ID. Under the ip allocation policy, you need to enable private nodes. This will only use private IP addreess 
# from our private subnet for Kubernetes nodes. Next is a private endpoint. 

# If you have a VPN setup or you use bastion host to connect to the Kubernetes cluster, set this option to true, ptherwise keep it false to be able
# to access GKE from your computer. You would also need to provie a CIDR range for the control plane. SInce it's managed by Google, they will create a control 
# plane in their network and establish a pering connection to your VPC.

# Optionally you can specify the CIDR ranges which can access the Kubernetes cluster. The typical use case is to enable Jenkins to access your GKE. 
# If you skip this, anyone can access your control plane endpoint. 
# Before we can create node groups for kubernetes, if we want to follow best practices, we need to created a dedicated service account. 




resource  "google_container_cluster" "primary" {

    name = "primary"
    location = "us-central1-a"
    remove_default_node_pool = true
    initial_node_count = 1
    network  = google_compute_network.main-self_link
    subnetwork = google_compute_subnetwork.private.self_link
    logging_service = "logging.googleapis.com/kubernetes"
    monitoring_service = "monitoring_googleapis.com/kubernetes"
    networking_mode = "VPC_NATIVE"


    # Optional, if you want multi-zonal 
    node_locations = [
        "us-central1-b"
    ]


    addons_config {
        http_load_balancing {
            disabled = true
        }
        horizontal_pod_autoscaling {
          disabled = false
        }
    }

    release_channel {
        channel = "REGULAR"
    }

    workload_identity_config{
        workload_pool = "devops-v4.svc.id.goog"
    }

    ip_allocation_policy{
        cluster_secondary_range_name = "k8s-pod-range"
        services_secondary_range_name = "k8s-service-range"
    }

    private_cluster_config{
        enable_private_nodes = true 
        enable_private_endpoint = false 
        master_ipv4_cidr_block = "172.16.0.0/28"           
    }

    # # Jenkins use case
    # master_authorized_networks_config {
    #     cidr_blocks {
    #         cidr_block = "10.0.0.0/18"
    #         display_name = "private-subnet-w-jenkins"
    #     }
    # }


}
