


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

    kubectl exec -ti doscont -c cont1 -- sh

    kubectl describe pod doscont (Obtener nombres de contenedores del pod)



### 37. Labels y Pods

Por ejemplo yo tengo 3 pods que son de desarrollo, 3 pods que son de stagging y 3 pods que son de production.

¿Como hago para diferenciar estos pods? Una opcion podria ser por labels.

Los labels son basicamente arbitrarios, se pueden definir los labels que se necesiten, por ejemplo: nombre: apellido: o cualquiera el mas comun es app: 


    kubectl apply -f podLabels.yaml

    kubectl get pods -l app=backend
    kubectl get pods -l app=front
    kubectl get pods -l env=dev


- Filtrar para reducir el output en la linea de comandos
- Para que objetos de mas alto nivel como un replicaset o un deployment puedan administrar los pods. (Estos objetos solo conocen a los pods por labels)


### 38. Problemas con los pods

- No se recuperan solos
- Si se requieren minimo 2 replicas de mi pod (¿Como garantizo esto?)
- Garantizar la minima replica que son 2.
- Los pods no pueden actualizarse a si mismos (Ej. Recursos, comando,)
No puedo actualizarlo desde el pod mismo, alguien externo debe hacer esa actualizacion sobre el pod para que sea valida.

Utilizar objetos mas altos para administrar los pods y asi aprovechar estas caracteristicas de replicas y de self healing que nos ofrecen estos objetos de kubernetes.


## Section 7: ReplicaSets - Aprende a garantizar replicas en tus Pods

### 39. ¿Que es Replicaset?

Por que deberiamos considerar un replicaset sobre un pod.
Replicaset (RS) crea pods. 

Se encarga de crear un pod con ese template.
Al yo decirle que quiero 2 replicas, va a crear 1 pod y va a crear otro pod a partir del template.
Si por alguna extraña razon algun pod se muere, el replicaset levanta otro con las mismas caracteristicas para garantizar que el numero actual de pods es igual al numero que el debe mantener. 

¿Como hace el replicaset para mantenerlos y diferenciarlos de otros pods?

Los pods deben tener un label, 

Cuando el replicaset crea los pods y le asigna esos labels, el replicaset coloca algo llamado el owner reference (en la metadata del pod).El pod A va a tener como owner el replicaset1 y el pod B va a tneer como owner el replicaset1 tambien.

El owner reference lo coloca el objeto de mas alto nivel. 

Podria darse el caso de que un replicaset2 podria convertirse en **owner reference** de estos pods si coinciden los labels, esto fuera un caso de error de overlaping de labels. 

Replicaset se encarga de mantener un numero n de replicas, del mismo pod ccorriendo en determinado tiempo



### 40. Tu primer ReplicaSet

> replicaset.yaml

En los pods se tiene en apiVersion v1 y para replicaset apps/v1

"Los labels son del replicaset, no son de los pods."

selector: que labels vamos a utilizar para seleccionar los pods

(Especificacion del replicaset)

    spec:
    # modifica las réplicas según tu caso de uso
    replicas: 3
    selector:
        matchLabels:
        tier: frontend

Esta parte hace referencia a los pods

    template:
        metadata:
        labels:
            tier: frontend
        spec:
        containers:
        - name: php-redis
            image: gcr.io/google_samples/gb-frontend:v3


### 41. Verifica el funcionamiento de un Replicaset


diegoall@ph03nix:~/courses/pro-kubernetes/kubernetes-master/replicaSet$ kubectl apply -f replicaset.yaml 
replicaset.apps/rs-test unchanged

Este fue el comando que se ejecuto anteriormente, y si se dan cuenta dice que nada ha cambiado, es decir que es idempotente, significa que no habran modificaciones a menos de que sean necesarias. 

A este punto todos los pods parecen estar bien, y al parecer replicaset no necesita tomar ninguna accion.

    kubectl get pods -l app=pod-label

    kubectl get rs


Se puede eliminar un pod y el replicaset vuelve y lo levanta.

        kubectl delete pod rs-fsdjf

Si se cambia el valor de replicas en el manifeisto se actualizan automaticamente.


### 42. Owner References - Entiende como RS se relaciona con los Pods

    kubectl describe rs rs-test

    kubectl get pods rs-test-gv6pv -o yaml


    ownerReferences:
    - apiVersion: apps/v1
        blockOwnerDeletion: true
        controller: true
        kind: ReplicaSet
        name: rs-test
        uid: 3b558796-3846-4e32-993c-144b46db2cc9

Este es el dueño del pod, con ese nombre y uuid.

Nadie es dueño del replicaset aun.

El replicaset siempre esta buscando los pods con el label que se haya colocado en el selector y va a tomar esos pods solamente si esos pods no tienen un owner definido. Si los pods no tienen un owner definido entonces el replicaset los hereda. Sino existe un pod con ese label, entonces el replicaset, los crea y adicionalmente los vuelve suyos, es decir les coloca esa metadata y les dice que 
el replicaset x es el dueño de esos pods. 


### 43. Adopcion de Pods desde ReplicaSet - !Evitar usar pods planos!

Como un replicaset puede heredar pods que no haya creado pero que hagan match con el selector que definimos.

Se crearan unos pods externos que no creo un replicaset y luego se les va a colocar unos labels. Esos pods como se crearon manualmente (ningun objeto los creo), significa que no tienen owner reference. 

POr lo tanto si yo creo un replicaset y los dos pods ya estan creados, y los labels son los mismos, el replicaset los va a adoptar, por que se estan cumpliendo las condiciones que se necesitan. 
POr eso no en conveniente crear pods planos, siempre deben ser creados por objetos de mayor nivel.

diegoall@ph03nix:~/courses/pro-kubernetes$ kubectl run --generator=run-pod/v1 podtest5 --image=nginx:alpine
error: unknown flag: --generator
See 'kubectl run --help' for usage.

**kubectl run ya no crea Deployments como antes, solo crea Pods. El flag --generator ya no existe.**

    kubectl run podtest5 --image=nginx:alpine
    kubectl run podtest6 --image=nginx:alpine

Estos pods no tienen labels, 

    kubectl describe pod podtest5

Solo tiene el label por defecto que coloca k8s

    Labels:           run=podtest5

**¿Como colocarle un label a un pod que ya esta corriendo?**

    diegoall@ph03nix:~/courses/pro-kubernetes$ kubectl label pods podtest5 app=pod-label
    pod/podtest5 labeled

Al etiquetar podtest5 y podtest6 con el label (pod-label) del ReplicaSet, les dijiste “ahora ustedes pertenecen a este ReplicaSet”. Kubernetes entonces los eliminó para que el ReplicaSet siga manejando solo sus propios pods administrados.

pod-label

kubectl label pods podtest5 app=pod-label

!! NO FUNCIONO !! EN EL VIDEO SI VUELVE EL POD ACA DESAPARECE EL POD !!

Es peligroso, por eso no se deben crear pods planos.


### 44. Problemas de ReplicaSet

Hay un pequeño detalle. EL coenpto general es que debe mantener un numero n de replicas del mismo pod en todo tiempo. Replicaset es el encargado de crear nuevos pods, y de que funcione de forma declarativa.

El replicaset solamente mira uno numero de pods deseados o esperados, que cumplan con ciertos labels. Y al momento de aplicar una nueva configuracion desde el manifiesto el numero de pods con los labels sigue siendo el mismo, por lo tanto el replicaset no toma ninguna acción. Y esto se traduce en que, 
un replicaset no puede actualizar los pods para cambiar por ejemplo la imagen, configuraciones (del manifiesto), y eso es problematico por que 

**Replicaset sirve para mantener el numero de replicas pero no para actualizar los pods.**

Si se quiere actualizar la version de un pod en un replicaset no es posible
(Al menos no es posible utilizando replicasets directamente)


**¿Como podemos forzar la actualizacion de los pods?**

Se puede eliminar algun pod del replicaset, y cuando vuelva a levantarse se evidencia que toma los cambios, pero el proceso no es el mas natural ni el mas sencillo posible. Imaginarse el escenario de un replicaset de mas de 1000 pods (eliminar los 1000 a mano para que se puedna actualizar).

**"El deployment es el dueño del replicaset, y el replicaset es el dueño de los pods."**


## Section 8: Deployments - Aprende a hacer un Rollout & Rollbacks


### 45. ¿Que es un Deployent?


### 46. Tu primer Deployment


### 47. Owner References - Deployment, ReplicaSet y Pods


### 48. Rolling updates - Actualiza tu version de tu aplicacion


### 49. Historico y revisiones de despliegues



### 50. Change-Cause -¿Cambiaste algo?


### 51.  Roll back - Si algo salio mal, !regresa a la version anterior!



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



