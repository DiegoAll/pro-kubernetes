# Kubernetes de principiante a experto

## Section 1: Introduction


## Section 2: Arquitectura de Kubernetes - !Conoce todos los secretos!


## Section 3: Instalación de Minikube - !Un cluster local, poderoso y muy facil de usar!



## Section 4: Recursos del curso


## Section 5: Pods en Kubernetes vs Contenedores de Docker


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


Cad apod tiene una IP, y al tener una Ip tiene un servicio corriendo.

Al servicio se le coloca el puerto 8080.

Si yo soy un usuario y le solicito algo a la IP del servicio 8080, lo que va a hacer el servicio es consultar el endpoint y basado en el endpoint elegir una de las ips validas. Enviar la solicitud a la IP, por el puerto que se definio previamente en este caso el 80.

De esta manera la puerta de entrada o el entrypoint de el servicio es la IP:PuertoDefinidoenElManifiesto y luego esto se va a enrutar al puerto del contenedor (Cada uno de los pods).



### 55. Describe tu servicio y encuentra información util

    kubectl get svc
    kubectl get svc -l app=front


NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
my-service   ClusterIP   10.101.86.254   <none>        8080/TCP   4d16h

**Por defecto en kubernetes si no se especifica ningun tipo de servicio va a ser ClusterIP**

Es una direccion IP virtual por que no esta asociada a ningun tipo de MAC fisica, por lo tanto es una IP virtual que se va a utilizar como punto de acceso, para nuestros pods, 

    diegoall@ph03nix:~/courses/pro-kubernetes/kubernetes-master/service$ kubectl describe svc svc my-service
    Name:              my-service
    Namespace:         default
    Labels:            app=front
    Annotations:       <none>
    Selector:          app=front
    Type:              ClusterIP
    IP Family Policy:  SingleStack
    IP Families:       IPv4
    IP:                10.101.86.254
    IPs:               10.101.86.254
    Port:              <unset>  8080/TCP
    TargetPort:        80/TCP
    Endpoints:         10.244.0.102:80,10.244.0.87:80,10.244.0.88:80 + 4 more...
    Session Affinity:  None
    Events:            <none>
    Error from server (NotFound): services "svc" not found

**Este servicio es el punto de entrada para acceder a nuestros pods.**


### 56. Pods & Endpoints

Endpoints:         10.244.0.102:80,10.244.0.87:80,10.244.0.88:80 + 4 more...

**¿Qué son entonces los endpoints?**

Son las direcciones IP internas de los pods (junto con el puerto) a los que el Service va a dirigir el tráfico.

"Endpoints es la manera que tiene el servicio para trackear las ips a la cuales puede enviarles request"

    kubectl get endpoints

Cuando se crea un servicio con labels, el endpoint se crea de manera automatica.

Para poder ver la direccion IP de los pods:

    kubectl get pods -l app=front -o wide


Debido a que el controadlro del servicio, esta observando los pods, que cumplen con el label que les fue asignado en el selector.

Si se crea un pod si ningun controlador, es decir sin ningun replicaset, sin ningun deployment que haga match con ese label, automaticamente la IP del pod va a aparecer en el endpoint, muy parecido al tema de cuando un replciaset adopta un pod, que cumple con el label.



    kubectl run --generator=run-pod/v1 podtest5 --image=nginx:alpine DEPRECADO
    kubectl run podtest5 --image=nginx:alpine

    kubectl label pods podtest5 app=front


    kubectl describe endpoints my-service
    Name:         my-service
    Namespace:    default
    Labels:       app=front
    Annotations:  endpoints.kubernetes.io/last-change-trigger-time: 2025-09-24T02:53:39Z
    Subsets:
    Addresses:          10.244.0.102,10.244.0.104,10.244.0.87,10.244.0.88,10.244.0.90,10.244.0.92,10.244.0.93,10.244.0.98
    NotReadyAddresses:  <none>
    Ports:
        Name     Port  Protocol
        ----     ----  --------
        <unset>  80    TCP

    Events:  <none>

Aparece cuando se filtra por el label recien agregado.

    kubectl get pods -l app=front
    NAME                                      READY   STATUS    RESTARTS        AGE
    deployment-test-b447c675-5s22h            1/1     Running   1 (3h23m ago)   4d21h
    podtest5                                  1/1     Running   0               3m15s

Supongase que se tienen 3 pods de nginx, y el nuevo pod creado es algo totalmente distinto, **como el servicio esta observando estos 4 pods**, significa que estas 4 direcciones IPs van a estar en el endpoint, y tambien significa que cualquier request, que le llegue al servicio, van a ser atendidas por estos 4 pods. Y probablemente pueda haber inconsistencia de datos, por que este nuevo pod puede tener data distinta, a estos 3 de nginx, y cuando el request caiga a nginx perfecto, pero cuando caiga a podtest5, va a haber un problema y es que se va a tener data distinta o probablemente no se va a tener nada.

**No es recomendable crear pods fuera de controladores, fuera de replicasets, fuera de deployments. Siempre se debe crear un pod con un objeto de mas alto nivel, que lo controle y que sea su dueño.**




### 57. Servicios y DNS

Cuando se crea un servicio, este herda una direccion IP y tambien hereda un DNS.

kubectl get svc 
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    42d
my-service   ClusterIP   10.101.86.254   <none>        8080/TCP   4d20h


Devuelve los servicios,

    kubectl run --rm -ti --generator=run-pod/v1 podtest6 --image=nginx:alpine --sh (DEPRECATED)

    kubectl run podtest6 --rm -it --image=nginx:alpine --command -- sh

    apk add -U curl 

Se le va a hacer un curl al servicio. (10.101.86.254)

    kubectl describe svc my-service
    Name:              my-service
    Namespace:         default
    Labels:            app=front
    Annotations:       <none>
    Selector:          app=front
    Type:              ClusterIP
    IP Family Policy:  SingleStack
    IP Families:       IPv4
    IP:                10.101.86.254
    IPs:               10.101.86.254
    Port:              <unset>  8080/TCP
    TargetPort:        80/TCP
    Endpoints:         10.244.0.102:80,10.244.0.104:80,10.244.0.87:80 + 5 more...
    Session Affinity:  None
    Events:            <none>


No responde nada esta IP:

    / # curl 10.101.86.254


**¿Por que?**

Por que desde la definicion se esta indicando que el servicio va a estar escuchando por el puerto 8080. Ahora se intenta agregando el puerto.

    / # curl 10.101.86.254:8080

Ahora si responde el servidor nginx desde los pods.

Lo que pasa es que cuando se hace la peticion al servicio por el puerto 8080, lo que pasa es que se redirige hacia la ip de un pod, en el puerto 80, obtiene la respuesta y luego la retorna hacia nosotros como un proxy.


El servicio hereda un DNS tambien, asi que si se ejecuta curl con el nombre del servicio, va a funcionar tambien:

        / # curl my-service:8080

Y esto es demasiado util cuando se pretenden llamar diferentes servicios en aplicaciones, por ejemplo se tiene un deployment de pods que funcionan como backend, y se tinee un deployment de pods que funcionan como front.

**¿Entonces como consume el front al backend?**

Se crea un servicio en frente del deployment del backend, y se le hace request al nombre 


### 58. Servicio de tipo ClusterIP


ClusterIP: Es una IP virtual, que kubernetes le asigna al servicio, esta IP es permanente en el tiempo, Kubernetes se va a encargar de mantener esta IP, esta IP es interna al cluster, es decir que utilizando nuestra IP o una IP externa no vamos a poder acceder a ella.

EL profesor si puede acceder con la IP del servicio y el puerto 8080 desde su browser al servidor web nginx (POr que la IP es privada y se esta ejecutando en la maquina local), en mi caso no funciona.

Posibles razones:

- Como esta instalado minikube utilizando maquina virtual.
- puede estar utilizando miniuke service

Si yo quisiera exponer esto a mi IP, es decir a mi red local (LAN). POr que se trata de una IP del tipo 192.168.X.X y se trata de una IP externa al cluster. y la IP del servicio es una IP interna del cluster.

El servicio de tipo cluster IP solamente crea una IP de tipo virtual, que es accesible dentro del cluster. Y esta IP es utilizada para la comunicacion interna entre servicios.

Asi que con esta IP no se podra exponer nada hacia afuera del cluster. Entronces para definir el tipo de servicio, podemos dirigirnos al spec del tipo de servicio.

Para exponer esta IP se va a utilizar algo llamado el NodePort.


### 59. Servicio de tipo NodePort

**"Minikube simula al master y al nodo al mismo tiempo."**

Es basicamente, otro tipó de servicio que funciona similar al CLusterIP peor permite exponer el servicio fuera del cluster.

El cluster IP hace las veces de un balanceador para un grupo de Pods, seleccionados por un label que deberian ser administrados por un deployment. De esta forma se puede acceder al servicio de ClusterIp dentro de este nodo para poder alcanzar los pods.


**¿Si un usuario en internet quisiera acceder al servicio como lo podria lograr?**

El NodePort es basicamente una exposicion del servicio, por medio de un puerto del nodo.
Este Nodo debe tener una IP, asi que se puede exponer un puerto al que el usuario puede llegar. El NodePort es basicamente un puerto que se abre a nivel del nodo. Para permitir el ingreso externo al cluster. Ala abrir este puerto se tiene la capacidad de ingresar al nodo, y una vez se ingrese al nodo se puede ingresar al servicio de cluster IP, que va a ingresar a mi servicio de pods, va a retornar una respuesta al cluster IP, y dicha respuesta retorna al usuario.

El nodeport sirve para exponer un servicio afuera del cluster.
NodePort expone un rango de puertos por defecto.

Kubernetes NodePort Range (30000-32767)

Al crear un servicio NodePort se puede definir el puerto o se toma uno de los por default en el rango anterior.

    kubectl get pods -l app=front
    kubectl get pods -l app=backend

    kubectl get svc -l app=backend

    NAME                  TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
    my-service-nodeport   NodePort   10.106.124.3   <none>        8080:30743/TCP   118m


El servicio NodePort nos entrega el ClusterIP, de todas maneras un NodePort crea un ClusterIP, para lograr la conunicacion fuera del cluster y luego internamente se comunica con el ClusterIP, y se tiene el puerto que se expuso:   (30743)

Nos podemos dar cuenta que ahora si se tiene el servicio por fuera del cluster.

    minikube service my-service-nodeport

    minikube service my-service-nodeport --url
    http://192.168.59.102:30743

O construir la IP manualmente con el puerto del servicio NodePort y la direccion IP de minikube.

    minikube ip

Probar con curl

    curl $(minikube service my-service-nodeport --url)

NodePort permite exponer el servicio por fuera del cluster, NodePort no reemplaza para nada un ClusterIP, NodePort crea un ClusterIP y adicionalmente abre un puerto en el nodo para recibir peticiones externas de fuentes externas. Recibimos en el NodePort y de todas maneras se va a enrutar en el ClusterIP, que esta apuntando hacia nuestros pods.


### 60. Servicio de tipo Load Balancer 

Hace referencia a un servicio de tipo balanceador de carga, En este curso no se va a hacer esta practica por una pequeña limitacion. Los servicios de tipos Load Balancers solamente crean **balanceadores externos** en algun Cloud Provider. Y Kubernetes por defecto no nos ofrece ningun tipo de balanceador, por esta razon solo se va a ver el tema de arquitectura. Cuando se llegue al tema de Cloud, se retoma el tema de balanceadores, 

Se tiene un nodo, lo que hace un tipo de servicio de Load balancer es efectivamente, provisionar un balanceador de carga en el Cloud provider definido,  luego de aprovisionarlo (crearlo en la nube) lo que va a pasar es que se van a abrir NodePorts en cada nodo, para que el usuario pueda acceder al balanceador, y una vez que acceda al balanceador, este va a acceder al NodePort, y una vez se acceda al NodePort vamos a poder acceder al ClusterIP, para acto seguido poder acceder a los pods que estan siendo observados por ese servicio.

Recordar que estos pods deben de estar administrados por algun tipo de controlador, por algun Deployment o algun Replicaset.

En Kubernetes se tienen muchas jerarquias,  de la misma manera que al crear un replicaset creamos pods, o al crear un Deployment creamos replicaset y pods, pasa algo similar, Cuando se crea un ClusterIP no pasada nada, solamente se crea un ClusterIP, cuando se crea un NodePort se esta creando automaticamente un ClusterIP mas un NodePort. Cuando se crea un balanceador, se esta creando un NodePort y al tiempo se esta creando un ClusterIP. Todo esto para que la comunicación pueda fluir de esta manera:

El usuario le hace una solicitud al balanceador de carga, el balanceador de carga llega a los Nodos, (NodePort) y de esta manera puede ingresar al cluster. Normalmente estos balanceadores suelen estar en una subnet publica, es decir que tienen acceso a internet, (EL usuario puede ver el balanceador desde internet) pero es muy probable que la comunicacion hacia el nodo, desde el balanceador se haga por una subnet privada, es decir que normalmente este nodo no deberia tener acceso a internet, exponiendo directamente una IP publica.

Por ahora no se va a utilizar, se requiere disponer de una cuenta de Cloud Provider. Esto se aborda cuando se vean los temas de ingress y los temas de Cloud.


## Section 10: Golang, Javascript y Kubernetes 


### 61. Introducción

Crear un servicio front, se van a tener n pods corriendo un servicio front que se va a escribir que va a estar administrado por un deployment. 
Este servicio front lo que va a hacer es conectarse con otros pods, que van a estar corriendo un servicio de Backend que deben de estar administrador por un Deployment 

La diferencia entre el Backend y el Frontend es que:

1. Frontent va a tener un servicio de tipo NodePort. 
2. Backend va a tener un servicio de Tipo ClusterIP.

El usuario va a solicitar por el front (Su punto de acceso a la aplicacion / Nuestra pagina web).
Asi que el usuario necesita que se le exponga el servicio. Por lo tanto se va a crear un NodePort, recordemos que el NodePort tambien crea un ClusterIP.

"Cuando el usuario llegue por el NodePort va a llegar al servicio de CLusterIP, y el ClusterIP va a enviar la solicitud hacia los pods, que se tienen corriendo con el label que se definio en el ClusterIp.

El front le va a hacer una peticion GET por http a nuestro backend. Asi que muy probablemente el backend sea un servicio REST. La idea es construir una pagina web muy sencilla, que va a obtener la informacion del backend, por medio de servicios, y se la va a devolver a nuestro usuario.


### 62. Notas sobre Golang

En este video, utilizaremos Golang para crear nuestra API. Para facilitar el proceso, usaremos Docker. 🐳

🔹 Si no tienes Docker:
No te preocupes. Puedes descargar la versión 1.13 de Golang para tu sistema operativo y simplemente ejecutar:

go run main.go
Esto iniciará la aplicación sin necesidad de Docker.

🔹 Si sí usas Docker:
En el video, utilizaremos el siguiente comando:

docker run --net host
Sin embargo, si tienes Docker en VirtualBox o en otra máquina distinta a la tuya, podrías tener problemas de conexión. En ese caso, en lugar de --net host, usa:

docker run -p 9090:9090
Luego, accede a tu aplicación en:
👉 http://localhost:9090


### 63. Golang: Empieza a escribir tu API

Va a ser un servicio REST que va a devolver la hora actual, y el nombre del pod es decir el hostname ue ejecuto esa tarea. Se usara Go por que no se necesitan utilizar librerias externas por lo que va a ser muy facil crear el contenedor.

**Se pudo haber escrito en python pero se necesitaria flask, o en node.js y se necesitaria express, con Go es bastante facil.**

API de Referencia:

    https://dev.to/moficodes/build-your-first-rest-api-with-go-2gcj


1.23.2

docker run --rm -dti --net host --name golang golang bash

docker ps  -l

docker rm -fv 

docker run --rm -dti -v $PWD/:/go --net host --name golang golang bash


docker pull golang:1.25.1

golang:1.25.1-alpine - Versión ligera basada en Alpine Linux
golang:1.25.1-bullseye - Basada en Debian Bullseye
golang:1.25.1-bookworm - Basada en Debian Bookworm

https://hub.docker.com/r/bitnami/golang


    docker run --rm -dti -v $PWD/kubernetes-master/k8s-hands-on:/app -w /app --net host --name go-k8s-hands-on golang bash

    docker exec -it go-k8s-hands-on bash

    go run main.go

Este servicio aun no devuelve nada dinamico, no devuelve la hora ni el hostname, solamente un string.


### 64. Golang. Ultimos detalles

"El curso esta orientado a Kubernetes, en K8s se necesitan aplicaciones funcionales" Por lo tanto se esta escribiendo esta.

Se necesita una aplicacion funcional que devuelva algo para poder aprender como utilizar Kubernetes.


### 65. Notas sobre Dockerfile para Golang

Esta nota es solo para quienes no tienen Docker en su sistema y no pueden construir la imagen.

image: ricardoandre97/backend-k8s-hands-on:v1

### 66. Crea un Dockerfile para tu aplicación en Golang

    docker build -t k8s-hands-on -f Dockerfile .

    docker run -d -p 9091:9090 --name k8s-hands-on k8s-hands-on

Asi se facil deberia ser para correr el contenedor que tiene el binario de la app.

Se logra construir el Dokcerfile para la app, el servicio ya puede correr en un contenedor y esta esperando request desde cualñquier otro servicio o aplicacion.

    docker rm -fv k8s-handson-on


### 67. Notas sobre manifiestos de Kubernetes


En el siguiente video, desplegaremos un par de objetos en Kubernetes. Uno de ellos será un servicio de tipo ClusterIP.

🔹 Cómo probar el servicio?
Para verificar que el servicio funciona, en el video seguimos estos pasos:

1️⃣ Ejecutamos:

kubectl get svc
2️⃣ Tomamos la IP del servicio y la colocamos en el navegador.

📌 Esto asume que tu clúster de Kubernetes está desplegado en tu propia máquina.

🔹 ¿Y si mi clúster está en otra máquina o en la nube?
Si tu clúster de Kubernetes está en otra máquina o en la nube, no podrás acceder directamente a la IP del ClusterIP, ya que esta solo es accesible internamente.

Para solucionarlo, puedes usar kubectl port-forward (similar a docker run -p 9090:9090):

kubectl port-forward service/<nombre-del-servicio> 9090:80
Esto mapeará el puerto 80 del servicio interno al puerto 9090 en tu máquina, permitiéndote acceder con:

👉 http://localhost:9090


### 68. Escribe manifiestos de Kubernetes para desplegar tu aplicación

Deberia crear un deployment tambien un servicio apuntando a los pods con label backend.

    kubectl apply -f backend.yaml

    deployment.apps/backend-k8s-hands-on created
    service/backend-k8s-hands-on created


    NAME                                    READY   STATUS    RESTARTS   AGE
    backend-k8s-hands-on-7f69954bd5-7jgcs   1/1     Running   0          7m46s
    backend-k8s-hands-on-7f69954bd5-l7w9p   1/1     Running   0          7m46s
    backend-k8s-hands-on-7f69954bd5-tw465   1/1     Running   0          7m46s

En caso de error se debe utilizar el image pull policy:

    imagePullPolicy: IfNotPresent
    Puede ser always


Pude acceder como NodePort

    minikube service backend-k8s-hands-on --url
    http://192.168.59.102:30542/


**No pude acceder con ClusterIP**

¿Quién puede acceder a ClusterIP?
Solo estos pueden acceder:

Otros pods dentro del cluster

# Desde otro pod, puedes hacer:

    curl http://backend-k8s-hands-on.default.svc.cluster.local
   
O simplemente:
   
    curl http://backend-k8s-hands-on

Usando kubectl port-forward (crea un túnel temporal)

    kubectl port-forward service/backend-k8s-hands-on 8080:80
   
   # Ahora puedes acceder en: http://localhost:8080


Andre accede con un cluster IP y no usa minikube tunnel


diegoall@ph03nix:~/courses/pro-kubernetes/kubernetes-master/k8s-hands-on/backend$ minikube service backend-k8s-hands-on --url
😿  service default/backend-k8s-hands-on has no node port
❗  Services [default/backend-k8s-hands-on] have type "ClusterIP" not meant to be exposed, however for local development minikube allows you to access this !

**El servicio es servido por pods distintos cuando se prueba con curl.**


### 69. Aprender a consumir el servicio que creaste 

Se va a ingresar a un pod y se va a generar una request POST, solamente para intentar hacer un llamado a la ip del servicio. Y ver sis e logra tener una respuesta desde el servicio, (Es el punto de entrada, y cuando se llama el va a traer la respuesta desde los pods  que cumplan con el label backend)

    kubectl run podtest3 --rm -it --image=nginx:alpine -- sh

    / # curl 10.111.65.200
    {"time":"2025-10-01T02:44:19.248857054Z","hostname":"backend-k8s-hands-on-797446b86d-jjgkx"}/ # 

**Si se repite la request se evidencia que cambia el pod que responde, se corrobora que el servicio esta funcionando bien y que adicionalmente todos los request que entren por el puerto 80 estan siendo redirigidos a los pods en el puerto :9090**

Tambien se puede validar el DNS.

    / # curl backend-k8s-hands-on
    {"time":"2025-10-01T02:47:57.032559229Z","hostname":"backend-k8s-hands-on-797446b86d-jjgkx"}/

Es decir que el servicio esta funcionando con el DNS y tambien con la dirección IP. De esta manera es como se va a llamar desde el front, el servicio del backend.


### 70. Notas sobre acceder pods


En el siguiente video, intentamos nuevamente acceder directamente a la IP de un pod. Esto funciona si tu clúster de Kubernetes está en tu máquina.

Sin embargo, si tu clúster está en otra máquina o esta opción no te funciona, puedes usar kubectl port-forward.

🔹 Acceder a un pod con kubectl port-forward
Este comando es similar a docker run -p 9090:9090 y te permite acceder al pod desde tu máquina local.

kubectl port-forward <nombre_del_pod> <puerto_en_tu_maquina>:<puerto_del_pod>
📌 Ejemplo:
Si el puerto del pod es 9090 y quieres verlo en tu maquina en http://localhost:9091, usa:

kubectl port-forward <nombre_del_pod> 9091:9090

    https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/


### 71. Empieza a escribir el cliente Javascript que consumira tu Backend en Go 

Desde el pod temporal

    / # curl backend-k8s-hands-on
    {"time":"2025-10-01T02:47:57.032559229Z","hostname":"backend-k8s-hands-on-797446b86d-jjgkx"}/


La peticion javascript se hace desd el navegador, y desde este no se puede ver este nombre: (backend-k8s-hands-on), por que es un nombre local, es un DNS interno del cluster,  y el navegador es algo externo, asi que se podra ver es utilizando la direccion IP

Se va a reemplazar el index.html que viene por default en nginx por el que se consulta en la web para ejecutar la request javascript.

El parametro por ahora se puede dejar asi:

    var url = "http://backend-k8s-hands-on";


Pero cuando se haga el llamado desde javascript en el navegador, se va a quejar por qeu este DNS no existe en el navegador es algo solamente interno, por ahora se puede dejar asi, y luego se cambia por la direccion IP.





Luego se inicia el servicio de nginx, con el comando nginx.

    <div id="id01"></div>

    <script>
    var xmlhttp = new XMLHttpRequest();
    var url = "http://backend-k8s-hands-on";

    xmlhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            var resp= JSON.parse(this.responseText);
            document.getElementById("id01").innerHTML = "<h2>La hora es: " + resp.time + "</h2>";

        }
    };

    xmlhttp.open("GET", url, true);
    xmlhttp.send();

    </script>

Como se creo un pod plano sin ningun controlador, solamente para el ejemplo. Se va a listar los pods para ver su IP. 

    podtest3                                1/1     Running   0          32m   10.244.0.134   minikube   <none>           <none>


Recrdar que esta IP es interna, solamente la podemos ver (nosotros). "Docente"

**En el tutorial (IP 172.17.x.x)**

Esa IP 172.17.0.17 corresponde a la red bridge de Docker.

🔹 1. Diferencia de red CNI

En tu entorno, los Pods reciben IPs 10.244.x.x. Eso es típico cuando Minikube usa CNI (Container Network Interface) como flannel, calico, etc.

En ese esquema, las IPs de los Pods están en una red privada solo accesible desde dentro del clúster.

En el video, los Pods estaban recibiendo IPs 172.17.x.x.
Eso es la red bridge de Docker, que sí es alcanzable desde el host.
Eso significa que Minikube estaba configurado con el driver de Docker y sin un CNI adicional, por lo que los Pods quedaban directamente expuestos en esa red.

🔹 2. Driver de Minikube

Cuando arrancas Minikube, eliges un driver (docker, virtualbox, kvm, etc).

Si usas --driver=docker, Minikube corre como un contenedor dentro de Docker, y los Pods pueden usar la red 172.17.0.0/16 que sí es accesible desde el host.

Si usas --driver=virtualbox o incluso --driver=docker + CNI, Minikube monta una red interna distinta (10.244.0.0/16), no visible desde tu navegador.

🔹 3. Conclusión

En el video:

Minikube estaba corriendo con el driver docker y sin CNI extra → Pods con IP 172.17.x.x accesibles desde el host.

En tu caso:

Minikube está corriendo con un CNI (flannel) → Pods con IP 10.244.x.x no accesibles desde el host sin un Service.


**⚡ Opciones para que tengas el mismo comportamiento que en el video:**

Levantar Minikube con el driver docker y sin CNI extra:

    minikube start --driver=docker --network-plugin=cni=false --cni=false


Eso debería darte Pods en 172.17.x.x accesibles desde el host.

O, con tu configuración actual (10.244.x.x), exponer el Pod con:

    kubectl expose pod podtest3 --type=NodePort --port=80
    minikube service podtest3 --url


diegoall@ph03nix:~/courses/pro-kubernetes$ minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured


diegoall@ph03nix:~/courses/pro-kubernetes$ minikube profile list
|----------|------------|---------|----------------|------|---------|---------|-------|----------------|--------------------|
| Profile  | VM Driver  | Runtime |       IP       | Port | Version | Status  | Nodes | Active Profile | Active Kubecontext |
|----------|------------|---------|----------------|------|---------|---------|-------|----------------|--------------------|
| minikube | virtualbox | docker  | 192.168.59.102 | 8443 | v1.30.0 | Running |     1 | *              | *                  |
|----------|------------|---------|----------------|------|---------|---------|-------|----------------|--------------------|


Para no cambiar la configuracion a Docker por que se usa Virtual Box.
Se puede hacer lo siguiente:

1️⃣ Exponer el Pod

    kubectl expose pod podtest3 --type=NodePort --port=80

2️⃣ Ver el puerto asignado

    kubectl expose pod podtest3 --type=NodePort --port=80
    service/podtest3 exposed
    kubectl get svc
    NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
    backend-k8s-hands-on   ClusterIP   10.111.65.200   <none>        80/TCP         26h
    kubernetes             ClusterIP   10.96.0.1       <none>        443/TCP        49d
    podtest3               NodePort    10.98.248.93    <none>        80:31647/TCP   4s


Luego accedo desde mi maquina local con la IP del cluster y el puerto asignado:

    minikube ip

http://192.168.59.102:31647/  (Ahora ya se puede acceder)



El profesor le da un problema de CORS, a mi me da otro.



### 72. Notas sobre acceder a un backend desde javascript


En el siguiente video intentaremos acceder al servicio desplegado en http://backend-k8s-hands-on desde tu navegador usando JavaScript.

🔹 Nota importante:
JavaScript intentará acceder a tu servicio desde tu navegador, por lo que este debe tener acceso al host.
📌 Si tu clúster de Kubernetes no está en tu máquina local, esto causará problemas.

🔹 Solución en 2 pasos  (Solo si tienes problemas):


1️⃣ Abre una terminal y haz un port-forward de tu servicio

# Mapea el puerto 80 de tu máquina al puerto 80 del servicio  
kubectl port-forward service/backend-k8s-hands-on 80:80 
2️⃣ Modifica tu archivo hosts para que el navegador pueda acceder al backend

# Abre el archivo hosts (en Linux y macOS)  
sudo vi /etc/hosts 
# Agrega esta línea al final:
127.0.0.1 backend-k8s-hands-on  
Guarda los cambios y cierra el archivo.

✨ ¡Listo! Ahora ve a http://backend-k8s-hands-on en tu navegador y deberías ver el servicio sin problemas. 🚀



### 73. Despliega una nueva versión de tu Backend para resolver errores en el FrontEnd

Modificar desde el backend este header para que permita el acceso a todos.

	w.Header().Set("Access-Control-Allow-Origin", "*")


El tema es que esto es una imagen de Docker y esta desplegado en Kubernetes,asi que se debe construir una imagen nueva y luego aplicarlo en el Deployment.
Por ahora toca ejecutar: 

    eval $(minikube -p minikube docker-env)
    docker build -t k8s-hands-on:v2 -f Dockerfile .

Es decir se esta creando un nuevo replicaset con pods nuevos y se van eliminando los antiguos y creando los nuevos. Para no tener Downtime es decir para que nuestro servicio siempre este arriba.

Se puede utilizar este comando para no tener que estar ejecutando cada cierto tiempo:

    kubectl get pods --watch 

Ahora que el backend esta corregido con un nuevo header se va a intentar de nuevo en Javascript.

Aparece este error:

    backend-k8s-hands-on/:1  Failed to load resource: net::ERR_NAME_NOT_RESOLVED

1. El frontend usa http://backend-k8s-hands-on como URL, pero:

- Ese nombre solo existe como Service dentro del cluster de Kubernetes.

- El navegador en tu máquina no conoce ese DNS interno → por eso falla la resolución.


2. El backend escucha en el puerto 9090, pero tu Service (podtest3) está exponiendo el puerto 80.

Eso quiere decir que aunque logres conectar, estarías apuntando al puerto incorrecto.

Debes mapear el puerto 9090 del contenedor al puerto 80 (o al NodePort) en el Service.


Opción 1: Usar el NodePort/IP directamente

    var url = "http://192.168.59.102:31647";

Así apuntas desde tu navegador al backend expuesto por Kubernetes.


Opción 2: Ajustar el Service para mapear el puerto real



#######################


- podtest3 : frontend

- 3 pods con el backend  (Por mi caso hay un nodeport en el Service)

        type: NodePort
        ports:
            - port: 80
            targetPort: 9090
            protocol: TCP

- No utilice el expose, solo cambie de ClusterIp a NodePort.


### 74. Valida que tu servicio FrontEnd este funcionando como deberia

**El problema del balanceo de carga**

Estás viendo siempre el mismo pod (backend-k8s-hands-on-68ff95bcf4-twshs) porque el balanceo de carga en Kubernetes funciona a nivel de conexión TCP, no de petición HTTP.

**¿Qué está pasando?**

Cuando accedes desde el navegador a través de NodePort:

Tu navegador reutiliza la misma conexión TCP para múltiples peticiones (HTTP Keep-Alive)
Kubernetes balancea por conexión, no por petición individual
Una vez establecida la conexión con un pod, todas las peticiones van al mismo pod mientras la conexión esté activa

Soluciones para ver el balanceo funcionando:
Opción 1: Usar curl desde la terminal (la más fácil)
Cada ejecución de curl crea una nueva conexión:

Ahora si despues de corregida le IP en el frontend en el pod directamente, se puede ver que cambia el pod que responde


Con curl se puede notar que si cambia el pod que responde, no es como http.

curl -s http://192.168.59.102:32735/
{"time":"2025-10-01T06:16:27.654341286Z","hostname":"backend-k8s-hands-on-68ff95bcf4-twshs"} 
curl -s http://192.168.59.102:32735/
{"time":"2025-10-01T06:16:30.647040428Z","hostname":"backend-k8s-hands-on-68ff95bcf4-2d9rc"}
 curl -s http://192.168.59.102:32735/
{"time":"2025-10-01T06:16:35.175963498Z","hostname":"backend-k8s-hands-on-68ff95bcf4-2d9rc"}
curl -s http://192.168.59.102:32735/
{"time":"2025-10-01T06:16:40.751668639Z","hostname":"backend-k8s-hands-on-68ff95bcf4-2d9rc"}
 curl -s http://192.168.59.102:32735/
{"time":"2025-10-01T06:16:45.237514267Z","hostname":"backend-k8s-hands-on-68ff95bcf4-twshs"}


COn curl se pueden ver respuestas de diferentes pods y desd el browser se ve siempre el mismo pod respondiendo:

Lo que estás observando es la diferencia entre cómo balancea Kubernetes el tráfico de un Service dependiendo del cliente:


Con curl desde la terminal:
Cada petición es una nueva conexión HTTP independiente (no mantiene keep-alive).
→ El Service de Kubernetes reparte las peticiones entre los pods del backend de manera round-robin (o según el algoritmo de kube-proxy en tu cluster).
→ Por eso ves que a veces responde un pod y a veces otro (twshs, 2d9rc, etc.).

Con el navegador:
El navegador mantiene una conexión persistente (HTTP keep-alive) con el pod que respondió primero.
→ Eso significa que todas las peticiones siguientes viajan por el mismo socket TCP y llegan al mismo pod, sin re-balanceo.
→ Por eso siempre ves el mismo pod (njjgj) en tus pruebas desde el browser.

🔎 En resumen:

curl → nuevas conexiones cada vez → balanceo entre pods.

navegador → conexión persistente → siempre el mismo pod (hasta que la conexión se cierre o expire).

👉 Si quisieras que el navegador también balanceara en cada request, tendrías que deshabilitar keep-alive o forzar nuevas conexiones (no es lo usual, ya que keep-alive mejora el rendimiento).


### 75. Notas sobre el servicio front

Recuerda que si tu cluster no es local, no tendra acceso a las imagenes de Docker y puede que tu pod falle con un error, diciendo que no puede bajar la imagen.

Asi que para solucionarlo, solo usa esta imagen:


frontend-k8s-hands-on:v1


### 76. Crea los manifiestos de K8s para desplegar tu servicio Front  

El puerto que ejecuta nginx es el 80


### 77. Crea un Dockerfile para tu aplicación en Javascript

    eval $(minikube -p minikube docker-env)
    docker build -t frontend-k8s-hands-on:v1 -f Dockerfile .


### 78. Despliega los servicios y valida su funcionamiento

kubectl get pods -l app=frontend
NAME                                     READY   STATUS    RESTARTS   AGE
frontend-k8s-hands-on-68f7db6c6d-648gr   1/1     Running   0          2m3s
frontend-k8s-hands-on-68f7db6c6d-hvvq9   1/1     Running   0          2m4s
frontend-k8s-hands-on-68f7db6c6d-pmqxw   1/1     Running   0          2m5s

kubectl get svc
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
backend-k8s-hands-on    NodePort    10.111.65.200    <none>        80:32735/TCP   2d2h
frontend-k8s-hands-on   NodePort    10.101.246.141   <none>        80:30433/TCP   4m39s
kubernetes              ClusterIP   10.96.0.1        <none>        443/TCP        50d
podtest3                NodePort    10.98.248.93     <none>        80:31647/TCP   23h


El servicio tiene NodePort por ende se puede realizar un llamado desde fuera del cluster.
Validar que el servicio este funcionando como se debe desde el navegador:

    http://192.168.59.102:30433/

La respuesta es:

La hora es: 2025-10-02T03:47:10.544860963Zy el hostname es backend-k8s-hands-on-68ff95bcf4-njjgj

Si yo quisiera que alguien vea este servicio lo que se puede hacer es utilizar la IP actual de la maquina.  

Se prueba y no se puede acceder, se valida el NodePort y se cuenta con un rango y en kubernetes asigna un puerto dentro de ese rango por defecto.

ip a
192.168.1.73

✅ Funciona: http://192.168.59.102:30433 (IP de Minikube)
❌ No funciona: http://192.168.1.73:30433 o http://192.168.1.49:30433 (IPs de tu host)

Es por el mismo tema de siempre, Andre esta utilizando otro driver.


Para poder alcanzar el frontend que esta al interior del cluster en minikube se puede hacer un port forward y se logra acceder desde el navegador local.

http://localhost:30433/
La hora es: 2025-10-02T04:04:04.977288315Zy el hostname es backend-k8s-hands-on-68ff95bcf4-njjgj

Solo se puede acceder con localhost:

http://192.168.1.73:30433/
http://192.168.1.49:30433/


Con las IPs asociadas a las interfaces no se puede entrar.

En resumen se vio como se pueden generar comunicaciones, entre deployments por medio de servicios.


## Section 11: Namespaces & Context - Organizar y aislar los recursos


### 79. Nota sobre el siguiente video

Bobada de un bug

### 80. ¿Que es un namaespace?

Separacion logica que nos brinda un scope, es unmo un limite, (Nos limita a ciertas cosas).

En la documentacion de kubernetes dicen que un namespace sirve para crea run cluster virtual. 

Todos los recursos que se creen, por ejemplo un deployment, un replicaset, un pod, etc. en un namespace y luego se crean otros objetos en otro namespace van a estar completamente aislados.

Ayuda a separar logicamente el cluster para aprovechar los recursos, digamos que no se quiere crear un cluster para cada ambiente, se considera crear un cluster para los 2 ambientes, se crea el namespace de Dev y luego el namespace de UAT sin ningun problema utilizando los mismos recursos sin nigun problema y esto nos evita tener que crear otro cluster nuevo.

Tambien sirven para poder tener diferentes proyectos, o tambien se pudiera no usar namespaces sino labels con los nombres de los proyectos.

para manejar diferentes equipos, uno para la gente de desarrollo, para la gente de finanzas o algo por el estilo. Y ayuda a separarlos de manera logica, es decir que el que tenga acceso al siguiente namespace, 

Nos ayuda a controlar muchos tipos de recursos, Ejemeplo, yo quiero que aquis e creen solamente 10 pods, y eso es muy bueno. Tambien nos ayuda a controlar por ejemplo que aca los pods de este namespace no superen 500 mb de ram cada uno, Se quiere que en este namespace no se consuman mas de 50 mb de ram,   

Puede ayudar con autorizacion, este usuario puede hacer estas acciones en este namespace, ayuda tambien a controlar autorizacion,

- Limite para usuarios, numero de objetos que podemos crear, es decir limites en los recursos de la API, limites por pod, por recurso, por objeto, limites por defecto si no se los colocan, limites a nivel de namespace, a nivel de cuanto maximo voy a permitir en recursos de hardware, 

### 81. Namespaces por defecto

    kubectl get namespaces

    kubectl get pods --namespace default

- default: es para todos los objetods que no especifiquen un namespace.
- kube-node-lease: Destinado a almacenar objetos de tipo Lease asociados a cada nodo del clúster.
- kube-public
- kube-system: contiene todos los objetos de kubernetes (kube-proxy) por que se esta actuando como nodo.
- 

    kubectl get all -n kube-node-lease


### 82. Crea tu primer Namespace

    kubectl create namespace test-ns

    kubectl get namespaces --show-labels

No resource quota.

era un convertidor decente.

https://www.bairesdev.com/tools/json2yaml/

    kubectl apply -f ns.yaml

    kubectl get namespaces --show-labels
    NAME                   STATUS   AGE   LABELS
    default                Active   50d   kubernetes.io/metadata.name=default
    development            Active   55s   kubernetes.io/metadata.name=development,name=development




### 83. Objetos en un Namespace


kubectl get deploy -n prod
NAME              READY   UP-TO-DATE   AVAILABLE   AGE
deployment-prod   2/2     2            2           4m39s

kubectl get deploy -n dev
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
deployment-dev   1/1     1            1           4m43s


### 84. DNS en los servicios de un Namespace

    kubectl get pods -n "prod"
    kubectl get svc -n ci


Crear un pod en el namespace default y se va a intentar acceder al backend creado anteriormente.

kubectl run --rm -ti --generator=run-pod/v1 podtest-random --image=nginx:alpine -- sh



Como se crean los DNSs?
Cuando los servicios que se estan creando, viven en un namespace y eso aplica incluso para el default.

    svcName + nsName + svc.cluster.local


Considerando que la api esta en otro namespace

    / # curl backend-k8s-hands-on.ci.svc.cluster.local
    {"time":"2025-10-03T02:52:29.377318565Z","hostname":"backend-k8s-hands-on-68ff95bcf4-wnmd4"}


kubectl get all -n ci
NAME                                        READY   STATUS    RESTARTS   AGE
pod/backend-k8s-hands-on-68ff95bcf4-kns8x   1/1     Running   0          13m
pod/backend-k8s-hands-on-68ff95bcf4-nksg6   1/1     Running   0          13m
pod/backend-k8s-hands-on-68ff95bcf4-wnmd4   1/1     Running   0          13m

NAME                           TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/backend-k8s-hands-on   NodePort   10.111.92.174   <none>        80:32410/TCP   13m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend-k8s-hands-on   3/3     3            3           13m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/backend-k8s-hands-on-68ff95bcf4   3         3         3       13m

Notese que se esta haciendo esta peticion desde el namespace de default.
Sino se le pasa el FQDN no se va a poder resolver porque el lo que hace ahora mismo. 

    / # curl backend-k8s-hands-on.ci
    {"time":"2025-10-03T02:58:13.816117391Z","hostname":"backend-k8s-hands-on-68ff95bcf4-kns8x"}/ 


### 85. Notas sobre el contexto

En el siguiente video, verás cómo acceder al archivo de configuración de Kubernetes.

Por defecto, este archivo se encuentra en:

$HOME/.kube/config
📌 Importante:
Si creaste el clúster con un usuario sin privilegios de root, el archivo estará en:

$HOME/.kube/config
Sin embargo, en mi caso, como creé el clúster de Minikube con el usuario root, mi $HOME es /root, por lo que (en mi caso) el archivo se encuentra en:

/root/.kube/config


### 86. Aprende a utilizar el contexto 

    kubectl config current-context
    
    kubectl config view

Enlazar namespace a un contexto  

    kubectl config set-context ci-context --namespace=ci --cluster=minikube --user=minikube
    Context "ci-context" created.

    kubectl config get-contexts
    CURRENT   NAME         CLUSTER    AUTHINFO   NAMESPACE
            ci-context   minikube   minikube   ci
    *         minikube     minikube   minikube   default

¿Como podemos ahora cambiarnos hacia ese contexto?

    kubectl config use-context ci-context


    kubectl config use-context ci-context
    Switched to context "ci-context".

    kubectl get pods
    NAME                                    READY   STATUS    RESTARTS   AGE
    backend-k8s-hands-on-68ff95bcf4-kns8x   1/1     Running   0          90m
    backend-k8s-hands-on-68ff95bcf4-nksg6   1/1     Running   0          90m
    backend-k8s-hands-on-68ff95bcf4-wnmd4   1/1     Running   0          90m

    kubectl config use-context minikube
    Switched to context "minikube".

    kubectl get pods
    NAME             READY   STATUS    RESTARTS   AGE
    podtest-random   1/1     Running   0          84m


**Es mas comodo crear el contexto y luego usar el contexto para ejecutar todos los comandos que se necesiten alli, sin necesidad de pasar el parametro -n que es algo tedioso**


## Section 12: Limita la RAM y la CPU que pueden utilizar tus pods


### 87.¿Por que deberias empezar a usar limites?

Como limitar un pod para que no consuma mas de x cantidad de RAM y de CPU.

Imaginarse 1 nodo que tiene 1 CPU y que tiene 1 GB de RAM.
Si no se colocan limites lod pods podrian consumirse el CPU completo e igualmente para la RAM.

Si un pod es capaz de consumir todos los recursos del nodo significa que es capaz que el nodo se caiga.
Por eso es importante poder limitar el consumo de recursos de los pods.

RAM: bytes, Mb, Gb
CPU: 

1 CPU significa 1000 milicores, esto significa que para limitar un contenedor al 10 % de la CPU, 
Se le puede decir que utilice el 0.1 de esa CPU, es decir 100 milicores 


### 88. ¿Que son los limits y los request?


Request: Cantidad de recursos de las que siempre el pod va a poder disponer.
Digamos que un pod siempre va a necesitar 20 Mb de RAM, (esa ejecutando un servicio ligero), si se solocan 20 Mb de RAM como request, Kubernetes se va a encargar de colocar este pod donde le pueda dar 20 Mb de RAM (Los va a garantizar, de forma dedicada). 

Limits: Es algo distinto,  si se tiene un limite de 30 Mb significa que se esta pasando 10 Mb del valor del request, esto significa que el pod va a poder acceder a 30 Mb de RAM ¿Cual es la diferencia?
Que estos 20 Mb son garantizados, los 10 adicionales no son garantizados.

Que pasa el el pod sobrepasa estos 30 Mb de limite, entra Kubernetes, ya se permitio aumentar en 10 Mb que fue lo que me dieron de limite, cuando llegue a este limite Kubernetes lo va a eliminar o lo va a reiniciar. Esto depende mucho de las politicas de reinicio del pod,  

De esta forma se puede decir que un request es basicamente la capacidad en recursos garantizada que tiene un pod, y los limites una posibilidad de incremento temporal pero no garantizada.


### 89. ¿Que sucede si un pod supera el request pero no el limite en RAM?

Se puede limitar contenedor por contenedor, esto es gracias al namespace del Cgroup, que cada contenedor dentro del pod mantiene como individual.

    pod-limit-ram.yaml



### 90. ¿Que sucede si un pod supera el limite de RAM?


### 91. ¿Qué sucede si ningun nodo tiene la RAM solicitada por un pod?



### 92. Limita los recursos de la cpu



### 93. ¿Que sucede si ningun nodo tiene la cpu solicitada por un pod?




### 94. QoS Classes


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



