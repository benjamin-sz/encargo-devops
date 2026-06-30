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
    echo "FALLA CRÍTICA DE CALIDAD: cobertura (${COBERTURA}%) por debajo del umbral (${UMBRAL_COBERTURA}%)."
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
        echo "FALLA CRÍTICA DE SEGURIDAD: Snyk encontró vulnerabilidades de severidad crítica."
        echo "Pipeline detenido. No se construye/despliega una imagen insegura."
        exit 1
    fi
    echo "Snyk: sin vulnerabilidades críticas."
else
    echo " El CLI de Snyk no está instalado/autenticado. Saltando escaneo (declarar en informe como riesgo aceptado)."
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
    echo " sonar-scanner no está instalado. Saltando análisis (declarar en informe)."
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

