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

El profesor si puede acceder con la IP del servicio y el puerto 8080 desde su browser al servidor web nginx (POr que la IP es privada y se esta ejecutando en la maquina local), en mi caso no funciona.

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

otro manifiesto, estresan el cluster 

$ kubectl apply -f limit-ram2.yaml 
pod/memory-demo created

$ kubectl get pods
NAME          READY   STATUS             RESTARTS     AGE
memory-demo   0/1     CrashLoopBackOff   1 (7s ago)   10s

$ kubectl get pods --watch
NAME          READY   STATUS      RESTARTS      AGE
memory-demo   0/1     OOMKilled   2 (18s ago)   21s
memory-demo   0/1     CrashLoopBackOff   2 (11s ago)   28s
memory-demo   0/1     OOMKilled          3 (28s ago)   45s
memory-demo   0/1     CrashLoopBackOff   3 (13s ago)   57s


**OOMKilled: Out of memory**


Indica que el contenedor esta utilizando mas memoria RAM de la que esta definida en los limites. POr lo tanto kubernetes va a intentar reiniciarlo un par de veces, para ver si logra recuperarse, para liberar al RAM e iniciar de nuevo.


    kubectl get pods memory-demo -o yaml

  - containerID: docker://0df86aff1418cd18851871783018b5db1fdd8b5710ecb4dbc24b09bcd9160b69
    image: polinux/stress:latest
    imageID: docker-pullable://polinux/stress@sha256:b6144f84f9c15dac80deb48d3a646b55c7043ab1d83ea0a697c09097aaad21aa
    lastState:
      terminated:
        containerID: docker://0df86aff1418cd18851871783018b5db1fdd8b5710ecb4dbc24b09bcd9160b69
        exitCode: 1
        finishedAt: "2025-10-03T16:04:29Z"
        reason: OOMKilled
        startedAt: "2025-10-03T16:04:29Z"
    name: memory-demo-ctr
    ready: false
    restartCount: 5
    started: false
    state:
      waiting:
        message: back-off 2m40s restarting failed container=memory-demo-ctr pod=memory-demo_default(6c91932f-54ef-4c8c-81da-cb795ad44e27)
        reason: CrashLoopBackOff

### 91. ¿Qué sucede si ningun nodo tiene la RAM solicitada por un pod?

limit-ram3.yaml


$ kubectl apply -f limit-ram3.yaml
pod/memory-demo created

$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
memory-demo   0/1     Pending   0          4s

$ kubectl get pods --watch
NAME          READY   STATUS    RESTARTS   AGE
memory-demo   0/1     Pending   0          15s


Pending: esta en espera de encontrar un nodo en el que pueda satisfacer sus necesidades, un nodo que tenga 1000 Gb de RAM donde pueda satisfacer el request de este pod, pero obviamente esto nunca va a pasar por lo tanto siempre va aq quedar en ese status Pending.

kubectl describe pod/memory-demo

Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  4m30s  default-scheduler  0/1 nodes are available: 1 Insufficient memory. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod.




### 92. Limita los recursos de la cpu

Segun lo aprendido el contenedor deberia ser reiniciado.
Con la CPU la declaracion es muy parecida, pero lo diferente es que kubernetes no va a reiniciar el pod, cuando el pod consuma mas de sus limites, en este caso lo que va a hacer kubernetes, es sencillamente garantizar que el pod no va a aumentar el consumo a mas de 1 CPU, de su limite asi se le pidan 2 CPus, el pod no se va a reiniciar ni a eliminar solo llega al limite y ya.

**"Kubernetes garantiza que en CPU no va a consumir mas de su limite"**

Para ver esto tendriamos que tener instalado el metrics server, que es una herramienta (plugin de kubernetes) que permite recolectar metricas.

Como no esta instalado se puede ver el uso del nodo, es decir el uso de la maquina.

    kubectl describe node minikube

    Allocated resources:
    (Total limits may be over 100 percent, i.e., overcommitted.)
    Resource           Requests     Limits
    --------           --------     ------
    cpu                1350m (27%)  1 (20%)
    memory             260Mi (6%)   170Mi (4%)
    ephemeral-storage  0 (0%)       0 (0%)
    hugepages-2Mi      0 (0%)       0 (0%)

Se tienen allocados 1'3 CPUs.

Y se solicitaron 2 CPUs.

    args:
    - -cpus
    - "2"

Por lo tanto deberia de tener 2 CPUs allocadas, lo que hace kuberntes es garantizar que el pod no va a sobrepasar el limite en terminos de CPU.

Si una aplicacion consume mas CPU de la que se le esta siendo entregada, se van a tner problemas de rendimiento y se colocaria lenta de a poco.


### 93. ¿Que sucede si ningun nodo tiene la cpu solicitada por un pod?

Se le va a solicitar a kubernetes muchisima CPU, es decir muchas unidades mayores a las que tienen nuestros nodos. Se le va a solicitar 100 CPUs por ejemplo.

Probablemente este pod no va a encontrar una maquina con 100 CPUs, por que las maquinas probablemente tengan menos, en este caso nuestro nodo.

    kubectl describe node minikube

Capacity:
  cpu:                5
  ephemeral-storage:  22747616Ki
  hugepages-2Mi:      0
  memory:             4010492Ki
  pods:               110
Allocatable:
  cpu:                5
  ephemeral-storage:  22747616Ki
  hugepages-2Mi:      0
  memory:             4010492Ki
  pods:               110


Por lo tanto pedir 100 CPUs como limite o como request, no tiene ningun sentido.

    kubectl apply -f limit-cpu-2.yaml
    pod/cpu-demo configured

    kubectl get pods
    NAME          READY   STATUS    RESTARTS   AGE
    cpu-demo      1/1     Running   0          45m
    cpu-demo2     1/1     Running   0          6m47s
    memory-demo   0/1     Pending   0          11h

Lo que sucede es que ninguno de lso nodos tiene 100 CPUs. POr lo tanto el scheduler de kubernetes no encuentra donde colocar este pod.


### 94. QoS Classes

    kubectl get pods cpu-demo2 -o yaml | grep -i qos
    qosClass: Burstable

A veces aparece:

    qosClass: BestEffort

**¿De que depende esta clase?**

Son clases en las que entra un pod dependiendo de su configuracion en limites.

- Guaranteed: Significa que tiene garantizados los mismos recursos en limits y lso mismos recursos en CPU. Si mi pod tiene los mismos limits y los mismos request significa que es un pod Guaranteed. (Tiene garantizados 700 milicores y 200 Mb de RAM.)

- Burstabled: Significa que puede aumentar o subir,  es cuando el limite es mayor al request. (Cuando se tiene un request por ejemplo de 100 Mb y tiene tiene un limite por ejemplo de 200 Mb significa que el pod esta garantizado en 100, pero todavia puede subir a 200, esto da una idea de que es busrtable.)

- BestEffort: Son lso pods que no definen ningun tipo de limites, por lo tanto el scheduller va a hacer el mejor esfuerzo para colocarlos en los nodos donde deberian ir. estos pods son los mas peligrosos, por lo tanto pueden consumir y consumir recursos hasta el punto de colapsar un nodo.


## Section 13: LimitRange - Uso de recursos a nivel de objetos


### 95. ¿Qué es un LimitRange? 

Como limitar recursos pero ahora enfocados en namespaces.

LimitRange es un objeto en Kubernetes que permite controlar objetos a nivel de objetos.
Se tiene un namespace llamado CI, y dentro de este namespace se quieren colocar constraints o limitantes, se quieren aplicar politicas o limits. Se pueden colocar valores por defecto en temas de limite, es decir yo quiero que cualquier pod que se cree en este namespace,  y que no tenga un  request o un limite de memoria o de CPU, yo puedo automaticamente asignarle un valor, es decir si no le colocan un valor, se lee la configuracion del limitRange y se le aplican al pod esos limites por defecto. Otra funcionalidad es que podemos, tambien definirle a este pod un  minimo de recursos y tambien un maximo. COmo se vio en un caso anterior se puede asignar a una maquina 1000 CPUs, pero ninguna maquina tiene 1000 CPUs, por lo tanto si se aplica una politica de maximo (1 CPU por ejemplo) , si alguien pide 2 CPUs va a encontrar un error y no va a poder crear el pod, es decir que eso se aplica a nivel del objeto, ni siquiera dejar crear el objeto, se puede decir que el limitRange nos ayuda a controlar las configuraciones o inyectar valores a nivel objeto.
Es decir yo puedo crear otro pod aqui y las mismas politicas van a aplicar, adiocionalmente si no tiene limites puedo colocarlos por default, puedo validar que el minimo de recursos sea el que yo defini, o tambien puedo validar que el maximo de recursos no sobrepase el que yo defini. Todas estas opciones son "opcionales". 


### 96. Aplica valores por defecto los pods que no definan limites

Se va a crear el primer limitRange y se analizara como funciona el tema de la memoria por default y de la CPU por default,

El limitRange opera solo en los objetos del namespace donde es creado, asi que si se crea un limitRange en el namespace por Default, solamente va a afectar a los objetos del Namespace por default, en este caso en el namespace dev.

    kubectl get limitrange -n dev
    NAME                  CREATED AT
    mem-cpu-limit-range   2025-10-05T02:40:28Z


    kubectl describe limitrange mem-cpu-limit-range -n dev
    Name:       mem-cpu-limit-range
    Namespace:  dev
    Type        Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
    ----        --------  ---  ---  ---------------  -------------  -----------------------
    Container   cpu       -    -    500m             1              -
    Container   memory    -    -    256Mi            512Mi          -


**Esto va aplicar solamente cuando se defina un contenedor que no defina limites, estos valores se van a aplicar por defecto.**


https://kubernetes.io/docs/tasks/


### 97. Valida el funcionamiento de los limites por defecto 

Se va a crear un pod sin ningun tipo de limites, y se va a ver como funciona esto de limitRange actuando en tiempo real

    $ kubectl apply -f default-cpu-mem.yaml 
    namespace/dev unchanged
    limitrange/mem-cpu-limit-range unchanged
    pod/podtest3 created

    $ kubectl get limitrange -n dev
    NAME                  CREATED AT
    mem-cpu-limit-range   2025-10-05T02:40:28Z

    kubectl describe limitrange mem-cpu-limit-range -n dev
    Name:       mem-cpu-limit-range
    Namespace:  dev
    Type        Resource  Min  Max  Default Request  Default Limit  Max Limit/Request Ratio
    ----        --------  ---  ---  ---------------  -------------  -----------------------
    Container   cpu       -    -    500m             1              -
    Container   memory    -    -    256Mi            512Mi


Se compara y en efecto se cumple:

    $ kubectl get pod podtest3 -o yaml -n dev | grep -i limits -C3
        imagePullPolicy: IfNotPresent
        name: cont1
        resources:
        limits:
            cpu: "1"
            memory: 512Mi
        requests:

    $ kubectl get pod podtest3 -o yaml -n dev | grep -i requests -C3
        limits:
            cpu: "1"
            memory: 512Mi
        requests:
            cpu: 500m
            memory: 256Mi
        terminationMessagePath: /dev/termination-log


Si se crea un pod que no definan ningun limite, automaticamente el limitRange va a inyectar esa data en al configuracion enviada hacia la APi de Kubernetes para que se satisfaga el limit range (los valores deseados por defecto) contra los valores que va a sumir o que va a heredar el pod desde esta configuracion.

Ahora se creara un pod en el namespace por default:

    kubectl run podtest3 --image=nginx:alpine -ti --rm -- sh


Los nombres de los recursos pueden ser distintos si estan en namespaces distintos, es decir en un namespace no podemos tener 2 objetos con el mismo nombre, pero en 2 namespaces distintos si.

    $ kubectl get pods
    NAME          READY   STATUS    RESTARTS   AGE
    podtest3      1/1     Running   0          2m28s

    $ kubectl get pod podtest3 -o yaml | grep -i limits -C3

    $ kubectl get pod podtest3 -o yaml | grep -i requests -C3

El limitRange solamente funciona en los objetos donde el limit range esta desplegado.

    kubectl describe ns default
    Name:         default
    Labels:       kubernetes.io/metadata.name=default
    Annotations:  <none>
    Status:       Active

    No resource quota.

    No LimitRange resource.

Pero si se describe el namespace de dev, si aparece un limitRange aplicado.


### 98. Crea un limitRange con valores minimos y maximos

> min-max-limits.yaml

LimitRange como crear valores minimos y valores maximos, en este punto ya se crearon valores por defecto.

    kubectl get limitranges -n prod
    NAME      CREATED AT
    min-max   2025-10-06T05:00:15Z

Como no se definio un valor por defecto se esta tomando el maximo valor permito. 

    $ kubectl describe limitranges min-max -n prod
    Name:       min-max
    Namespace:  prod
    Type        Resource  Min   Max  Default Request  Default Limit  Max Limit/Request Ratio
    ----        --------  ---   ---  ---------------  -------------  -----------------------
    Container   cpu       100m  1    1                1              -
    Container   memory    100M  1Gi  1Gi              1Gi 

Se puede describir el namespace para ver los limitranges que tiene configurado:

    kubectl describe limitranges min-max -n prod
    Name:       min-max
    Namespace:  prod
    Type        Resource  Min   Max  Default Request  Default Limit  Max Limit/Request Ratio
    ----        --------  ---   ---  ---------------  -------------  -----------------------
    Container   cpu       100m  1    1                1              -
    Container   memory    100M  1Gi  1Gi              1Gi            -



### 99. Valida el funcionamiento de las politicas de minimi/macimo de un limitRange

Se va a empezar a probar como funciona esto de los limites del minimo y maximo valor en un limitRange.

No se deberia de tener error por que los valores estand entro del minimo y maximo permitido.

    spec:
    containers:
    - name: cont1
        image: nginx:alpine
    resources: 
        limits:
        memory: "500M"
        cpu: 0.5
        requests:
        memory: 400M
        cpu: 0.3

    kubectl apply -f min-max-limits.yaml 
    namespace/prod unchanged
    limitrange/min-max configured
    pod/podtest3 created


El valor maximo es 1 Gb de RAM y el valor de cpu maximo es 1. Se va a intentar superar 


Los pods mismos no pueden hacer estos cambios, solo los replicasets o los deployments que estan mas arriba si. Se debe de utilizar un objeto de mayor nivel para que lo actualice.

**Se elimina el pod de forma manual**

Luego se obtiene un nuevo error pero del limitrange:

    kubectl apply -f min-max-limits.yaml 
    namespace/prod unchanged
    limitrange/min-max configured
    Error from server (Forbidden): error when creating "min-max-limits.yaml": pods "podtest3" is forbidden: [maximum memory usage per Container is 1Gi, but limit is 2G, maximum cpu usage per Container is 1, but limit is 2]

Esta prohibido, el maximo consumo de cpuy por contenedor es de 1.

Esa es la idea del limitrange, delimitar los recursos para garantizar que un manifiesto no cree un objeto se exceda en consumo de recursos.


**Probar cuando los limites son menores al minimo**

Se modifican los parametros:

    spec:
    containers:
    - name: cont1
        image: nginx:alpine
        resources: 
        limits:
            memory: "50M"
            cpu: "50m"
        requests:
            memory: 400M
            cpu: "0.3"


    kubectl apply -f min-max-limits.yaml 
    namespace/prod unchanged
    limitrange/min-max configured
    The Pod "podtest3" is invalid: 
    * spec.containers[0].resources.requests: Invalid value: "300m": must be less than or equal to cpu limit of 50m
    * spec.containers[0].resources.requests: Invalid value: "400M": must be less than or equal to memory limit of 50M

No se puede decir que el limite sea menor que el request, asi que se va a eliminar el request.

    spec:
    containers:
    - name: cont1
        image: nginx:alpine
        resources: 
        limits:
            memory: "50M"
            cpu: "50m"
        # requests:
        #   memory: 400M
        #   cpu: "0.3"


    kubectl apply -f min-max-limits.yaml 
    namespace/prod unchanged
    limitrange/min-max configured
    Error from server (Forbidden): error when creating "min-max-limits.yaml": pods "podtest3" is forbidden: [minimum cpu usage per Container is 100m, but request is 50m, minimum memory usage per Container is 100M, but request is 50M]

El minimo uso de cpu por contenedor es 100m pero se estan solicitando 50m.
El minimo uso de memoria por contenedor es 100M, se estan solicitando 50M.

Asi es como se usan los limit ranges para controlar un minimo, un maximo y un valor por defecto, en tema de recursos en pods.



## Section 14: ResourceQuota - Agrega limites a nivel de namespace


### 100. ¿Que es un ResourceQuota?

Objeto

¿Cual es la diferencia con un Limit rage?

Un limit range es un objeto que funciona en un namespace que afecta todos los objetos dentro de un namespace pero los afecta a nivel individual es decir a nivel de objeto.
Yo creo un pod, ese pod va a estar sujeto a las politicas de cpu, memoria, pero solamernte aplican en ese pod. 

POr el contrario un resource quota aplica en general, al nivel del namespace 



Un limit range es util para limitar los objetos individualmente.

namespace:

1 pod => 1 CPU
1 pod => 1 CPU
1 pod => 1 CPU
1 pod => 1 CPU


Pero que pasa si tu limite es de 1 CPU, y alguien crea un deployment con 200 replicas?

En ese caso vas a consumir 200 CPUs.

Asiq ue resources quota viene a ayudarnos con ese problema. Ya no va a actuar a nivel de objeto sino que va a actuar a nivel de namespace. y va a decri, "aca en este namespace se va a permitir como maximo el uso de 3 CPUs y como maximo el uso de 5 GB de ram"

¿Como se van a distribuir eso ustedes? Yo no se.

El resource quota lo que hace es limitar, la sumatoria de todos los recursos individuales. 

Cuando yo quiera crear otro pod para crear otro CPU, el resource quota por que la quota para este namespace es de 3 CPUs  y tu ya quieres consumir 4, asi que lo siento mucho pero lo maximo en este namespace es 3 asi que el nuevo pod va a dar error y no va a poder crearse.

Un resource quota no es un reemplazo del limit range, por el contrario es un objeto que funciona a nivel de namespace y que en conjunto con el limit range nos ayuda a tener un control, en nuestro cluster en nuestro namespace en especifico.

En este caso el limit range opera a nivel de objeto dentro del namepsace y el resource quota opera a nivel de namespace, independiente del numero de objetos que hayan dentro del namepsace 

POr que al resource quota no le inteereza si hay un solo pod, de 2 CPUs



### 101. Crea tu primer Resource Quota  

Crear un resource quota

Las cuotas funcionan tambien a nivel de namespace por lo tanto, podemos tomar el limit range 

    ---
    apiVersion: v1
    kind: ResourceQuota
    metadata:
    name: mem-cpu-demo
    namespace: uat
    spec:
    hard:
        requests.cpu: "1"
        requests.memory: 1Gi
        limits.cpu: "2"
        limits.memory: 2Gi


Se esta diciendo que se van a limitar los request de CPU en todo el namespace a 1 CPU es decir que la suma  de todos los objetos individuales no puede ser mayor a un CPU.

Por lo tanto si tenemos 2 pods y cada uno consume 500, entonces vamos a estar bien por que no estaremos superando este request.
Por el contrario si tuvieramos 3 pods cada uno consumiendo 500, eso seria en total 1.5 por ende obtendriamosun error.

Lo mismo acontece con los request de memoria, se tiene maximo 1 GB para todo el namespace, eso significa que la sumatoria de todos los recursos individuales no debe ser mayor a 1 GB.


    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl describe resourcequotas -n uat mem-cpu-demo
    Name:            mem-cpu-demo
    Namespace:       uat
    Resource         Used  Hard
    --------         ----  ----
    limits.cpu       0     2
    limits.memory    0     2Gi
    requests.cpu     0     1
    requests.memory  0     1Gi
    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get resourcequotas -n uat
    NAME           REQUEST                                     LIMIT                                   AGE
    mem-cpu-demo   requests.cpu: 0/1, requests.memory: 0/1Gi   limits.cpu: 0/2, limits.memory: 0/2Gi   3m34s
    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ 

Ahora se van a crear un par de pods para ver como funcionna estos valores vs la confogiracion que nosotrod apliquemos.


### 102. Intenta sobrepasar los limites de tu ResourceQuota


res-quota.yaml

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl apply -f res-quota.yaml 
    namespace/uat unchanged
    resourcequota/mem-cpu-demo unchanged
    deployment.apps/deployment-test created


    No resources found in uat namespace.
    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get deployments.apps -n uat
    NAME              READY   UP-TO-DATE   AVAILABLE   AGE
    deployment-test   0/2     0            0           2m52s



    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl describe deployments.apps -n uat deployment-test
    Name:                   deployment-test
    Namespace:              uat
    CreationTimestamp:      Mon, 31 Aug 2026 15:16:43 -0500
    Labels:                 app=front
    Annotations:            deployment.kubernetes.io/revision: 1
    Selector:               app=front
    Replicas:               2 desired | 0 updated | 0 total | 0 available | 2 unavailable
    StrategyType:           RollingUpdate
    MinReadySeconds:        0
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    Pod Template:
    Labels:  app=front
    Containers:
    nginx:
        Image:      nginx:alpine
        Port:       <none>
        Host Port:  <none>
        Requests:
        cpu:         500m
        memory:      500Mi
        Environment:   <none>
        Mounts:        <none>
    Volumes:         <none>
    Node-Selectors:  <none>
    Tolerations:     <none>
    Conditions:
    Type             Status  Reason
    ----             ------  ------
    Progressing      True    NewReplicaSetCreated
    Available        False   MinimumReplicasUnavailable
    ReplicaFailure   True    FailedCreate
    OldReplicaSets:    <none>
    NewReplicaSet:     deployment-test-7599fd966 (0/2 replicas created)
    Events:
    Type    Reason             Age    From                   Message
    ----    ------             ----   ----                   -------
    Normal  ScalingReplicaSet  4m11s  deployment-controller  Scaled up replica set deployment-test-7599fd966 from 0 to 2

Se puede observar el: **ReplicaFailure   True    FailedCreate**

Fallo al crear las replicas, no se tiene mucha informacion, por lo tanto se va a revisar el replicaset.


diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get rs -n uat
NAME                        DESIRED   CURRENT   READY   AGE
deployment-test-7599fd966   2         0         0       6m46s


Ahora lo describimos:

diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl describe rs deployment-test-7599fd966 -n uat
Name:           deployment-test-7599fd966
Namespace:      uat
Selector:       app=front,pod-template-hash=7599fd966
Labels:         app=front
                pod-template-hash=7599fd966
Annotations:    deployment.kubernetes.io/desired-replicas: 2
                deployment.kubernetes.io/max-replicas: 3
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/deployment-test
Replicas:       0 current / 2 desired
Pods Status:    0 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=front
           pod-template-hash=7599fd966
  Containers:
   nginx:
    Image:      nginx:alpine
    Port:       <none>
    Host Port:  <none>
    Requests:
      cpu:         500m
      memory:      500Mi
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type             Status  Reason
  ----             ------  ------
  ReplicaFailure   True    FailedCreate
Events:
  Type     Reason        Age                   From                   Message
  ----     ------        ----                  ----                   -------
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-lqqjl" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-5t8bk" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-4mmm6" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-rdl8j" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-tcs8m" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-pfw6w" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-c749x" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m11s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-52nqk" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  9m10s                 replicaset-controller  Error creating: pods "deployment-test-7599fd966-mcnw8" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx
  Warning  FailedCreate  3m43s (x8 over 9m9s)  replicaset-controller  (combined from similar events): Error creating: pods "deployment-test-7599fd966-pvl59" is forbidden: failed quota: mem-cpu-demo: must specify limits.cpu for: nginx; limits.memory for: nginx


**replicaset-controller  Error creating: pods**

Cuando creamos un resource quota, si o si debemos definir en el contenedor los request y los limits, por que en el resource quota definimos un limite y un request.

      containers:
      - name: nginx
        image: nginx:alpine
        resources:
          requests: 
            memory: 500Mi
            cpu: 500m
          limits: 
            memory: 500Mi
            cpu: 500m

diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl apply -f res-quota.yaml 
namespace/uat unchanged
resourcequota/mem-cpu-demo unchanged
deployment.apps/deployment-test configured
diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get pods -n uat
NAME                               READY   STATUS    RESTARTS   AGE
deployment-test-67796f8cdf-k4sxq   1/1     Running   0          21s
deployment-test-67796f8cdf-p8zsw   0/1     Pending   0          15s

Se vana tener los pods corriendo sin ningun problema

AL PARECER HAY UN PROBLEMA CON ESTE CLUSTER SE CREO CON LA CAPACIDAD MINIMA 

    kubectl describe node | grep -A 8 "Allocated resources"

Por razones de agilidad voy a cambiar los valores para adaptar el ejercicio.


El problema no es tu código YAML ni la cuota de Kubernetes (ResourceQuota). El problema es de capacidad del cluster de GCP (GKE):Tienes un cluster de 3 nodos.Ninguno de los 3 nodos tiene $500\text{m}$ de CPU ni $500\text{Mi}$ de RAM libres de forma individual para ubicar ese segundo pod.Los pods de sistema de GKE (como kube-dns, fluentbit, metrics-server, etc.) y las workloads que ya tenías en el cluster están ocupando la mayoría de la CPU/RAM asignable de tus instancias.

    kubectl rollout restart deployment deployment-test -n uat

> Es por que es un e2-small.


Despues del cambio de replica a 5

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl apply -f res-quota.yaml 
    namespace/uat unchanged
    resourcequota/mem-cpu-demo unchanged
    deployment.apps/deployment-test configured
    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get pods -n uat
    NAME                              READY   STATUS    RESTARTS   AGE
    deployment-test-6dc8f5f99-d48fq   1/1     Running   0          32m
    deployment-test-6dc8f5f99-g2v77   1/1     Running   0          2m4s
    deployment-test-6dc8f5f99-htrfm   1/1     Running   0          33m
    deployment-test-6dc8f5f99-zffgk   1/1     Running   0          85s


bacrim nalga

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get deployment.apps -n uat deployment-test
    NAME              READY   UP-TO-DATE   AVAILABLE   AGE
    deployment-test   4/5     4            4           67m


kubectl get deployment
kubectl get deployments
kubectl get deploy
kubectl get deployment.apps


Aca vamos a poder ver el ultimo estado.

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get deployment.apps -n uat deployment-test -o yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    annotations:
        deployment.kubernetes.io/revision: "5"
        kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"labels":{"app":"front"},"name":"deployment-test","namespace":"uat"},"spec":{"replicas":5,"selector":{"matchLabels":{"app":"front"}},"template":{"metadata":{"labels":{"app":"front"}},"spec":{"containers":[{"image":"nginx:alpine","name":"nginx","resources":{"limits":{"cpu":"200m","memory":"250Mi"},"requests":{"cpu":"200m","memory":"250Mi"}}}]}}}}
    creationTimestamp: "2026-08-31T20:16:43Z"
    generation: 8
    labels:
        app: front
    name: deployment-test
    namespace: uat
    resourceVersion: "1788211187494319019"
    uid: 55d0749d-c810-4ec1-89c7-86d338cdb58d
    spec:
    progressDeadlineSeconds: 600
    replicas: 5
    revisionHistoryLimit: 10
    selector:
        matchLabels:
        app: front
    strategy:
        rollingUpdate:
        maxSurge: 25%
        maxUnavailable: 25%
        type: RollingUpdate
    template:
        metadata:
        annotations:
            kubectl.kubernetes.io/restartedAt: "2026-08-31T15:46:45-05:00"
        labels:
            app: front
        spec:
        containers:
        - image: nginx:alpine
            imagePullPolicy: IfNotPresent
            name: nginx
            resources:
            limits:
                cpu: 200m
                memory: 250Mi
            requests:
                cpu: 200m
                memory: 250Mi
            terminationMessagePath: /dev/termination-log
            terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
    status:
    availableReplicas: 4
    conditions:
    - lastTransitionTime: "2026-08-31T20:33:18Z"
        lastUpdateTime: "2026-08-31T20:47:02Z"
        message: ReplicaSet "deployment-test-6dc8f5f99" has successfully progressed.
        reason: NewReplicaSetAvailable
        status: "True"
        type: Progressing
    - lastTransitionTime: "2026-08-31T21:17:50Z"
        lastUpdateTime: "2026-08-31T21:17:50Z"
        message: Deployment has minimum availability.
        reason: MinimumReplicasAvailable
        status: "True"
        type: Available
    - lastTransitionTime: "2026-08-31T21:19:47Z"
        lastUpdateTime: "2026-08-31T21:19:47Z"
        message: 'pods "deployment-test-6dc8f5f99-njw4x" is forbidden: exceeded quota:
        mem-cpu-demo, requested: requests.memory=250Mi, used: requests.memory=1000Mi,
        limited: requests.memory=1Gi'
        reason: FailedCreate
        status: "True"
        type: ReplicaFailure
    observedGeneration: 8
    readyReplicas: 4
    replicas: 4
    terminatingReplicas: 0
    unavailableReplicas: 1
    updatedReplicas: 4


**message: 'pods "deployment-test-6dc8f5f99-njw4x" is forbidden: exceeded quota:**

No se puede crear el ultimo pod por que supera los limites asignados.


### 103. Limita el numero de pods que se pueden crear en un Namespace


Vamos a aprender otra utilidad del resource quota , aparte de permitirnos controlar el total de recursos  como CPU y RAM que podemos asignar a un namespace tambien podemos controlar el total de objetos en kubernetes que podemos crear.

Como ya sabemos en un resource quota es valido decir quiero limitar este namespace a 1 CPU, no va a poder consumir mas.
Al mismo tiempo  este namespace va a ser capaz de tener solamente 3 pods, no va a ser caapz de crear 4 ni 5 y esto pues es una herramienta que nos puede servir en el futuro para una necesidad en especifico,  pero es muy bueno saber que aparte de limitar recursos podemos limtiar objetos tambien, 

    ---
    apiVersion: v1
    kind: Namespace
    metadata:
    name: qa
    labels:
        name: qa
    ---
    apiVersion: v1
    kind: ResourceQuota
    metadata:
    name: pod-demo
    spec:
    hard:
        pods: "3"

Vamos a crear un deployment por que no vamos a crear 3 pods a mano. En este dployment se pueden borrar los limites por que no se van a usar.

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get -n qa resourcequotas pod-demo
    NAME       REQUEST     LIMIT   AGE
    pod-demo   pods: 3/3           105s


    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl describe namespaces qa
    Name:         qa
    Labels:       kubernetes.io/metadata.name=qa
                name=qa
    Annotations:  <none>
    Status:       Active

    Resource Quotas
    Name:     pod-demo
    Resource  Used  Hard
    --------  ---   ---
    pods      3     3

    No LimitRange resource.


Se puede ver que se tiene el resourceQuota aplicado a nivel de objeto, el hard lo maximo son 3 y tenemos usados 3. En teoria no podemos crear mas pods.

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/resource-quota$ kubectl get pods -n qa
    NAME                            READY   STATUS    RESTARTS   AGE
    deployment-qa-8c6f547bd-5x74g   0/1     Pending   0          26m
    deployment-qa-8c6f547bd-bl7px   0/1     Pending   0          26m
    deployment-qa-8c6f547bd-n8rwn   0/1     Pending   0          26m


Ahora se intentan desplegar 4 replicas con esta configuracion.

Al ejecutar de nuevo el manifeisto se puede ver que aun se tienene 3 pods.

Es hora de revisar el deployment:

    kubectl get deployment -n qa deployment-qa -o yaml

Tambien aparecera un error que indica que se excede la quota.

1
## Section 15: Health Checks & Probes - Vigila el estado de tus contenedores


### 104.  ¿Que son los Probes y como se ejecutan?

Es basicamente una prueba, un diagnostico que se ejecuta, sobre un contnedor en un podpara ver el estado de ese contenedor para saber si esta bien, para saber que tiene, para ver si esta respondiendo como deberia de responder.
En kubernetes se tienen varios tipos de probes, de diagnosticos que podemos aplicar sobre los probes, es un diagnostico que realiza el kubelet.

Kubelet es un servivioo que esta corriendo en cada nodo y es el responsable de crear y actualizar los pods en ese nodo. El kubelet es el encargado de ejecutar estos diagnosticos, sobre los contenedores de los pods que nosotros definamos, en este caso lo que va a hacer kubelet es:

Se tiene un pod que tiene un solo contenedor y aca se define un probe y se define tambien un rango de tiempo que va a ser n, es decri cada 5 , 10, 15 20 s ...

Kubelet basado ene ste rangod e tiempo periodicamente va a ir al contenedor dentro del pod a preguntar, 

En caso de que este mal y no responda, va a tomar una acción 

Sencillamenete le pregunta al contenedor el estado,ejecuita el contendor que nosotrod hayamos definido 

Vamos a ver como kubelet ejecuta estos probes dntro de los contenednores de ..

Como lo hace? puede hacerlo de 3 maneras:

- Por medio de un comando, basicamente kubelet va y ejecuta un comando en el contenedor y si el comando devuelve 9 el comando esta bien, si retorna otra cosa esta mal.

- La segunda manera es haciendo un llamado por TCP, es decir ku8belet va al contenedor y le pregunta, tienes el puerto x abierto? si el probe es ok se considera satisfactorio, si el puwerto no responde entonces kubelet asume que hay un problema con el contenedor en el pod

- la ultima forma es por HTTP. kubeletr has un llamado get a un /path, puede ser 
Si la respuesta esta entre 200 y 399 , se considera saitisfactoria.

si es mayopr a 400 o 500 kubelet asume que hay un problema en el contenedor 

Basicamente estas son las 3 maneras en que kubelet ejecuta un probe en un contenedor de un pod, para saber si esta bien o esta mal. 



### 105. Tipos de probes en Kubernetes

ya sabemos que un probe es ejecuta por kubelet en un contenedor de un pod y que puede ser un comando, un TCP o un HTTP. Ahora, que tipos de probes tenemos?

Liveness: Un diagnostico para validar si la aplicacion esta funcionando como deberia.

Readiness: Es para ver si la aplicacion ya inicio como deberia.

Startup: Es para aplicaciones que son demoradas al iniciar.

que es esto? y cuando deberia usar cual?

Resulta que tenemos nuestro pod y aca esta nuestro contenedor, ahora ya sabemos que podemos ejecutar un Liveness, Readiness o un Startup y podemos decidir si queremos un comando, TCP o HTTP. Es decir que somos libres de elegir como queremos ejecutar el probe,


un Liveness probe es una prueba que ejecuta kubelet en el contendor cada n internvalo de tiempo, en esta prueba solo esperamos una respuesta del contenedor,

si es una aplicacion web podemos hacerle un GET a un endpoint por HTTP para esperar una respuesta corecta. que pasa? normalmente en las aplicaciones, en los servicios web, luego de mucho tienpo de servicio, puede que hayan aplicaciones que crasheen no del todo, es decir el servicio web sigue arriba, pero cuando los consultas, te devuelven un 500, Desde el punto de vista del contendor el servicio se esta ejecutnado bien, pero la respuesta que esta devolviendo, es indiferente para el. 
Desde el punto de vista del contenedor en este caso, el esta ejecutnado su proceso y el piensa que todo esta bien,  nosotros como usuarios sabemos que aunque el servicio esta corriendo, esta devolviendo 500 por cualquier cosa, por cualquier tema que pudo haber ocurrido, entonces con un **liveness** nos aseguramos de reiniciar esta aplicacion, 

Podemos ejecutar un GET liveness probe que sea por HTTP a este contenedor y si nos devuelve 200 entonces esta bien, no hacemos nada, pero si nos devuelve 400 o 500. TEnemos un error y significa que este contendor debe ser reiniciado, o eliminado, por que algo no esta bien. 

Basicamente eso es un liveness probe, asegurarnos de que la aplicacion esta respondiendo, como deberia responder, por lo menos tener un poquito de control y saber que la aplicacion no se ha crasheado,  o que esta funcionando como no deberia de funcionar, liveness es saber que la aplicacion sigue con vida. 


Que es el readiness? imaginemos que tenemos un servicio por aca, y tambien imaginemos que no tenemos ningun pod, o esta bien imaginemos que tenemos 2 pods que estan sirviendo request, 2 pods que estan en servicio, ahora digamos que queremos agregar un nuevo pod, pero queremos garantizar que solamente cuando este pod este ready,  este listo va a empezar a recibir request desde el servicio. ahi es donde entra el readiness.
Es nbasicamente un diagnostico que se ejecuta en el pod, cuando se crea antes de colocarlo como un endpoint valido. Ya sabemos que la manera de obtener la respuesta, puede ser por HTTP, por TCP, o por un comando, dependiendo de lo que configuremos si es un HTTP y no retorna un 200, significa que este pod ya esta listo para empezar a aceptar request, de este servicio, una vez pase el **readiness** lo podemos incluir en este servicio, si no pasa el readineess entonces no se incluye en los endpoints, de este servicio, y en readineess lo mismo ocurre cuando ya tenemos un pod, qure paso por el estado de readiness, y esta conectado a un servicio, es decir esta recibiendo request, si por alguna razon el readiness falla, significa que ese pod, se va a desconectar del servicio, es decir va a eliminar ls entradas que tenga en el endpoint de ese servicio, y va a dejar de recibir request hasta que el readiness, vuelva a funcionar, de esta manera garantizamos que un pod, no va a recibir request, cuando el readiness no se haya completado, es decir que el readiness nos ayuda a garantizar que  erl pod esta listo, para recibir trafico,  en cualquier momento en el tiempo. 

En cosrtas palabras eso es el readiness, un probe que nos ayuda a garantizar, que el servicio dentro del pod, esta listo para recibir request,  

Con el startup ocurre algo muy curiosop, ty es que si el startup esta definido en un manifiesto de kubernetes, es dcir que si nosotros definimos un startup, el readiness y el liveness si estan definidos, se van a pausar, es decir no se van a ejecutar hasta que el startup,  este listo, y que es el startup ? normalmente se utilizan en aplicaciones que demoran mucho en subir, asi que si tenemos un JAr  grande un war muy grande, una aplicacin estilo web logic, podemos utilizar entonces un startup, y le decrimos oye por favor epserat, hasta qeu esta aplciacion suba, cionfrigure todo lo que tiene que configurar, y una vez el probe pase, hay si voy ad esbloquear el readinees, y el liveness, para ver si la aplicacion ya esta lista, para poder colocarla en el servicio, y luego que la coloque para garantizar, qu e siga viva en el tiempo.

En pocas palabras estos son los rpobes mas comunes en kubernetes,  y los qu vana  ver normalmente en la matyoria de partes, y esta es la funcion de cada uno.



### 106. Crea un LivenessProbe para que ejecute un comando.

    apiVersion: v1
    kind: Pod
    metadata:
    labels:
        test: liveness
    name: liveness-exec
    spec:
    containers:
    - name: liveness
        image: busybox
        args:
        - /bin/sh
        - -c
        - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
        livenessProbe:
        exec:
            command:
            - cat
            - /tmp/healthy
        initialDelaySeconds: 5
        periodSeconds: 5

Ahí lo tienes, en estado 1/1 Running.

El script dentro del contenedor ejecutó el touch /tmp/healthy al arrancar. Durante los primeros 30 segundos, el livenessProbe ejecutará exitosamente el cat /tmp/healthy. Pasados los 30 segundos (cuando el comando ejecute rm -rf /tmp/healthy), la sonda fallará y verás que Kubernetes reiniciará automáticamente el contenedor (incrementando el contador en la columna RESTARTS).


    NAME            READY   STATUS    RESTARTS   AGE
    liveness-exec   1/1     Running   0          3s
    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/probes$ kubectl get pods
    NAME            READY   STATUS    RESTARTS      AGE
    liveness-exec   1/1     Running   1 (30s ago)   105s


Va a encontrar qu el archivo no existe, va a encontrar una falla asi que el liveness probe falla. y el contenedor dentro del pod se ve obligado a  recrearse 

    kubectl describe pod liveness-exec


    Events:
    Type     Reason     Age                   From               Message
    ----     ------     ----                  ----               -------
    Normal   Scheduled  5m3s                  default-scheduler  Successfully assigned default/liveness-exec to gke-diego-cluster-default-pool-290fda81-mwq4
    Normal   Pulled     5m1s                  kubelet            Successfully pulled image "busybox" in 2.005s (2.005s including waiting). Image size: 2236931 bytes.
    Normal   Pulled     3m48s                 kubelet            Successfully pulled image "busybox" in 361ms (361ms including waiting). Image size: 2236931 bytes.
    Normal   Pulled     2m33s                 kubelet            Successfully pulled image "busybox" in 312ms (312ms including waiting). Image size: 2236931 bytes.
    Normal   Pulled     78s                   kubelet            Successfully pulled image "busybox" in 373ms (373ms including waiting). Image size: 2236931 bytes.
    Warning  Unhealthy  33s (x12 over 4m28s)  kubelet            Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
    Normal   Killing    33s (x4 over 4m18s)   kubelet            Container liveness failed liveness probe, will be restarted
    Normal   Pulling    3s (x5 over 5m3s)     kubelet            Pulling image "busybox"
    Normal   Created    3s (x5 over 5m1s)     kubelet            Container created
    Normal   Started    3s (x5 over 5m1s)     kubelet            Container started
    Normal   Pulled     3s                    kubelet            Successfully pulled image "busybox" in 317ms (317ms including waiting). Image size: 2236931 bytes.

**Warning  Unhealthy  33s (x12 over 4m28s)  kubelet            Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory**


No existe el archivo por lo tanto nos dice que el contenedor sera reiniciado.

**Normal   Killing    33s (x4 over 4m18s)   kubelet            Container liveness failed liveness probe, will be restarted**

Una vez el contenedor dentor del pod rse reinicie, va a pasar lo mismo. Se va a crear el archivo, por 30 segundos va a estar bien y luego cuando falle el liveness probe, se va a volver a ejecutar. Hasta que caiga en un **backoff** que significa que kubernetes itnento varias veces. Pero que el resultado fue siempre el mismo con el contenedor. Es decir que hay algun error que esta crasheando el contenedor por lo tanto kubernetes va a dejar en algun punto de reiniciar ese contenedor, y va a quedar en un backoff.

Asi que veamos el estado actual del pod, va a ser este va a seguir corriendo. Recordemos que al momento de reiniciarse el contenedor, de nuevo se crea el archivo, se duerme por 30 segundos, y luego eliminamos el archivo, asi que vamos a ver de nuevo el estado del pod.

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/probes$ kubectl get pods
    NAME            READY   STATUS    RESTARTS        AGE
    liveness-exec   1/1     Running   196 (29s ago)   12h

Describamos el pod y asi es como vemos la funcionalidad del liveness y basicamente lo que kubernetes puede hacer por nosotros es 
reiniciar el cotnenedor en el pod una vez este falle.

¿Por que puede fallar un contenedor en el pod? Nosa bemos, puede ser que se caiga la aplicacion, que haya un bug, y si es un bug es muy problematico, si fue por carga, un reinicio normalmente lo ayuda, la yutilidad del liveness es muy buena como vemos, garantiza en el tiempo que el pod va a tener un servicio saludable.


### 107. LivenessProbe con TCP

Como se crea un LivenessProbe con protocolo TCP es decir utilizando un puerto.

En este LivenessProbe se tiene un TCP socket, ya no tenemos un comando se tiene un socket TCP. Oye kubernetes, tyu me vas a ejecutar un LivenessProbe, en este contenedor cada 20 segundos, la primera vez que el contenedor se cree vas a esperar 15 segundos, **(initialDelaySeconds)**, para ejecutar rl primer diagnostico, y lo vas a ejecutar cada 20 segundos contra el puerto 8080. que es donde esta corriendo el servicio en ese contenedor.


El resultado de esto en caso de que el púerto falle va a ser el mismo, que vimos con el comando, es decir va a reiniciar el contenedor,  dentro del pod para intentar, revivir de alguna manera la aplicacion.


### 108. LivenessProbe con HTTP

    apiVersion: v1
    kind: Pod
    metadata:
    labels:
        test: liveness
    name: liveness-http
    spec:
    containers:
    - name: liveness
        image: registry.k8s.io/liveness
        args:
        - /server
        livenessProbe:
        httpGet:
            path: /healthz
            port: 8080
            httpHeaders:
            - name: Custom-Header
            value: Awesome
        initialDelaySeconds: 3
        periodSeconds: 3

El /server es propio de la imagen.

POr lo tanto se puede hacer un GET al path /healthz en el puerto 8080, incluso se puedne aplicar custom headers,  y aca tenemos lo que nos compete la demora inicial, 
que significa cuando inicia el pod, cuando se crea por primera vez espera 3 segundos y luego aplica el livenessProbe, luego de este el LivenessProbe se va a ejecutar cada 3 segundos, este valor no necesariamente titne que ser el mismo siempre, esto depende muchod e como sea su aplicaicon y cuanto tarde ene star lista, 

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/probes$ kubectl get pods
    NAME            READY   STATUS             RESTARTS         AGE
    goproxy         1/1     Running            0                17m
    liveness-exec   0/1     CrashLoopBackOff   208 (115s ago)   12h
    liveness-http   1/1     Running            0                15s

Un vez se descargue el pod va a iniciar y el LivenessProbe despues de 3 segundos, va a empezar a hacer su tarea 

    Events:
    Type     Reason     Age                 From               Message
    ----     ------     ----                ----               -------
    Normal   Scheduled  105s                default-scheduler  Successfully assigned default/liveness-http to gke-diego-cluster-default-pool-290fda81-7lkr
    Normal   Pulling    105s                kubelet            Pulling image "registry.k8s.io/e2e-test-images/agnhost:2.40"
    Normal   Pulled     102s                kubelet            Successfully pulled image "registry.k8s.io/e2e-test-images/agnhost:2.40" in 2.498s (2.498s including waiting). Image size: 51155161 bytes.
    Warning  Unhealthy  30s (x12 over 90s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
    Normal   Killing    30s (x4 over 84s)   kubelet            Container liveness failed liveness probe, will be restarted
    Warning  BackOff    29s (x2 over 30s)   kubelet            Back-off restarting failed container liveness in pod liveness-http_default(7e450831-07e9-4829-bf5f-bc30b2579d18)
    Normal   Created    8s (x5 over 102s)   kubelet            Container created
    Normal   Started    8s (x5 over 102s)   kubelet            Container started
    Normal   Pulled     8s (x4 over 83s)    kubelet            Container image "registry.k8s.io/e2e-test-images/agnhost:2.40" already present on machine and can be accessed by the pod


kubectl get pods liveness-http -o yaml | grep -i liv -A12 

    --
        name: liveness
        ready: false
        resources: {}
        restartCount: 6
        started: false
        state:
        waiting:
            message: back-off 2m40s restarting failed container=liveness pod=liveness-http_default(7e450831-07e9-4829-bf5f-bc30b2579d18)
            reason: CrashLoopBackOff


    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/probes$ kubectl get pods
    NAME            READY   STATUS             RESTARTS        AGE
    goproxy         1/1     Running            0               24m
    liveness-exec   0/1     CrashLoopBackOff   210 (68s ago)   13h
    liveness-http   0/1     CrashLoopBackOff   6 (2m20s ago)   7m8s

Si se esta haciendo el LivenessProbe que ene ste caso tiene un FailureThereshold: 3

    livenessProbe:
      failureThreshold: 3

Este servicio tiene algo en particular, 


    Events:
    Type     Reason     Age                    From               Message
    ----     ------     ----                   ----               -------
    Normal   Scheduled  11m                    default-scheduler  Successfully assigned default/liveness-http to gke-diego-cluster-default-pool-290fda81-7lkr
    Normal   Pulling    11m                    kubelet            Pulling image "registry.k8s.io/e2e-test-images/agnhost:2.40"
    Normal   Pulled     10m                    kubelet            Successfully pulled image "registry.k8s.io/e2e-test-images/agnhost:2.40" in 2.498s (2.498s including waiting). Image size: 51155161 bytes.
    Normal   Created    8m15s (x6 over 10m)    kubelet            Container created
    Normal   Started    8m15s (x6 over 10m)    kubelet            Container started
    Normal   Killing    7m56s (x6 over 10m)    kubelet            Container liveness failed liveness probe, will be restarted
    Warning  Unhealthy  6m20s (x19 over 10m)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
    Warning  BackOff    4m46s (x9 over 9m47s)  kubelet            Back-off restarting failed container liveness in pod liveness-http_default(7e450831-07e9-4829-bf5f-bc30b2579d18)
    Normal   Pulled     3m34s (x7 over 10m)    kubelet            Container image "registry.k8s.io/e2e-test-images/agnhost:2.40" already present on machine and can be accessed by the pod


**Warning  Unhealthy  6m20s (x19 over 10m)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
  Warning  BackOff    4m46s (x9 over 9m47s)  kubelet            Back-off restarting failed container liveness in pod liveness-http_default(7e450831-07e9-4829-bf5f-bc30b2579d18)**

Como retorno un status code 500 el container va a ser reiniciado. 

De esta manera es como funcionan los probes en kubernetes Y es como nos ayuda por lo menos la aplicacion va a ser reiniciada cuando un probe no devuelva lo que deberia devolver.



### 109. Crea un ReadinessProbe

ReadinessProbe es muy parecido al LivenessProbe y es normal, no tiene ningun problema. Es muy comun que sean parecidos, que hace el readyness? va a al puerto 8080, cada 10 segundos, a validar que el puertoe ste abierto,  ¿Cual es la diferencia entre el Readiness y el Liveness?

EN primera instancia el readiness va a validar cada 10 segundos, que este puerto este abierto. Y si encuentra algun problema, l no es el encargado de reiniciar el contenedor, por el contrario lo que hace el readinessProbe es desregistrar la IP de los endpoints del servicio para que el pod no reciba mas carga o mas request hasta qeu este en un estado correcto,  asi que el readinessProbe nos garantiza de que en caso de que el pod sufra algun problema y que el probe del readiness no se ejecute correctamente, de una vez el pod va a a quedar fuera de los pods habiulitados, para recibir request desde el servicio 

Readiness se ejecuta en un intervalo de tiempo X y valida, que el servicio este arriba con esta prueba, y si no esta arriba llo que voy a hacer es eliminar la IP del endpoint del servicio,   paara evitar que le lleguen request a un pod que no esta en servicio.


Y el livenessProbe lo que va a hacer cada x tiempo es ejecutar una prueba sobre el contenedor, y en caso de que esta no sea satisfactoria,  su mision es reiniciar el contenedor dentro del pod. 

Diferencia entre Readiness y el Liveness


## Section 16: ConfigMaps & Environment Variables - Inyecta datos en tus pods


### 110. Crea tu primera variable de entorno

Vamos a aprender a crear variables de en torno en los pods, utilizando manifiestos de kubernetes.

kubectl apply -f env.yaml 
kubectl exec -it envar-demo -- sh

Se pueden ver las variables de entorno con el comando env

    / # env
    KUBERNETES_PORT=tcp://34.118.224.1:443
    KUBERNETES_SERVICE_PORT=443
    HOSTNAME=envar-demo
    SHLVL=1
    HOME=/root
    PKG_RELEASE=1
    DYNPKG_RELEASE=1
    ACME_VERSION=0.4.1
    TERM=xterm
    NGINX_VERSION=1.31.4
    KUBERNETES_PORT_443_TCP_ADDR=34.118.224.1
    VAR1=valor de prueba 1
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    VAR2=test2
    NJS_VERSION=1.0.0
    VAR3=test3
    KUBERNETES_PORT_443_TCP_PORT=443
    KUBERNETES_PORT_443_TCP_PROTO=tcp
    NJS_RELEASE=1
    KUBERNETES_PORT_443_TCP=tcp://34.118.224.1:443
    KUBERNETES_SERVICE_PORT_HTTPS=443
    KUBERNETES_SERVICE_HOST=34.118.224.1
    PWD=/

Estas variables de entorno son accesibles desde cualquier parte de este contenedor en el pod.

    diegoall@p3rseus:~/courses/pro-kubernetes/kubernetes-master/envs$ kubectl exec -it envar-demo -- sh
    / # echo $VAR1
    valor de prueba 1
    / # echo $VAR2
    test2
    / # 

Estas variables estan disponibles globalmente en el contenedor.


### 111. Captura  valores embebidos al Pod por medio de variables de entorno


Vamos a inyectar valoresun poco mas reales y valores que nos pueden s er utiles, al momento de ejecutar nuestras aplicaciones 


Se ve la definicion demuestro pod con respecto a la API de Kubernetes.

    kubectl get pods envar-demo -o yaml


envars
nodo donde esta localizado
status
hostIP
podIPs


kubernetes ref environment variables

    https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/


Como podemos extraer informacion y como la podemos colocar dentro del pod.

    apiVersion: v1
    kind: Pod
    metadata:
    name: dapi-envars-fieldref
    spec:
    containers:
        - name: test-container
        image: nginx:alpine
        env:
            - name: MY_NODE_NAME
            valueFrom:
                fieldRef:
                fieldPath: spec.nodeName
            - name: MY_POD_NAME
            valueFrom:
                fieldRef:
                fieldPath: metadata.name
            - name: MY_POD_NAMESPACE
            valueFrom:
                fieldRef:
                fieldPath: metadata.namespace
            - name: MY_POD_IP
            valueFrom:
                fieldRef:
                fieldPath: status.podIP
    restartPolicy: Never


Veamos como se ven estas variables de entorno con valores dinamicos, estan siendo referenciados por unos campos, dentro del pod 

    / # env
    KUBERNETES_SERVICE_PORT=443
    KUBERNETES_PORT=tcp://34.118.224.1:443
    HOSTNAME=dapi-envars-fieldref
    SHLVL=1
    HOME=/root
    PKG_RELEASE=1
    MY_POD_NAMESPACE=default
    DYNPKG_RELEASE=1
    ACME_VERSION=0.4.1
    MY_POD_IP=10.64.0.7
    TERM=xterm
    NGINX_VERSION=1.31.4
    KUBERNETES_PORT_443_TCP_ADDR=34.118.224.1
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    NJS_VERSION=1.0.0
    KUBERNETES_PORT_443_TCP_PORT=443
    KUBERNETES_PORT_443_TCP_PROTO=tcp
    NJS_RELEASE=1
    MY_NODE_NAME=gke-diego-cluster-default-pool-290fda81-9zk5
    KUBERNETES_SERVICE_PORT_HTTPS=443
    KUBERNETES_PORT_443_TCP=tcp://34.118.224.1:443
    KUBERNETES_SERVICE_HOST=34.118.224.1
    PWD=/
    MY_POD_NAME=dapi-envars-fieldref
    / # echo $MY_NODE_NAME
    gke-diego-cluster-default-pool-290fda81-9zk5
    / # 


De estas sencilla manera es como podemos referenciar valores externos de nuestor pod como el nombre, la ip, el estado, etc . Capturarlos y dejarlos disponibles como variables de entorno.
dentro de nuestro pod.


### 112. ¿Que es un ConfigMap?

Un configmap es otro objeto que podemos crear, actualizar, eliminar, ahora cual es la funcion?

Para que se creo un configMap?

Como creamos aplicaciones con Docker en un Dockerfile, y como aplicamos configuraciones en ese Dockerfile.

Bueno, para entenderlo hablemos normalmente de cómo creamos aplicaciones con Docker en un Dockerfile y cómo aplicamos configuraciones en este Dockerfile.

Imaginemos que queremos crear una aplicación de nginx muy sencilla Entonces aquí tendríamos nuestro from desde cualquier parte. Aquí tendríamos, por ejemplo, un copy de nuestro código hacia el root de nuestro web server. Más abajito, opcionalmente, podemos copiar la configuración de nginx. Por ejemplo, si queremos habilitar certificados SSL, si queremos cambiar el puerto, si queremos hacer algún tipo de proxy, cualquier configuración adicional tenemos que pasarla con un copy para que quede en la imagen final.

Así las cosas, desplegamos la versión 1 de esta imagen. ¿Qué pasa si luego en el futuro yo quiero modificar esta configuración que copié al Dockerfile? Digamos que quiero cambiar el puerto, quiero agregar un alias, quiero cambiar la ruta de los logs, del document root, etcétera. Tendría entonces que llegar al archivo original donde le estoy haciendo el copy, hacer la modificación aquí, y luego reconstruir una nueva imagen y desplegarla con la versión número 2, ¿cierto? Así es como normalmente trabajamos con Docker, y así es como normalmente utilizamos la configuración, porque es una de las maneras para garantizar que va a ser consistente en el tiempo.

Así que con Kubernetes podemos seguir haciéndolo así, no hay ningún problema, Pero Kubernetes nos ofrece un objeto que es el ConfigMap para manejar estas situaciones de una manera mucho más sencilla. Ahora vamos a ver qué es un ConfigMap. Un ConfigMap, como lo dije, es un objeto distinto a un pod. Entonces aquí tenemos un ConfigMap y aquí podemos tener un pod.

Ahora, la idea de los ConfigMaps es separar las configuraciones y hacer más portable un pod. Por ejemplo, en este pod digamos que yo no hardcodeé ningún tipo de configuración de nginx, pero en mi ConfigMap estoy creando la configuración de nginx, toda la configuración normal, lo que utilizaría nginx. Y lo que hace el pod es sencillamente consumir este ConfigMap. Así yo puedo solamente llegar aquí, cambiar cualquier parámetro para que el pod lo tome sin necesidad de redesplegar una nueva versión de la aplicación.


### 113. ¿Como puede un Pod consumir un ConfigMap?

Un ConfigMap es básicamente un objeto que vive en un namespace y que es llave-valor. Significa que aquí yo voy a colocar una llave que se va a llamar como yo quiera, en este caso podemos decir "nginx.conf", y aquí como valor yo puedo empezar a escribir la configuración de nginx o la configuración que yo quiero aplicar.
 
En mi pod yo voy a referenciar a esta llave, entonces él va a decir: "Ok, yo quiero consumir la llave 'nginx.conf' del ConfigMap llamado 'configmap-x'", por ejemplo, y de esta manera es como se puede acceder.
 
Cómo se crean los ConfigMaps
 
Ahora, ¿estos ConfigMaps cómo se crean? Bueno, hay varias maneras:
 
1. Desde un archivo: podemos tener nuestro archivo "nginx.conf" normalmente y podemos decirle a Kubernetes: "Oye Kubernetes, por favor crea un ConfigMap basado en el contenido de este archivo". Esa es una manera muy sencilla de hacerlo.
 
2. Escribiendo un manifiesto de Kubernetes: donde definimos un objeto ConfigMap, y en este objeto escribimos la configuración de nginx en vez de cargarla de un archivo. Esta va a ser la forma que van a usar normalmente, porque nos da la habilidad de manipular el objeto ConfigMap, de cambiar las configuraciones y de hacerlo muchísimo más portable.
 
Entonces, a este punto podemos crear un ConfigMap desde un archivo, o creando un manifiesto de Kubernetes en el que escribamos las configuraciones que queramos en este ConfigMap.
 
Cómo un pod consume un ConfigMap
 
Perfecto, ahora la pregunta es: ya sabemos cómo crear un ConfigMap, teóricamente ya sabemos cuál es su composición. Ahora, ¿un pod cómo es capaz de ver este ConfigMap? Bueno, hay dos opciones:
 
Opción 1: Variables de entorno
 
Lo que podemos hacer para que un pod vea el ConfigMap es decirle: "Oye pod, tú vas a cargar (le damos un nombre a la variable, digamos 'variable-x') y la variable-x va a ser igual a ConfigMap.llave", y esto nos va a entregar el valor.
 
Digamos que creamos una llave que se llame "test" (recuerden que es llave-valor), la llave es "test" y el valor va a ser, por ejemplo, "hola". Así las cosas, vamos a decir entonces que la variable-x en el pod va a ser -o el valor de esta variable va a ser- lo que encontremos en el objeto "configmap-x" que debe tener un nombre en la llave "test". Así que colocamos esa configuración acá: "test como ConfigMap, llegamos a la llave test", y esto automáticamente va a cargar el valor dentro del pod en la variable-x.
 
Si no es claro este punto, no se preocupen, lo vamos a ver más adelante a detalle; es solo para que tengan una idea.
 
Opción 2: Volumen (archivo)
 
La segunda forma de cargarla en un pod es con un archivo. Así que vamos a decir que la segunda forma aquí es con un volumen. Si ya utilizaron Docker antes, están relacionados con los volúmenes.
 
Lo que vamos a hacer con el volumen es: en el pod vamos a montar una carpeta, por ejemplo en "/opt", y vamos a montar un archivo que por defecto tiene este nombre, pero podemos darle uno diferente. Le decimos, por ejemplo, aquí "config" -va a ser un archivo normal- y el contenido de este "config" va a ser el valor de esta llave dentro del ConfigMap.
 
Resumen
 
Así las cosas, quiero que tengan en mente cómo consumir los ConfigMaps en un pod: ya sabemos que lo podemos consumir con una variable de entorno, o montándolo en un volumen como un archivo normal.



### 114. Explora un Pod de Nginx y conoce cual sera el contenido de nuestro ConfigMap

Bienvenidos a este vídeo donde vamos a crear nuestro primer ConfigMap. Antes de eso quiero mostrarles cuál es el contenido de nuestro ConfigMap.
 
Explorando la configuración por defecto de nginx
 
Si creamos un pod, como normalmente lo hacemos, e ingresamos a él a una shell interactiva, vamos a intentar ingresar. Aquí estamos creando un pod con la imagen de nginx, por lo tanto vamos a tener la configuración de nginx disponible. Recordemos que estas imágenes ya vienen con una configuración, por ejemplo: "/etc/nginx/conf.d/default.conf". Aquí podemos ver la configuración por defecto que viene en la imagen.
 
Algo que quiero que tengan en cuenta es que esta configuración, esta "default", es la que está tomando obviamente este pod, porque es la configuración por default.
 
Modificando la configuración manualmente (solo como ejemplo)
 
Quiero que vean que si yo modifico este archivo dentro del contenedor -no debería hacerlo, porque si se elimina el pod mis cambios se van a perder, pero solamente para que lo vean- si yo cambio, por ejemplo, el puerto:
 
Antes de hacerlo voy a guardar esto y voy a iniciar el servicio de nginx aquí, porque no estaba iniciado. Perfecto, ya tenemos nuestro servicio iniciado en el contenedor.
 
Si vemos la IP del contenedor (recordemos que esto es accesible únicamente dentro del clúster, pero debido a que nuestra máquina es del clúster lo podemos ver), aquí lo vemos en el puerto 80. Perfecto.
 
Ahora, si yo modifico el archivo del que estábamos hablando y le cambio el puerto al 8080, y luego lo guardo, si me voy a mi navegador y recargo, no voy a ver nada. Tengo que obviamente recargar el servicio de nginx, así que: "nginx -s reload", y aquí debería poder ver mi servicio en el puerto 8080. Perfecto.
 
Conclusión
 
Como se dan cuenta, este es el archivo de configuración que nginx está tomando por defecto, y este es el archivo de configuración que vamos a utilizar como ejemplo para crear nuestro ConfigMap y entender cómo funciona esto.



### 115. Crea un ConfigMap desde un archivo





### 116. Asocia el ConfigMap que creaste a un Volumen en un Pod



### 117. Monta un ConfigMapcomo volumen sin especificar items


### 118. Crea un ConfigMap nuevo para inyectarlo como una variable de entorno



### 119. Configura tu pod para consumir el ConfigMap por medio de variables de entorno




### 120. Valida que todas las Variables y los Mount funcionen bien.





## Section 17: Secrets - Aprende a manejar data sensible en Kubernetes


### 121. ¿Que es un Secret?



### 122. Crea un secret desde un archivo plano


### 123. ¿Que es base64?


### 124. StringData vs Data 


### 125. Tip. Nunca versiones un yaml con informacion sensitiva!


### 126. Inyecta Secrets en tus Pods con Volumenes 


### 127. Inyecta Secrets en tus pods con variables de entorno



## Section 18: Kubernetes Volumes - Entiende los conceptos detrás de la persistencia de datos

### ¿?




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


### 226.


