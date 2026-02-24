.data
    arreglo: .word 15, 3, 8, 20, 1, 4  # Datos de prueba
    tamano:  .word 6                   # N = 6

.text
.globl main

main:
    la $t0, arreglo         # Dirección base
    lw $t1, tamano          # $t1 = N

    # Bucle Externo (i)
    li $t2, 0               # i = 0
bucle_externo:
    sub $t3, $t1, 1         # $t3 = N - 1
    beq $t2, $t3, fin_sort  # Si i == N - 1, ya terminamos

    # Bucle Interno (j)
    li $t4, 0               # j = 0
bucle_interno:
    sub $t5, $t1, $t2       # N - i
    sub $t5, $t5, 1         # $t5 = N - i - 1 (límite para j)
    beq $t4, $t5, siguiente_i # Si j llegó al límite, saltamos a la siguiente 'i'

    # Calcular dirección de arreglo[j]
    sll $t6, $t4, 2         # j * 4 (convertir índice a bytes)
    add $t7, $t0, $t6       # Dirección base + offset
    
    # Cargar valores adyacentes
    lw $s0, 0($t7)          # valor_actual = arreglo[j]
    lw $s1, 4($t7)          # valor_siguiente = arreglo[j+1]

    # ¿Está en orden? (Si actual <= siguiente, no hacemos nada)
    ble $s0, $s1, sin_cambio
    
    # Intercambio (Swap) rústico
    sw $s1, 0($t7)          # El menor va a la izquierda
    sw $s0, 4($t7)          # El mayor va a la derecha

sin_cambio:
    addi $t4, $t4, 1        # j++
    j bucle_interno

siguiente_i:
    addi $t2, $t2, 1        # i++
    j bucle_externo

fin_sort:
    # Fin del programa
    li $v0, 10
    syscall