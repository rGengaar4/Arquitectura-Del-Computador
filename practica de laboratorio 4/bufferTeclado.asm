.data
    buffer:     .space 100       # Espacio para el buffer circular
    buf_idx:    .word 0          # Indice actual del buffer
    msg_out:    .asciiz "\n[20s pasados] Contenido del buffer: "
    msg_nl:     .asciiz "\n"

.text
.globl main
main:
    # Habilitar interrupciones de teclado (Receiver Control 0xFFFF0000, bit 1)
    li $t0, 0xFFFF0000
    lw $t1, 0($t0)
    ori $t1, $t1, 0x0002
    sw $t1, 0($t0)

    # Habilitar interrupciones en el Coprocesador 0 (Status register)
    mfc0 $t0, $12
    ori $t0, $t0, 0x0801        # Habilitar IE y mascara de teclado
    mtc0 $t0, $12

loop_principal:
    # Obtener tiempo de inicio
    li $v0, 30
    syscall                     # $a0 = low 32 bits, $a1 = high 32 bits
    move $s0, $a0               # Guardar tiempo inicial en $s0

esperar_20s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0          # Tiempo transcurrido
    bge $t0, 20000, imprimir_buffer # 20000 ms = 20 segundos
    j esperar_20s

imprimir_buffer:
    # Imprimir mensaje
    li $v0, 4
    la $a0, msg_out
    syscall

    # Imprimir contenido
    la $t0, buffer
    lw $t1, buf_idx
    add $t2, $t0, $t1
    sb $zero, 0($t2)            # Null terminator
    move $a0, $t0
    li $v0, 4
    syscall

    # Reiniciar indice del buffer a 0
    sw $zero, buf_idx

    j loop_principal

# -----------------------------------------------------------------
# MANEJADOR DE EXCEPCIONES
# -----------------------------------------------------------------
.ktext 0x80000180
    # Guardar contexto basico (solo usamos $k0 y $k1 aquí para no afectar main)
    mfc0 $k0, $13               # Leer registro Cause
    andi $k0, $k0, 0x003C       # Extraer ExcCode
    bne $k0, $zero, fin_int     # Si no es 0 (interrupcion de HW), salir

    # Leer caracter del teclado
    li $k0, 0xFFFF0004
    lw $k1, 0($k0)              # Caracter en $k1

    # Filtrar solo Mayusculas (A-Z) -> ASCII 65 a 90
    blt $k1, 65, fin_int
    bgt $k1, 90, fin_int

    # Guardar en buffer
    la $k0, buffer
    lw $a0, buf_idx
    add $k0, $k0, $a0           # Dirección exacta
    sb $k1, 0($k0)              # Guardar caracter

    # Incrementar indice (limitado a tamaño del buffer-1 por seguridad)
    addi $a0, $a0, 1
    blt $a0, 99, guardar_idx
    li $a0, 0                   # Reiniciar si llena (comportamiento circular basico)
guardar_idx:
    sw $a0, buf_idx

fin_int:
    eret
