paridad:
    # 1. Comprobar Caso Base (n == 0)
    beq $a0, $zero, caso_base     # Si n == 0, salta a la etiqueta 'caso_base'

    # 2. Caso Recursivo (n > 0)
    # Prólogo: Guardamos $ra (dirección de retorno) y $a0 (valor de n actual) en la pila.
    addi $sp, $sp, -8       # Hacemos espacio para 2 palabras (8 bytes)
    sw $ra, 4($sp)          # Guardar la dirección de retorno en el offset 4
    sw $a0, 0($sp)          # Guardar el valor de 'n' en el offset 0

    # Preparar el argumento para la llamada recursiva: paridad(n - 1)
    addi $a0, $a0, -1       # $a0 = n - 1
    jal paridad             # Llama recursivamente a paridad

    # Epílogo: Restauramos $ra y $a0 de la pila una vez que la función retorna.
    lw $a0, 0($sp)          # Restauramos el 'n' original
    lw $ra, 4($sp)          # Restauramos la dirección de retorno
    addi $sp, $sp, 8        # Liberamos el espacio de la pila

    # En este punto, $v0 tiene el resultado de paridad(n - 1).
    # Debemos calcular: 1 - paridad(n - 1)
    li $t0, 1               # Cargar 1 en un registro temporal
    sub $v0, $t0, $v0       # $v0 = 1 - $v0

    jr $ra                  # Retornamos al llamador original

caso_base:
    # Si n = 0, el resultado es 0.
    li $v0, 0               # Cargar 0 en $v0
    jr $ra                  # Retornar