# Encargo: Implementación de Flujo de Trabajo DevOps & Microservicios (DevSecOps)

Este repositorio contiene la simulación de un entorno de desarrollo profesional y el despliegue del microservicio de **Autenticación (Auth)** para la plataforma BibliotecaTecEdu. El proyecto integra el flujo de trabajo **GitFlow**, convenciones estrictas de desarrollo y un pipeline automatizado local y en la nube bajo estándares de **DevSecOps** (Alta Disponibilidad, Contenedores y Seguridad), extendido en la Evaluación Parcial 3 con **observabilidad, métricas y validación de cumplimiento normativo**.

---

## 1. Justificación del Modelo de Trabajo
Se ha seleccionado **GitFlow** como flujo de trabajo debido a su robustez para proyectos que requieren un ciclo de liberación estructurado:
* **Main:** Contiene el código siempre estable (Producción).
* **Develop:** Rama de integración para nuevas funcionalidades.
* **Features/Hotfixes:** Permiten el desarrollo en paralelo sin ensuciar las ramas principales, facilitando la colaboración y la revisión de código mediante *Pull Requests (PR)*.

### Convenciones de Desarrollo
* **Naming de Ramas:** `feature/nombre-de-la-tarea` o `hotfix/nombre-del-error`.
* **Mensajes de Commit (Conventional Commits):** `feat:` (funcionalidades), `fix:` (errores), `docs:` (documentación), `ci:` (automatización).
* **Simulación realizada:** Se estructuraron tareas en paralelo como `feature/login-system` (módulo de autenticación), `feature/user-profile` e hitos de seguridad como `hotfix/fix-seguridad`. Para la EP3 se utilizó `feature/observabilidad-ep3`.

---

## 2. Arquitectura del Microservicio y Tecnologías
Para la fase de implementación técnica, el artefacto se compone de:
* **Backend:** Java 21 / Spring Boot 3.4.5
* **Base de Datos:** MySQL 8.0
* **Contenerización:** Docker & Docker Compose (2 réplicas en alta disponibilidad simulada)
* **Seguridad (SAST/SCA):** Snyk CLI Integration + SonarQube (Quality Gate)
* **Observabilidad:** Prometheus, Grafana, Alertmanager, cAdvisor, Pushgateway
* **CI/CD Local:** Automatización mediante Script en Bash (`pipeline.sh`)
* **CI/CD Cloud:** Workflow basado en GitHub Actions (`ci-cd.yml`)

---

## 3. Instrucciones de Despliegue Local (WSL 2 / Ubuntu)

Para ejecutar este proyecto de manera óptima de forma nativa en tu distribución de Linux, ejecuta los siguientes pasos:

### Paso A: Clonar el repositorio e ingresar
```bash
git clone https://github.com/benjamin-sz/encargo-devops.git
cd encargo-devops
```

### Paso B: Lanzar el Pipeline Automatizado CI/CD
```bash
# Otorgar permisos de ejecución al script (solo la primera vez)
chmod +x pipeline.sh demo-falla-critica.sh

# Lanzar el pipeline completo (build, tests, seguridad, SonarQube, despliegue, observabilidad)
./pipeline.sh
```

---

## 4. Observabilidad, Métricas y Cumplimiento Normativo (EP3)

A partir de esta entrega, el pipeline no solo construye y despliega: también **observa, mide y
valida** que el sistema cumpla estándares mínimos de calidad y seguridad antes de llegar a
"producción simulada", deteniéndose automáticamente si alguno de esos estándares no se cumple.

### 4.1 Arquitectura añadida

| Herramienta | Función | Puerto local |
|---|---|---|
| Spring Boot Actuator + Micrometer | Expone métricas y health checks del microservicio | `8083` / `8084` (`/actuator/*`) |
| Prometheus | Recolecta y almacena métricas (scrape cada 10s) | `9090` |
| Grafana | Dashboard con métricas clave del sistema y del pipeline | `3000` (admin/admin) |
| Pushgateway | Recibe métricas del pipeline que no son HTTP (cobertura, duración de despliegue, hallazgos de seguridad) | `9091` |
| Alertmanager | Alertas: servicio caído, error rate alto, latencia alta, memoria alta | `9093` |
| cAdvisor | Métricas de CPU/memoria por contenedor | `8081` |
| SonarQube | Análisis estático + Quality Gate (cumplimiento de calidad/seguridad) | `9000` |
| Snyk | Escaneo de vulnerabilidades de la imagen Docker | CLI |

### 4.2 Qué mide el dashboard (Grafana)

* Disponibilidad de las réplicas (instancias `UP`)
* Tasa de errores HTTP 5xx
* Latencia P95
* Uso de CPU y memoria heap JVM por contenedor
* Solicitudes por segundo
* Cobertura de pruebas de la última build
* Duración del último despliegue
* Vulnerabilidades críticas detectadas por Snyk
* Issues bloqueantes detectados por SonarQube

### 4.3 Gates de cumplimiento que detienen el pipeline

El pipeline corta la ejecución (sin construir/desplegar) si:

1. La cobertura de pruebas cae bajo el umbral mínimo definido (`UMBRAL_COBERTURA` en `pipeline.sh`).
2. Snyk detecta una vulnerabilidad de severidad **crítica** en la imagen Docker.
3. El Quality Gate de SonarQube no es aprobado.

`demo-falla-critica.sh` reproduce y evidencia este comportamiento bajando el umbral de
cobertura para forzar el corte, sin necesidad de modificar el pipeline real.

### 4.4 Auditoría

Cada ejecución del pipeline registra el commit, autor, rama y timestamp en
`auditoria-pipeline.csv`. Adicionalmente, la rama `main` cuenta con branch protection
rules en GitHub (revisión obligatoria + status checks obligatorios antes de mergear).

### 4.5 Acceso a las herramientas tras correr `./pipeline.sh`

```
App (réplica 1):  http://localhost:8083
App (réplica 2):  http://localhost:8084
Prometheus:        http://localhost:9090
Grafana:            http://localhost:3000  (admin/admin)
SonarQube:          http://localhost:9000
Alertmanager:        http://localhost:9093
```

### 4.6 Despliegue orquestado (Kubernetes)

Ver `k8s/README.md` para desplegar el microservicio en Minikube (o cualquier nube
compatible con Kubernetes), con 2 réplicas, resource limits y probes de salud.

### 4.7 Estructura de archivos añadida en la EP3

```
.
├── pipeline.sh                       # actualizado: gates de cumplimiento + metricas
├── demo-falla-critica.sh             # evidencia de corte ante falla critica
├── docker-compose.observabilidad.yml # Prometheus, Grafana, SonarQube, etc.
├── mysql-init/                       # creacion de bases (dev y test)
├── monitoring/                       # configuracion de Prometheus, alertas y Grafana
├── k8s/                               # manifiestos de Kubernetes
└── sonar-project.properties          # configuracion de analisis SonarQube
```
