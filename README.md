# Encargo: Implementación de Flujo de Trabajo DevOps & Microservicios (DevSecOps)

Este repositorio contiene la simulación de un entorno de desarrollo profesional y el despliegue del microservicio de **Autenticación (Auth)** para la plataforma BibliotecaTecEdu. El proyecto integra el flujo de trabajo **GitFlow**, convenciones estrictas de desarrollo y un pipeline automatizado local y en la nube bajo estándares de **DevSecOps** (Alta Disponibilidad, Contenedores y Seguridad).

---

## 1. Justificación del Modelo de Trabajo
Se ha seleccionado **GitFlow** como flujo de trabajo debido a su robustez para proyectos que requieren un ciclo de liberación estructurado:
* **Main:** Contiene el código siempre estable (Producción).
* **Develop:** Rama de integración para nuevas funcionalidades.
* **Features/Hotfixes:** Permiten el desarrollo en paralelo sin ensuciar las ramas principales, facilitando la colaboración y la revisión de código mediante *Pull Requests (PR)*.

### Convenciones de Desarrollo
* **Naming de Ramas:** `feature/nombre-de-la-tarea` o `hotfix/nombre-del-error`.
* **Mensajes de Commit (Conventional Commits):** `feat:` (funcionalidades), `fix:` (errores), `docs:` (documentación), `ci:` (automatización).
* **Simulación realizada:** Se estructuraron tareas en paralelo como `feature/login-system` (módulo de autenticación), `feature/user-profile` e hitos de seguridad como `hotfix/fix-seguridad`.

---

## 2. Arquitectura del Microservicio y Tecnologías
Para la fase de implementación técnica, el artefacto se compone de:
* **Backend:** Java 17 / Spring Boot
* **Base de Datos:** MySQL 8.0
* **Contenerización:** Docker & Docker Compose
* **Seguridad (SAST):** Snyk CLI Integration
* **CI/CD Local:** Automatización mediante Script en Bash (`pipeline.sh`)
* **CI/CD Cloud:** Workflow basado en GitHub Actions (`ci-cd.yml`)

---

## 3. Instrucciones de Despliegue Local (WSL 2 / Ubuntu)

Para ejecutar este proyecto de manera óptima de forma nativa en tu distribución de Linux, ejecuta los siguientes pasos:

### Paso A: Clonar el repositorio e ingresar
```bash
git clone [https://github.com/benjamin-sz/encargo-devops.git](https://github.com/benjamin-sz/encargo-devops.git)
cd encargo-devops

### Paso B: Lanzar el Pipeline Automatizado CI/CD

# Otorgar permisos de ejecución al script (solo la primera vez)
chmod +x pipeline.sh

# Lanzar el pipeline completo
./pipeline.sh