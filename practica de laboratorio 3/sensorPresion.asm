.data
PresionControl: .word 0   # 0x10010000
PresionEstado:  .word 0   # 0x10010004
PresionDatos:   .word 0   # 0x10010008

.text
.globl main
main:
    # 1. Llamar a leer la presion (este inicializa internamente si falla)
    jal InicializarSensorPresion
    jal LeerPresion
    
    # Guardamos los resultados en registros seguros para verlos tranquilamente
    move $t8, $v0   # $t8 tendra la presion leida
    move $t9, $v1   # $t9 tendra el estado (0 o -1)
    
    # 2. Terminar el programa limpiamente
    li $v0, 10
    syscall

# --- PROCEDIMIENTOS ---
InicializarSensorPresion:
    la $t0, PresionControl
    li $t1, 5               # Escribir 0x5
    sw $t1, 0($t0)
    la $t0, PresionEstado
    sw $zero, 0($t0)        # Forzamos el estado a 0
    jr $ra

LeerPresion:
    # Prologo
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    li $s0, 0               # $s0 = contador de reintentos (0)

bucle_lectura_p:
    la $t0, PresionEstado
    lw $t1, 0($t0)
    beqz $t1, bucle_lectura_p # Espera activa si estado es 0

    li $t2, -1
    beq $t1, $t2, error_presion # Si es -1, error transitorio
    
    la $t0, PresionDatos
    lw $v0, 0($t0)
    li $v1, 0
    j fin_leer_p

error_presion:
    bnez $s0, fallo_definitivo # Si $s0 ya no es 0, fallo final
    
    li $s0, 1               # Marcar reintento
    jal InicializarSensorPresion # Reinicializar
    j bucle_lectura_p       # Reintentar

fallo_definitivo:
    li $v0, 0
    li $v1, -1

fin_leer_p:
    # Epilogo
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra