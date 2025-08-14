# Google Kubernetes ENgine (GKE) - A complete Practical Guide

    20,5 horas

## Section 1: Architecture

### 1. Introduction




### 2. Kubernetes Architecture

Control Plane

controller Manager
Cloud controller: Habla con la nube.
API Server
etcd
Scheduler


Node
kubelet: Monitoriza los workloads o los pods en un nodo.
kube-proxy: Puerta de enlace de red desde el nodo al mundo exterior.
pod:



### 3. GKE Architecture

cluster privado, cluster publico, autopilot

Regional, zonal

Control plane in Google VPC


GKE Cluster architecture

- Control plane is always managed a VPC networking in a Google managed project
- Connectedto the project VPC via VPC peering
- Private and public endpoint for control plane
- Node management varies depending on Standard or Auto-pilot cluster

Cualquier comunicaicon entre los nodos y el plano de control se producira mediante la conexion privada a traves del VPC peering. (Configurado por Google)



### 4. GKE - Configuration Choices

GKE Cluster - Configuration Choice

Modes of Operation: Standar | Autopilot
Network Visibility: Public | Private
Availability: Regional | Zonal (Single Zone | Multi Zone)

El Cluster publico tiene casos muy limitados de uso.

Zonal vs Regional: Si la zona se cae por un problema de red o de disco, el workload de una sola zona se veria afectada.

En GCP todas las regiones tienen al menos tres o mas zonas. Cuando se divide la carga de tabajo entre varias zonas. Asi, la misma aplicación tendrá una instancia ejecutandose en diferentes zonas. Se tendran mas opciones disponibilidad.

Ahora bien, existe una diferencia entre un cluster regiona, que en cierto modo es un cluster multizona, y un cluster multicanal, que forma parte de un cluster zonal. 


### 5. Standard vs Autopilot



### 6. GCP Public vs Private VMs



### 7.  GKE Private Cluster




### 8. GKE Public Cluster



### 9. Standard vs Enterprise Tier Cluster



### 10. GKE Availability Choices



## Section 2: Cluster Creation & Access



### 11. Section Introduction

In this section we will discuss about creating a standard cluster as well as creating an autopilot cluster and line by line will understand all the aspects of your cluster creation. And then we will learn all the different ways how you can connect to the cluster from your cloud shell, from your same network like from a VM or Compute Engine in GCP, or from your home network from your laptop. So we will cover everything in this section. So let us get started. Thank you.


### 12. Note on New GKE Screen Options

This video is recorded in a later point of time, not originally when the course was created. That is because GCP has introduced a few extra features in the GKE screen. Also, the menu options to create a cluster has also changed. You might see there are a few extra options over here in the left side menu as well. So let us go and see one major difference. So when you now go and create a Kubernetes cluster, you will see this screen. However the videos those are recorded for creating the cluster, they come under the previous menu structure. So you might see the options of creating the cluster a bit different than how you are seeing now. However, the choices that you see here, they are exactly the same, just that they come under different menu sections. So they have kind of simplified the cluster creation screen. Now though, the options are more or less the same. And one major difference is that you might not see this option of choosing between a standard and enterprise tier cluster while creating the cluster. So those are not there in the upcoming videos for creating a cluster. So we are working on this and very soon we will upload new lectures on the new menu screen. However, for now we have those old screens or old videos with the old screen design. So that is something we will just keep in mind. And also we will rerecord few things just to make sure that we are up to date with the guys screen. Thank you.


### 13.Creating a Standard Cluster - Part 1

So in this lecture we will create a standard cluster in GKE. So before that so this is the Google Cloud Console from where we can create a cluster. Now there are two ways you can create a cluster. Either you can go to the cloud shell. And then you run the gcloud container command to create a cluster. Or you can do it from the UI or the console. So for better understanding of different elements of a cluster, we will create a cluster from the UI. So I am assuming you are aware of the basic traversing and the menu structure of Google Cloud Console. So to create a cluster you have to go to the Kubernetes page. So what you can do, you can search in the Kubernetes in the search bar for Kubernetes or else from the burger menu you can select Kubernetes cluster or the engine. It will take you to the Gujaratis home page. Now you might see a different screen here, so not entirely different. However, you might not see something called the split or enterprise. That is because for me the enterprise GCC version is enabled. So what is enterprise GCC? We'll discuss that later in this course, but for now you can ignore it. So you might just see, uh, a Kubernetes engine heading over here and then these menus. So it doesn't make any difference whether you are seeing this menu or the other one. So what we will do, we'll go to straight away to the cluster menu. So select here cluster. And then this will give you a menu option to create a cluster. So you can create it from here, or you can create it from here. So when I press the create button, you will see that Google is suggesting you to create a auto pilot cluster. So we discussed what is Autopilot and standard or else you you might see a different screen where it will straight away ask you to give the cluster name. And it will assume that you are interested in creating a autopilot cluster. However, for this demo, we are creating a standard cluster, so we will go with standard. So I'll choose configure a standard cluster. So if you don't see this screen, you'll see a screen where you will see a option to switch to standard cluster like just like this. So it says switch to auto pilot cluster. In this place you will see option that will say switch to standard cluster. So create a standard cluster. You can just press that button. However we are in the standard cluster screen. So we will continue with our standard cluster creation. So the right side you will see the price. We will discuss price a little later. In the left side we will see the different options to create or choose different features of GK. In the center you will have your values or the fields where you will enter your values. So first thing you have to name the cluster. So let us keep it. Default cluster one whatever GCP suggesting and then location. So this is something we discussed in one of our previous lecture. So you can create a zonal cluster or a regional cluster. So we discussed when we select a regional cluster you have to select a region. So by default it suggests us central one. You can choose any region you want I'll keep with the default. And then the region might have multiple will have multiple zones. It might have three zones or more four. So you can specify how many zones you want to use. So if you click on this checkbox it will give you a option to choose the zones where you want to put your workloads. So by default you can choose one zone. But that does not make any sense because that is as good as using a zonal cluster. So you can choose one, two, three, four, or you can just choose as many you want. So let us go with two zones for this example. And if you want to go with the zonal cluster. So before that, just to recap, I am choosing two zones. So my control plane will be in both the zones along with the worker node. Now if I choose a zonal cluster you have to choose a zone, not a region. So your central has got four zones so you can choose any of them. Now. By default this might be unchecked. So we'll just go with this particular zone. Or else if you want to go for a multi zone cluster which we again discussed, then you can select other than the default zone the one you have selected here. So in this case you Central1 B you can choose another zone or multiple zones from this checkbox. Now the difference is the default zone will host your control plane. However, you will have your worker nodes in all the other selected zones. So in this case A, B, C zone will have worker nodes, all the three zones and only. June we will have the control plan. So if zone B goes down, you will lose your control plane or access to your Kubernetes cluster. However, your workload will still run because your zone A and C are still hosting your workload. So this is the region and zone selection. So let us go with the regional cluster and with two zones. So let me uncheck this one then. We have release channel. Now this is very important because Kubernetes itself has a release channel. So it has alpha version, beta version then releases the stable version. And then again Kubernetes supports two previous versions along with the current version. So you have to keep updating your upgrade so that you are always in a supported version. The Google will make sure you are always in a supported version, irrespective of the release channel you choose, or the type of cluster that you choose, standard or autopilot. However, you have a flexibility to choose the release channel how you want to go. This is G how you want to upgrade your cluster with respect to Kubernetes releases. So there are four options. Option for no, not no channel. We are not going there. I don't see any reason when you want to use it. So we'll just discuss the first three options. Rapid channel. Rapid channel is something where you will. We want to use all the new features which is recently launched, not tested well. However, these are the features that you might want to use in your application. Say, suppose you want you can come across that Kubernetes is releasing a new feature or a new element that will be useful for you. So you might go for the Rapid channel. So this is useful for development purpose for POC purpose, but not beyond that. Then you have regular channel which is the recommended one. Regular channel is always a stable version of Kubernetes and it is something which is recently made stable. Say recently we had Kubernetes version 1.29. So if you see here we have 1.29 and the patch version is one. Right. So this this may not be the latest stable version. So when you choose a regular channel, it will always give you the latest general availability version of Kubernetes. And then you can choose the version which version you want to go for. So if you see here version 1.27 to 1.29, so recent is 1.29 and two previous version 1.28 and 1.27 listed. So if you go with 1.27 very soon, you will have to upgrade to 1.28, and then you might have to upgrade to 1.29 when you get 1.30 release. So you might want to choose a newer version. But again this 1.2 net may not be very stable with respect to usage. So that is where you have this stable channel option comes. So when you choose a stable channel you won't see 1.29 here because as per Google, the documentation says stable channel is something where something is used and proven to be efficient. So now 1.29 is still a relatively new, newer release. So Google doesn't treat it as a stable channel, though it is a general availability channel, a release from Kubernetes. However. Still, Google doesn't treat this as a regular, sorry, stable channel, so it gives you option to select 1.27 or the different versions of 1.28. However, if you go to the repeat channel, you will see you only getting 1.29 because these are the only recent releases. So these are the just been released just recently. And you want to go for this channel or this release. So these are the options that you get. So we'll go go with the recommended one regular channel. And then you choose the version which version you want to go with. So I'll go with the stable version 1.27. So this is the first update. Cluster creation. So we'll take a patch in this video. In the next video, we'll continue with the remaining of the options.


### 14. Creating a Standard Cluster - Part 2




### 15. Creating a Standard Cluster - Part 3



### 16. Public/Private Node - New Option




### 17. Creating A Autopilot Cluster



### 18. Accessing the Cluster - Options



### 19. Accessing the Cluster from Laptop



### 20. Accessing the CLuster - From Cloud Shell



### 21. Accesing the Cluster - From Compute Instance



## Section 3: Deploying and Exposing App


## 22. Section Introduction


