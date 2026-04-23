CC := gcc
CFLAGS := -nostdlib -static
TARGET := analyzer
SRC := src/analyzer.s

.PHONY: all clean run test

all: $(TARGET)

$(TARGET): $(SRC)
	@echo "[INFO] Compilando en host ARM64 con gcc..."
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

run: $(TARGET)
	@echo "[INFO] Ejecutando analyzer..."
	./$(TARGET)

test: $(TARGET)
	@echo "[INFO] Ejecutando pruebas..."
	@chmod +x tests/test.sh
	@./tests/test.sh

clean:
	@echo "[INFO] Limpiando archivos generados..."
	@rm -f $(TARGET)
