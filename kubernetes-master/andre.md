


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

Como es que un deployment nos ayuda a solucionar este problema de actualizacion de pods en un replicaset.

Cuando yo creo un deployment tengo que especificar un template para el replicaset. Es decir que al crear un deployment este va a crear un replicaset, y en el replicaset se dice que pod y cuantos se quieren. Lo que significa que se van a creas por a consecuencia del replicaset que se creo.

MaxAvailable: cuantos pods yo voy a permitir que mueran. 25% por defecto en kubernetes

Max Surge: relacionado con rolling update strategy

Pendiente


### 46. Tu primer Deployment

**Cuando se define un Deployment, en realidad se está definiendo un controlador de más alto nivel que se encarga de manejar un ReplicaSet, y este a su vez se encarga de manejar los Pods.**

Parte Deployment

    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: deployment-test
    labels:
        app: front
    spec:
    replicas: 3
    selector:
        matchLabels:
        app: front

Parte Replicaset

    replicas: 3
    selector:
        matchLabels:
        app: front

Parte Pod:

    template:
        metadata:
        labels:
            app: front
        spec:
        containers:
        - name: nginx
            image: nginx:alpine



**Nota:** Recordar que el deployment se compone de 3 partes:

    kubectl get deployment --show-labels

    kubectl rollout status deployment deployment-test
    deployment "deployment-test" successfully rolled out


Muestra si la actualización (rollout) del Deployment terminó correctamente o si aún está en proceso.

Asi se crea y despliega un deployment en kubernetes.
Similar al replicaset pero con la diferencia que el deployment brinda la opcion de actualizar los pods.


### 47. Owner References - Deployment, ReplicaSet y Pods

Se puede ver el deployment:

    kubectl get deployment
    NAME              READY   UP-TO-DATE   AVAILABLE   AGE
    deployment-test   3/3     3            3           20h

Efectivamente se tiene un replicaset con el nombre del deployment

    kubectl get rs
    NAME                        DESIRED   CURRENT   READY   AGE
    deployment-test-84b6b84fb   3         3         3       20h

Se pueden ver los pods con el nombre del deployment

    kubectl get pods --show-labels
    NAME                              READY   STATUS    RESTARTS       AGE    LABELS
    deployment-test-84b6b84fb-2q87g   1/1     Running   0              20h    app=front,pod-template-hash=84b6b84fb
    deployment-test-84b6b84fb-jj8t5   1/1     Running   0              20h    app=front,pod-template-hash=84b6b84fb
    deployment-test-84b6b84fb-khvg9   1/1     Running   0              20h    app=front,pod-template-hash=84b6b84fb


Todos tienen los mismos labels:

    kubectl get deployment --show-labels
    NAME              READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
    deployment-test   3/3     3            3           20h   app=front
    
    kubectl get rs --show-labels
    NAME                        DESIRED   CURRENT   READY   AGE    LABELS
    deployment-test-84b6b84fb   3         3         3       20h    app=front,pod-template-hash=84b6b84fb
    rs-test                     3         3         3       4d6h   app=rs-test
    
    kubectl get pods --show-labels
    NAME                              READY   STATUS    RESTARTS       AGE    LABELS
    deployment-test-84b6b84fb-2q87g   1/1     Running   0              20h    app=front,pod-template-hash=84b6b84fb
    deployment-test-84b6b84fb-jj8t5   1/1     Running   0              20h    app=front,pod-template-hash=84b6b84fb
    deployment-test-84b6b84fb-khvg9   1/1     Running   0              20h    app=front,pod-template-hash=84b6b84fb

pod-template-hash=84b6b84fb : Kubernetes utiliza internamente para garantizar que el replicaset tambien sepa cuales son sus pods, debido a que lo creo un deployment.

    kubectl get replicaset deployment-test-84b6b84fb -o yaml

  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: Deployment
    name: deployment-test
    uid: b38c7e70-d905-48e8-ae99-5e3fc8d60158

El dueño de este replicaset es el deployment relacionado.

El deployment se va a encargar de modificar el replicaset segun sea necesario.


  ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: deployment-test-84b6b84fb
    uid: 39556943-8da5-4504-a694-5ca8ea4522db

El dueño de los pods es el replicaset relacionado.


### 48. Rolling updates - Actualiza tu version de tu aplicacion

Como actualizar un deployment para que consecuentemente se actualicen nuestros pods.

Se va a actualizar el deployment para que ahora utilice la imagen de nginx y no la de nginx-alpine.

    kubectl apply -f deployment.yaml 
    deployment.apps/deployment-test configured

    kubectl rollout status deployment deployment-test
    Waiting for deployment "deployment-test" rollout to finish: 1 old replicas are pending termination...
    Waiting for deployment "deployment-test" rollout to finish: 1 old replicas are pending termination...
    deployment "deployment-test" successfully rolled out


**¿Como kubernetes llevo a cabo este deployment?**

    kubectl describe deployment deployment-test

    Events:
    Type    Reason             Age                    From                   Message
    ----    ------             ----                   ----                   -------
    Normal  ScalingReplicaSet  8m24s                  deployment-controller  Scaled up replica set deployment-test-5d45fd875f to 1
    Normal  ScalingReplicaSet  8m23s                  deployment-controller  Scaled down replica set deployment-test-84b6b84fb to 2 from 3
    Normal  ScalingReplicaSet  8m23s                  deployment-controller  Scaled up replica set deployment-test-5d45fd875f to 2 from 1
    Normal  ScalingReplicaSet  8m22s                  deployment-controller  Scaled down replica set deployment-test-84b6b84fb to 1 from 2
    Normal  ScalingReplicaSet  8m22s                  deployment-controller  Scaled up replica set deployment-test-5d45fd875f to 3 from 2
    Normal  ScalingReplicaSet  8m21s                  deployment-controller  Scaled down replica set deployment-test-84b6b84fb to 0 from 1
    Normal  ScalingReplicaSet  4m45s                  deployment-controller  Scaled up replica set deployment-test-84b6b84fb to 1 from 0
    Normal  ScalingReplicaSet  4m44s                  deployment-controller  Scaled down replica set deployment-test-5d45fd875f to 2 from 3
    Normal  ScalingReplicaSet  4m44s                  deployment-controller  Scaled up replica set deployment-test-84b6b84fb to 2 from 1
    Normal  ScalingReplicaSet  4m42s (x3 over 4m43s)  deployment-controller  (combined from similar events): Scaled down replica set deployment-test-5d45fd875f to 0 from 1



### 49. Historico y revisiones de despliegues

Cada que se hace un deployment y un rollout esto crea un replicaset y al final estos replicaset se van a ir acumulando.

    kubectl get rs -l app=front

Para ver cuanta hostoria (revisiones) nos deja kubernetes tener.

kubectl get rs -l app=front
NAME                         DESIRED   CURRENT   READY   AGE
deployment-test-5d45fd875f   0         0         0       23m
deployment-test-84b6b84fb    3         3         3       20h

Con esto se ven las revisiones o rollouts que se han ejecutado

    kubectl rollout history deployment deployment-test
    deployment.apps/deployment-test 
    REVISION  CHANGE-CAUSE
    2         <none>
    3         <none>

Kubernetes se de cuenta que hay algo distinto en el template y sea forzado a actualizar el deployment. 

Ahora se puede ver que aparece una revision nueva despues de actualizar el deployment:

    kubectl apply -f deployment.yaml 
    deployment.apps/deployment-test configured

    kubectl rollout history deployment deployment-test
    deployment.apps/deployment-test 
    REVISION  CHANGE-CAUSE
    2         <none>
    3         <none>
    4         <none>

Ahora se puede evidenciar que aparece un nuevo replicaset

    kubectl get replicaset
    NAME                         DESIRED   CURRENT   READY   AGE
    deployment-test-5d45fd875f   0         0         0       31m
    deployment-test-84b6b84fb    0         0         0       21h
    deployment-test-f6bb7bb78    3         3         3       70s

El rollout termino, todos los pods de este replicaset fueron actualizados de manera correcta y los otros dos anteriores estan en cero.

la idea de mantener estas replicasets con los parametros en 0es en caso de que yo quiera volver a una version anterior de estos replicasets, que puedo controlar aqui? 

Se tiene la REVISION 2,3,4 y se puede volver a cualquiera de ellas si asi se quisiera.


**HistoryLimit**

Un Deployment siempre va a mantener por defecto un historico de 10 replicasets, a menos de que se modifique este valor.

Se coloca en el deployment en spec,     revisionHistoryLimit: 1

Para validar que se pueda cambiar el limite en el historial. Si funciona, redujo los history que se tienen.

kubectl apply -f deployment.yaml 
deployment.apps/deployment-test configured

kubectl rollout history deployment deployment-test
deployment.apps/deployment-test 
REVISION  CHANGE-CAUSE
3         <none>
4         <none>

Es decir, cuantos replicasets quieren guardar para poder volver a esas versiones en caso de ser necesario.



### 50. Change-Cause -¿Cambiaste algo?

No se especifico cual es la razon o la causa de este deployment, por eso aparece <none>

REVISION  CHANGE-CAUSE
3         <none>

Hay 3 formas para esto

1. Utilizando el flag --record

        kubectl rollout history deployment deployment-test
        deployment.apps/deployment-test 
        REVISION  CHANGE-CAUSE
        4         <none>
        5         kubectl apply --filename=deployment.yaml --record=true

2. Crear una anotacion en el deployment

La Annotation es metadata que kubernetes utiliza para otras cosas.
En este caso esta utilizando la anotacion para saber cual es la causa del deployment.

Esta anotacion tiene que ir en el template, 

    kubectl apply -f deployment.yaml  (Ya no es necesario el --record, se coloca desde el manifiesto)


Se pueden ver que cambios ocurrieron en una revision:

Este es el estado de este pod en esta revision.

    kubectl rollout history deployment deployment-test --revision=6
    deployment.apps/deployment-test with revision #6
    Pod Template:
    Labels:       app=front
            pod-template-hash=b447c675
    Annotations:  kubernetes.io/change-cause: Changes port to 110
    Containers:
    nginx:
        Image:      nginx:alpine
        Port:       110/TCP
        Host Port:  0/TCP
        Environment:        <none>
        Mounts:     <none>
    Volumes:      <none>
    Node-Selectors:       <none>
    Tolerations:  <none>

Se puede valiar que cambios se tenian en dicha version y quizas de ser necesario retornar a esta version en el tiempo.


### 51.  Roll back - Si algo salio mal, !regresa a la version anterior!

Un rollback se puede hacer por muchas razones, el depsliegue de una neuva version funcione bien , pero que la aplicacion misma tenga errores y no esta funcionandno como se espera que funcione.

Hay escearios en las que el deployment puede quedarse pegado, puede quedarse con problemas, puede volverse inestable debido a una mala configuracion, algun problema de red, muchas cosas.


cambio de imagen por test-fake

deployment-test-dfd6bdd8-ln4fc   0/1     ErrImagePull

    kubectl rollout history deployment deployment-test --revision=7
    deployment.apps/deployment-test with revision #7
    Pod Template:
    Labels:       app=front
            pod-template-hash=dfd6bdd8
    Annotations:  kubernetes.io/change-cause: Changes port to 110
    Containers:
    nginx:
        Image:      test-fake
        Port:       110/TCP
        Host Port:  0/TCP
        Environment:        <none>
        Mounts:     <none>
    Volumes:      <none>
    Node-Selectors:       <none>
    Tolerations:  <none>

Ahora se hara el rollout previa al error con la imagen

    kubectl rollout undo deployment deployment-test --to-revision=6
    deployment.apps/deployment-test rolled back

Se puede corroborar que se ejecuto con exito el rollback

    kubectl rollout status deployment deployment-test


## Section 9: Service & Endpoints - Kuberntes Service Discovery


### 52. ¿Que es un servicio?

Si 2 pods logran manejar el trafico de 100 request por segundo, se puede decir que 4 pods pueden manejar el trafico de 200 request /s. En esencia esta es la idea de escalar horizontalmente para ser capaces de manejar mass trafico.

**¿Como accedemos a todos estos pods en un solo punto?**

Como hacer que un usuario consulte este punto y peuda obtener la informacion de estos pods?


Para esto en kubernetes existe un objeto que se llama servicio, lo que hace es observar los pods con cierto label.

Este servicio actuara coo balancerador sobre los pods que el este observando.

Si se crea un pod por fuera de un replicaset o un deployment y se le coloca un label por ejemplo app=web, el servicio tambien lo va a observar a el.

Al servicio no le importa si esta deontro de un reployment o replicaset, solo le interesa el label.


### 53. ¿Que son y para que sirven los endpoints?

Consultando la IP del servicio siempre se va apoder acceder a los pods que el servicio este observando.

Cuando un request llega al servicio, el servicio necesaita enviarselo a alguien, y ese alguien van a ser lods pods. POr lo tanto en este servicio se creara un deployment para que responsa los request cuando alguien solicite la ip del servicio.



### 54. Crea tu primer servicio

    kubectl apply -f service/svc.yaml
    deployment.apps/deployment-test-service created
    service/my-service created


### 55. Describe tu servicio y encuentra información util


### 56. Pods & Endpoints


### 57. Servicios y DNS


### 58. Servicio de tipo ClusterIP



### 59. Servicio de tipo NodePort


### 60. Servicio de tipo Load Balancer 


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



