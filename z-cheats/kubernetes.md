# Kubernetes


kubectl run --generator=run-pod/v1 podtest --image=nginx:alpine

**(el argumento --generator ya no está soportado en versiones recientes.)**

fue eliminada en versiones recientes de kubectl (a partir de Kubernetes 1.18 aproximadamente). el comando kubectl run solo sirve para crear Pods directamente.


pod
deployment
job
cronjob


Pods

    kubectl run podtest --image=nginx:alpine
    kubectl api-resources  (Ver Recursos disponibles de la API en el cluster)
    kubectl get po
    kubectl get pod podName -o yaml
    kubectl describe pods/podName
    kubectl delete pod <podName>
    kubectl port-forward <pod-name> 7000:<pod-port>
    kubectl exec -it podtest -- sh


    kubectl logs -f doscont -c cont1
    kubectl logs -f doscont -c cont2
    kubectl logs -f doscont --all-containers=true


Deployments

    kubect apply -f deploymentName.yml
    kubectl delete -f deploymentName.yml





