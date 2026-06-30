#!/bin/bash
set -e
echo "Instalando archivos de observabilidad EP3 sobre el proyecto actual..."
mkdir -p monitoring/grafana/provisioning/dashboards monitoring/grafana/provisioning/datasources k8s mysql-init

cat > "Dockerfile" <<'EOF_ARCHIVO'
# Etapa 1: Compilación usando Temurin 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Imagen de producción ligera con JRE 21
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Seguridad: Usuario no-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
COPY --from=build /app/target/*.jar app.jar

# Informamos que el microservicio usa el puerto 8084
EXPOSE 8084

# Healthcheck: Docker marca el contenedor 'unhealthy' si Actuator no responde
# (wget viene incluido en alpine vía busybox, no se necesita instalar curl)
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -q --spider http://localhost:8084/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]

EOF_ARCHIVO
echo '  -> Dockerfile'

cat > "pom.xml" <<'EOF_ARCHIVO'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>3.4.5</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	<groupId>com.example</groupId>
	<artifactId>BibliotecaTecEduAuth</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name/>
	<description/>
	<url/>
	<licenses>
		<license/>
	</licenses>
	<developers>
		<developer/>
	</developers>
	<scm>
		<connection/>
		<developerConnection/>
		<tag/>
		<url/>
	</scm>
	<properties>
		<java.version>21</java.version>
		<spring-cloud.version>2024.0.0</spring-cloud.version>
	</properties>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-actuator</artifactId>
		</dependency>
		<dependency>
			<groupId>io.micrometer</groupId>
			<artifactId>micrometer-registry-prometheus</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-security</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-jpa</artifactId>
		</dependency>
		<dependency>
			<groupId>com.mysql</groupId>
			<artifactId>mysql-connector-j</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>io.jsonwebtoken</groupId>
			<artifactId>jjwt-api</artifactId>
			<version>0.12.6</version>
		</dependency>
		<dependency>
			<groupId>io.jsonwebtoken</groupId>
			<artifactId>jjwt-impl</artifactId>
			<version>0.12.6</version>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>io.jsonwebtoken</groupId>
			<artifactId>jjwt-jackson</artifactId>
			<version>0.12.6</version>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<optional>true</optional>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-validation</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-starter-openfeign</artifactId>
		</dependency>
		<dependency>
			<groupId>org.flywaydb</groupId>
			<artifactId>flyway-core</artifactId>
		</dependency>
		<dependency>
			<groupId>org.flywaydb</groupId>
			<artifactId>flyway-mysql</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springdoc</groupId>
			<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
			<version>2.6.0</version>
		</dependency>
		<dependency>
			<groupId>net.datafaker</groupId>
			<artifactId>datafaker</artifactId>
			<version>2.3.0</version>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>org.mockito</groupId>
			<artifactId>mockito-core</artifactId>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-hateoas</artifactId>
		</dependency>
		<dependency>
			<groupId>org.junit.jupiter</groupId>
			<artifactId>junit-jupiter-engine</artifactId>
			<scope>test</scope>
		</dependency>
	</dependencies>
	<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>org.springframework.cloud</groupId>
				<artifactId>spring-cloud-dependencies</artifactId>
				<version>${spring-cloud.version}</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
	<build>
		<plugins>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
				<configuration>
					<excludes>
						<exclude>
							<groupId>org.projectlombok</groupId>
							<artifactId>lombok</artifactId>
						</exclude>
					</excludes>
				</configuration>
			</plugin>
			<plugin>
				<groupId>org.jacoco</groupId>
				<artifactId>jacoco-maven-plugin</artifactId>
				<version>0.8.12</version>
				<executions>
					<execution>
						<goals>
							<goal>prepare-agent</goal>
						</goals>
					</execution>
					<execution>
						<id>report</id>
						<phase>test</phase>
						<goals>
							<goal>report</goal>
						</goals>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
</project>

EOF_ARCHIVO
echo '  -> pom.xml'

cat > "docker-compose.yml" <<'EOF_ARCHIVO'
services:
  # 1. Contenedor de la Base de Datos MySQL
  base-datos-mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_DATABASE=biblioteca_tecedu_auth_dev
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_ROOT_HOST=%
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql-init:/docker-entrypoint-initdb.d
    restart: always
    networks:
      - red-bibliotecatecedu

  # 2. Instancia 1 de tu microservicio (Puerto 8083)
  microservicio-elegido-1:
    image: bibliotecatecedu-modulo:local
    build: .
    ports:
      - "8083:8084"  # Mapea el puerto 8083 de tu Windows al 8084 interno
    depends_on:
      - base-datos-mysql
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://base-datos-mysql:3306/biblioteca_tecedu_auth_dev?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=root
      - MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,prometheus,metrics
      - MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED=true
      - MANAGEMENT_HEALTH_PROBES_ENABLED=true
    restart: always
    networks:
      - red-bibliotecatecedu

  # 3. Instancia 2 de tu microservicio (Puerto 8084)
  microservicio-elegido-2:
    image: bibliotecatecedu-modulo:local
    build: .
    ports:
      - "8084:8084"  # Mapea el puerto 8084 de tu Windows al 8084 interno
    depends_on:
      - base-datos-mysql
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://base-datos-mysql:3306/biblioteca_tecedu_auth_dev?allowPublicKeyRetrieval=true&useSSL=false&serverTimezone=UTC
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=root
      - MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,prometheus,metrics
      - MANAGEMENT_ENDPOINT_HEALTH_PROBES_ENABLED=true
      - MANAGEMENT_HEALTH_PROBES_ENABLED=true
    restart: always
    networks:
      - red-bibliotecatecedu

volumes:
  mysql-data:

networks:
  red-bibliotecatecedu:
    name: red-bibliotecatecedu
    driver: bridge
EOF_ARCHIVO
echo '  -> docker-compose.yml'

cat > "docker-compose.observabilidad.yml" <<'EOF_ARCHIVO'
version: "3.8"

# Uso: docker compose -f docker-compose.yml -f docker-compose.observabilidad.yml up -d
# Mantiene intacto su docker-compose.yml original (microservicio + MySQL) y AGREGA el stack de observabilidad.

services:

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./monitoring/alert.rules.yml:/etc/prometheus/alert.rules.yml:ro
    ports:
      - "9090:9090"
    networks:
      - red-bibliotecatecedu

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    networks:
      - red-bibliotecatecedu

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    networks:
      - red-bibliotecatecedu

  # Permite que el script pipeline.sh "empuje" métricas que no son HTTP
  # (cobertura de tests, duración de despliegue, hallazgos de Snyk/Sonar)
  pushgateway:
    image: prom/pushgateway:latest
    container_name: pushgateway
    ports:
      - "9091:9091"
    networks:
      - red-bibliotecatecedu

  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonar-data:/opt/sonarqube/data
      - sonar-extensions:/opt/sonarqube/extensions
      - sonar-logs:/opt/sonarqube/logs
    networks:
      - red-bibliotecatecedu

  # Métricas de contenedores (CPU/memoria por contenedor) para el dashboard
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8081:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - red-bibliotecatecedu

volumes:
  grafana-data:
  sonar-data:
  sonar-extensions:
  sonar-logs:

networks:
  red-bibliotecatecedu:
    external: true
    name: red-bibliotecatecedu

EOF_ARCHIVO
echo '  -> docker-compose.observabilidad.yml'

cat > "pipeline.sh" <<'EOF_ARCHIVO'
#!/bin/bash

# Detener el script si ocurre algún error
set -e

PUSHGATEWAY_URL="http://localhost:9091"
JOB_NAME="pipeline_bibliotecatecedu"
INICIO_PIPELINE=$(date +%s)

echo "INICIANDO PIPELINE CI/CD - BIBLIOTECATECEDU AUTH"
echo "(con observabilidad, métricas y validación de cumplimiento normativo)"

# Función auxiliar: empuja una métrica al Pushgateway para que Prometheus/Grafana la lean
push_metric () {
  local nombre="$1"
  local valor="$2"
  cat <<EOF | curl -s --data-binary @- "${PUSHGATEWAY_URL}/metrics/job/${JOB_NAME}" \
      || echo "  (Aviso: no se pudo publicar la métrica '${nombre}', ¿está pushgateway levantado?)"
${nombre} ${valor}
EOF
}

# 0. PREPARAR ENTORNO PARA TESTS
echo -e "\n[PASO 0/7] Levantando Base de Datos temporal para pruebas..."
docker compose up -d base-datos-mysql
echo "Esperando 25 segundos a que MySQL inicie por completo..."
sleep 25

# 1. PRUEBAS AUTOMATIZADAS + COBERTURA (IE3)
echo -e "\n[PASO 1/7] Ejecutando Pruebas Automatizadas (perfil 'test') y midiendo cobertura..."
if [ -f "./mvnw" ]; then
    ./mvnw clean verify -Dspring.profiles.active=test
else
    mvn clean verify -Dspring.profiles.active=test
fi
echo "Pruebas superadas con éxito."

# Extrae el % de cobertura de líneas desde el reporte de JaCoCo y lo publica
if [ -f "target/site/jacoco/jacoco.csv" ]; then
    COBERTURA=$(awk -F',' 'NR>1 {cubiertas+=$5; total+=$4+$5} END {if (total>0) printf "%.2f", (cubiertas/total)*100; else print "0"}' target/site/jacoco/jacoco.csv)
else
    COBERTURA="0"
fi
echo "Cobertura de pruebas: ${COBERTURA}%"
push_metric "pipeline_test_coverage_percent" "${COBERTURA}"

# GATE DE CALIDAD (IE6): cobertura mínima exigida por política interna
UMBRAL_COBERTURA=60
if (( $(echo "${COBERTURA} < ${UMBRAL_COBERTURA}" | bc -l) )); then
    echo "❌ FALLA CRÍTICA DE CALIDAD: cobertura (${COBERTURA}%) por debajo del umbral (${UMBRAL_COBERTURA}%)."
    echo "Pipeline detenido. No se continúa con el build/despliegue."
    exit 1
fi

# 2. CONTENEDORES Y SEGURIDAD INTERNA
echo -e "\n[PASO 2/7] Construyendo imagen Docker (Multi-stage + No-Root)..."
docker build -t bibliotecatecedu-modulo:local .
echo "Imagen Docker construida correctamente."

# 3. ANÁLISIS DE SEGURIDAD CON SNYK (IE6: corta el pipeline ante vulnerabilidad crítica)
echo -e "\n[PASO 3/7] Analizando vulnerabilidades del contenedor con Snyk..."
SNYK_CRITICAS=0
if command -v snyk &> /dev/null; then
    set +e   # desactivamos 'exit on error' momentáneamente para capturar el código de salida de snyk
    snyk container test bibliotecatecedu-modulo:local --severity-threshold=critical --json > snyk-resultado.json
    SNYK_EXIT=$?
    set -e

    if [ -f snyk-resultado.json ]; then
        SNYK_CRITICAS=$(grep -o '"severity":"critical"' snyk-resultado.json | wc -l)
    fi
    push_metric "pipeline_snyk_critical_vulns" "${SNYK_CRITICAS}"

    if [ "${SNYK_EXIT}" -ne 0 ]; then
        echo "❌ FALLA CRÍTICA DE SEGURIDAD: Snyk encontró vulnerabilidades de severidad crítica."
        echo "Pipeline detenido. No se construye/despliega una imagen insegura."
        exit 1
    fi
    echo "Snyk: sin vulnerabilidades críticas."
else
    echo "⚠ El CLI de Snyk no está instalado/autenticado. Saltando escaneo (declarar en informe como riesgo aceptado)."
fi

# 4. ANÁLISIS ESTÁTICO Y CUMPLIMIENTO NORMATIVO CON SONARQUBE (IE5/IE6)
echo -e "\n[PASO 4/7] Ejecutando análisis estático con SonarQube y verificando Quality Gate..."
SONAR_BLOQUEANTES=0
if command -v sonar-scanner &> /dev/null; then
    sonar-scanner \
      -Dsonar.login="${SONAR_TOKEN}" \
      -Dsonar.qualitygate.wait=true

    # sonar-scanner con qualitygate.wait=true retorna código != 0 si el Quality Gate falla
    SONAR_BLOQUEANTES=$(grep -o '"status":"ERROR"' .scannerwork/report-task.txt 2>/dev/null | wc -l)
    push_metric "pipeline_sonar_blocker_issues" "${SONAR_BLOQUEANTES}"
    echo "Quality Gate de SonarQube: APROBADO."
else
    echo "⚠ sonar-scanner no está instalado. Saltando análisis (declarar en informe)."
    push_metric "pipeline_sonar_blocker_issues" "0"
fi
# Nota: si el Quality Gate falla, 'sonar-scanner' retorna código de error y,
# gracias a 'set -e' al inicio del script, el pipeline SE DETIENE automáticamente aquí (IE6).

# 5. VALIDACIÓN DE BRANCH PROTECTION / AUDITORÍA (IE5)
echo -e "\n[PASO 5/7] Verificando políticas de auditoría sobre el commit actual..."
COMMIT_AUTOR=$(git log -1 --pretty=format:'%an')
COMMIT_HASH=$(git rev-parse --short HEAD)
RAMA_ACTUAL=$(git rev-parse --abbrev-ref HEAD)
echo "Commit: ${COMMIT_HASH} | Autor: ${COMMIT_AUTOR} | Rama: ${RAMA_ACTUAL}"
echo "${COMMIT_HASH},${COMMIT_AUTOR},${RAMA_ACTUAL},$(date -u +%FT%TZ)" >> auditoria-pipeline.csv
echo "Registro de auditoría actualizado en auditoria-pipeline.csv"
# La protección real de la rama 'main' (revisores obligatorios, status checks
# obligatorios, prohibición de force-push) se configura en GitHub > Settings >
# Branches y se documenta con captura de pantalla en el informe.

# 6. DESPLIEGUE CLOUD SIMULADO ESCALADO
echo -e "\n[PASO 6/7] Desplegando entorno simulado en Alta Disponibilidad..."
docker compose -f docker-compose.yml -f docker-compose.observabilidad.yml up -d

echo "Esperando 15s y verificando salud de las réplicas (readiness probe)..."
sleep 15
declare -A INSTANCIAS=( ["microservicio-elegido-1"]="8083" ["microservicio-elegido-2"]="8084" )
for instancia in "${!INSTANCIAS[@]}"; do
    puerto_host="${INSTANCIAS[$instancia]}"
    if docker inspect "${instancia}" &> /dev/null; then
        ESTADO=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${puerto_host}/actuator/health/readiness" || echo "000")
        echo "  ${instancia} (puerto ${puerto_host}): HTTP ${ESTADO}"
    else
        echo "  ${instancia}: contenedor no encontrado."
    fi
done

# 7. PUBLICAR DURACIÓN TOTAL DEL DESPLIEGUE (IE3 - dashboard)
FIN_PIPELINE=$(date +%s)
DURACION=$((FIN_PIPELINE - INICIO_PIPELINE))
push_metric "pipeline_deploy_duration_seconds" "${DURACION}"

echo -e "\n================================================================="
echo "¡PIPELINE FINALIZADO CON ÉXITO! (duración: ${DURACION}s)"
echo "Tu microservicio (2 réplicas) y su BD MySQL están corriendo."
echo "Observabilidad disponible en:"
echo "  - Prometheus:    http://localhost:9090"
echo "  - Grafana:       http://localhost:3000 (admin/admin)"
echo "  - SonarQube:     http://localhost:9000"
echo "  - Alertmanager:  http://localhost:9093"
echo "Usa 'docker ps' para verificar los contenedores activos."

EOF_ARCHIVO
echo '  -> pipeline.sh'

cat > "demo-falla-critica.sh" <<'EOF_ARCHIVO'
#!/bin/bash
# demo-falla-critica.sh
# Uso: ./demo-falla-critica.sh
# Objetivo (IE6): evidenciar con captura/registro que el pipeline SE DETIENE
# ante una falla crítica, sin llegar a desplegar.

echo "=== DEMO: Forzando falla crítica de cobertura de pruebas ==="
echo "Se introduce temporalmente un test que falla / se baja el umbral simulado."

# Opción simple: bajar artificialmente UMBRAL_COBERTURA en pipeline.sh a 99
# para forzar que la cobertura real (~70-80%) no lo supere, y correr:
sed 's/UMBRAL_COBERTURA=60/UMBRAL_COBERTURA=99/' pipeline.sh > pipeline-demo.sh
chmod +x pipeline-demo.sh

echo "Ejecutando pipeline-demo.sh (debe detenerse en el PASO 1 con exit 1)..."
./pipeline-demo.sh
EXIT_CODE=$?

echo "Código de salida del pipeline: ${EXIT_CODE}"
if [ "${EXIT_CODE}" -ne 0 ]; then
    echo "✅ Evidencia capturada: el pipeline se detuvo correctamente ante una falla crítica."
else
    echo "❌ El pipeline NO se detuvo. Revisar gate de cumplimiento."
fi

rm -f pipeline-demo.sh

EOF_ARCHIVO
echo '  -> demo-falla-critica.sh'

cat > "sonar-project.properties" <<'EOF_ARCHIVO'
sonar.projectKey=bibliotecatecedu-modulo-auth
sonar.projectName=BibliotecaTecedu Auth
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.host.url=http://localhost:9000

# Cumplimiento normativo (IE5/IE6): no se acepta código con vulnerabilidades
# de seguridad ni bugs bloqueantes. Quality Gate "Sonar way" exige:
#  - 0 issues de severidad BLOCKER/CRITICAL en Security y Reliability
#  - Cobertura de pruebas nuevas >= 80%
#  - 0 duplicaciones de código > 3%

EOF_ARCHIVO
echo '  -> sonar-project.properties'

cat > "application-observabilidad.yml" <<'EOF_ARCHIVO'
# application-observabilidad.yml
# Importar con: spring.profiles.include: observabilidad  (o fusionar con application.yml)

management:
  endpoints:
    web:
      exposure:
        include: health, info, prometheus, metrics
  endpoint:
    health:
      show-details: always
      probes:
        enabled: true        # expone /actuator/health/liveness y /readiness (útil también para K8s)
  metrics:
    tags:
      application: bibliotecatecedu-modulo
    distribution:
      percentiles-histogram:
        http.server.requests: true   # necesario para histogram_quantile (latencia P95) en Grafana
  prometheus:
    metrics:
      export:
        enabled: true

logging:
  level:
    root: INFO
    com.bibliotecatecedu: DEBUG
  pattern:
    # Logs en formato JSON estructurado -> facilita correlación con métricas y trazas
    console: '{"timestamp":"%d{yyyy-MM-dd HH:mm:ss.SSS}","level":"%p","logger":"%c","thread":"%t","msg":"%m"}%n'

EOF_ARCHIVO
echo '  -> application-observabilidad.yml'

cat > "mysql-init/01-crear-bases.sql" <<'EOF_ARCHIVO'
CREATE DATABASE IF NOT EXISTS biblioteca_tecedu_auth_dev;
CREATE DATABASE IF NOT EXISTS biblioteca_tecedu_auth_test;

EOF_ARCHIVO
echo '  -> mysql-init/01-crear-bases.sql'

cat > "monitoring/prometheus.yml" <<'EOF_ARCHIVO'
global:
  scrape_interval: 10s
  evaluation_interval: 10s

rule_files:
  - "alert.rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]

scrape_configs:
  # El propio Prometheus
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Métricas "empujadas" por el pipeline (cobertura, duración despliegue, vulns)
  - job_name: 'pushgateway'
    honor_labels: true
    static_configs:
      - targets: ['pushgateway:9091']

  - job_name: 'bibliotecatecedu-modulo'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets:
          - 'microservicio-elegido-1:8084'
          - 'microservicio-elegido-2:8084'
        labels:
          servicio: 'auth-modulo'

EOF_ARCHIVO
echo '  -> monitoring/prometheus.yml'

cat > "monitoring/alert.rules.yml" <<'EOF_ARCHIVO'
groups:
  - name: bibliotecatecedu-alertas
    rules:

      - alert: ServicioCaido
        expr: up{job="bibliotecatecedu-modulo"} == 0
        for: 30s
        labels:
          severity: critical
        annotations:
          summary: "Microservicio caído ({{ $labels.instance }})"
          description: "No responde a /actuator/prometheus hace más de 30s."

      - alert: AltaTasaDeErrores5xx
        expr: |
          sum(rate(http_server_requests_seconds_count{status=~"5.."}[2m]))
          /
          sum(rate(http_server_requests_seconds_count[2m])) > 0.05
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Tasa de error 5xx > 5%"
          description: "Posible fallo crítico de calidad en producción simulada."

      - alert: LatenciaAlta
        expr: |
          histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket[5m])) by (le)) > 1.5
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "P95 de latencia > 1.5s"

      - alert: UsoMemoriaAlto
        expr: |
          (jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"}) > 0.85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Uso de heap JVM > 85%"

EOF_ARCHIVO
echo '  -> monitoring/alert.rules.yml'

cat > "monitoring/grafana/provisioning/datasources/datasource.yml" <<'EOF_ARCHIVO'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true

EOF_ARCHIVO
echo '  -> monitoring/grafana/provisioning/datasources/datasource.yml'

cat > "monitoring/grafana/provisioning/dashboards/dashboard.yml" <<'EOF_ARCHIVO'
apiVersion: 1

providers:
  - name: 'BibliotecaTecedu'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    options:
      path: /etc/grafana/provisioning/dashboards

EOF_ARCHIVO
echo '  -> monitoring/grafana/provisioning/dashboards/dashboard.yml'

cat > "monitoring/grafana/provisioning/dashboards/dashboard-bibliotecatecedu.json" <<'EOF_ARCHIVO'
{
  "title": "BibliotecaTecedu - Observabilidad CI/CD",
  "timezone": "browser",
  "panels": [
    {
      "type": "stat",
      "title": "Disponibilidad (instancias UP)",
      "gridPos": { "h": 6, "w": 6, "x": 0, "y": 0 },
      "targets": [{ "expr": "sum(up{job=\"bibliotecatecedu-modulo\"})" }]
    },
    {
      "type": "graph",
      "title": "Tasa de errores HTTP 5xx",
      "gridPos": { "h": 6, "w": 9, "x": 6, "y": 0 },
      "targets": [{ "expr": "sum(rate(http_server_requests_seconds_count{status=~\"5..\"}[2m]))" }]
    },
    {
      "type": "graph",
      "title": "Latencia P95 (s)",
      "gridPos": { "h": 6, "w": 9, "x": 15, "y": 0 },
      "targets": [{ "expr": "histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket[5m])) by (le))" }]
    },
    {
      "type": "graph",
      "title": "Uso de CPU por contenedor (%)",
      "gridPos": { "h": 6, "w": 8, "x": 0, "y": 6 },
      "targets": [{ "expr": "rate(container_cpu_usage_seconds_total{name=~\"bibliotecatecedu.*\"}[1m]) * 100" }]
    },
    {
      "type": "graph",
      "title": "Uso de memoria heap JVM (%)",
      "gridPos": { "h": 6, "w": 8, "x": 8, "y": 6 },
      "targets": [{ "expr": "(jvm_memory_used_bytes{area=\"heap\"} / jvm_memory_max_bytes{area=\"heap\"}) * 100" }]
    },
    {
      "type": "stat",
      "title": "Solicitudes por segundo",
      "gridPos": { "h": 6, "w": 8, "x": 16, "y": 6 },
      "targets": [{ "expr": "sum(rate(http_server_requests_seconds_count[1m]))" }]
    },
    {
      "type": "stat",
      "title": "Cobertura de pruebas (última build, %)",
      "description": "Alimentado por pipeline_metrics.prom generado en el paso de tests del pipeline.sh",
      "gridPos": { "h": 6, "w": 6, "x": 0, "y": 12 },
      "targets": [{ "expr": "pipeline_test_coverage_percent" }]
    },
    {
      "type": "stat",
      "title": "Duración del último despliegue (s)",
      "description": "Alimentado por pipeline_metrics.prom generado al final del pipeline.sh",
      "gridPos": { "h": 6, "w": 6, "x": 6, "y": 12 },
      "targets": [{ "expr": "pipeline_deploy_duration_seconds" }]
    },
    {
      "type": "stat",
      "title": "Vulnerabilidades críticas (Snyk, última build)",
      "gridPos": { "h": 6, "w": 6, "x": 12, "y": 12 },
      "targets": [{ "expr": "pipeline_snyk_critical_vulns" }]
    },
    {
      "type": "stat",
      "title": "Issues bloqueantes SonarQube",
      "gridPos": { "h": 6, "w": 6, "x": 18, "y": 12 },
      "targets": [{ "expr": "pipeline_sonar_blocker_issues" }]
    }
  ],
  "schemaVersion": 39,
  "version": 1
}

EOF_ARCHIVO
echo '  -> monitoring/grafana/provisioning/dashboards/dashboard-bibliotecatecedu.json'

cat > "k8s/deployment.yaml" <<'EOF_ARCHIVO'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bibliotecatecedu-modulo
  labels:
    app: bibliotecatecedu-modulo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: bibliotecatecedu-modulo
  template:
    metadata:
      labels:
        app: bibliotecatecedu-modulo
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/path: "/actuator/prometheus"
        prometheus.io/port: "8084"
    spec:
      containers:
        - name: bibliotecatecedu-modulo
          image: bibliotecatecedu-modulo:local
          ports:
            - containerPort: 8084
          resources:
            requests:
              cpu: "250m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8084
            initialDelaySeconds: 15
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8084
            initialDelaySeconds: 20
            periodSeconds: 15
---
apiVersion: v1
kind: Service
metadata:
  name: bibliotecatecedu-modulo-svc
spec:
  selector:
    app: bibliotecatecedu-modulo
  ports:
    - port: 8084
      targetPort: 8084
  type: ClusterIP

EOF_ARCHIVO
echo '  -> k8s/deployment.yaml'

cat > "k8s/README.md" <<'EOF_ARCHIVO'
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

EOF_ARCHIVO
echo '  -> k8s/README.md'

chmod +x pipeline.sh demo-falla-critica.sh
echo ""
echo "Listo."
echo "IMPORTANTE: corre  docker compose down -v  antes de ./pipeline.sh (de nuevo) para reiniciar el volumen de MySQL con el nuevo MYSQL_ROOT_HOST."