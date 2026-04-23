<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/a44bb0d7-30f9-4fff-95bf-f08277476255" />

## Información General
- **Nombre del estudiante:*MENDOZA SALGADO JESSICA*  
- **Grupo / Materia:*26B 4PM*  
- **Docente:*RENE SOLIS REYES *  
- **Fecha de entrega:*23/04/2026*  
- **Arquitectura:** Implementación de un Mini Cloud Log Analyzer en Bash Script + Assmblr 
- **Sistema operativo:** ARM64 LINUX
  ## Asciinema
https://asciinema.org/a/Oy7hsLjPuRe9GuGD
# Mini Cloud Log Analyzer (Bash + ARM64 + GNU Make)

Práctica universitaria orientada a estudiantes principiantes para reforzar fundamentos de:
- Ensamblador **ARM64 (AArch64 Linux)**,
- uso de **syscalls Linux** sin libc,
- automatización con **Bash**,
- y flujo de trabajo con **GitHub Classroom**.

---


## 📋 Descripción

Analizador de logs de servidor HTTP implementado completamente en **ARM64 Assembly**, sin usar libc ni funciones de C. El programa lee códigos de estado HTTP desde la entrada estándar (uno por línea) y genera un reporte estadístico incluyendo:

- Conteo de códigos 2xx (éxitos)
- Conteo de códigos 4xx (errores del cliente)
- Conteo de códigos 5xx (errores del servidor)
- **Código de estado más frecuente**

## 🏗️ Diseño Arquitectónico

### 1. Uso Exclusivo de Syscalls Linux

El programa utiliza únicamente syscalls directas sin intermediarios:

| Syscall | Número | Uso |
|---------|--------|-----|
| `read`  | 63     | Leer datos desde stdin |
| `write` | 64     | Imprimir resultados |
| `exit`  | 93     | Terminar el programa |

### 2. Estructura de Memoria


### 3. Registros Utilizados

| Registro | Propósito |
|----------|-----------|
| `x19` | Contador de códigos 2xx |
| `x20` | Contador de códigos 4xx |
| `x21` | Contador de códigos 5xx |
| `x22` | Número actual siendo parseado |
| `x23` | Flag: tiene_digitos (0/1) |
| `x24` | Índice en buffer actual |
| `x25` | Bytes leídos en bloque actual |
| `x26` | Almacenamiento temporal / código frecuente |
| `x27` | Frecuencia del código más frecuente |

## 🔄 Lógica de Procesamiento

### Diagrama de Flujo Principal

INICIO
├─→ Inicializar contadores en 0
│
└─→ │
│ read(stdin, buffer, 4096)
│
├─→ ¿bytes_leidos == 0? ───→ FIN_LECTURA
│
└─→ Procesar byte por byte
│
├─→ ¿byte == '\n'?
│ └─→ Clasificar número actual
│ ├─→ 200-299 → incrementar x19
│ ├─→ 400-499 → incrementar x20
│ ├─→ 500-599 → incrementar x21
│ └─→ Actualizar código más frecuente
│
└─→ ¿byte es dígito?
└─→ numero_actual = numero_actual * 10 + dígito

### Parseo de Enteros por Bloque

El programa implementa un parser **stateful** que:
1. Acumula dígitos mientras encuentra caracteres numéricos
2. Al encontrar `\n`, clasifica el código acumulado
3. Reinicia el acumulador para el siguiente código

Esto permite procesar archivos de cualquier tamaño sin cargar todo en memoria.

### Clasificación de Códigos HTTP

```arm64
clasificar_codigo:
    cmp x0, #200    ; límite inferior 2xx
    b.lt fin
    cmp x0, #299    ; límite superior 2xx
    b.gt revisar_4xx
    add x19, x19, #1    ; éxito
    
revisar_4xx:
    cmp x0, #400
    b.lt fin
    cmp x0, #499
    b.gt revisar_5xx
    add x20, x20, #1    ; error cliente
    
revisar_5xx:
    cmp x0, #500
    b.lt fin
    cmp x0, #599
    b.gt fin
    add x21, x21, #1    ; error servidor
```


