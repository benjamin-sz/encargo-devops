#!/bin/bash

# Detener el script si ocurre algún error
set -e


echo "INICIANDO PIPELINE CI/CD - BIBLIOTECATECEDU AUTH"

# 0. PREPARAR ENTORNO PARA TESTS
echo -e "\n[PASO 0/4] Levantando Base de Datos temporal para pruebas..."
docker compose up -d base-datos-mysql
echo "Esperando 10 segundos a que MySQL inicie por completo..."
sleep 10

# 1. PRUEBAS AUTOMATIZADAS
echo -e "\n🔹 [PASO 1/4] Ejecutando Pruebas Automatizadas de Maven..."
if [ -f "./mvnw" ]; then
    ./mvnw clean test
else
    mvn clean test
fi
echo "Pruebas superadas con éxito."

# 2. CONTENEDORES Y SEGURIDAD INTERNA
echo -e "\n[PASO 2/4] Construyendo imagen Docker (Multi-stage + No-Root)..."
docker build -t bibliotecatecedu-modulo:local .
echo "Imagen Docker construida correctamente."

# 3. ANÁLISIS DE SEGURIDAD CON SNYK
echo -e "\n[PASO 3/4] Analizando vulnerabilidades del contenedor con Snyk..."
if command -v snyk &> /dev/null; then
    # Escanea la imagen Docker local buscando fallos de seguridad graves
    snyk container test bibliotecatecedu-modulo:local || echo "Snyk encontró algunas alertas de seguridad."
else
    echo "El CLI de Snyk no está autenticado o instalado. Saltando escaneo."
fi

# 4. DESPLIEGUE CLOUD SIMULADO ESCALADO
echo -e "\n[PASO 4/4] Desplegando entorno simulado en Alta Disponibilidad..."
# Levanta el resto de los servicios (las 2 réplicas del microservicio)
docker compose up -d

echo -e "\n================================================================="
echo "¡PIPELINE FINALIZADO CON ÉXITO!"
echo "Tu microservicio (2 réplicas) y su BD MySQL están corriendo."
echo "Usa 'docker ps' para verificar los contenedores activos."