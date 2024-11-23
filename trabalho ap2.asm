; ---------------------------------------------------------
; Projeto: Sistema Controlador de Tabela de Caracteres
; Disciplina: Arquitetura de Computadores
; Professor: Clayton J A Silva
; Alunos: [Nome 1 - Matrícula - TA/TP/NT]
;         [Nome 2 - Matrícula - TA/TP/NT]
;         [Nome 3 - Matrícula - TA/TP/NT]
; ---------------------------------------------------------

; Configuração inicial e diretivas
.org 0x0000         ; Define o ponto de entrada inicial
rjmp main           ; Salta para a rotina principal

; ---------------------------------------------------------
; Rotina principal
; ---------------------------------------------------------
main:
    ; Configurar PORTD como entrada e PORTC como saída
    clr r16             ; R16 = 0
    out DDRD, r16       ; Configura PORTD como entrada
    ldi r16, 0xFF       ; R16 = 0xFF
    out DDRC, r16       ; Configura PORTC como saída

    ; Criar tabela de caracteres desejados
    ldi ZH, 0x02        ; Configura Z para apontar para 0x200
    ldi ZL, 0x00

    ; Adiciona caracteres A-Z maiúsculos
    ldi r16, 'A'        ; Primeiro caractere: 'A'
store_uppercase:
    st Z+, r16          ; Armazena o caractere no endereço Z
    inc r16             ; Próximo caractere
    cpi r16, 'Z'+1      ; Verifica se passou de 'Z'
    brne store_uppercase

    ; Adiciona caracteres a-z minúsculos
    ldi r16, 'a'        ; Primeiro caractere: 'a'
store_lowercase:
    st Z+, r16          ; Armazena o caractere no endereço Z
    inc r16             ; Próximo caractere
    cpi r16, 'z'+1      ; Verifica se passou de 'z'
    brne store_lowercase

    ; Adiciona caracteres 0-9
    ldi r16, '0'        ; Primeiro caractere: '0'
store_digits:
    st Z+, r16          ; Armazena o caractere no endereço Z
    inc r16             ; Próximo caractere
    cpi r16, '9'+1      ; Verifica se passou de '9'
    brne store_digits

    ; Adiciona espaço em branco (0x20)
    ldi r16, 0x20       ; Espaço em branco
    st Z+, r16

    ; Adiciona caractere <ESC> (0x1B)
    ldi r16, 0x1B       ; Caractere <ESC>
    st Z+, r16

    rjmp loop           ; Vai para o loop principal

; ---------------------------------------------------------
; Loop principal
; ---------------------------------------------------------
loop:
    in r17, PIND        ; Lê o comando da porta de entrada
    cpi r17, 0x1C       ; Comando para ler sequência de caracteres
    breq read_sequence
    cpi r17, 0x1D       ; Comando para contar caracteres
    breq count_chars
    cpi r17, 0x1E       ; Comando para contar ocorrências
    breq count_occurrences
    rjmp loop           ; Volta ao início do loop

; ---------------------------------------------------------
; Rotina: Ler sequência de caracteres
; ---------------------------------------------------------
read_sequence:
    ldi ZH, 0x03        ; Configura Z para 0x300
    ldi ZL, 0x00
read_loop:
    in r18, PIND        ; Lê o caractere da porta de entrada
    cpi r18, 0x1B       ; Verifica se é o caractere <ESC>
    breq end_sequence
    cpi ZH, 0x04        ; Verifica se atingiu o limite 0x400
    brcs store_char_seq
    rjmp end_sequence
store_char_seq:
    st Z+, r18          ; Armazena o caractere na memória
    ldi r16, 0x20       ; Insere espaço em branco como separador
    st Z+, r16
    rjmp read_loop
end_sequence:
    rjmp loop

; ---------------------------------------------------------
; Rotina: Contar número de caracteres
; ---------------------------------------------------------
count_chars:
    ldi ZH, 0x03        ; Configura Z para 0x300
    ldi ZL, 0x00
    clr r19             ; R19 será o contador
count_loop:
    ld r16, Z+          ; Lê o caractere da memória
    cpi r16, 0x00       ; Verifica o final da tabela
    breq store_count
    inc r19             ; Incrementa o contador
    rjmp count_loop
store_count:
    sts 0x401, r19      ; Armazena o resultado em 0x401
    out PORTC, r19      ; Exibe o resultado na porta de saída
    rjmp loop

; ---------------------------------------------------------
; Rotina: Contar ocorrências de um caractere
; ---------------------------------------------------------
count_occurrences:
    in r20, PIND        ; Lê o caractere a ser contado
    ldi ZH, 0x03        ; Configura Z para 0x300
    ldi ZL, 0x00
    clr r21             ; R21 será o contador de ocorrências
count_occ_loop:
    ld r16, Z+          ; Lê o caractere da memória
    cpi r16, 0x00       ; Verifica o final da tabela
    breq store_occurrences
    cp r16, r20         ; Compara com o caractere de entrada
    brne count_occ_loop
    inc r21             ; Incrementa o contador
    rjmp count_occ_loop
store_occurrences:
    sts 0x402, r21      ; Armazena o resultado em 0x402
    out PORTC, r21      ; Exibe o resultado na porta de saída
    rjmp loop

; ---------------------------------------------------------
; Final do código
; ---------------------------------------------------------
