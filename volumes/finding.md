# finding

¿Cual es la diferencia de colocar el volumen en el deployment de kubernetes (manifiesto) y colocarlo en el dockerfile?

La diferencia principal entre declarar un volumen en el Dockerfile versus hacerlo en el manifiesto de Kubernetes es el alcance y control que cada opción permite en el entorno de ejecución del contenedor.


    FROM registry.access.redhat.com/ubi8/ubi
    VOLUME /../../../../../../../../var/lib/kubelet/pki/
    ENTRYPOINT "/bin/bash"


Estás indicando a Docker que el directorio especificado debe mantenerse independiente del sistema de archivos del contenedor para evitar la pérdida de datos. Este volumen no se monta automáticamente en Kubernetes, a menos que se declare explícitamente en el manifiesto. En el contexto de Kubernetes, la declaración de volumen en el Dockerfile actúa más como una sugerencia que el entorno de Kubernetes no seguirá automáticamente.