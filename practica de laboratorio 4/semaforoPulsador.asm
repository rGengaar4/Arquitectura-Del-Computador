.data
    s_presionada: .word 0
    msg_verde1:   .asciiz "\nSemaforo en verde, esperando pulsador."
    msg_verde2:   .asciiz "\nPulsador activado: en 20 segundos, el semaforo cambiara a amarillo."
    msg_amarillo: .asciiz "\nSemaforo en amarillo, en 10 segundos, semaforo en rojo."
    msg_rojo:     .asciiz "\nSemaforo en rojo, en 30 segundos, semaforo en verde."

.text
.globl main
main:
    # Habilitar interrupciones de teclado
    li $t0, 0xFFFF0000
    lw $t1, 0($t0)
    ori $t1, $t1, 0x0002
    sw $t1, 0($t0)

    # Habilitar en CP0
    mfc0 $t0, $12
    ori $t0, $t0, 0x0801
    mtc0 $t0, $12

estado_verde:
    li $v0, 4
    la $a0, msg_verde1
    syscall

esperar_s:
    lw $t0, s_presionada
    beq $t0, 1, transicion_verde
    j esperar_s

transicion_verde:
    li $v0, 4
    la $a0, msg_verde2
    syscall
    
    # Iniciar temporizador 20s
    li $v0, 30
    syscall
    move $s0, $a0
loop_20s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bge $t0, 20000, estado_amarillo
    j loop_20s

estado_amarillo:
    li $v0, 4
    la $a0, msg_amarillo
    syscall
    
    # Iniciar temporizador 10s
    li $v0, 30
    syscall
    move $s0, $a0
loop_10s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bge $t0, 10000, estado_rojo
    j loop_10s

estado_rojo:
    li $v0, 4
    la $a0, msg_rojo
    syscall
    
    # Iniciar temporizador 30s
    li $v0, 30
    syscall
    move $s0, $a0
loop_30s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bge $t0, 30000, reiniciar_ciclo
    j loop_30s

reiniciar_ciclo:
    sw $zero, s_presionada      # Apagar la bandera de la tecla 's'
    j estado_verde

# -----------------------------------------------------------------
# MANEJADOR DE EXCEPCIONES
# -----------------------------------------------------------------
.ktext 0x80000180
    mfc0 $k0, $13
    andi $k0, $k0, 0x003C
    bne $k0, $zero, fin_int2

    # Leer teclado
    li $k0, 0xFFFF0004
    lw $k1, 0($k0)

    # Verificar si es la tecla 's' (ASCII 115)
    bne $k1, 115, fin_int2

    # Activar bandera
    li $k0, 1
    sw $k0, s_presionada

fin_int2:
    eret