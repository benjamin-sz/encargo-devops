# Encargo: Implementación de Flujo de Trabajo DevOps

Este repositorio contiene la simulación de un entorno de desarrollo profesional utilizando **GitFlow**, integrando convenciones de código y automatización mediante **GitHub Actions**.

## 1. Justificación del Modelo
Se ha seleccionado **GitFlow** como flujo de trabajo debido a su robustez para proyectos que requieren un ciclo de liberación estructurado. 
- **Main:** Contiene el código siempre estable (Producción).
- **Develop:** Rama de integración para nuevas funcionalidades.
- **Features/Hotfixes:** Permiten el desarrollo en paralelo sin ensuciar las ramas principales, facilitando la colaboración y la revisión de código.

## 2. Convenciones de Desarrollo

### Naming (Nombramiento)
- **Ramas de Función:** `feature/nombre-de-la-tarea`
- **Ramas de Corrección:** `hotfix/nombre-del-error`
- **Archivos:** Uso de minúsculas y guiones (ej: `login-system.txt`).

### Commits (Mensajes)
Se utiliza el estándar de **Commits Convencionales**:
- `feat:` Para la implementación de nuevas funcionalidades.
- `fix:` Para corrección de errores.
- `docs:` Para cambios exclusivamente en la documentación.
- `ci:` Para cambios en la configuración de integración continua (GitHub Actions).

### Proceso de Revisión
Todo cambio debe ser integrado mediante **Pull Requests (PR)**:
1. Las **Features** se integran hacia la rama `develop`.
2. Los **Hotfixes** se integran hacia la rama `main` para soluciones inmediatas.

## 3. Simulación de Desarrollo
Durante el encargo se realizaron las siguientes acciones:
- **Feature 1:** Creación del módulo de autenticación (`feature/login-system`).
- **Feature 2:** Implementación del perfil de usuario (`feature/user-profile`).
- **Hotfix:** Resolución de vulnerabilidad crítica de seguridad (`hotfix/fix-seguridad`).

## 4. Automatización (GitHub Actions)
Se configuró un flujo de CI (Integración Continua) básico que se activa con cada `push` en el repositorio. Este flujo valida que el entorno esté disponible y que la entrega se haya realizado correctamente en los servidores de GitHub.
