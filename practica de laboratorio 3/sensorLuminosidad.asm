.data
# Mapeo de los registros del sensor de luminosidad en memoria de datos
LuzControl: .word 0
LuzEstado:  .word 0
LuzDatos:   .word 0

.text
.globl main
main:
    # 1. Llamar a inicializar
    jal InicializarSensorLuz
    
    # 2. Llamar a leer
    jal LeerLuminosidad
    
    # Al retornar, $v0 tendra la luz y $v1 el estado
    # (Puedes ver estos registros en el panel lateral de MARS)
    
    # 3. Terminar el programa limpiamente (Syscall 10)
    li $v0, 10
    syscall

# -------------------------------------------------------------------
# Procedimiento: InicializarSensorLuz
# Proposito: Escribe 0x1 en LuzControl y espera a que LuzEstado sea 1
# -------------------------------------------------------------------
InicializarSensorLuz:
    la $t0, LuzControl      # Cargar la direccion de LuzControl en $t0
    li $t1, 1               # Cargar el valor 0x1
    sw $t1, 0($t0)          # Escribir 0x1 para inicializar el sensor

esperar_luz:
    la $t0, LuzEstado       # Cargar la direccion de LuzEstado
    lw $t1, 0($t0)          # Leer el valor actual de LuzEstado
    li $t2, 1
    bne $t1, $t2, esperar_luz # Bucle de espera activa (polling) hasta que sea 1
    jr $ra                  # Retornar al invocador

# -------------------------------------------------------------------
# Procedimiento: LeerLuminosidad
# Proposito: Retorna el valor en $v0 y el estado en $v1 (0 = OK, -1 = Error)
# -------------------------------------------------------------------
LeerLuminosidad:
    la $t0, LuzEstado
    lw $t1, 0($t0)          # Revisar el estado actual del sensor
    
    li $t2, -1
    beq $t1, $t2, error_luz # Si el estado es -1, saltar a la rutina de error
    
    # Lectura correcta
    la $t0, LuzDatos
    lw $v0, 0($t0)          # Cargar la lectura de luminosidad en $v0
    li $v1, 0               # Codigo de estado 0 (lectura correcta) en $v1
    jr $ra                  # Retornar al invocador

error_luz:
    li $v0, 0               # Valor nulo por defecto en caso de error
    li $v1, -1              # Codigo de estado -1 (error de hardware) en $v1
    jr $ra                  # Retornar al invocador