.data
    arreglo: .word 10, 80, 30, 90, 40, 50, 70
    tamano:  .word 7

.text
.globl main

main:
    la $a0, arreglo          # Dirección base
    li $a1, 0                # Bajo = 0
    lw $t0, tamano
    sub $a2, $t0, 1          # Alto = n - 1

    jal quicksort            # Llamada inicial

    # Fin del programa
    li $v0, 10
    syscall

# --- Función Quicksort ---
quicksort:
    # Guardar en la pila (puntero de retorno y argumentos)
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)

    # Condición base: si bajo < alto
    bge $a1, $a2, fin_quicksort

    # Partición (devuelve el índice del pivote en $v0)
    jal particion
    sw $v0, 12($sp)          # Guardar el índice del pivote (p)

    # Quicksort Izquierda: quicksort(arreglo, bajo, p - 1)
    lw $a1, 4($sp)           # Recuperar bajo original
    lw $v0, 12($sp)          # Recuperar p
    sub $a2, $v0, 1          # alto = p - 1
    jal quicksort

    # Quicksort Derecha: quicksort(arreglo, p + 1, alto)
    lw $v0, 12($sp)          # Recuperar p
    addi $a1, $v0, 1         # bajo = p + 1
    lw $a2, 8($sp)           # Recuperar alto original
    jal quicksort

fin_quicksort:
    lw $ra, 0($sp)           # Restaurar retorno
    addi $sp, $sp, 16        # Limpiar pila
    jr $ra

# --- Función Partición (Esquema de Lomuto) ---
particion:
    # $a0: base, $a1: bajo, $a2: alto
    sll $t0, $a2, 2          # alto * 4
    add $t0, $t0, $a0        # Dirección de arreglo[alto]
    lw $t1, 0($t0)           # $t1 = pivote (usamos el último elemento)

    addi $t2, $a1, -1        # $t2 = i (índice del más pequeño)
    move $t3, $a1            # $t3 = j (contador del bucle)

bucle_particion:
    bge $t3, $a2, terminar_particion
    
    sll $t4, $t3, 2          # j * 4
    add $t4, $t4, $a0        # Dirección arreglo[j]
    lw $t5, 0($t4)           # $t5 = arreglo[j]

    # Si arreglo[j] <= pivote
    bgt $t5, $t1, siguiente_j
    
    addi $t2, $t2, 1         # i++
    sll $t6, $t2, 2          # i * 4
    add $t6, $t6, $a0        # Dirección arreglo[i]
    lw $t7, 0($t6)           # Swap: cargar arreglo[i]
    sw $t5, 0($t6)           # arreglo[i] = arreglo[j]
    sw $t7, 0($t4)           # arreglo[j] = temp

siguiente_j:
    addi $t3, $t3, 1         # j++
    j bucle_particion

terminar_particion:
    # Swap final del pivote: swap(arreglo[i+1], arreglo[alto])
    addi $t2, $t2, 1         # i + 1
    sll $t6, $t2, 2
    add $t6, $t6, $a0        # Dirección arreglo[i+1]
    lw $t7, 0($t6)
    sw $t1, 0($t6)           # arreglo[i+1] = pivote
    sw $t7, 0($t0)           # arreglo[alto] = anterior arreglo[i+1]

    move $v0, $t2            # Devolver índice i + 1
    jr $ra