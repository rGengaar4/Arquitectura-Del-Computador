.data
# Mapeo de memoria (4 palabras consecutivas)
TensionControl: .word 0   # 0x10010000 (Columna Value +0)
TensionEstado:  .word 0   # 0x10010004 (Columna Value +4)
TensionSistol:  .word 0   # 0x10010008 (Columna Value +8)
TensionDiastol: .word 0   # 0x1001000c (Columna Value +c)

.text
.globl main
main:
    # 1. Llamar al controlador para iniciar y leer
    jal controlador_tension
    
    # 2. Rescatar los datos a registros seguros para poder verlos
    move $t8, $v0   # $t8 guardara la presion Sistolica
    move $t9, $v1   # $t9 guardara la presion Diastolica
    
    # 3. Terminar el programa limpiamente
    li $v0, 10
    syscall

# --- PROCEDIMIENTO ---
controlador_tension:
    # Iniciar la medicion
    la $t0, TensionControl
    li $t1, 1
    sw $t1, 0($t0)          # Escribir 1 en Control
    
    # --- SIMULACIÓN DEL HARDWARE FÍSICO ---
    # El hardware real pondría su estado en 0 (ocupado midiendo)
    la $t0, TensionEstado
    sw $zero, 0($t0)
    # --------------------------------------

esperar_tension:
    la $t0, TensionEstado
    lw $t1, 0($t0)          
    beqz $t1, esperar_tension  # Polling: se queda aqui mientras sea 0

    # Si sale del bucle, el estado es 1 (Listo)
    la $t0, TensionSistol
    lw $v0, 0($t0)          # Cargar Sistolica en $v0
    
    la $t0, TensionDiastol
    lw $v1, 0($t0)          # Cargar Diastolica en $v1
    
    jr $ra                  # Retornar al main