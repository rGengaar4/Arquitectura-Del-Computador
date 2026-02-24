# Entrada: $a0 (Número a evaluar)
# Salida: $v0 (0 si es par, 1 si es impar)

paridad:
    addi $t0, $zero, 1      # Cargo la constante 1 en $t0 para comparar más tarde

bucle:
    beq $a0, $zero, es_par   # CASO BASE: Si el número llegó a 0, es PAR. Salta.
    beq $a0, $t0, es_impar  # CASO BASE: Si el número llegó a 1, es IMPAR. Salta.

    addi $a0, $a0, -2       # LÓGICA: Le resto 2 al valor actual de $a0.
    j bucle                 # REPETIR: Vuelve a evaluar el nuevo valor de $a0.

es_par:
    add $v0, $zero, $a0     # Guardo el resultado final (0) en $v0 para devolverlo.
    jr $ra                  # Retorno: Vuelvo a la dirección que llamó a la función.

es_impar:
    add $v0, $zero, $a0     # Guardo el resultado final (1) en $v0 para devolverlo.
    jr $ra                  # Retorno: Vuelvo a la dirección que llamó a la función.