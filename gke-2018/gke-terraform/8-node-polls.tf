# In this tutorial,
# we will create two nodes groups.

# The first one is general without tains to be able to run cluster components such as DNS. Provide a clsuter ID. This node group will not have 
# autoscaling enabled; we need to specify how many nodes we want. For the management allow undo_repair and auto_upgrade . Under node config, 
# we can specify that this node group is not preemptible. Choose a machine type, for example, e2-small. I prefer to  have large instances and 
# a small number of nodes since there are a lot of system components that need to be deployed  on each node, such as fluentbit, nodes exporter, and many others.

# If you have smaller instance, those components will eat a lot of your resources. You can give this node  group a label. Provide a service account 
# and oauth_scope cloud-platform. Google recommends custom services accounts that have cloud-platform scope and permissions granted via IAM Roles.  

# Later we will grant the IAM role to the service account to access GS buckets in our project.  

# Now the second instance group. It will have a few different parameters. Give it a name spot. Then the same cluster-id. Management config will stay 
# the same. But now we have autoscaling. 

# You can define the maximum number of nodes and a maximum number of nodes. Under node config, let's set preemptible equal to true. 
# This will use much cheaper VMs for the Kubernetes nodes, but they can  be taken away by google at any time,and they last up to 24 hours. 
# They are perfect  for some batch jobs and some data pipelines. They can be used with regular applications, but they have have to be able 
# to tolerate if nodes will go down. Give it a label team equal to devops. And most importantly such nodes must have taints to avoid accidental scheduling. 
# In this case, your deployment or pod object must tolerate those taints. Same service account and scope for this node group.
# To run Terraform locally on your computer, you need to configure default application credentials.

# Run gcloud auth application-default login command.

resource "google_service_account" "kubernetes"{
    account_id = "kubernetes"
}


// Ordenada con chatgpt
resource "google_container_node_pool" "general" {
    name = "general"
    cluster = google_container_cluster.primary.id
    node_count = 1

    management{
        auto_repair = true
        auto_upgrade = true
    }

   node_config {
    preemptible = false
    machine_type = "e2-small"

    labels = {
      role = "general"
    } 

    service_account = google_service_account.kubernetes.email
    oauth_scopes = [
           "https://www.googleapis.com/auth/cloud-platform"
    ]
   }
}



resource "google_container_node_pool" "spot" {
    name = "spot"
    cluster = google_container_cluster.primary.id

    management {
        auto_repair = true
        auto_upgrade = true
    }

    autoscaling {
        min_node_count = 0
        max_node_count = 10
    }

  node_config{
        preemptible = true
        machine_type = "e2-small"

        labels = {
            team = "devops"
        }

    taint {
        key = "instance_type"
        value = "spot"
        effect = "NO_SCHEDULE"
    }
  }
}



