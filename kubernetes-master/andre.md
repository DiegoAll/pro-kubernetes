


## Section 6: Explorando pods

### 24. Notas sobre creando tu primer pod

    kubectl exec -it falco-f2n4b /bin/rbash


la opción --generator fue eliminada en versiones recientes de kubectl.


    kubectl create deployment podtest --image=nginx:alpine

--restart=Never: Asegura que se cree un pod independiente en lugar de un Deployment o un ReplicaSet.

    kubectl run podtest --image=nginx:alpine --restart=Never



crear un Deployment en lugar de un pod único, usa:  ( Si se elimina el pod este vuelve y se recrea)

    kubectl create deployment podtest --image=nginx:alpine

kubectl delete deployment podtest  **(Debe eliminarse el deployment)**


    kubectl delete all --selector=app=podtest


### 25. !Manos a la obra! Crea tu primer pod 

La estrategia de pod por contenedor es la mas utilizada.

    kubectl run podtest --image=nginx:alpine


###  26. Describe pods

    kubectl describe pod sneaking

READY 1/1 (1 contenedor de 1 contenedor esperado, un pod puede tener varios contenedores)


### 27. Aprende a eliminar Pods

    kubectl delete pod <PodName>

### 28. ¿Yaml ¿Como obtengo el yaml desde un pod?


    kubectl get pod podName -o yaml


### 29. Pods y contenendores - Aqui vamos de nuevo

Por temas de que minikube ese ejecuta en una maquina virtual de VirtualBox se requiere ejecutar el siguiente comando:

    eval $(minikube -p minikube docker-env)

    docker ps -l  (SE EXTRAE LA COLUMNA NAMES)

k8s_podtest_podtest_default_de75b25b-4d8b-42c6-9fff-60103c98b2b3_0

Esto se visualiza desde otro Docker que esta en la maquina virtual que ejecuta minikube:

    docker ps -f=name=k8s_podtest_podtest_default_de75b25b-4d8b-42c6-9fff-60103c98b2b3_0


**Este comando sirve para ver si está corriendo el contenedor de Docker correspondiente a ese pod de Kubernetes en específico.**

Relacion entre contenedores y pods

"El contenedor es el que esta corriendo, el pod en si no corre, es simplemente un recubrimiento un wrapper"  


### 30. Nota: ¿No puedes ver la IP de tu pod?

Es posible que tengas problemas en el próximo video y no puedas ver la IP del pod. Si eso sucede, vuelve aquí y revisa la solución. De lo contrario, puedes ignorar este artículo.

🔍 Solución
Si creaste tu clúster con un driver como VirtualBox o HyperV, es probable que no puedas ver la IP del pod porque está en una máquina distinta a tu localhost, lo que impide el acceso a esas IPs locales.

Para solucionarlo, ejecuta este comando:

    kubectl port-forward <pod-name> 7000:<pod-port>


⚡ kubectl port-forward es un pequeño truco que te permite acceder al puerto de tu pod desde tu máquina local. Funciona de manera similar a:

docker run -p TU_PUERTO:PUERTO_DEL_CONTENEDOR
Luego, abre tu navegador y ve a http://localhost:7000, ¡y deberías ver tu pod funcionando! 🎉


### 31. Aprende a obtener la IP de un Pod

Para el caso del pod de nginx:

**La IP del pod (10.244.0.44 en tu caso) pertenece a la red interna de Kubernetes (CNI), no es accesible directamente desde tu máquina host o desde el navegador.**


En el video sucede que se accede a la IP 172.17.0.2 porque seguramente se esta ejecutando minikube con Docker, y en ese caso los contenedores **usan la red bridge de Docker**, que sí es alcanzable desde el host.

Cuando usas minikube con driver=“docker”, internamente Minikube crea un contenedor “máquina virtual” dentro de Docker.
Ese contenedor corre Kubernetes y a su vez crea los pods.


Opciones para acceder al Nginx de tu pod:

1. Port-forwarding (la más rápida para pruebas)

    kubectl port-forward <pod-name> 7000:<pod-port>

    kubectl port-forward podtest 7000:80

**Welcome to nginx!**

2. Crear un Service tipo ClusterIP + usar port-forward


3. Crear un Service tipo NodePort (exponer hacia el host de Minikube)


### 32. Kubectl exec - Ingresa a los contenedores dentro de un Pod!

    kubectl exec -it podtest -- sh


### 33. Kubectl logs - Aprende a ver que sucede con los contenedores de un Pod

    kubectl logs podtest -f


### 34. Manifiestos de Kubernetes 

Define el recurso que queremos crear o actualizar en Kubernetes.

### 35. Pods con mas de un contenedor

Un pod es un wrapper que envuelve uno o mas contenedores.
En Kubernetes el modelo de 1 contenedor por pod es el mas utilizado.

    docker run --net host -ti python:3.6-alpine sh

Para levantar un servidor http con un modulo de python

**manifest: pod2cont.yaml**


    kubectl logs -f doscont -c cont1
    kubectl logs -f doscont -c cont2
    kubectl logs -f doscont --all-containers=true




### 36. Solución: Evita utilizar el mismo puerto en los contenedores de un Pod


### 37. Labels y Pods



### 38. Problemas con los pods



## Section 7: ReplicaSets - Aprende a garantizar replicas en tus Pods


## Section 8: Deployments - Aprende a hacer un Rollout & Rollbacks


## Section 9: Service & Endpoints - Kuberntes Service Discovery


## Section 10: Golang, Javascript y Kubernetes 


## Section 11: Namespaces & Context - Organizar y aislar los recursos


## Section 12: Limita la RAM y la CPU que pueden utilizar tus pods


## Section 13: LimitRange - Uso de recursos a nivel de objetos


## Section 14: ResourceQuota - Agrega limites a nivel de namespace



## Section 15: Health Checks & Probes - Vigila el estado de tus contenedores



## Section 16: ConfigMaps & Environment Variables - Inyecta datos en tus pods



## Section 17: Secrets - Aprende a manejar data sensible en Kubernetes



## Section 18: Kubernetes Volumes - Entiende los conceptos detrás de la persistencia de datos



## Section 19: Kubernetes Volumes - EmptyDir, HostPath, PV, PVC, StorageClasses



## Section 20: Role based Access Control: Users & Groups



## Section 21: Role Based Access Control: Service Account


## Section 22: Ingress: Aprende a exponer tus aplicaciones fuera del Cluster



## Section 23: AWS EKS & Kubernetes: Introduction



## Section 24: AWS EKS & Kubernetes: Crea un cluster real para ambientes productivos



## Section 25: AWS EKS & Kubernetes: Ingress & Load Balancers



## Section 26: AWS EKS & Kubernetes: Horizontal Pod Autoscaler



## Section 27: AWS EKS & Kubernetes: Cluster AutoScaler



## Section 28: AWS EKS & Kubernetes: Destruye todos los recursos que creaste 


## Section 29: Bonus



