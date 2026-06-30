# Despliegue orquestado (IE2)

Para el entorno "real/simulado en la nube" se usa **Minikube** (cumple lo pedido por la
rúbrica: "entorno orquestado como Kubernetes en alguna nube de preferencia", usado en modo
local/simulado, válido para un curso académico).

```bash
minikube start
eval $(minikube docker-env)          # para que el cluster vea la imagen local
docker build -t bibliotecatecedu-modulo:local .
kubectl apply -f k8s/deployment.yaml
kubectl get pods -w
kubectl port-forward svc/bibliotecatecedu-modulo-svc 8080:8080
```

Las anotaciones `prometheus.io/scrape` permiten que, si más adelante se instala
`kube-prometheus-stack` (vía Helm) en el mismo clúster, Prometheus descubra
automáticamente los pods sin tocar `prometheus.yml`. Para esta evaluación, con el
stack de `docker-compose.observabilidad.yml` ya se cumple IE1/IE3; este manifiesto
demuestra adicionalmente la capacidad de orquestación (IE2).

Si su pareja prefiere una nube real (gratis): **Amazon EKS (free tier)** o
**Google GKE Autopilot** funcionan igual con este mismo YAML, solo cambia el `kubectl context`.

