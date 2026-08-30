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


### 14.Creating a Standard Cluster - Part 1

So in this lecture we will create a standard cluster in GKE. So before that so this is the Google Cloud Console from where we can create a cluster. Now there are two ways you can create a cluster. Either you can go to the cloud shell. And then you run the gcloud container command to create a cluster. Or you can do it from the UI or the console. So for better understanding of different elements of a cluster, we will create a cluster from the UI. So I am assuming you are aware of the basic traversing and the menu structure of Google Cloud Console. So to create a cluster you have to go to the Kubernetes page. So what you can do, you can search in the Kubernetes in the search bar for Kubernetes or else from the burger menu you can select Kubernetes cluster or the engine. It will take you to the Gujaratis home page. Now you might see a different screen here, so not entirely different. However, you might not see something called the split or enterprise. That is because for me the enterprise GCC version is enabled. So what is enterprise GCC? We'll discuss that later in this course, but for now you can ignore it. So you might just see, uh, a Kubernetes engine heading over here and then these menus. So it doesn't make any difference whether you are seeing this menu or the other one. So what we will do, we'll go to straight away to the cluster menu. So select here cluster. And then this will give you a menu option to create a cluster. So you can create it from here, or you can create it from here. So when I press the create button, you will see that Google is suggesting you to create a auto pilot cluster. So we discussed what is Autopilot and standard or else you you might see a different screen where it will straight away ask you to give the cluster name. And it will assume that you are interested in creating a autopilot cluster. However, for this demo, we are creating a standard cluster, so we will go with standard. So I'll choose configure a standard cluster. So if you don't see this screen, you'll see a screen where you will see a option to switch to standard cluster like just like this. So it says switch to auto pilot cluster. In this place you will see option that will say switch to standard cluster. So create a standard cluster. You can just press that button. However we are in the standard cluster screen. So we will continue with our standard cluster creation. So the right side you will see the price. We will discuss price a little later. In the left side we will see the different options to create or choose different features of GK. In the center you will have your values or the fields where you will enter your values. So first thing you have to name the cluster. So let us keep it. Default cluster one whatever GCP suggesting and then location. So this is something we discussed in one of our previous lecture. So you can create a zonal cluster or a regional cluster. So we discussed when we select a regional cluster you have to select a region. So by default it suggests us central one. You can choose any region you want I'll keep with the default. And then the region might have multiple will have multiple zones. It might have three zones or more four. So you can specify how many zones you want to use. So if you click on this checkbox it will give you a option to choose the zones where you want to put your workloads. So by default you can choose one zone. But that does not make any sense because that is as good as using a zonal cluster. So you can choose one, two, three, four, or you can just choose as many you want. So let us go with two zones for this example. And if you want to go with the zonal cluster. So before that, just to recap, I am choosing two zones. So my control plane will be in both the zones along with the worker node. Now if I choose a zonal cluster you have to choose a zone, not a region. So your central has got four zones so you can choose any of them. Now. By default this might be unchecked. So we'll just go with this particular zone. Or else if you want to go for a multi zone cluster which we again discussed, then you can select other than the default zone the one you have selected here. So in this case you Central1 B you can choose another zone or multiple zones from this checkbox. Now the difference is the default zone will host your control plane. However, you will have your worker nodes in all the other selected zones. So in this case A, B, C zone will have worker nodes, all the three zones and only. June we will have the control plan. So if zone B goes down, you will lose your control plane or access to your Kubernetes cluster. However, your workload will still run because your zone A and C are still hosting your workload. So this is the region and zone selection. So let us go with the regional cluster and with two zones. So let me uncheck this one then. We have release channel. Now this is very important because Kubernetes itself has a release channel. So it has alpha version, beta version then releases the stable version. And then again Kubernetes supports two previous versions along with the current version. So you have to keep updating your upgrade so that you are always in a supported version. The Google will make sure you are always in a supported version, irrespective of the release channel you choose, or the type of cluster that you choose, standard or autopilot. However, you have a flexibility to choose the release channel how you want to go. This is G how you want to upgrade your cluster with respect to Kubernetes releases. So there are four options. Option for no, not no channel. We are not going there. I don't see any reason when you want to use it. So we'll just discuss the first three options. Rapid channel. Rapid channel is something where you will. We want to use all the new features which is recently launched, not tested well. However, these are the features that you might want to use in your application. Say, suppose you want you can come across that Kubernetes is releasing a new feature or a new element that will be useful for you. So you might go for the Rapid channel. So this is useful for development purpose for POC purpose, but not beyond that. Then you have regular channel which is the recommended one. Regular channel is always a stable version of Kubernetes and it is something which is recently made stable. Say recently we had Kubernetes version 1.29. So if you see here we have 1.29 and the patch version is one. Right. So this this may not be the latest stable version. So when you choose a regular channel, it will always give you the latest general availability version of Kubernetes. And then you can choose the version which version you want to go for. So if you see here version 1.27 to 1.29, so recent is 1.29 and two previous version 1.28 and 1.27 listed. So if you go with 1.27 very soon, you will have to upgrade to 1.28, and then you might have to upgrade to 1.29 when you get 1.30 release. So you might want to choose a newer version. But again this 1.2 net may not be very stable with respect to usage. So that is where you have this stable channel option comes. So when you choose a stable channel you won't see 1.29 here because as per Google, the documentation says stable channel is something where something is used and proven to be efficient. So now 1.29 is still a relatively new, newer release. So Google doesn't treat it as a stable channel, though it is a general availability channel, a release from Kubernetes. However. Still, Google doesn't treat this as a regular, sorry, stable channel, so it gives you option to select 1.27 or the different versions of 1.28. However, if you go to the repeat channel, you will see you only getting 1.29 because these are the only recent releases. So these are the just been released just recently. And you want to go for this channel or this release. So these are the options that you get. So we'll go go with the recommended one regular channel. And then you choose the version which version you want to go with. So I'll go with the stable version 1.27. So this is the first update. Cluster creation. So we'll take a patch in this video. In the next video, we'll continue with the remaining of the options.



**Sección 1: Autopilot**

Autopilot: Google manages your cluster (Recommended)
Descripción: A pay-per-Pod Kubernetes cluster where GKE manages your nodes with minimal configuration required. Learn more ↗


**Sección 2: Standard**

Standard: You manage your cluster
Descripción: A pay-per-node Kubernetes cluster where you configure and manage your nodes. Learn more ↗


**Cluster zonal o regional**

**Zonal:** el plano de control (el "cerebro" que administra el cluster) vive en una sola zona. Si esa zona falla, pierdes acceso a administrar el cluster (aunque las cargas de trabajo ya corriendo podrían seguir funcionando por un tiempo). Es más barato — solo pagas por una instancia de control plane — y es lo que estás usando ahora (diego-cluster en us-east1-b).

**Regional:** el plano de control se replica en varias zonas de la misma región (normalmente 3). Si una zona cae, el cluster sigue administrable porque las otras réplicas siguen activas. Es más resiliente, pero también implica más costo (aparte de que, como vimos, el free tier de $74.40 no cubre clusters regionales, solo zonales).

En resumen: zonal = más barato, menos resiliente. Regional = más caro, más resiliente ante caída de una zona. Para pruebas y aprendizaje, zonal es la elección correcta (que es justo lo que armamos).

**Cluster de Prueba**  **Zonal para practicas**

    export PROJECT_ID=project-f50a094d-d02b-40c5-b0d
    export ZONE=us-east1-b


    gcloud container clusters create diego-cluster \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-small \
    --spot \
    --num-nodes=3 \
    --disk-size=20 \
    --disk-type=pd-standard \
    --no-enable-autoupgrade

- Configurar kubeconfig en tu máquina

Primero asegúrate de tener el plugin de autenticación instalado

    gcloud components install gke-gcloud-auth-plugin
    gke-gcloud-auth-plugin --version

Si tu versión de gcloud/kubectl lo requiere, exporta esta variable (agrégala también a tu ~/.bashrc si quieres que persista):

    export USE_GKE_GCLOUD_AUTH_PLUGIN=True

Ahora genera la entrada de kubeconfig — como el cluster es zonal, usa --zone, no --region:

    gcloud container clusters get-credentials diego-cluster \
    --zone=$ZONE \
    --project=$PROJECT_ID

Verifica que quedó conectado:

    kubectl get nodes

Deberías ver tus 3 nodos en estado Ready, cada uno con el tipo e2-small.

Al terminar tus prácticas

**Como quedamos, bórralo cuando no lo estés usando para estirar el crédito aún más (aunque con $964k prácticamente no hace falta):**

    gcloud container clusters delete diego-cluster --zone=$ZONE


**¿Qué es el Release Channel?**

Es el mecanismo con el que GKE decide qué tan "fresca" o estable debe ser la versión de Kubernetes que corre en tu cluster, y cómo se manejan las actualizaciones automáticas futuras. Las opciones son:

| Release Channel | Frescura / Novedad | Estabilidad | Actualizaciones Automáticas | Uso Recomendado |
|---|---|---|---|---|
| **Rapid** | La más alta (últimas funciones) | Menor (menos probadas en producción) | Sí, automáticas y muy frecuentes | Pruebas, desarrollo y experimentación de nuevas *features*. |
| **Regular** | Media (versiones GA maduras) | Balanceada (estabilidad vs. novedad) | Sí, automáticas con frecuencia moderada | Producción en general (opción por defecto y recomendada por Google). |
| **Stable** | Baja (versiones más antiguas) | Máxima (probadas ampliamente en el mundo real) | Sí, automáticas pero menos frecuentes | Entornos críticos donde la estabilidad absoluta es prioridad. |
| **No channel** | Manual (versión fija a elección) | Depende de la versión elegida | No (gestión manual de *upgrades*) | Control total de versiones y ventanas de mantenimiento personalizadas. |

En la práctica, el canal también determina cuándo y con qué frecuencia GKE actualiza automáticamente tu control plane y nodos (parches de seguridad, nuevas versiones menores, etc.).



### 15. Creating a Standard Cluster - Part 2

Bienvenido de nuevo. Continuemos con la configuración de un clúster estándar de GKE centrándonos en la sección de pools de nodos. La opción de Flota (Fleet) la omitiremos por ahora, ya que corresponde a la gestión multiclúster de GKE Enterprise y Anthos, la cual se tratará en una sección posterior del curso.

Un pool de nodos es un conjunto de máquinas virtuales que actúan como nodos trabajadores dentro del clúster. Su propósito principal es brindar la flexibilidad de agrupar nodos con diferentes características según la carga de trabajo: por ejemplo, nodos optimizados para memoria para aplicaciones de alto consumo, o nodos optimizados para CPU para tareas intensivas de cómputo. Kubernetes permite luego asignar los pods a nodos específicos utilizando mecanismos como Node Selectors, Node Affinity, Taints y Tolerations.

Por defecto, GKE sugiere crear un pool único denominado "default-pool". Al configurar el tamaño del pool en un clúster regional, la cantidad de nodos especificada se aplica por cada zona seleccionada. Si se configuran 2 zonas y se especifica 1 nodo por zona, el clúster tendrá un total de 2 nodos. No es posible asignar nodos de forma asimétrica entre zonas en la consola.

En cuanto al escalado y automatización, la función Cluster Autoscaler permite a GKE ajustar el número de nodos según la demanda. Para entornos de prueba mantendremos el autoscaling desactivado. Por otro lado, la opción de autorreparación (Auto-repair) viene activada por defecto para sanear nodos con fallos automáticamente.

Respecto a las estrategias de actualización del pool de nodos (Upgrade Strategies) para evitar la interrupción del servicio (downtime):

Surge Update: Agrega un número determinado de nodos con la nueva versión (max surge), migra las cargas de trabajo y luego elimina los nodos antiguos (max unavailable).

Blue-Green Update: Crea un pool secundario completo con la versión nueva. Ambos grupos coexisten temporalmente hasta que se migra todo el tráfico al nuevo pool y se destruye el anterior. Es la opción de mayor disponibilidad pero conlleva un mayor coste temporal por duplicar la infraestructura.

Para la configuración del sistema operativo y hardware de la VM:

SO: Se mantiene Container-Optimized OS (basado en Linux), que es el predeterminado y recomendado, aunque existe soporte para Windows si la carga de trabajo lo requiere.

Tipo de VM: Se selecciona la serie E2 por su relación coste-eficiencia. Para demostración se utiliza e2-medium (1 vCPU, 4 GB RAM).

Disco de arranque: Se reduce el tamaño persistente a 30 GB para optimizar costes. Se deja el cifrado gestionado por Google.

Spot VMs: No se habilitan, ya que Google puede reclamar la VM en cualquier momento, lo cual no es adecuado para servicios que requieran alta disponibilidad.

En la sección de red y capacidad:

Pods por nodo: Se mantiene la capacidad predeterminada (hasta 110 pods por nodo).

Rangos IP: Los nodos utilizan la IP primaria de la VPC, mientras que los pods utilizan el rango secundario para asignar una dirección IP a cada contenedor.

En la sección de seguridad:

Cuenta de Servicio: Por defecto se asigna la cuenta predeterminada de Compute Engine. Aunque para producción se recomienda aplicar el principio de mínimo privilegio creando una cuenta de servicio dedicada con permisos limitados (logging, monitoring), para fines de esta demostración se utiliza la opción por defecto.

Access Scopes: Se mantiene la opción "Allow default access" para otorgar acceso básico a las APIs de Google Cloud.

Shielded VMs: Se deja la protección integrada para la integridad del firmware.

Finalmente, en la sección de Metadatos se pueden configurar etiquetas (Labels) y restricciones (Taints) para controlar la programación de pods, temas que se profundizarán más adelante mediante comandos de kubectl.


¿Qué es Fleet?

Es una forma de agrupar lógicamente varios clusters (de uno o más proyectos) para administrarlos como una unidad: aplicar políticas consistentes, usar Anthos Service Mesh, Multi-cluster Ingress, etc. Para un solo cluster de pruebas como el tuyo, no aporta nada — por eso el curso lo deja sin marcar y por eso nosotros no lo tocamos al crear diego-cluster (usamos gcloud, que no registra el cluster a ningún fleet por defecto).

¿Qué es un Node Pool? ¿Por qué no aparece en la versión actual?

Un node pool es un grupo de nodos dentro del cluster que comparten la misma configuración (tipo de máquina, disco, imagen del SO, etc.). Un cluster puede tener varios node pools distintos (por ejemplo, uno con VMs pequeñas para cargas livianas y otro con GPU para ML).

Sí existe en la versión actual — no desapareció, solo cambió de ubicación en la navegación. En tu diego-cluster sí tienes un node pool, se llama default-pool (el nombre que gcloud asigna automáticamente cuando no especificas --node-pool-name en la creación). Puedes confirmarlo:

    gcloud container node-pools list --cluster=diego-cluster --zone=us-east1-b


¿Dónde está "Enable cluster autoscaling"? ¿Se define al crear o se puede editar después?

Está en la sección de creación bajo Node Pools → [nombre-pool] → Nodes → Size, justo debajo de "Number of nodes (per zone)" (lo ves en tu Image 4, el checkbox "Enable cluster autoscaler").

Se puede hacer en ambos momentos — al crear el cluster, o después editando el node pool existente:

    gcloud container clusters update diego-cluster \
    --zone=us-east1-b \
    --enable-autoscaling --min-nodes=1 --max-nodes=5 \
    --node-pool=default-pool


Tu diego-cluster no tiene autoscaling habilitado (no lo pusimos), así que siempre vas a tener exactamente 3 nodos fijos, ni más ni menos — lo cual está bien para tus prácticas de quorum, ya que no quieres que el número de nodos cambie solo mientras estás probando migración de cargas.


¿Qué es "Enable auto-repair"?

Si un nodo falla los health checks repetidamente (kubelet no responde, el nodo queda NotReady por mucho tiempo, etc.), GKE automáticamente lo recrea sin que tengas que intervenir. Viene activado por defecto tanto en la consola como al crear con gcloud (nuestro diego-cluster lo tiene activo).

¿Qué es Surge upgrade vs Blue-green upgrade?

Ambas son estrategias para actualizar los nodos (por ejemplo, a una nueva versión de Kubernetes) sin tumbar el cluster completo:

Surge upgrade (la que usa tu cluster por defecto): actualiza los nodos uno por uno en el mismo lugar. Por defecto crea un nodo temporal extra (max-surge=1) mientras actualiza, y no tolera que ningún nodo esté indisponible durante el proceso (max-unavailable=0). Es más rápida y barata.
Blue-green upgrade: crea un node pool completamente nuevo con la versión actualizada, mantiene el viejo corriendo en paralelo temporalmente, y migra el tráfico gradualmente. Es más seguro para cargas sensibles a interrupciones (puedes hacer rollback fácil si algo sale mal), pero más caro porque duplicas nodos durante la transición.

Sobre "Ubuntu with containerd — soporte para NFS, GlusterFS, XFS"

Es la imagen del sistema operativo del nodo (no del pod). GKE ofrece varias imágenes base para los nodos:

Container-Optimized OS (COS) — la default, hecha por Google, minimalista y más segura, pero con menos flexibilidad de sistema de archivos/paquetes.
Ubuntu — un SO más completo, con soporte nativo para sistemas de archivos de red como NFS (Network File System) y GlusterFS (sistema de archivos distribuido), y XFS (un sistema de archivos alternativo a ext4, bueno para grandes volúmenes de datos). Útil si tus workloads necesitan montar ese tipo de almacenamiento compartido directamente en el nodo.


IP de rango primario vs rango secundario para un pod

Esto es sobre clusters VPC-native (el modo default desde hace años, como viste en uno de los logs anteriores: "VPC-native is the default mode..."). Cada nodo tiene:

Rango primario: la IP normal del nodo en tu VPC (ej. 10.142.0.x).
Rango secundario para Pods: un rango de IPs alias adicional, dedicado exclusivamente a los pods que corren en ese nodo (cada pod obtiene una IP real y enrutable de este rango, no NAT).
Rango secundario para Services: otro rango aparte, para las IPs internas de los Service de Kubernetes (ClusterIP).

Esto permite que los pods tengan IPs reales dentro de tu VPC, enrutables directamente sin necesitar overlay networks — es la clave del mensaje que viste antes: "tu Pod address range puede acomodar hasta 1008 nodos", calculado justamente a partir del tamaño de ese rango secundario de pods.


Sobre la Service Account

Es la identidad con la que cada nodo (VM) se autentica ante las APIs de Google Cloud — no es una cuenta de usuario, es una cuenta de servicio (machine identity). Cuando un pod necesita, por ejemplo, escribir logs a Cloud Logging, leer un archivo de Cloud Storage, o hablar con otra API de GCP, usa (por defecto) los permisos de esta service account del nodo.

"Compute Engine default service account" (lo que usa tu diego-cluster porque no especificamos otra): es una cuenta genérica con permisos amplios (Editor en proyectos antiguos, o roles bastante permisivos) — cómoda para pruebas, pero no recomendada para producción por exceso de privilegios.
Lo recomendado en producción es crear una service account dedicada y mínimamente privilegiada (solo los permisos que tu carga de trabajo realmente necesita) y asignarla al node pool.

Para tus prácticas actuales, usar la default está bien — es exactamente el tipo de decisión que en un ambiente real revisarías con más cuidado antes de ir a producción.


De todo lo que repasamos, nada era estrictamente necesario que faltara para que el cluster funcione bien para tus prácticas — los defaults de GKE están pensados para ser razonables. Las dos únicas que yo destacaría como mejoras válidas si quieres reforzar el cluster sin tocar su propósito actual:

Master authorized networks (restringir quién puede llegar al API server):

    gcloud container clusters update diego-cluster \
    --zone=us-east1-b \
    --enable-master-authorized-networks \
    --master-authorized-networks=$(curl -s ifconfig.me)/32

Service account dedicada — esta no se puede cambiar en un node pool existente, solo al crear uno nuevo, así que solo aplicaría si en algún momento agregas un node pool adicional o recreas el cluster.

Todo lo demás (release channel, autoscaling, image type, etc.) está correctamente resuelto por los defaults para el propósito que tiene este cluster.


    terraform apply -var="machine_type=e2-medium" -var="num_nodes=5"


### 16. Creating a Standard Cluster - Part 3



### 17. Public/Private Node - New Option




### 17. Creating A Autopilot Cluster



### 18. Accessing the Cluster - Options



### 19. Accessing the Cluster from Laptop



### 20. Accessing the CLuster - From Cloud Shell



### 21. Accesing the Cluster - From Compute Instance



## Section 3: Deploying and Exposing App


## 22. Section Introduction


