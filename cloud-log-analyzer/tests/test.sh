#!/usr/bin/env bash
# Pruebas automáticas para la variante base (conteo 2xx/4xx/5xx).

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -x ./analyzer ]]; then
  echo "[INFO] Compilando binario..."
  make
fi

run_analyzer() {
  local input_file="$1"

  if [[ $(uname -m) == "aarch64" ]]; then
    cat "$input_file" | ./analyzer
  elif command -v qemu-aarch64 >/dev/null 2>&1; then
    cat "$input_file" | qemu-aarch64 ./analyzer
  else
    echo "[WARN] Host no ARM64 y qemu-aarch64 no disponible; pruebas omitidas." >&2
    return 99
  fi
}

# Mapa de esperados por archivo
expected_output() {
  local key="$1"
  case "$key" in
    logs_A.txt)
      cat <<'TXT'
=== Mini Cloud Log Analyzer ===
Éxitos 2xx: 6
Errores 4xx: 2
Errores 5xx: 2
TXT
      ;;
    logs_B.txt)
      cat <<'TXT'
=== Mini Cloud Log Analyzer ===
Éxitos 2xx: 2
Errores 4xx: 3
Errores 5xx: 5
TXT
      ;;
    logs_C.txt)
      cat <<'TXT'
=== Mini Cloud Log Analyzer ===
Éxitos 2xx: 0
Errores 4xx: 10
Errores 5xx: 0
TXT
      ;;
    logs_D.txt)
      cat <<'TXT'
=== Mini Cloud Log Analyzer ===
Éxitos 2xx: 4
Errores 4xx: 3
Errores 5xx: 3
TXT
      ;;
    logs_E.txt)
      cat <<'TXT'
=== Mini Cloud Log Analyzer ===
Éxitos 2xx: 0
Errores 4xx: 0
Errores 5xx: 10
TXT
      ;;
    *)
      echo "Caso no definido: $key" >&2
      return 1
      ;;
  esac
}

status=0
for f in data/logs_*.txt; do
  base="$(basename "$f")"
  echo "[TEST] Validando $base"

  set +e
  output="$(run_analyzer "$f")"
  rc=$?
  set -e

  if [[ $rc -eq 99 ]]; then
    exit 0
  elif [[ $rc -ne 0 ]]; then
    echo "[FAIL] Falló la ejecución para $base (rc=$rc)"
    status=1
    continue
  fi

  expected="$(expected_output "$base")"

  if [[ "$output" == "$expected" ]]; then
    echo "[OK] $base"
  else
    echo "[FAIL] $base"
    echo "--- Esperado ---"
    echo "$expected"
    echo "--- Obtenido ---"
    echo "$output"
    status=1
  fi
  echo
 done

if [[ $status -eq 0 ]]; then
  echo "[RESULTADO] Todas las pruebas pasaron."
else
  echo "[RESULTADO] Hay pruebas fallidas."
fi

exit $status
