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

