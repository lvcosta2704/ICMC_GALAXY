; ==================================================================
;                  JOGO ICMC GALAXY - FUNDOS DINÂMICOS
; ==================================================================

jmp TelaDeTitulo    ; Começa na abertura

; --- VARIÁVEIS GLOBAIS ---

PosJogador: var #1
static PosJogador + #0, #1140
; Variável de Fundo

PtrFundoAtual: var #1
static PtrFundoAtual + #0, #0

; Placar
mensagemlevel: var #7
static mensagemlevel + #0, #'L'
static mensagemlevel + #1, #'E'
static mensagemlevel + #2, #'V'
static mensagemlevel + #3, #'E'
static mensagemlevel + #4, #'L'
static mensagemlevel + #5, #':'
static mensagemlevel + #6, #0

Level: var #1
static Level + #0, #1 

GameSpeed: var #1
static GameSpeed + #0, #100   

; Inimigo
AlienTimer: var #1
static AlienTimer + #0, #0
AlienSpeed: var #1
static AlienSpeed + #0, #50
AlienPos: var #1
static AlienPos + #0, #250
AlienDir: var #1
static AlienDir + #0, #1
AlienVivo: var #1
static AlienVivo + #0, #1

; Tiro
TiroTimer: var #1
static TiroTimer + #0, #0
TiroSpeed: var #1
static TiroSpeed + #0, #13  
TiroStatus: var #1
static TiroStatus + #0, #0
TiroPos: var #1
static TiroPos + #0, #0

Score: var #1
static Score + #0, #0

; ==================================================================
; 1. TELA DE TÍTULO
; ==================================================================
TelaDeTitulo:
    call printTelaInicioScreen
    
LoopEsperaEnter:
    loadn r1, #255
    inchar r0
    cmp r0, r1
    jeq LoopEsperaEnter

    loadn r1, #13
    cmp r0, r1
    jeq IniciarJogo

    jmp LoopEsperaEnter

IniciarJogo:
    call LimpaTela
    jmp main

; ==================================================================
; 2. MAIN
; ==================================================================
main:
    ; --- 1. RESET GERAL ---
    loadn r0, #250
    store AlienPos, r0
    loadn r0, #1
    store AlienVivo, r0
    store AlienDir, r0
    store Level, r0
    loadn r0, #0
    store Score, r0
    store TiroStatus, r0
    loadn r0, #50
    store AlienSpeed, r0
    store PosJogador, r0

    ; --- 2. SELETOR DE FUNDO ---
    load r0, Level
    
    ; Niveis 1-3 (Azul)
    loadn r1, #3
    cmp r0, r1
    jle CarregaFundo1
    
    ; Niveis 4-6 (Verde)
    loadn r1, #6
    cmp r0, r1
    jle CarregaFundo2
    
    ; Niveis 7+ (Vermelho)
    jmp CarregaFundo3

CarregaFundo1:
    loadn r1, #nivel1-3
    jmp DefineFundo
CarregaFundo2:
    loadn r1, #nivel4-6
    jmp DefineFundo
CarregaFundo3:
    loadn r1, #nivel7-9

DefineFundo:
    store PtrFundoAtual, r1
    call DesenhaFundoCompleto  ; <--- DESENHA O FUNDO

    ; --- 3. DESENHA RESTO (DEPOIS DO FUNDO!) ---
    call ImprimePlacar         ; <--- AGORA O PLACAR APARECE

    loadn r0, #1140
    loadn r6, #40
    call DesenhaJogador
    
    push r0
    load r0, AlienPos
    call DesenhaAlien
    pop r0

    jmp LoopJogo

LoopJogo:
    call ProcessaInput
    call AtualizaTiro
    call AtualizaAlien
    call VerificaColisao
    call Delay
    jmp LoopJogo

; ==================================================================
; 3. LÓGICA
; ==================================================================

ProcessaInput:
    push r0
    push r3
    push r4
    push r5

    loadn r3, #255
    inchar r4
    cmp r4, r3
    jeq FimInput

    loadn r5, #'a'
    cmp r4, r5
    jeq MoveEsq

    loadn r5, #'d'
    cmp r4, r5
    jeq MoveDir

    loadn r5, #' '
    cmp r4, r5
    jeq TentaAtirar

    jmp FimInput

MoveEsq:
    loadn r5, #40
    mod r3, r0, r5
    loadn r5, #0
    cmp r3, r5
    jeq FimInput

    call ApagaJogador  
    dec r0
    store PosJogador, r0
    call DesenhaJogador 
    jmp FimInput

MoveDir:
    loadn r5, #40
    mod r3, r0, r5
    loadn r5, #38        
    cmp r3, r5
    jeq FimInput

    call ApagaJogador  
    inc r0
    store PosJogador, r0
    call DesenhaJogador
    jmp FimInput

TentaAtirar:
    load r3, TiroStatus
    loadn r5, #1
    cmp r3, r5
    jeq FimInput

    loadn r5, #40
    sub r5, r0, r5
    inc r5
    store TiroPos, r5
    loadn r5, #1
    store TiroStatus, r5
    jmp FimInput

FimInput:
    pop r5
    pop r4
    pop r3
    pop r5
    rts

AtualizaTiro:
    push r0
    push r3
    push r4
    push r5
    push r6

    load r0, TiroTimer
    inc r0
    store TiroTimer, r0
    load r3, TiroSpeed
    cmp r0, r3
    jle SaiTiro
    loadn r0, #0
    store TiroTimer, r0

    load r3, TiroStatus
    loadn r4, #0
    cmp r3, r4
    jeq SaiTiro

    load r0, TiroPos
    loadn r6, #40

    cmp r0, r6
    jle ApagaTiro

    ; --- CORREÇÃO: USA RESTAURA PIXEL ---
    call RestauraPixel  ; Apaga tiro velho restaurando fundo

    sub r0, r0, r6
    
    ; Desenha novo tiro
    loadn r5, #11       ; Índice do seu projetil verde
    outchar r5, r0
    store TiroPos, r0
    jmp SaiTiro

ApagaTiro:
    call RestauraPixel  ; Apaga tiro no teto restaurando fundo
    loadn r4, #0
    store TiroStatus, r4

SaiTiro:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r0
    rts

AtualizaAlien:
    push r0
    push r1
    push r2
    push r3
    push r4

    load r0, AlienTimer
    inc r0
    store AlienTimer, r0
    load r1, AlienSpeed
    cmp r0, r1
    jle SaiAtualizaAlien
    loadn r0, #0
    store AlienTimer, r0

    load r0, AlienVivo
    loadn r1, #0
    cmp r0, r1
    jeq SaiAtualizaAlien

    load r0, AlienPos
    loadn r2, #40

    call ApagaAlien    ; Apaga restaurando fundo

    mod r3, r0, r2
    loadn r4, #38      
    cmp r3, r4
    jgr ViraParaEsquerda
    jeq ViraParaEsquerda

    loadn r4, #0       
    cmp r3, r4
    jle ViraParaDireita
    jeq ViraParaDireita
    
    jmp AplicaMovimento

ViraParaEsquerda:
    loadn r1, #0
    store AlienDir, r1
    loadn r4, #40
    add r0, r0, r4
    jmp AplicaMovimento

ViraParaDireita:
    loadn r1, #1
    store AlienDir, r1
    loadn r4, #40
    add r0, r0, r4
    jmp AplicaMovimento

AplicaMovimento:
    loadn r4, #1100
    cmp r0, r4
    jgr TeladeGameOver

    load r1, AlienDir
    loadn r2, #1
    cmp r1, r2
    jeq MoveAlienDir
    dec r0
    jmp SalvaAlien

MoveAlienDir:
    inc r0
    jmp SalvaAlien

SalvaAlien:
    store AlienPos, r0
    call DesenhaAlien

SaiAtualizaAlien:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

VerificaColisao:
    push r0
    push r1
    push r2
    push r3
    push r4

    load r0, TiroStatus
    loadn r1, #0
    cmp r0, r1
    jeq FimColisao

    load r0, AlienVivo
    cmp r0, r1
    jeq FimColisao

    load r0, TiroPos
    load r1, AlienPos
    
    cmp r0, r1
    jeq MatarAlien
    loadn r2, #1
    add r3, r1, r2
    cmp r0, r3
    jeq MatarAlien
    loadn r2, #40
    add r3, r1, r2
    cmp r0, r3
    jeq MatarAlien
    loadn r2, #41
    add r3, r1, r2
    cmp r0, r3
    jeq MatarAlien
    
    jmp FimColisao

MatarAlien:
    mov r0, r1
    call ApagaAlien
    
    loadn r2, #0
    store TiroStatus, r2
    load r0, TiroPos
    call RestauraPixel  ; Apaga o tiro que acertou

    load r0, Score
    inc r0
    store Score, r0

    ; Aumenta Nivel e Velocidade
    load r0, Level
    inc r0
    store Level, r0
    call ImprimePlacar

    call VerificaTrocaFundo

    load r0, AlienSpeed
    loadn r2, #5
    sub r0, r0, r2
    loadn r2, #2
    cmp r0, r2
    jle MantemVelocidade
    store AlienSpeed, r0

MantemVelocidade:
    loadn r0, #250
    store AlienPos, r0
    loadn r0, #1
    store AlienVivo, r0
    jmp FimColisao

FimColisao:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

TeladeGameOver:
    call LimpaTela
    call printGameOverScreen
LoopOpcaoTelaGameOverDados:
    loadn r1, #255
    inchar r0
    cmp r0, r1
    jeq LoopOpcaoTelaGameOverDados
    loadn r1, #'s'
    cmp r0, r1
    jeq ReiniciarJogo
    loadn r1, #'n'
    cmp r0, r1
    jeq IrParaTitulo
    jmp LoopOpcaoTelaGameOverDados

IrParaTitulo:
    jmp TelaDeTitulo

ReiniciarJogo:
    call LimpaTela
    jmp main

; --- GRÁFICOS E AUXILIARES ---

RestauraPixel:
    push r1
    push r2
    load r1, PtrFundoAtual
    add r1, r1, r0
    loadi r2, r1
    outchar r2, r0
    pop r2
    pop r1
    rts

DesenhaFundoCompleto:
    push r0
    push r1
    push r2
    push r3
    load r1, PtrFundoAtual
    loadn r0, #0
    loadn r2, #1200
LoopDesenhaFundo:
    loadi r3, r1
    outchar r3, r0
    inc r0
    inc r1
    dec r2
    jnz LoopDesenhaFundo
    pop r3
    pop r2
    pop r1
    pop r0
    rts

ApagaJogador:
    push r0
    push r1
    push r2
    
    ; Apaga Cima-Esq
    call RestauraPixel
    
    ; Apaga Cima-Dir
    inc r0
    call RestauraPixel
    
    ; Apaga Baixo-Esq
    loadn r2, #39
    add r0, r0, r2
    call RestauraPixel
    
    ; Apaga Baixo-Dir
    inc r0
    call RestauraPixel
    
    pop r2
    pop r1
    pop r0
    rts

ApagaAlien:
    push r0
    push r1
    push r2
    call RestauraPixel
    inc r0
    call RestauraPixel
    loadn r2, #39
    add r0, r0, r2
    call RestauraPixel
    inc r0
    call RestauraPixel
    pop r2
    pop r1
    pop r0
    rts

DesenhaJogador:
    push r0
    push r1
    push r2
    
    ; -- Parte 1: Cima Esq (Index 7) --
    loadn r1, #2823    ; 2816 (Amarelo) + 7
    outchar r1, r0
    
    ; -- Parte 2: Cima Dir (Index 8) --
    inc r0             ; Vai pra direita
    loadn r1, #2824    ; 2816 + 8
    outchar r1, r0
    
    ; -- Parte 3: Baixo Esq (Index 9) --
    ; Estamos na direita (pos + 1). 
    ; Para ir para a linha de baixo na esquerda (pos + 40), somamos 39.
    loadn r2, #39
    add r0, r0, r2
    loadn r1, #2826    ; 2816 + 9
    outchar r1, r0
    
    ; -- Parte 4: Baixo Dir (Index 10) --
    inc r0             ; Vai pra direita
    loadn r1, #2825    ; 2816 + 10
    outchar r1, r0
    
    pop r2
    pop r1
    pop r0
    rts

DesenhaAlien:
    push r0
    push r1
    push r2
    loadn r1, #2307
    outchar r1, r0
    inc r0
    loadn r1, #2308
    outchar r1, r0
    loadn r2, #39
    add r0, r0, r2
    loadn r1, #2309
    outchar r1, r0
    inc r0
    loadn r1, #2310
    outchar r1, r0
    pop r2
    pop r1
    pop r0
    rts

Delay: 
    push r0
    push r1
    load r0, GameSpeed
DelayLoop1:
    loadn r1, #100
DelayLoop2:
    dec r1
    jnz DelayLoop2
    dec r0
    jnz DelayLoop1
    pop r1
    pop r0
    rts

ImprimePlacar:
    push r0
    push r1
    push r2
    push r3
    loadn r0, #0
    loadn r1, #mensagemlevel
    loadn r2, #512
    call ImprimeString
    loadn r0, #6
    load r1, Level
    loadn r2, #512
    loadn r3, #48
    add r1, r1, r3
    add r1, r1, r2
    outchar r1, r0
    pop r3
    pop r2
    pop r1
    pop r0
    rts

ImprimeString:
    push r0
    push r1
    push r2
    push r3
    push r4
    loadn r4, #'\0'
ImprimeStringLoop:
    loadi r3, r1
    cmp r3, r4
    jeq SaiImprimeString
    add r3, r3, r2
    outchar r3, r0
    inc r0
    inc r1
    jmp ImprimeStringLoop
SaiImprimeString:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

LimpaTela:
    push r0
    push r1
    push r2
    loadn r0, #1200
    loadn r1, #0
    loadn r2, #' '
LimpaLoop:
    outchar r2, r1
    inc r1
    dec r0
    jnz LimpaLoop
    pop r2
    pop r1
    pop r0
    rts

printTelaInicioScreen:
    push R0
    push R1
    push R2
    push R3
    loadn R0, #TelaInicioDados
    loadn R1, #0
    loadn R2, #1200
printTelaInicioScreenLoop:
    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2
    jne printTelaInicioScreenLoop
    pop R3
    pop R2
    pop R1
    pop R0
    rts

printGameOverScreen:
    push R0
    push R1
    push R2
    push R3
    loadn R0, #TelaGameOverDados
    loadn R1, #0
    loadn R2, #1200
printGameOverScreenLoop:
    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2
    jne printGameOverScreenLoop
    pop R3
    pop R2
    pop R1
    pop R0
    rts

VerificaTrocaFundo:
    push r0
    push r1
    push r2
    
    load r0, Level
    
    ; --- Nível 1 a 3: Fundo 1 ---
    loadn r1, #3
    cmp r0, r1
    jle SetFundo1      ; Se Nivel <= 3, Fundo 1
    
    ; --- Nível 4 a 6: Fundo 2 ---
    loadn r1, #6
    cmp r0, r1
    jle SetFundo2      ; Se Nivel <= 6, Fundo 2
    
    ; --- Nível 7+: Fundo 3 ---
    jmp SetFundo3

SetFundo1:
    loadn r1, #nivel1-3
    jmp AplicaFundo
SetFundo2:
    loadn r1, #nivel4-6
    jmp AplicaFundo
SetFundo3:
    loadn r1, #nivel7-9

AplicaFundo:
    load r2, PtrFundoAtual
    cmp r1, r2
    jeq SaiTrocaFundo   

    ; SE MUDOU DE FUNDO:
    store PtrFundoAtual, r1
    
    ; 1. Desenha Fundo
    call DesenhaFundoCompleto
    
    ; 2. Desenha Placar
    call ImprimePlacar
    
    ; 3. REDESENHA O JOGADOR (A Correção!)
    push r0             ; Salva r0 (que tem o Level)
    load r0, PosJogador ; Carrega a posição real do jogador
    call DesenhaJogador ; Desenha ele por cima do fundo novo
    pop r0              ; Devolve r0 (Level)
    
SaiTrocaFundo:
    pop r2
    pop r1
    pop r0
    rts

TelaInicioDados : var #1200
  ;Linha 0
  static TelaInicioDados + #0, #512
  static TelaInicioDados + #1, #512
  static TelaInicioDados + #2, #3967
  static TelaInicioDados + #3, #3967
  static TelaInicioDados + #4, #3967
  static TelaInicioDados + #5, #3967
  static TelaInicioDados + #6, #3967
  static TelaInicioDados + #7, #3967
  static TelaInicioDados + #8, #3967
  static TelaInicioDados + #9, #3114
  static TelaInicioDados + #10, #3118
  static TelaInicioDados + #11, #3967
  static TelaInicioDados + #12, #3967
  static TelaInicioDados + #13, #3967
  static TelaInicioDados + #14, #3118
  static TelaInicioDados + #15, #3967
  static TelaInicioDados + #16, #3967
  static TelaInicioDados + #17, #3967
  static TelaInicioDados + #18, #3967
  static TelaInicioDados + #19, #3967
  static TelaInicioDados + #20, #3967
  static TelaInicioDados + #21, #3967
  static TelaInicioDados + #22, #3967
  static TelaInicioDados + #23, #3967
  static TelaInicioDados + #24, #3967
  static TelaInicioDados + #25, #3370
  static TelaInicioDados + #26, #3118
  static TelaInicioDados + #27, #3967
  static TelaInicioDados + #28, #3967
  static TelaInicioDados + #29, #3967
  static TelaInicioDados + #30, #3967
  static TelaInicioDados + #31, #3967
  static TelaInicioDados + #32, #3967
  static TelaInicioDados + #33, #3967
  static TelaInicioDados + #34, #3967
  static TelaInicioDados + #35, #3967
  static TelaInicioDados + #36, #3967
  static TelaInicioDados + #37, #3967
  static TelaInicioDados + #38, #512
  static TelaInicioDados + #39, #512

  ;Linha 1
  static TelaInicioDados + #40, #512
  static TelaInicioDados + #41, #512
  static TelaInicioDados + #42, #3967
  static TelaInicioDados + #43, #3967
  static TelaInicioDados + #44, #3967
  static TelaInicioDados + #45, #3967
  static TelaInicioDados + #46, #3967
  static TelaInicioDados + #47, #3967
  static TelaInicioDados + #48, #3967
  static TelaInicioDados + #49, #2602
  static TelaInicioDados + #50, #3967
  static TelaInicioDados + #51, #3967
  static TelaInicioDados + #52, #3967
  static TelaInicioDados + #53, #3967
  static TelaInicioDados + #54, #3967
  static TelaInicioDados + #55, #3967
  static TelaInicioDados + #56, #3370
  static TelaInicioDados + #57, #3967
  static TelaInicioDados + #58, #3967
  static TelaInicioDados + #59, #3967
  static TelaInicioDados + #60, #3967
  static TelaInicioDados + #61, #1026
  static TelaInicioDados + #62, #3967
  static TelaInicioDados + #63, #3967
  static TelaInicioDados + #64, #3967
  static TelaInicioDados + #65, #3967
  static TelaInicioDados + #66, #3967
  static TelaInicioDados + #67, #3967
  static TelaInicioDados + #68, #3967
  static TelaInicioDados + #69, #3967
  static TelaInicioDados + #70, #3967
  static TelaInicioDados + #71, #3967
  static TelaInicioDados + #72, #3967
  static TelaInicioDados + #73, #3967
  static TelaInicioDados + #74, #2602
  static TelaInicioDados + #75, #3967
  static TelaInicioDados + #76, #3967
  static TelaInicioDados + #77, #3967
  static TelaInicioDados + #78, #512
  static TelaInicioDados + #79, #512

  ;Linha 2
  static TelaInicioDados + #80, #512
  static TelaInicioDados + #81, #512
  static TelaInicioDados + #82, #3967
  static TelaInicioDados + #83, #3967
  static TelaInicioDados + #84, #3967
  static TelaInicioDados + #85, #2602
  static TelaInicioDados + #86, #3967
  static TelaInicioDados + #87, #3118
  static TelaInicioDados + #88, #3967
  static TelaInicioDados + #89, #3967
  static TelaInicioDados + #90, #3967
  static TelaInicioDados + #91, #3967
  static TelaInicioDados + #92, #3967
  static TelaInicioDados + #93, #3328
  static TelaInicioDados + #94, #3967
  static TelaInicioDados + #95, #3328
  static TelaInicioDados + #96, #3328
  static TelaInicioDados + #97, #3328
  static TelaInicioDados + #98, #3967
  static TelaInicioDados + #99, #3328
  static TelaInicioDados + #100, #3328
  static TelaInicioDados + #101, #3967
  static TelaInicioDados + #102, #3328
  static TelaInicioDados + #103, #3328
  static TelaInicioDados + #104, #3967
  static TelaInicioDados + #105, #3328
  static TelaInicioDados + #106, #3328
  static TelaInicioDados + #107, #3328
  static TelaInicioDados + #108, #3118
  static TelaInicioDados + #109, #1026
  static TelaInicioDados + #110, #3967
  static TelaInicioDados + #111, #3967
  static TelaInicioDados + #112, #3114
  static TelaInicioDados + #113, #3967
  static TelaInicioDados + #114, #3967
  static TelaInicioDados + #115, #3967
  static TelaInicioDados + #116, #3967
  static TelaInicioDados + #117, #3967
  static TelaInicioDados + #118, #512
  static TelaInicioDados + #119, #512

  ;Linha 3
  static TelaInicioDados + #120, #512
  static TelaInicioDados + #121, #512
  static TelaInicioDados + #122, #3967
  static TelaInicioDados + #123, #3967
  static TelaInicioDados + #124, #3107
  static TelaInicioDados + #125, #3967
  static TelaInicioDados + #126, #3967
  static TelaInicioDados + #127, #3967
  static TelaInicioDados + #128, #3630
  static TelaInicioDados + #129, #3630
  static TelaInicioDados + #130, #3967
  static TelaInicioDados + #131, #3967
  static TelaInicioDados + #132, #3967
  static TelaInicioDados + #133, #3328
  static TelaInicioDados + #134, #3967
  static TelaInicioDados + #135, #3328
  static TelaInicioDados + #136, #3967
  static TelaInicioDados + #137, #3967
  static TelaInicioDados + #138, #3967
  static TelaInicioDados + #139, #3328
  static TelaInicioDados + #140, #3967
  static TelaInicioDados + #141, #3328
  static TelaInicioDados + #142, #3967
  static TelaInicioDados + #143, #3328
  static TelaInicioDados + #144, #3967
  static TelaInicioDados + #145, #3328
  static TelaInicioDados + #146, #3967
  static TelaInicioDados + #147, #3967
  static TelaInicioDados + #148, #3967
  static TelaInicioDados + #149, #3967
  static TelaInicioDados + #150, #3118
  static TelaInicioDados + #151, #3967
  static TelaInicioDados + #152, #3967
  static TelaInicioDados + #153, #3967
  static TelaInicioDados + #154, #3967
  static TelaInicioDados + #155, #3967
  static TelaInicioDados + #156, #3967
  static TelaInicioDados + #157, #3967
  static TelaInicioDados + #158, #512
  static TelaInicioDados + #159, #512

  ;Linha 4
  static TelaInicioDados + #160, #512
  static TelaInicioDados + #161, #512
  static TelaInicioDados + #162, #3967
  static TelaInicioDados + #163, #3967
  static TelaInicioDados + #164, #3967
  static TelaInicioDados + #165, #3967
  static TelaInicioDados + #166, #3967
  static TelaInicioDados + #167, #2
  static TelaInicioDados + #168, #3967
  static TelaInicioDados + #169, #3118
  static TelaInicioDados + #170, #3967
  static TelaInicioDados + #171, #3967
  static TelaInicioDados + #172, #3118
  static TelaInicioDados + #173, #3328
  static TelaInicioDados + #174, #3967
  static TelaInicioDados + #175, #3328
  static TelaInicioDados + #176, #3967
  static TelaInicioDados + #177, #3967
  static TelaInicioDados + #178, #2602
  static TelaInicioDados + #179, #3328
  static TelaInicioDados + #180, #3967
  static TelaInicioDados + #181, #3328
  static TelaInicioDados + #182, #3967
  static TelaInicioDados + #183, #3328
  static TelaInicioDados + #184, #3967
  static TelaInicioDados + #185, #3328
  static TelaInicioDados + #186, #3967
  static TelaInicioDados + #187, #3967
  static TelaInicioDados + #188, #3967
  static TelaInicioDados + #189, #3967
  static TelaInicioDados + #190, #3967
  static TelaInicioDados + #191, #32
  static TelaInicioDados + #192, #1282
  static TelaInicioDados + #193, #3967
  static TelaInicioDados + #194, #2602
  static TelaInicioDados + #195, #3967
  static TelaInicioDados + #196, #3967
  static TelaInicioDados + #197, #3967
  static TelaInicioDados + #198, #512
  static TelaInicioDados + #199, #512

  ;Linha 5
  static TelaInicioDados + #200, #512
  static TelaInicioDados + #201, #512
  static TelaInicioDados + #202, #3967
  static TelaInicioDados + #203, #3967
  static TelaInicioDados + #204, #3967
  static TelaInicioDados + #205, #3967
  static TelaInicioDados + #206, #3967
  static TelaInicioDados + #207, #3967
  static TelaInicioDados + #208, #3967
  static TelaInicioDados + #209, #3967
  static TelaInicioDados + #210, #2602
  static TelaInicioDados + #211, #3967
  static TelaInicioDados + #212, #3967
  static TelaInicioDados + #213, #3328
  static TelaInicioDados + #214, #3967
  static TelaInicioDados + #215, #3328
  static TelaInicioDados + #216, #3328
  static TelaInicioDados + #217, #3328
  static TelaInicioDados + #218, #3967
  static TelaInicioDados + #219, #3328
  static TelaInicioDados + #220, #2602
  static TelaInicioDados + #221, #3967
  static TelaInicioDados + #222, #3967
  static TelaInicioDados + #223, #3328
  static TelaInicioDados + #224, #3967
  static TelaInicioDados + #225, #3328
  static TelaInicioDados + #226, #3328
  static TelaInicioDados + #227, #3328
  static TelaInicioDados + #228, #3967
  static TelaInicioDados + #229, #1026
  static TelaInicioDados + #230, #3967
  static TelaInicioDados + #231, #3967
  static TelaInicioDados + #232, #3967
  static TelaInicioDados + #233, #3967
  static TelaInicioDados + #234, #3967
  static TelaInicioDados + #235, #3967
  static TelaInicioDados + #236, #3967
  static TelaInicioDados + #237, #3967
  static TelaInicioDados + #238, #512
  static TelaInicioDados + #239, #512

  ;Linha 6
  static TelaInicioDados + #240, #512
  static TelaInicioDados + #241, #512
  static TelaInicioDados + #242, #3967
  static TelaInicioDados + #243, #3967
  static TelaInicioDados + #244, #3967
  static TelaInicioDados + #245, #3967
  static TelaInicioDados + #246, #3967
  static TelaInicioDados + #247, #3114
  static TelaInicioDados + #248, #3967
  static TelaInicioDados + #249, #3967
  static TelaInicioDados + #250, #3967
  static TelaInicioDados + #251, #3967
  static TelaInicioDados + #252, #3967
  static TelaInicioDados + #253, #3967
  static TelaInicioDados + #254, #3967
  static TelaInicioDados + #255, #3967
  static TelaInicioDados + #256, #3967
  static TelaInicioDados + #257, #3967
  static TelaInicioDados + #258, #3967
  static TelaInicioDados + #259, #3967
  static TelaInicioDados + #260, #3967
  static TelaInicioDados + #261, #3967
  static TelaInicioDados + #262, #3967
  static TelaInicioDados + #263, #3967
  static TelaInicioDados + #264, #3967
  static TelaInicioDados + #265, #3967
  static TelaInicioDados + #266, #3967
  static TelaInicioDados + #267, #3967
  static TelaInicioDados + #268, #3967
  static TelaInicioDados + #269, #3967
  static TelaInicioDados + #270, #3967
  static TelaInicioDados + #271, #3967
  static TelaInicioDados + #272, #3967
  static TelaInicioDados + #273, #3967
  static TelaInicioDados + #274, #3967
  static TelaInicioDados + #275, #3967
  static TelaInicioDados + #276, #3967
  static TelaInicioDados + #277, #3967
  static TelaInicioDados + #278, #512
  static TelaInicioDados + #279, #512

  ;Linha 7
  static TelaInicioDados + #280, #512
  static TelaInicioDados + #281, #512
  static TelaInicioDados + #282, #3967
  static TelaInicioDados + #283, #2
  static TelaInicioDados + #284, #3967
  static TelaInicioDados + #285, #3967
  static TelaInicioDados + #286, #3072
  static TelaInicioDados + #287, #3072
  static TelaInicioDados + #288, #3072
  static TelaInicioDados + #289, #3967
  static TelaInicioDados + #290, #3072
  static TelaInicioDados + #291, #3072
  static TelaInicioDados + #292, #3072
  static TelaInicioDados + #293, #3072
  static TelaInicioDados + #294, #3967
  static TelaInicioDados + #295, #3072
  static TelaInicioDados + #296, #3967
  static TelaInicioDados + #297, #3967
  static TelaInicioDados + #298, #3118
  static TelaInicioDados + #299, #3072
  static TelaInicioDados + #300, #3072
  static TelaInicioDados + #301, #3072
  static TelaInicioDados + #302, #3072
  static TelaInicioDados + #303, #3967
  static TelaInicioDados + #304, #3072
  static TelaInicioDados + #305, #3967
  static TelaInicioDados + #306, #3967
  static TelaInicioDados + #307, #3072
  static TelaInicioDados + #308, #3967
  static TelaInicioDados + #309, #3072
  static TelaInicioDados + #310, #3840
  static TelaInicioDados + #311, #3072
  static TelaInicioDados + #312, #3967
  static TelaInicioDados + #313, #2
  static TelaInicioDados + #314, #3967
  static TelaInicioDados + #315, #3370
  static TelaInicioDados + #316, #3967
  static TelaInicioDados + #317, #3967
  static TelaInicioDados + #318, #512
  static TelaInicioDados + #319, #512

  ;Linha 8
  static TelaInicioDados + #320, #512
  static TelaInicioDados + #321, #512
  static TelaInicioDados + #322, #3967
  static TelaInicioDados + #323, #3967
  static TelaInicioDados + #324, #2862
  static TelaInicioDados + #325, #3967
  static TelaInicioDados + #326, #3072
  static TelaInicioDados + #327, #3967
  static TelaInicioDados + #328, #3967
  static TelaInicioDados + #329, #3967
  static TelaInicioDados + #330, #3072
  static TelaInicioDados + #331, #2346
  static TelaInicioDados + #332, #3967
  static TelaInicioDados + #333, #3072
  static TelaInicioDados + #334, #3967
  static TelaInicioDados + #335, #3072
  static TelaInicioDados + #336, #3967
  static TelaInicioDados + #337, #3967
  static TelaInicioDados + #338, #3967
  static TelaInicioDados + #339, #3072
  static TelaInicioDados + #340, #3967
  static TelaInicioDados + #341, #3967
  static TelaInicioDados + #342, #3072
  static TelaInicioDados + #343, #3967
  static TelaInicioDados + #344, #3967
  static TelaInicioDados + #345, #3072
  static TelaInicioDados + #346, #3072
  static TelaInicioDados + #347, #3967
  static TelaInicioDados + #348, #3967
  static TelaInicioDados + #349, #3072
  static TelaInicioDados + #350, #3072
  static TelaInicioDados + #351, #3072
  static TelaInicioDados + #352, #3967
  static TelaInicioDados + #353, #3967
  static TelaInicioDados + #354, #3118
  static TelaInicioDados + #355, #3967
  static TelaInicioDados + #356, #3967
  static TelaInicioDados + #357, #3967
  static TelaInicioDados + #358, #512
  static TelaInicioDados + #359, #512

  ;Linha 9
  static TelaInicioDados + #360, #512
  static TelaInicioDados + #361, #512
  static TelaInicioDados + #362, #3967
  static TelaInicioDados + #363, #3967
  static TelaInicioDados + #364, #3967
  static TelaInicioDados + #365, #3967
  static TelaInicioDados + #366, #3072
  static TelaInicioDados + #367, #3967
  static TelaInicioDados + #368, #3072
  static TelaInicioDados + #369, #3967
  static TelaInicioDados + #370, #3072
  static TelaInicioDados + #371, #3072
  static TelaInicioDados + #372, #3072
  static TelaInicioDados + #373, #3072
  static TelaInicioDados + #374, #3967
  static TelaInicioDados + #375, #3072
  static TelaInicioDados + #376, #3967
  static TelaInicioDados + #377, #3967
  static TelaInicioDados + #378, #3967
  static TelaInicioDados + #379, #3072
  static TelaInicioDados + #380, #3072
  static TelaInicioDados + #381, #3072
  static TelaInicioDados + #382, #3072
  static TelaInicioDados + #383, #3967
  static TelaInicioDados + #384, #3967
  static TelaInicioDados + #385, #3072
  static TelaInicioDados + #386, #3072
  static TelaInicioDados + #387, #3967
  static TelaInicioDados + #388, #3967
  static TelaInicioDados + #389, #3967
  static TelaInicioDados + #390, #3967
  static TelaInicioDados + #391, #3072
  static TelaInicioDados + #392, #3967
  static TelaInicioDados + #393, #3967
  static TelaInicioDados + #394, #3967
  static TelaInicioDados + #395, #3374
  static TelaInicioDados + #396, #3967
  static TelaInicioDados + #397, #3967
  static TelaInicioDados + #398, #512
  static TelaInicioDados + #399, #512

  ;Linha 10
  static TelaInicioDados + #400, #512
  static TelaInicioDados + #401, #512
  static TelaInicioDados + #402, #3967
  static TelaInicioDados + #403, #32
  static TelaInicioDados + #404, #32
  static TelaInicioDados + #405, #3967
  static TelaInicioDados + #406, #3072
  static TelaInicioDados + #407, #3072
  static TelaInicioDados + #408, #3072
  static TelaInicioDados + #409, #3967
  static TelaInicioDados + #410, #3072
  static TelaInicioDados + #411, #3967
  static TelaInicioDados + #412, #3967
  static TelaInicioDados + #413, #3072
  static TelaInicioDados + #414, #3967
  static TelaInicioDados + #415, #3072
  static TelaInicioDados + #416, #3072
  static TelaInicioDados + #417, #3072
  static TelaInicioDados + #418, #3967
  static TelaInicioDados + #419, #3072
  static TelaInicioDados + #420, #3967
  static TelaInicioDados + #421, #3967
  static TelaInicioDados + #422, #3072
  static TelaInicioDados + #423, #3967
  static TelaInicioDados + #424, #3072
  static TelaInicioDados + #425, #3967
  static TelaInicioDados + #426, #3967
  static TelaInicioDados + #427, #3072
  static TelaInicioDados + #428, #3967
  static TelaInicioDados + #429, #3072
  static TelaInicioDados + #430, #3072
  static TelaInicioDados + #431, #3072
  static TelaInicioDados + #432, #3967
  static TelaInicioDados + #433, #3967
  static TelaInicioDados + #434, #3967
  static TelaInicioDados + #435, #3967
  static TelaInicioDados + #436, #3967
  static TelaInicioDados + #437, #3967
  static TelaInicioDados + #438, #512
  static TelaInicioDados + #439, #512

  ;Linha 11
  static TelaInicioDados + #440, #512
  static TelaInicioDados + #441, #512
  static TelaInicioDados + #442, #3967
  static TelaInicioDados + #443, #3967
  static TelaInicioDados + #444, #3967
  static TelaInicioDados + #445, #3967
  static TelaInicioDados + #446, #3967
  static TelaInicioDados + #447, #3967
  static TelaInicioDados + #448, #3967
  static TelaInicioDados + #449, #3967
  static TelaInicioDados + #450, #3967
  static TelaInicioDados + #451, #3967
  static TelaInicioDados + #452, #3967
  static TelaInicioDados + #453, #3967
  static TelaInicioDados + #454, #3967
  static TelaInicioDados + #455, #3370
  static TelaInicioDados + #456, #3967
  static TelaInicioDados + #457, #3967
  static TelaInicioDados + #458, #3967
  static TelaInicioDados + #459, #3967
  static TelaInicioDados + #460, #3118
  static TelaInicioDados + #461, #3967
  static TelaInicioDados + #462, #3967
  static TelaInicioDados + #463, #3967
  static TelaInicioDados + #464, #3967
  static TelaInicioDados + #465, #3967
  static TelaInicioDados + #466, #3967
  static TelaInicioDados + #467, #3967
  static TelaInicioDados + #468, #3967
  static TelaInicioDados + #469, #3967
  static TelaInicioDados + #470, #3967
  static TelaInicioDados + #471, #3118
  static TelaInicioDados + #472, #3967
  static TelaInicioDados + #473, #3967
  static TelaInicioDados + #474, #3967
  static TelaInicioDados + #475, #2
  static TelaInicioDados + #476, #3967
  static TelaInicioDados + #477, #3967
  static TelaInicioDados + #478, #512
  static TelaInicioDados + #479, #512

  ;Linha 12
  static TelaInicioDados + #480, #512
  static TelaInicioDados + #481, #512
  static TelaInicioDados + #482, #3967
  static TelaInicioDados + #483, #3967
  static TelaInicioDados + #484, #3967
  static TelaInicioDados + #485, #3967
  static TelaInicioDados + #486, #3114
  static TelaInicioDados + #487, #3967
  static TelaInicioDados + #488, #3967
  static TelaInicioDados + #489, #3967
  static TelaInicioDados + #490, #3967
  static TelaInicioDados + #491, #3967
  static TelaInicioDados + #492, #3118
  static TelaInicioDados + #493, #32
  static TelaInicioDados + #494, #32
  static TelaInicioDados + #495, #32
  static TelaInicioDados + #496, #32
  static TelaInicioDados + #497, #3967
  static TelaInicioDados + #498, #3967
  static TelaInicioDados + #499, #3967
  static TelaInicioDados + #500, #3967
  static TelaInicioDados + #501, #3967
  static TelaInicioDados + #502, #3967
  static TelaInicioDados + #503, #3374
  static TelaInicioDados + #504, #3967
  static TelaInicioDados + #505, #3967
  static TelaInicioDados + #506, #3967
  static TelaInicioDados + #507, #3967
  static TelaInicioDados + #508, #3967
  static TelaInicioDados + #509, #3967
  static TelaInicioDados + #510, #3967
  static TelaInicioDados + #511, #3967
  static TelaInicioDados + #512, #3967
  static TelaInicioDados + #513, #3967
  static TelaInicioDados + #514, #32
  static TelaInicioDados + #515, #32
  static TelaInicioDados + #516, #32
  static TelaInicioDados + #517, #3967
  static TelaInicioDados + #518, #512
  static TelaInicioDados + #519, #512

  ;Linha 13
  static TelaInicioDados + #520, #512
  static TelaInicioDados + #521, #512
  static TelaInicioDados + #522, #3967
  static TelaInicioDados + #523, #3967
  static TelaInicioDados + #524, #2306
  static TelaInicioDados + #525, #3967
  static TelaInicioDados + #526, #32
  static TelaInicioDados + #527, #32
  static TelaInicioDados + #528, #3967
  static TelaInicioDados + #529, #1282
  static TelaInicioDados + #530, #3967
  static TelaInicioDados + #531, #3967
  static TelaInicioDados + #532, #3967
  static TelaInicioDados + #533, #3967
  static TelaInicioDados + #534, #3374
  static TelaInicioDados + #535, #3967
  static TelaInicioDados + #536, #32
  static TelaInicioDados + #537, #32
  static TelaInicioDados + #538, #32
  static TelaInicioDados + #539, #1282
  static TelaInicioDados + #540, #3967
  static TelaInicioDados + #541, #32
  static TelaInicioDados + #542, #32
  static TelaInicioDados + #543, #32
  static TelaInicioDados + #544, #46
  static TelaInicioDados + #545, #32
  static TelaInicioDados + #546, #32
  static TelaInicioDados + #547, #32
  static TelaInicioDados + #548, #32
  static TelaInicioDados + #549, #1282
  static TelaInicioDados + #550, #3967
  static TelaInicioDados + #551, #46
  static TelaInicioDados + #552, #32
  static TelaInicioDados + #553, #32
  static TelaInicioDados + #554, #46
  static TelaInicioDados + #555, #32
  static TelaInicioDados + #556, #3967
  static TelaInicioDados + #557, #3967
  static TelaInicioDados + #558, #512
  static TelaInicioDados + #559, #512

  ;Linha 14
  static TelaInicioDados + #560, #512
  static TelaInicioDados + #561, #512
  static TelaInicioDados + #562, #3967
  static TelaInicioDados + #563, #3967
  static TelaInicioDados + #564, #3967
  static TelaInicioDados + #565, #3967
  static TelaInicioDados + #566, #32
  static TelaInicioDados + #567, #46
  static TelaInicioDados + #568, #3967
  static TelaInicioDados + #569, #3967
  static TelaInicioDados + #570, #3967
  static TelaInicioDados + #571, #3967
  static TelaInicioDados + #572, #3967
  static TelaInicioDados + #573, #3967
  static TelaInicioDados + #574, #3967
  static TelaInicioDados + #575, #3967
  static TelaInicioDados + #576, #3967
  static TelaInicioDados + #577, #32
  static TelaInicioDados + #578, #32
  static TelaInicioDados + #579, #32
  static TelaInicioDados + #580, #32
  static TelaInicioDados + #581, #32
  static TelaInicioDados + #582, #32
  static TelaInicioDados + #583, #46
  static TelaInicioDados + #584, #3967
  static TelaInicioDados + #585, #3967
  static TelaInicioDados + #586, #3967
  static TelaInicioDados + #587, #46
  static TelaInicioDados + #588, #3967
  static TelaInicioDados + #589, #3967
  static TelaInicioDados + #590, #3967
  static TelaInicioDados + #591, #3967
  static TelaInicioDados + #592, #3967
  static TelaInicioDados + #593, #3967
  static TelaInicioDados + #594, #3967
  static TelaInicioDados + #595, #32
  static TelaInicioDados + #596, #3967
  static TelaInicioDados + #597, #3967
  static TelaInicioDados + #598, #512
  static TelaInicioDados + #599, #512

  ;Linha 15
  static TelaInicioDados + #600, #512
  static TelaInicioDados + #601, #512
  static TelaInicioDados + #602, #3967
  static TelaInicioDados + #603, #3967
  static TelaInicioDados + #604, #3967
  static TelaInicioDados + #605, #32
  static TelaInicioDados + #606, #32
  static TelaInicioDados + #607, #32
  static TelaInicioDados + #608, #32
  static TelaInicioDados + #609, #32
  static TelaInicioDados + #610, #32
  static TelaInicioDados + #611, #46
  static TelaInicioDados + #612, #32
  static TelaInicioDados + #613, #32
  static TelaInicioDados + #614, #2
  static TelaInicioDados + #615, #32
  static TelaInicioDados + #616, #2306
  static TelaInicioDados + #617, #3967
  static TelaInicioDados + #618, #3967
  static TelaInicioDados + #619, #32
  static TelaInicioDados + #620, #32
  static TelaInicioDados + #621, #32
  static TelaInicioDados + #622, #32
  static TelaInicioDados + #623, #32
  static TelaInicioDados + #624, #32
  static TelaInicioDados + #625, #3967
  static TelaInicioDados + #626, #2346
  static TelaInicioDados + #627, #3967
  static TelaInicioDados + #628, #3967
  static TelaInicioDados + #629, #3967
  static TelaInicioDados + #630, #3967
  static TelaInicioDados + #631, #3967
  static TelaInicioDados + #632, #46
  static TelaInicioDados + #633, #3967
  static TelaInicioDados + #634, #3967
  static TelaInicioDados + #635, #32
  static TelaInicioDados + #636, #3967
  static TelaInicioDados + #637, #3374
  static TelaInicioDados + #638, #512
  static TelaInicioDados + #639, #512

  ;Linha 16
  static TelaInicioDados + #640, #512
  static TelaInicioDados + #641, #512
  static TelaInicioDados + #642, #3967
  static TelaInicioDados + #643, #32
  static TelaInicioDados + #644, #2862
  static TelaInicioDados + #645, #32
  static TelaInicioDados + #646, #3967
  static TelaInicioDados + #647, #3374
  static TelaInicioDados + #648, #3967
  static TelaInicioDados + #649, #3967
  static TelaInicioDados + #650, #3967
  static TelaInicioDados + #651, #3967
  static TelaInicioDados + #652, #3967
  static TelaInicioDados + #653, #3967
  static TelaInicioDados + #654, #32
  static TelaInicioDados + #655, #32
  static TelaInicioDados + #656, #3374
  static TelaInicioDados + #657, #32
  static TelaInicioDados + #658, #32
  static TelaInicioDados + #659, #32
  static TelaInicioDados + #660, #3967
  static TelaInicioDados + #661, #3374
  static TelaInicioDados + #662, #32
  static TelaInicioDados + #663, #46
  static TelaInicioDados + #664, #2306
  static TelaInicioDados + #665, #3967
  static TelaInicioDados + #666, #3967
  static TelaInicioDados + #667, #3967
  static TelaInicioDados + #668, #3967
  static TelaInicioDados + #669, #3967
  static TelaInicioDados + #670, #3967
  static TelaInicioDados + #671, #3374
  static TelaInicioDados + #672, #3967
  static TelaInicioDados + #673, #3967
  static TelaInicioDados + #674, #3967
  static TelaInicioDados + #675, #32
  static TelaInicioDados + #676, #3967
  static TelaInicioDados + #677, #3967
  static TelaInicioDados + #678, #512
  static TelaInicioDados + #679, #512

  ;Linha 17
  static TelaInicioDados + #680, #512
  static TelaInicioDados + #681, #512
  static TelaInicioDados + #682, #3967
  static TelaInicioDados + #683, #32
  static TelaInicioDados + #684, #32
  static TelaInicioDados + #685, #2306
  static TelaInicioDados + #686, #3967
  static TelaInicioDados + #687, #3967
  static TelaInicioDados + #688, #3967
  static TelaInicioDados + #689, #32
  static TelaInicioDados + #690, #3967
  static TelaInicioDados + #691, #32
  static TelaInicioDados + #692, #3967
  static TelaInicioDados + #693, #3967
  static TelaInicioDados + #694, #3967
  static TelaInicioDados + #695, #3967
  static TelaInicioDados + #696, #3967
  static TelaInicioDados + #697, #3967
  static TelaInicioDados + #698, #32
  static TelaInicioDados + #699, #3374
  static TelaInicioDados + #700, #3967
  static TelaInicioDados + #701, #32
  static TelaInicioDados + #702, #32
  static TelaInicioDados + #703, #32
  static TelaInicioDados + #704, #32
  static TelaInicioDados + #705, #3967
  static TelaInicioDados + #706, #3967
  static TelaInicioDados + #707, #3967
  static TelaInicioDados + #708, #3967
  static TelaInicioDados + #709, #3967
  static TelaInicioDados + #710, #3967
  static TelaInicioDados + #711, #3967
  static TelaInicioDados + #712, #3967
  static TelaInicioDados + #713, #3967
  static TelaInicioDados + #714, #46
  static TelaInicioDados + #715, #32
  static TelaInicioDados + #716, #3967
  static TelaInicioDados + #717, #3967
  static TelaInicioDados + #718, #512
  static TelaInicioDados + #719, #512

  ;Linha 18
  static TelaInicioDados + #720, #512
  static TelaInicioDados + #721, #512
  static TelaInicioDados + #722, #3967
  static TelaInicioDados + #723, #3967
  static TelaInicioDados + #724, #32
  static TelaInicioDados + #725, #32
  static TelaInicioDados + #726, #32
  static TelaInicioDados + #727, #32
  static TelaInicioDados + #728, #3967
  static TelaInicioDados + #729, #3967
  static TelaInicioDados + #730, #46
  static TelaInicioDados + #731, #3967
  static TelaInicioDados + #732, #3967
  static TelaInicioDados + #733, #46
  static TelaInicioDados + #734, #3967
  static TelaInicioDados + #735, #3967
  static TelaInicioDados + #736, #3967
  static TelaInicioDados + #737, #3967
  static TelaInicioDados + #738, #3967
  static TelaInicioDados + #739, #32
  static TelaInicioDados + #740, #32
  static TelaInicioDados + #741, #46
  static TelaInicioDados + #742, #32
  static TelaInicioDados + #743, #3967
  static TelaInicioDados + #744, #32
  static TelaInicioDados + #745, #3967
  static TelaInicioDados + #746, #3967
  static TelaInicioDados + #747, #3967
  static TelaInicioDados + #748, #3967
  static TelaInicioDados + #749, #1282
  static TelaInicioDados + #750, #3967
  static TelaInicioDados + #751, #2306
  static TelaInicioDados + #752, #3967
  static TelaInicioDados + #753, #3967
  static TelaInicioDados + #754, #32
  static TelaInicioDados + #755, #32
  static TelaInicioDados + #756, #3967
  static TelaInicioDados + #757, #3967
  static TelaInicioDados + #758, #512
  static TelaInicioDados + #759, #512

  ;Linha 19
  static TelaInicioDados + #760, #512
  static TelaInicioDados + #761, #512
  static TelaInicioDados + #762, #3967
  static TelaInicioDados + #763, #3967
  static TelaInicioDados + #764, #3967
  static TelaInicioDados + #765, #2862
  static TelaInicioDados + #766, #32
  static TelaInicioDados + #767, #3967
  static TelaInicioDados + #768, #2862
  static TelaInicioDados + #769, #46
  static TelaInicioDados + #770, #3967
  static TelaInicioDados + #771, #3967
  static TelaInicioDados + #772, #3967
  static TelaInicioDados + #773, #3967
  static TelaInicioDados + #774, #3374
  static TelaInicioDados + #775, #2306
  static TelaInicioDados + #776, #3967
  static TelaInicioDados + #777, #3967
  static TelaInicioDados + #778, #3967
  static TelaInicioDados + #779, #3967
  static TelaInicioDados + #780, #32
  static TelaInicioDados + #781, #3967
  static TelaInicioDados + #782, #3967
  static TelaInicioDados + #783, #3967
  static TelaInicioDados + #784, #32
  static TelaInicioDados + #785, #32
  static TelaInicioDados + #786, #32
  static TelaInicioDados + #787, #2862
  static TelaInicioDados + #788, #3967
  static TelaInicioDados + #789, #3967
  static TelaInicioDados + #790, #3967
  static TelaInicioDados + #791, #3967
  static TelaInicioDados + #792, #32
  static TelaInicioDados + #793, #32
  static TelaInicioDados + #794, #32
  static TelaInicioDados + #795, #3967
  static TelaInicioDados + #796, #3967
  static TelaInicioDados + #797, #3967
  static TelaInicioDados + #798, #512
  static TelaInicioDados + #799, #512

  ;Linha 20
  static TelaInicioDados + #800, #512
  static TelaInicioDados + #801, #512
  static TelaInicioDados + #802, #3967
  static TelaInicioDados + #803, #3967
  static TelaInicioDados + #804, #3967
  static TelaInicioDados + #805, #3967
  static TelaInicioDados + #806, #32
  static TelaInicioDados + #807, #32
  static TelaInicioDados + #808, #3967
  static TelaInicioDados + #809, #3967
  static TelaInicioDados + #810, #3967
  static TelaInicioDados + #811, #3967
  static TelaInicioDados + #812, #3967
  static TelaInicioDados + #813, #3967
  static TelaInicioDados + #814, #3967
  static TelaInicioDados + #815, #3967
  static TelaInicioDados + #816, #3967
  static TelaInicioDados + #817, #3967
  static TelaInicioDados + #818, #3967
  static TelaInicioDados + #819, #32
  static TelaInicioDados + #820, #3967
  static TelaInicioDados + #821, #3374
  static TelaInicioDados + #822, #3967
  static TelaInicioDados + #823, #3967
  static TelaInicioDados + #824, #3967
  static TelaInicioDados + #825, #46
  static TelaInicioDados + #826, #3967
  static TelaInicioDados + #827, #32
  static TelaInicioDados + #828, #32
  static TelaInicioDados + #829, #32
  static TelaInicioDados + #830, #32
  static TelaInicioDados + #831, #3374
  static TelaInicioDados + #832, #32
  static TelaInicioDados + #833, #3967
  static TelaInicioDados + #834, #3967
  static TelaInicioDados + #835, #3967
  static TelaInicioDados + #836, #3374
  static TelaInicioDados + #837, #3967
  static TelaInicioDados + #838, #512
  static TelaInicioDados + #839, #512

  ;Linha 21
  static TelaInicioDados + #840, #512
  static TelaInicioDados + #841, #512
  static TelaInicioDados + #842, #3967
  static TelaInicioDados + #843, #3967
  static TelaInicioDados + #844, #3967
  static TelaInicioDados + #845, #3967
  static TelaInicioDados + #846, #3967
  static TelaInicioDados + #847, #3967
  static TelaInicioDados + #848, #3967
  static TelaInicioDados + #849, #3967
  static TelaInicioDados + #850, #3967
  static TelaInicioDados + #851, #3967
  static TelaInicioDados + #852, #3967
  static TelaInicioDados + #853, #3967
  static TelaInicioDados + #854, #3967
  static TelaInicioDados + #855, #3967
  static TelaInicioDados + #856, #3374
  static TelaInicioDados + #857, #3967
  static TelaInicioDados + #858, #3967
  static TelaInicioDados + #859, #32
  static TelaInicioDados + #860, #3967
  static TelaInicioDados + #861, #3967
  static TelaInicioDados + #862, #3967
  static TelaInicioDados + #863, #3967
  static TelaInicioDados + #864, #3967
  static TelaInicioDados + #865, #3967
  static TelaInicioDados + #866, #3967
  static TelaInicioDados + #867, #3967
  static TelaInicioDados + #868, #3967
  static TelaInicioDados + #869, #3967
  static TelaInicioDados + #870, #3967
  static TelaInicioDados + #871, #46
  static TelaInicioDados + #872, #46
  static TelaInicioDados + #873, #3967
  static TelaInicioDados + #874, #3967
  static TelaInicioDados + #875, #3967
  static TelaInicioDados + #876, #3967
  static TelaInicioDados + #877, #3967
  static TelaInicioDados + #878, #512
  static TelaInicioDados + #879, #512

  ;Linha 22
  static TelaInicioDados + #880, #512
  static TelaInicioDados + #881, #512
  static TelaInicioDados + #882, #3967
  static TelaInicioDados + #883, #3967
  static TelaInicioDados + #884, #3967
  static TelaInicioDados + #885, #3967
  static TelaInicioDados + #886, #3967
  static TelaInicioDados + #887, #3967
  static TelaInicioDados + #888, #3967
  static TelaInicioDados + #889, #3374
  static TelaInicioDados + #890, #3967
  static TelaInicioDados + #891, #3967
  static TelaInicioDados + #892, #3967
  static TelaInicioDados + #893, #3967
  static TelaInicioDados + #894, #3967
  static TelaInicioDados + #895, #3967
  static TelaInicioDados + #896, #3967
  static TelaInicioDados + #897, #3967
  static TelaInicioDados + #898, #3967
  static TelaInicioDados + #899, #3967
  static TelaInicioDados + #900, #3967
  static TelaInicioDados + #901, #3967
  static TelaInicioDados + #902, #2862
  static TelaInicioDados + #903, #3967
  static TelaInicioDados + #904, #3967
  static TelaInicioDados + #905, #3967
  static TelaInicioDados + #906, #3967
  static TelaInicioDados + #907, #3967
  static TelaInicioDados + #908, #3967
  static TelaInicioDados + #909, #3967
  static TelaInicioDados + #910, #3967
  static TelaInicioDados + #911, #3967
  static TelaInicioDados + #912, #3967
  static TelaInicioDados + #913, #3967
  static TelaInicioDados + #914, #3967
  static TelaInicioDados + #915, #46
  static TelaInicioDados + #916, #3967
  static TelaInicioDados + #917, #3967
  static TelaInicioDados + #918, #512
  static TelaInicioDados + #919, #512

  ;Linha 23
  static TelaInicioDados + #920, #512
  static TelaInicioDados + #921, #512
  static TelaInicioDados + #922, #2862
  static TelaInicioDados + #923, #3967
  static TelaInicioDados + #924, #3967
  static TelaInicioDados + #925, #2862
  static TelaInicioDados + #926, #3967
  static TelaInicioDados + #927, #3967
  static TelaInicioDados + #928, #3967
  static TelaInicioDados + #929, #3967
  static TelaInicioDados + #930, #80
  static TelaInicioDados + #931, #114
  static TelaInicioDados + #932, #101
  static TelaInicioDados + #933, #115
  static TelaInicioDados + #934, #115
  static TelaInicioDados + #935, #32
  static TelaInicioDados + #936, #69
  static TelaInicioDados + #937, #78
  static TelaInicioDados + #938, #84
  static TelaInicioDados + #939, #69
  static TelaInicioDados + #940, #82
  static TelaInicioDados + #941, #32
  static TelaInicioDados + #942, #116
  static TelaInicioDados + #943, #111
  static TelaInicioDados + #944, #32
  static TelaInicioDados + #945, #112
  static TelaInicioDados + #946, #108
  static TelaInicioDados + #947, #97
  static TelaInicioDados + #948, #121
  static TelaInicioDados + #949, #32
  static TelaInicioDados + #950, #32
  static TelaInicioDados + #951, #3967
  static TelaInicioDados + #952, #3967
  static TelaInicioDados + #953, #3967
  static TelaInicioDados + #954, #3967
  static TelaInicioDados + #955, #3967
  static TelaInicioDados + #956, #3967
  static TelaInicioDados + #957, #3967
  static TelaInicioDados + #958, #512
  static TelaInicioDados + #959, #512

  ;Linha 24
  static TelaInicioDados + #960, #512
  static TelaInicioDados + #961, #512
  static TelaInicioDados + #962, #3967
  static TelaInicioDados + #963, #3967
  static TelaInicioDados + #964, #3967
  static TelaInicioDados + #965, #3967
  static TelaInicioDados + #966, #3967
  static TelaInicioDados + #967, #3967
  static TelaInicioDados + #968, #3967
  static TelaInicioDados + #969, #3374
  static TelaInicioDados + #970, #3967
  static TelaInicioDados + #971, #3967
  static TelaInicioDados + #972, #3967
  static TelaInicioDados + #973, #3967
  static TelaInicioDados + #974, #3967
  static TelaInicioDados + #975, #3967
  static TelaInicioDados + #976, #3967
  static TelaInicioDados + #977, #3967
  static TelaInicioDados + #978, #3967
  static TelaInicioDados + #979, #3967
  static TelaInicioDados + #980, #3967
  static TelaInicioDados + #981, #3967
  static TelaInicioDados + #982, #3967
  static TelaInicioDados + #983, #3967
  static TelaInicioDados + #984, #3967
  static TelaInicioDados + #985, #3967
  static TelaInicioDados + #986, #3967
  static TelaInicioDados + #987, #3967
  static TelaInicioDados + #988, #3967
  static TelaInicioDados + #989, #3967
  static TelaInicioDados + #990, #3967
  static TelaInicioDados + #991, #3967
  static TelaInicioDados + #992, #3967
  static TelaInicioDados + #993, #3967
  static TelaInicioDados + #994, #3967
  static TelaInicioDados + #995, #3967
  static TelaInicioDados + #996, #3967
  static TelaInicioDados + #997, #3967
  static TelaInicioDados + #998, #512
  static TelaInicioDados + #999, #512

  ;Linha 25
  static TelaInicioDados + #1000, #512
  static TelaInicioDados + #1001, #512
  static TelaInicioDados + #1002, #3967
  static TelaInicioDados + #1003, #3967
  static TelaInicioDados + #1004, #3967
  static TelaInicioDados + #1005, #3967
  static TelaInicioDados + #1006, #3967
  static TelaInicioDados + #1007, #3967
  static TelaInicioDados + #1008, #3967
  static TelaInicioDados + #1009, #3967
  static TelaInicioDados + #1010, #3967
  static TelaInicioDados + #1011, #2862
  static TelaInicioDados + #1012, #3967
  static TelaInicioDados + #1013, #3967
  static TelaInicioDados + #1014, #3967
  static TelaInicioDados + #1015, #3967
  static TelaInicioDados + #1016, #3967
  static TelaInicioDados + #1017, #3374
  static TelaInicioDados + #1018, #3967
  static TelaInicioDados + #1019, #3967
  static TelaInicioDados + #1020, #3967
  static TelaInicioDados + #1021, #3967
  static TelaInicioDados + #1022, #3967
  static TelaInicioDados + #1023, #46
  static TelaInicioDados + #1024, #3967
  static TelaInicioDados + #1025, #3967
  static TelaInicioDados + #1026, #3967
  static TelaInicioDados + #1027, #3967
  static TelaInicioDados + #1028, #3967
  static TelaInicioDados + #1029, #46
  static TelaInicioDados + #1030, #2862
  static TelaInicioDados + #1031, #3967
  static TelaInicioDados + #1032, #3967
  static TelaInicioDados + #1033, #3967
  static TelaInicioDados + #1034, #3967
  static TelaInicioDados + #1035, #3374
  static TelaInicioDados + #1036, #3967
  static TelaInicioDados + #1037, #3967
  static TelaInicioDados + #1038, #512
  static TelaInicioDados + #1039, #512

  ;Linha 26
  static TelaInicioDados + #1040, #512
  static TelaInicioDados + #1041, #512
  static TelaInicioDados + #1042, #3967
  static TelaInicioDados + #1043, #3967
  static TelaInicioDados + #1044, #3967
  static TelaInicioDados + #1045, #3967
  static TelaInicioDados + #1046, #3967
  static TelaInicioDados + #1047, #3967
  static TelaInicioDados + #1048, #3967
  static TelaInicioDados + #1049, #3967
  static TelaInicioDados + #1050, #3967
  static TelaInicioDados + #1051, #3967
  static TelaInicioDados + #1052, #3967
  static TelaInicioDados + #1053, #3967
  static TelaInicioDados + #1054, #3967
  static TelaInicioDados + #1055, #3967
  static TelaInicioDados + #1056, #3967
  static TelaInicioDados + #1057, #3967
  static TelaInicioDados + #1058, #3967
  static TelaInicioDados + #1059, #3967
  static TelaInicioDados + #1060, #2862
  static TelaInicioDados + #1061, #3967
  static TelaInicioDados + #1062, #3967
  static TelaInicioDados + #1063, #3967
  static TelaInicioDados + #1064, #3967
  static TelaInicioDados + #1065, #3967
  static TelaInicioDados + #1066, #46
  static TelaInicioDados + #1067, #3967
  static TelaInicioDados + #1068, #3967
  static TelaInicioDados + #1069, #3967
  static TelaInicioDados + #1070, #3967
  static TelaInicioDados + #1071, #3967
  static TelaInicioDados + #1072, #3967
  static TelaInicioDados + #1073, #3967
  static TelaInicioDados + #1074, #3967
  static TelaInicioDados + #1075, #3967
  static TelaInicioDados + #1076, #3967
  static TelaInicioDados + #1077, #3967
  static TelaInicioDados + #1078, #512
  static TelaInicioDados + #1079, #512

  ;Linha 27
  static TelaInicioDados + #1080, #512
  static TelaInicioDados + #1081, #512
  static TelaInicioDados + #1082, #1024
  static TelaInicioDados + #1083, #1024
  static TelaInicioDados + #1084, #1024
  static TelaInicioDados + #1085, #1024
  static TelaInicioDados + #1086, #1024
  static TelaInicioDados + #1087, #1024
  static TelaInicioDados + #1088, #1024
  static TelaInicioDados + #1089, #1024
  static TelaInicioDados + #1090, #1024
  static TelaInicioDados + #1091, #1024
  static TelaInicioDados + #1092, #1024
  static TelaInicioDados + #1093, #1024
  static TelaInicioDados + #1094, #1024
  static TelaInicioDados + #1095, #1024
  static TelaInicioDados + #1096, #1024
  static TelaInicioDados + #1097, #1024
  static TelaInicioDados + #1098, #1024
  static TelaInicioDados + #1099, #1024
  static TelaInicioDados + #1100, #1024
  static TelaInicioDados + #1101, #1024
  static TelaInicioDados + #1102, #1024
  static TelaInicioDados + #1103, #1024
  static TelaInicioDados + #1104, #1024
  static TelaInicioDados + #1105, #1024
  static TelaInicioDados + #1106, #1024
  static TelaInicioDados + #1107, #1024
  static TelaInicioDados + #1108, #1024
  static TelaInicioDados + #1109, #1024
  static TelaInicioDados + #1110, #1024
  static TelaInicioDados + #1111, #1024
  static TelaInicioDados + #1112, #1024
  static TelaInicioDados + #1113, #1024
  static TelaInicioDados + #1114, #1024
  static TelaInicioDados + #1115, #1024
  static TelaInicioDados + #1116, #1024
  static TelaInicioDados + #1117, #1024
  static TelaInicioDados + #1118, #512
  static TelaInicioDados + #1119, #512

  ;Linha 28
  static TelaInicioDados + #1120, #512
  static TelaInicioDados + #1121, #512
  static TelaInicioDados + #1122, #3072
  static TelaInicioDados + #1123, #3072
  static TelaInicioDados + #1124, #3072
  static TelaInicioDados + #1125, #3072
  static TelaInicioDados + #1126, #3072
  static TelaInicioDados + #1127, #3072
  static TelaInicioDados + #1128, #3072
  static TelaInicioDados + #1129, #3072
  static TelaInicioDados + #1130, #3072
  static TelaInicioDados + #1131, #3072
  static TelaInicioDados + #1132, #3072
  static TelaInicioDados + #1133, #3072
  static TelaInicioDados + #1134, #3072
  static TelaInicioDados + #1135, #3072
  static TelaInicioDados + #1136, #3072
  static TelaInicioDados + #1137, #3072
  static TelaInicioDados + #1138, #3072
  static TelaInicioDados + #1139, #3072
  static TelaInicioDados + #1140, #3072
  static TelaInicioDados + #1141, #3072
  static TelaInicioDados + #1142, #3072
  static TelaInicioDados + #1143, #3072
  static TelaInicioDados + #1144, #3072
  static TelaInicioDados + #1145, #3072
  static TelaInicioDados + #1146, #3072
  static TelaInicioDados + #1147, #3072
  static TelaInicioDados + #1148, #3072
  static TelaInicioDados + #1149, #3072
  static TelaInicioDados + #1150, #3072
  static TelaInicioDados + #1151, #3072
  static TelaInicioDados + #1152, #3072
  static TelaInicioDados + #1153, #3072
  static TelaInicioDados + #1154, #3072
  static TelaInicioDados + #1155, #3072
  static TelaInicioDados + #1156, #3072
  static TelaInicioDados + #1157, #3072
  static TelaInicioDados + #1158, #512
  static TelaInicioDados + #1159, #512

  ;Linha 29
  static TelaInicioDados + #1160, #512
  static TelaInicioDados + #1161, #512
  static TelaInicioDados + #1162, #3072
  static TelaInicioDados + #1163, #3072
  static TelaInicioDados + #1164, #3072
  static TelaInicioDados + #1165, #3072
  static TelaInicioDados + #1166, #3072
  static TelaInicioDados + #1167, #3072
  static TelaInicioDados + #1168, #3072
  static TelaInicioDados + #1169, #3072
  static TelaInicioDados + #1170, #3072
  static TelaInicioDados + #1171, #3072
  static TelaInicioDados + #1172, #3072
  static TelaInicioDados + #1173, #3072
  static TelaInicioDados + #1174, #3072
  static TelaInicioDados + #1175, #3072
  static TelaInicioDados + #1176, #3072
  static TelaInicioDados + #1177, #3072
  static TelaInicioDados + #1178, #3072
  static TelaInicioDados + #1179, #3072
  static TelaInicioDados + #1180, #3072
  static TelaInicioDados + #1181, #3072
  static TelaInicioDados + #1182, #3072
  static TelaInicioDados + #1183, #3072
  static TelaInicioDados + #1184, #3072
  static TelaInicioDados + #1185, #3072
  static TelaInicioDados + #1186, #3072
  static TelaInicioDados + #1187, #3072
  static TelaInicioDados + #1188, #3072
  static TelaInicioDados + #1189, #3072
  static TelaInicioDados + #1190, #3072
  static TelaInicioDados + #1191, #3072
  static TelaInicioDados + #1192, #3072
  static TelaInicioDados + #1193, #3072
  static TelaInicioDados + #1194, #3072
  static TelaInicioDados + #1195, #3072
  static TelaInicioDados + #1196, #3072
  static TelaInicioDados + #1197, #3072
  static TelaInicioDados + #1198, #512
  static TelaInicioDados + #1199, #512


;                  TELA GAME OVER
;===================================================


  TelaGameOverDados : var #1200
  ;Linha 0
  static TelaGameOverDados + #0, #3967
  static TelaGameOverDados + #1, #3967
  static TelaGameOverDados + #2, #3967
  static TelaGameOverDados + #3, #3967
  static TelaGameOverDados + #4, #3967
  static TelaGameOverDados + #5, #3967
  static TelaGameOverDados + #6, #3967
  static TelaGameOverDados + #7, #3967
  static TelaGameOverDados + #8, #3967
  static TelaGameOverDados + #9, #2350
  static TelaGameOverDados + #10, #3967
  static TelaGameOverDados + #11, #3967
  static TelaGameOverDados + #12, #3967
  static TelaGameOverDados + #13, #3967
  static TelaGameOverDados + #14, #3967
  static TelaGameOverDados + #15, #3967
  static TelaGameOverDados + #16, #3967
  static TelaGameOverDados + #17, #3967
  static TelaGameOverDados + #18, #3967
  static TelaGameOverDados + #19, #3967
  static TelaGameOverDados + #20, #3967
  static TelaGameOverDados + #21, #3967
  static TelaGameOverDados + #22, #1838
  static TelaGameOverDados + #23, #3967
  static TelaGameOverDados + #24, #3967
  static TelaGameOverDados + #25, #3967
  static TelaGameOverDados + #26, #3967
  static TelaGameOverDados + #27, #3967
  static TelaGameOverDados + #28, #3967
  static TelaGameOverDados + #29, #3967
  static TelaGameOverDados + #30, #3967
  static TelaGameOverDados + #31, #3967
  static TelaGameOverDados + #32, #3967
  static TelaGameOverDados + #33, #3967
  static TelaGameOverDados + #34, #3967
  static TelaGameOverDados + #35, #3967
  static TelaGameOverDados + #36, #3967
  static TelaGameOverDados + #37, #3967
  static TelaGameOverDados + #38, #3967
  static TelaGameOverDados + #39, #3967

  ;Linha 1
  static TelaGameOverDados + #40, #3967
  static TelaGameOverDados + #41, #3967
  static TelaGameOverDados + #42, #2880
  static TelaGameOverDados + #43, #3967
  static TelaGameOverDados + #44, #3967
  static TelaGameOverDados + #45, #3967
  static TelaGameOverDados + #46, #1792
  static TelaGameOverDados + #47, #3967
  static TelaGameOverDados + #48, #3967
  static TelaGameOverDados + #49, #3967
  static TelaGameOverDados + #50, #3967
  static TelaGameOverDados + #51, #3967
  static TelaGameOverDados + #52, #2350
  static TelaGameOverDados + #53, #3967
  static TelaGameOverDados + #54, #3967
  static TelaGameOverDados + #55, #3967
  static TelaGameOverDados + #56, #3967
  static TelaGameOverDados + #57, #3967
  static TelaGameOverDados + #58, #3967
  static TelaGameOverDados + #59, #3967
  static TelaGameOverDados + #60, #3967
  static TelaGameOverDados + #61, #3967
  static TelaGameOverDados + #62, #3967
  static TelaGameOverDados + #63, #2350
  static TelaGameOverDados + #64, #3967
  static TelaGameOverDados + #65, #2350
  static TelaGameOverDados + #66, #3967
  static TelaGameOverDados + #67, #3967
  static TelaGameOverDados + #68, #3967
  static TelaGameOverDados + #69, #3967
  static TelaGameOverDados + #70, #2856
  static TelaGameOverDados + #71, #2857
  static TelaGameOverDados + #72, #3967
  static TelaGameOverDados + #73, #3967
  static TelaGameOverDados + #74, #3967
  static TelaGameOverDados + #75, #3967
  static TelaGameOverDados + #76, #3967
  static TelaGameOverDados + #77, #2862
  static TelaGameOverDados + #78, #3967
  static TelaGameOverDados + #79, #3967

  ;Linha 2
  static TelaGameOverDados + #80, #3967
  static TelaGameOverDados + #81, #3967
  static TelaGameOverDados + #82, #3967
  static TelaGameOverDados + #83, #3074
  static TelaGameOverDados + #84, #3967
  static TelaGameOverDados + #85, #3967
  static TelaGameOverDados + #86, #3967
  static TelaGameOverDados + #87, #3967
  static TelaGameOverDados + #88, #3967
  static TelaGameOverDados + #89, #3371
  static TelaGameOverDados + #90, #3967
  static TelaGameOverDados + #91, #3967
  static TelaGameOverDados + #92, #3967
  static TelaGameOverDados + #93, #3967
  static TelaGameOverDados + #94, #3967
  static TelaGameOverDados + #95, #3371
  static TelaGameOverDados + #96, #3967
  static TelaGameOverDados + #97, #3967
  static TelaGameOverDados + #98, #3967
  static TelaGameOverDados + #99, #3967
  static TelaGameOverDados + #100, #3967
  static TelaGameOverDados + #101, #3967
  static TelaGameOverDados + #102, #3967
  static TelaGameOverDados + #103, #3967
  static TelaGameOverDados + #104, #3967
  static TelaGameOverDados + #105, #2862
  static TelaGameOverDados + #106, #2942
  static TelaGameOverDados + #107, #3967
  static TelaGameOverDados + #108, #3967
  static TelaGameOverDados + #109, #3967
  static TelaGameOverDados + #110, #3967
  static TelaGameOverDados + #111, #2862
  static TelaGameOverDados + #112, #3967
  static TelaGameOverDados + #113, #3967
  static TelaGameOverDados + #114, #3967
  static TelaGameOverDados + #115, #1838
  static TelaGameOverDados + #116, #3967
  static TelaGameOverDados + #117, #3967
  static TelaGameOverDados + #118, #3967
  static TelaGameOverDados + #119, #3967

  ;Linha 3
  static TelaGameOverDados + #120, #3967
  static TelaGameOverDados + #121, #3967
  static TelaGameOverDados + #122, #3967
  static TelaGameOverDados + #123, #3967
  static TelaGameOverDados + #124, #3967
  static TelaGameOverDados + #125, #3967
  static TelaGameOverDados + #126, #3967
  static TelaGameOverDados + #127, #3967
  static TelaGameOverDados + #128, #2350
  static TelaGameOverDados + #129, #3967
  static TelaGameOverDados + #130, #3967
  static TelaGameOverDados + #131, #3967
  static TelaGameOverDados + #132, #3967
  static TelaGameOverDados + #133, #3967
  static TelaGameOverDados + #134, #3967
  static TelaGameOverDados + #135, #3967
  static TelaGameOverDados + #136, #3967
  static TelaGameOverDados + #137, #3967
  static TelaGameOverDados + #138, #3074
  static TelaGameOverDados + #139, #3967
  static TelaGameOverDados + #140, #3967
  static TelaGameOverDados + #141, #3967
  static TelaGameOverDados + #142, #1838
  static TelaGameOverDados + #143, #3967
  static TelaGameOverDados + #144, #3967
  static TelaGameOverDados + #145, #3967
  static TelaGameOverDados + #146, #3967
  static TelaGameOverDados + #147, #1838
  static TelaGameOverDados + #148, #3967
  static TelaGameOverDados + #149, #3967
  static TelaGameOverDados + #150, #3967
  static TelaGameOverDados + #151, #3967
  static TelaGameOverDados + #152, #3967
  static TelaGameOverDados + #153, #3967
  static TelaGameOverDados + #154, #3967
  static TelaGameOverDados + #155, #3967
  static TelaGameOverDados + #156, #2862
  static TelaGameOverDados + #157, #3074
  static TelaGameOverDados + #158, #3967
  static TelaGameOverDados + #159, #3967

  ;Linha 4
  static TelaGameOverDados + #160, #3967
  static TelaGameOverDados + #161, #3967
  static TelaGameOverDados + #162, #3967
  static TelaGameOverDados + #163, #3967
  static TelaGameOverDados + #164, #3967
  static TelaGameOverDados + #165, #3967
  static TelaGameOverDados + #166, #3967
  static TelaGameOverDados + #167, #3967
  static TelaGameOverDados + #168, #2350
  static TelaGameOverDados + #169, #3967
  static TelaGameOverDados + #170, #3967
  static TelaGameOverDados + #171, #2862
  static TelaGameOverDados + #172, #3967
  static TelaGameOverDados + #173, #2862
  static TelaGameOverDados + #174, #3967
  static TelaGameOverDados + #175, #3967
  static TelaGameOverDados + #176, #2350
  static TelaGameOverDados + #177, #3967
  static TelaGameOverDados + #178, #3967
  static TelaGameOverDados + #179, #2942
  static TelaGameOverDados + #180, #1838
  static TelaGameOverDados + #181, #3967
  static TelaGameOverDados + #182, #3967
  static TelaGameOverDados + #183, #3967
  static TelaGameOverDados + #184, #3967
  static TelaGameOverDados + #185, #3967
  static TelaGameOverDados + #186, #3967
  static TelaGameOverDados + #187, #3967
  static TelaGameOverDados + #188, #3967
  static TelaGameOverDados + #189, #3967
  static TelaGameOverDados + #190, #1792
  static TelaGameOverDados + #191, #3967
  static TelaGameOverDados + #192, #3967
  static TelaGameOverDados + #193, #3967
  static TelaGameOverDados + #194, #3074
  static TelaGameOverDados + #195, #3967
  static TelaGameOverDados + #196, #3967
  static TelaGameOverDados + #197, #3967
  static TelaGameOverDados + #198, #3967
  static TelaGameOverDados + #199, #3967

  ;Linha 5
  static TelaGameOverDados + #200, #3967
  static TelaGameOverDados + #201, #3967
  static TelaGameOverDados + #202, #3967
  static TelaGameOverDados + #203, #3967
  static TelaGameOverDados + #204, #2350
  static TelaGameOverDados + #205, #3967
  static TelaGameOverDados + #206, #3967
  static TelaGameOverDados + #207, #3967
  static TelaGameOverDados + #208, #3967
  static TelaGameOverDados + #209, #3967
  static TelaGameOverDados + #210, #3967
  static TelaGameOverDados + #211, #3967
  static TelaGameOverDados + #212, #2862
  static TelaGameOverDados + #213, #2862
  static TelaGameOverDados + #214, #3967
  static TelaGameOverDados + #215, #3967
  static TelaGameOverDados + #216, #3967
  static TelaGameOverDados + #217, #3967
  static TelaGameOverDados + #218, #3967
  static TelaGameOverDados + #219, #2862
  static TelaGameOverDados + #220, #3967
  static TelaGameOverDados + #221, #3967
  static TelaGameOverDados + #222, #1838
  static TelaGameOverDados + #223, #3967
  static TelaGameOverDados + #224, #3967
  static TelaGameOverDados + #225, #1838
  static TelaGameOverDados + #226, #3074
  static TelaGameOverDados + #227, #3967
  static TelaGameOverDados + #228, #3967
  static TelaGameOverDados + #229, #3967
  static TelaGameOverDados + #230, #3967
  static TelaGameOverDados + #231, #2862
  static TelaGameOverDados + #232, #3967
  static TelaGameOverDados + #233, #3371
  static TelaGameOverDados + #234, #3967
  static TelaGameOverDados + #235, #2942
  static TelaGameOverDados + #236, #3967
  static TelaGameOverDados + #237, #3967
  static TelaGameOverDados + #238, #3967
  static TelaGameOverDados + #239, #3967

  ;Linha 6
  static TelaGameOverDados + #240, #3967
  static TelaGameOverDados + #241, #3967
  static TelaGameOverDados + #242, #3967
  static TelaGameOverDados + #243, #3967
  static TelaGameOverDados + #244, #2350
  static TelaGameOverDados + #245, #3967
  static TelaGameOverDados + #246, #3967
  static TelaGameOverDados + #247, #3967
  static TelaGameOverDados + #248, #3967
  static TelaGameOverDados + #249, #3967
  static TelaGameOverDados + #250, #3967
  static TelaGameOverDados + #251, #2350
  static TelaGameOverDados + #252, #3967
  static TelaGameOverDados + #253, #3967
  static TelaGameOverDados + #254, #3967
  static TelaGameOverDados + #255, #2350
  static TelaGameOverDados + #256, #3967
  static TelaGameOverDados + #257, #3967
  static TelaGameOverDados + #258, #3967
  static TelaGameOverDados + #259, #3967
  static TelaGameOverDados + #260, #3967
  static TelaGameOverDados + #261, #3967
  static TelaGameOverDados + #262, #3967
  static TelaGameOverDados + #263, #3967
  static TelaGameOverDados + #264, #3967
  static TelaGameOverDados + #265, #3967
  static TelaGameOverDados + #266, #3967
  static TelaGameOverDados + #267, #3967
  static TelaGameOverDados + #268, #1838
  static TelaGameOverDados + #269, #3967
  static TelaGameOverDados + #270, #3967
  static TelaGameOverDados + #271, #3967
  static TelaGameOverDados + #272, #3967
  static TelaGameOverDados + #273, #3967
  static TelaGameOverDados + #274, #3967
  static TelaGameOverDados + #275, #3967
  static TelaGameOverDados + #276, #3967
  static TelaGameOverDados + #277, #2350
  static TelaGameOverDados + #278, #2350
  static TelaGameOverDados + #279, #3967

  ;Linha 7
  static TelaGameOverDados + #280, #3967
  static TelaGameOverDados + #281, #3967
  static TelaGameOverDados + #282, #3967
  static TelaGameOverDados + #283, #3074
  static TelaGameOverDados + #284, #3967
  static TelaGameOverDados + #285, #3967
  static TelaGameOverDados + #286, #3371
  static TelaGameOverDados + #287, #3967
  static TelaGameOverDados + #288, #3967
  static TelaGameOverDados + #289, #3967
  static TelaGameOverDados + #290, #3967
  static TelaGameOverDados + #291, #3967
  static TelaGameOverDados + #292, #3967
  static TelaGameOverDados + #293, #3967
  static TelaGameOverDados + #294, #3967
  static TelaGameOverDados + #295, #3967
  static TelaGameOverDados + #296, #3967
  static TelaGameOverDados + #297, #3967
  static TelaGameOverDados + #298, #3967
  static TelaGameOverDados + #299, #3967
  static TelaGameOverDados + #300, #3967
  static TelaGameOverDados + #301, #3967
  static TelaGameOverDados + #302, #3967
  static TelaGameOverDados + #303, #2350
  static TelaGameOverDados + #304, #2862
  static TelaGameOverDados + #305, #3967
  static TelaGameOverDados + #306, #3967
  static TelaGameOverDados + #307, #3967
  static TelaGameOverDados + #308, #3967
  static TelaGameOverDados + #309, #3967
  static TelaGameOverDados + #310, #3967
  static TelaGameOverDados + #311, #3967
  static TelaGameOverDados + #312, #3967
  static TelaGameOverDados + #313, #3967
  static TelaGameOverDados + #314, #3967
  static TelaGameOverDados + #315, #2862
  static TelaGameOverDados + #316, #3967
  static TelaGameOverDados + #317, #3967
  static TelaGameOverDados + #318, #3967
  static TelaGameOverDados + #319, #3967

  ;Linha 8
  static TelaGameOverDados + #320, #3967
  static TelaGameOverDados + #321, #3967
  static TelaGameOverDados + #322, #3967
  static TelaGameOverDados + #323, #3967
  static TelaGameOverDados + #324, #3967
  static TelaGameOverDados + #325, #3967
  static TelaGameOverDados + #326, #3967
  static TelaGameOverDados + #327, #3967
  static TelaGameOverDados + #328, #3967
  static TelaGameOverDados + #329, #3967
  static TelaGameOverDados + #330, #3967
  static TelaGameOverDados + #331, #3967
  static TelaGameOverDados + #332, #3967
  static TelaGameOverDados + #333, #3967
  static TelaGameOverDados + #334, #3967
  static TelaGameOverDados + #335, #3967
  static TelaGameOverDados + #336, #3967
  static TelaGameOverDados + #337, #3967
  static TelaGameOverDados + #338, #3967
  static TelaGameOverDados + #339, #2862
  static TelaGameOverDados + #340, #3967
  static TelaGameOverDados + #341, #3967
  static TelaGameOverDados + #342, #3967
  static TelaGameOverDados + #343, #3371
  static TelaGameOverDados + #344, #3967
  static TelaGameOverDados + #345, #3967
  static TelaGameOverDados + #346, #3967
  static TelaGameOverDados + #347, #1792
  static TelaGameOverDados + #348, #3967
  static TelaGameOverDados + #349, #3967
  static TelaGameOverDados + #350, #3371
  static TelaGameOverDados + #351, #3967
  static TelaGameOverDados + #352, #3967
  static TelaGameOverDados + #353, #3967
  static TelaGameOverDados + #354, #3967
  static TelaGameOverDados + #355, #2350
  static TelaGameOverDados + #356, #3967
  static TelaGameOverDados + #357, #2350
  static TelaGameOverDados + #358, #3967
  static TelaGameOverDados + #359, #3967

  ;Linha 9
  static TelaGameOverDados + #360, #3967
  static TelaGameOverDados + #361, #3967
  static TelaGameOverDados + #362, #3967
  static TelaGameOverDados + #363, #3967
  static TelaGameOverDados + #364, #3967
  static TelaGameOverDados + #365, #2304
  static TelaGameOverDados + #366, #2304
  static TelaGameOverDados + #367, #2304
  static TelaGameOverDados + #368, #2336
  static TelaGameOverDados + #369, #2304
  static TelaGameOverDados + #370, #2304
  static TelaGameOverDados + #371, #2304
  static TelaGameOverDados + #372, #2336
  static TelaGameOverDados + #373, #2304
  static TelaGameOverDados + #374, #2304
  static TelaGameOverDados + #375, #3074
  static TelaGameOverDados + #376, #2304
  static TelaGameOverDados + #377, #2304
  static TelaGameOverDados + #378, #3967
  static TelaGameOverDados + #379, #2304
  static TelaGameOverDados + #380, #2304
  static TelaGameOverDados + #381, #2304
  static TelaGameOverDados + #382, #3967
  static TelaGameOverDados + #383, #3967
  static TelaGameOverDados + #384, #1838
  static TelaGameOverDados + #385, #3967
  static TelaGameOverDados + #386, #3967
  static TelaGameOverDados + #387, #3967
  static TelaGameOverDados + #388, #1838
  static TelaGameOverDados + #389, #3967
  static TelaGameOverDados + #390, #3967
  static TelaGameOverDados + #391, #3967
  static TelaGameOverDados + #392, #3967
  static TelaGameOverDados + #393, #3967
  static TelaGameOverDados + #394, #3967
  static TelaGameOverDados + #395, #3967
  static TelaGameOverDados + #396, #3967
  static TelaGameOverDados + #397, #2350
  static TelaGameOverDados + #398, #3967
  static TelaGameOverDados + #399, #3967

  ;Linha 10
  static TelaGameOverDados + #400, #3967
  static TelaGameOverDados + #401, #3967
  static TelaGameOverDados + #402, #1838
  static TelaGameOverDados + #403, #3967
  static TelaGameOverDados + #404, #3967
  static TelaGameOverDados + #405, #2304
  static TelaGameOverDados + #406, #3967
  static TelaGameOverDados + #407, #3967
  static TelaGameOverDados + #408, #2336
  static TelaGameOverDados + #409, #2304
  static TelaGameOverDados + #410, #2336
  static TelaGameOverDados + #411, #2304
  static TelaGameOverDados + #412, #2336
  static TelaGameOverDados + #413, #2304
  static TelaGameOverDados + #414, #3967
  static TelaGameOverDados + #415, #2304
  static TelaGameOverDados + #416, #3967
  static TelaGameOverDados + #417, #2304
  static TelaGameOverDados + #418, #3967
  static TelaGameOverDados + #419, #2304
  static TelaGameOverDados + #420, #2316
  static TelaGameOverDados + #421, #2316
  static TelaGameOverDados + #422, #3967
  static TelaGameOverDados + #423, #3967
  static TelaGameOverDados + #424, #3967
  static TelaGameOverDados + #425, #3967
  static TelaGameOverDados + #426, #3967
  static TelaGameOverDados + #427, #3967
  static TelaGameOverDados + #428, #3967
  static TelaGameOverDados + #429, #3967
  static TelaGameOverDados + #430, #2862
  static TelaGameOverDados + #431, #3967
  static TelaGameOverDados + #432, #2350
  static TelaGameOverDados + #433, #3967
  static TelaGameOverDados + #434, #3967
  static TelaGameOverDados + #435, #3967
  static TelaGameOverDados + #436, #3967
  static TelaGameOverDados + #437, #3967
  static TelaGameOverDados + #438, #3967
  static TelaGameOverDados + #439, #3967

  ;Linha 11
  static TelaGameOverDados + #440, #3967
  static TelaGameOverDados + #441, #3967
  static TelaGameOverDados + #442, #3967
  static TelaGameOverDados + #443, #3967
  static TelaGameOverDados + #444, #3967
  static TelaGameOverDados + #445, #2304
  static TelaGameOverDados + #446, #2336
  static TelaGameOverDados + #447, #2304
  static TelaGameOverDados + #448, #2336
  static TelaGameOverDados + #449, #2304
  static TelaGameOverDados + #450, #2304
  static TelaGameOverDados + #451, #2304
  static TelaGameOverDados + #452, #2336
  static TelaGameOverDados + #453, #2304
  static TelaGameOverDados + #454, #2336
  static TelaGameOverDados + #455, #2304
  static TelaGameOverDados + #456, #3967
  static TelaGameOverDados + #457, #2304
  static TelaGameOverDados + #458, #3967
  static TelaGameOverDados + #459, #2304
  static TelaGameOverDados + #460, #3967
  static TelaGameOverDados + #461, #3967
  static TelaGameOverDados + #462, #3967
  static TelaGameOverDados + #463, #3967
  static TelaGameOverDados + #464, #3967
  static TelaGameOverDados + #465, #3967
  static TelaGameOverDados + #466, #3967
  static TelaGameOverDados + #467, #3074
  static TelaGameOverDados + #468, #2862
  static TelaGameOverDados + #469, #3967
  static TelaGameOverDados + #470, #3967
  static TelaGameOverDados + #471, #3967
  static TelaGameOverDados + #472, #2350
  static TelaGameOverDados + #473, #3967
  static TelaGameOverDados + #474, #1838
  static TelaGameOverDados + #475, #3967
  static TelaGameOverDados + #476, #3967
  static TelaGameOverDados + #477, #3967
  static TelaGameOverDados + #478, #3967
  static TelaGameOverDados + #479, #3967

  ;Linha 12
  static TelaGameOverDados + #480, #3967
  static TelaGameOverDados + #481, #3967
  static TelaGameOverDados + #482, #3967
  static TelaGameOverDados + #483, #3967
  static TelaGameOverDados + #484, #3967
  static TelaGameOverDados + #485, #2304
  static TelaGameOverDados + #486, #2304
  static TelaGameOverDados + #487, #2304
  static TelaGameOverDados + #488, #2336
  static TelaGameOverDados + #489, #2304
  static TelaGameOverDados + #490, #2336
  static TelaGameOverDados + #491, #2304
  static TelaGameOverDados + #492, #2336
  static TelaGameOverDados + #493, #2304
  static TelaGameOverDados + #494, #2336
  static TelaGameOverDados + #495, #3967
  static TelaGameOverDados + #496, #3967
  static TelaGameOverDados + #497, #2304
  static TelaGameOverDados + #498, #3967
  static TelaGameOverDados + #499, #2304
  static TelaGameOverDados + #500, #2304
  static TelaGameOverDados + #501, #2304
  static TelaGameOverDados + #502, #3967
  static TelaGameOverDados + #503, #3967
  static TelaGameOverDados + #504, #1838
  static TelaGameOverDados + #505, #3967
  static TelaGameOverDados + #506, #3967
  static TelaGameOverDados + #507, #3967
  static TelaGameOverDados + #508, #3967
  static TelaGameOverDados + #509, #3967
  static TelaGameOverDados + #510, #3967
  static TelaGameOverDados + #511, #3967
  static TelaGameOverDados + #512, #3967
  static TelaGameOverDados + #513, #3967
  static TelaGameOverDados + #514, #3967
  static TelaGameOverDados + #515, #3454
  static TelaGameOverDados + #516, #3967
  static TelaGameOverDados + #517, #3074
  static TelaGameOverDados + #518, #3967
  static TelaGameOverDados + #519, #3967

  ;Linha 13
  static TelaGameOverDados + #520, #3967
  static TelaGameOverDados + #521, #3967
  static TelaGameOverDados + #522, #3967
  static TelaGameOverDados + #523, #3967
  static TelaGameOverDados + #524, #3967
  static TelaGameOverDados + #525, #3967
  static TelaGameOverDados + #526, #1838
  static TelaGameOverDados + #527, #3967
  static TelaGameOverDados + #528, #3967
  static TelaGameOverDados + #529, #3967
  static TelaGameOverDados + #530, #3967
  static TelaGameOverDados + #531, #3967
  static TelaGameOverDados + #532, #3967
  static TelaGameOverDados + #533, #3967
  static TelaGameOverDados + #534, #3967
  static TelaGameOverDados + #535, #3967
  static TelaGameOverDados + #536, #3967
  static TelaGameOverDados + #537, #3967
  static TelaGameOverDados + #538, #3967
  static TelaGameOverDados + #539, #3967
  static TelaGameOverDados + #540, #3967
  static TelaGameOverDados + #541, #3967
  static TelaGameOverDados + #542, #3967
  static TelaGameOverDados + #543, #3967
  static TelaGameOverDados + #544, #3967
  static TelaGameOverDados + #545, #3967
  static TelaGameOverDados + #546, #3967
  static TelaGameOverDados + #547, #3371
  static TelaGameOverDados + #548, #3967
  static TelaGameOverDados + #549, #3967
  static TelaGameOverDados + #550, #3967
  static TelaGameOverDados + #551, #3967
  static TelaGameOverDados + #552, #3967
  static TelaGameOverDados + #553, #3967
  static TelaGameOverDados + #554, #3967
  static TelaGameOverDados + #555, #3074
  static TelaGameOverDados + #556, #3967
  static TelaGameOverDados + #557, #3967
  static TelaGameOverDados + #558, #3967
  static TelaGameOverDados + #559, #3967

  ;Linha 14
  static TelaGameOverDados + #560, #3967
  static TelaGameOverDados + #561, #3967
  static TelaGameOverDados + #562, #3371
  static TelaGameOverDados + #563, #3967
  static TelaGameOverDados + #564, #3967
  static TelaGameOverDados + #565, #3967
  static TelaGameOverDados + #566, #3967
  static TelaGameOverDados + #567, #3967
  static TelaGameOverDados + #568, #3967
  static TelaGameOverDados + #569, #3967
  static TelaGameOverDados + #570, #3967
  static TelaGameOverDados + #571, #3967
  static TelaGameOverDados + #572, #2350
  static TelaGameOverDados + #573, #3967
  static TelaGameOverDados + #574, #3967
  static TelaGameOverDados + #575, #3967
  static TelaGameOverDados + #576, #3371
  static TelaGameOverDados + #577, #3967
  static TelaGameOverDados + #578, #3967
  static TelaGameOverDados + #579, #3967
  static TelaGameOverDados + #580, #3967
  static TelaGameOverDados + #581, #3967
  static TelaGameOverDados + #582, #3967
  static TelaGameOverDados + #583, #3967
  static TelaGameOverDados + #584, #3967
  static TelaGameOverDados + #585, #3967
  static TelaGameOverDados + #586, #3967
  static TelaGameOverDados + #587, #3967
  static TelaGameOverDados + #588, #3967
  static TelaGameOverDados + #589, #3967
  static TelaGameOverDados + #590, #3967
  static TelaGameOverDados + #591, #3967
  static TelaGameOverDados + #592, #3371
  static TelaGameOverDados + #593, #3967
  static TelaGameOverDados + #594, #3967
  static TelaGameOverDados + #595, #3967
  static TelaGameOverDados + #596, #3967
  static TelaGameOverDados + #597, #3967
  static TelaGameOverDados + #598, #3967
  static TelaGameOverDados + #599, #3967

  ;Linha 15
  static TelaGameOverDados + #600, #3967
  static TelaGameOverDados + #601, #3967
  static TelaGameOverDados + #602, #3967
  static TelaGameOverDados + #603, #2350
  static TelaGameOverDados + #604, #3967
  static TelaGameOverDados + #605, #3967
  static TelaGameOverDados + #606, #1792
  static TelaGameOverDados + #607, #3967
  static TelaGameOverDados + #608, #2350
  static TelaGameOverDados + #609, #3967
  static TelaGameOverDados + #610, #3967
  static TelaGameOverDados + #611, #3967
  static TelaGameOverDados + #612, #3967
  static TelaGameOverDados + #613, #2350
  static TelaGameOverDados + #614, #3967
  static TelaGameOverDados + #615, #3967
  static TelaGameOverDados + #616, #3967
  static TelaGameOverDados + #617, #3967
  static TelaGameOverDados + #618, #3967
  static TelaGameOverDados + #619, #2304
  static TelaGameOverDados + #620, #2304
  static TelaGameOverDados + #621, #2304
  static TelaGameOverDados + #622, #3967
  static TelaGameOverDados + #623, #2304
  static TelaGameOverDados + #624, #3967
  static TelaGameOverDados + #625, #2304
  static TelaGameOverDados + #626, #3967
  static TelaGameOverDados + #627, #2304
  static TelaGameOverDados + #628, #2304
  static TelaGameOverDados + #629, #2304
  static TelaGameOverDados + #630, #3967
  static TelaGameOverDados + #631, #2304
  static TelaGameOverDados + #632, #2304
  static TelaGameOverDados + #633, #2304
  static TelaGameOverDados + #634, #3967
  static TelaGameOverDados + #635, #3967
  static TelaGameOverDados + #636, #3967
  static TelaGameOverDados + #637, #3967
  static TelaGameOverDados + #638, #3967
  static TelaGameOverDados + #639, #3967

  ;Linha 16
  static TelaGameOverDados + #640, #3967
  static TelaGameOverDados + #641, #1838
  static TelaGameOverDados + #642, #3967
  static TelaGameOverDados + #643, #3967
  static TelaGameOverDados + #644, #3967
  static TelaGameOverDados + #645, #3967
  static TelaGameOverDados + #646, #3967
  static TelaGameOverDados + #647, #3967
  static TelaGameOverDados + #648, #3967
  static TelaGameOverDados + #649, #3371
  static TelaGameOverDados + #650, #3967
  static TelaGameOverDados + #651, #3967
  static TelaGameOverDados + #652, #3967
  static TelaGameOverDados + #653, #3967
  static TelaGameOverDados + #654, #3967
  static TelaGameOverDados + #655, #3967
  static TelaGameOverDados + #656, #3371
  static TelaGameOverDados + #657, #3967
  static TelaGameOverDados + #658, #3967
  static TelaGameOverDados + #659, #2304
  static TelaGameOverDados + #660, #3967
  static TelaGameOverDados + #661, #2304
  static TelaGameOverDados + #662, #3967
  static TelaGameOverDados + #663, #2304
  static TelaGameOverDados + #664, #3967
  static TelaGameOverDados + #665, #2304
  static TelaGameOverDados + #666, #3967
  static TelaGameOverDados + #667, #2304
  static TelaGameOverDados + #668, #2316
  static TelaGameOverDados + #669, #2316
  static TelaGameOverDados + #670, #3967
  static TelaGameOverDados + #671, #2304
  static TelaGameOverDados + #672, #2316
  static TelaGameOverDados + #673, #2317
  static TelaGameOverDados + #674, #3967
  static TelaGameOverDados + #675, #3967
  static TelaGameOverDados + #676, #3967
  static TelaGameOverDados + #677, #1838
  static TelaGameOverDados + #678, #3967
  static TelaGameOverDados + #679, #3967

  ;Linha 17
  static TelaGameOverDados + #680, #3967
  static TelaGameOverDados + #681, #3967
  static TelaGameOverDados + #682, #3967
  static TelaGameOverDados + #683, #3967
  static TelaGameOverDados + #684, #3967
  static TelaGameOverDados + #685, #3967
  static TelaGameOverDados + #686, #3967
  static TelaGameOverDados + #687, #3967
  static TelaGameOverDados + #688, #3967
  static TelaGameOverDados + #689, #3967
  static TelaGameOverDados + #690, #3967
  static TelaGameOverDados + #691, #3967
  static TelaGameOverDados + #692, #3967
  static TelaGameOverDados + #693, #3967
  static TelaGameOverDados + #694, #2350
  static TelaGameOverDados + #695, #3967
  static TelaGameOverDados + #696, #3967
  static TelaGameOverDados + #697, #3967
  static TelaGameOverDados + #698, #3967
  static TelaGameOverDados + #699, #2304
  static TelaGameOverDados + #700, #3967
  static TelaGameOverDados + #701, #2304
  static TelaGameOverDados + #702, #3967
  static TelaGameOverDados + #703, #2304
  static TelaGameOverDados + #704, #3967
  static TelaGameOverDados + #705, #2304
  static TelaGameOverDados + #706, #3967
  static TelaGameOverDados + #707, #2304
  static TelaGameOverDados + #708, #3967
  static TelaGameOverDados + #709, #3967
  static TelaGameOverDados + #710, #3967
  static TelaGameOverDados + #711, #2304
  static TelaGameOverDados + #712, #2304
  static TelaGameOverDados + #713, #3967
  static TelaGameOverDados + #714, #3967
  static TelaGameOverDados + #715, #3967
  static TelaGameOverDados + #716, #2350
  static TelaGameOverDados + #717, #3967
  static TelaGameOverDados + #718, #3967
  static TelaGameOverDados + #719, #3967

  ;Linha 18
  static TelaGameOverDados + #720, #3967
  static TelaGameOverDados + #721, #3967
  static TelaGameOverDados + #722, #3967
  static TelaGameOverDados + #723, #3967
  static TelaGameOverDados + #724, #3967
  static TelaGameOverDados + #725, #3074
  static TelaGameOverDados + #726, #2350
  static TelaGameOverDados + #727, #3967
  static TelaGameOverDados + #728, #3967
  static TelaGameOverDados + #729, #3967
  static TelaGameOverDados + #730, #2350
  static TelaGameOverDados + #731, #1838
  static TelaGameOverDados + #732, #3967
  static TelaGameOverDados + #733, #3967
  static TelaGameOverDados + #734, #2350
  static TelaGameOverDados + #735, #3967
  static TelaGameOverDados + #736, #3967
  static TelaGameOverDados + #737, #3967
  static TelaGameOverDados + #738, #3967
  static TelaGameOverDados + #739, #2304
  static TelaGameOverDados + #740, #2304
  static TelaGameOverDados + #741, #2304
  static TelaGameOverDados + #742, #3967
  static TelaGameOverDados + #743, #3967
  static TelaGameOverDados + #744, #2304
  static TelaGameOverDados + #745, #3967
  static TelaGameOverDados + #746, #3967
  static TelaGameOverDados + #747, #2304
  static TelaGameOverDados + #748, #2304
  static TelaGameOverDados + #749, #2304
  static TelaGameOverDados + #750, #3967
  static TelaGameOverDados + #751, #2304
  static TelaGameOverDados + #752, #3967
  static TelaGameOverDados + #753, #2304
  static TelaGameOverDados + #754, #3967
  static TelaGameOverDados + #755, #3967
  static TelaGameOverDados + #756, #3967
  static TelaGameOverDados + #757, #3967
  static TelaGameOverDados + #758, #3967
  static TelaGameOverDados + #759, #3371

  ;Linha 19
  static TelaGameOverDados + #760, #3967
  static TelaGameOverDados + #761, #3967
  static TelaGameOverDados + #762, #3967
  static TelaGameOverDados + #763, #3967
  static TelaGameOverDados + #764, #2350
  static TelaGameOverDados + #765, #3967
  static TelaGameOverDados + #766, #3967
  static TelaGameOverDados + #767, #3967
  static TelaGameOverDados + #768, #3967
  static TelaGameOverDados + #769, #3967
  static TelaGameOverDados + #770, #3967
  static TelaGameOverDados + #771, #3967
  static TelaGameOverDados + #772, #3967
  static TelaGameOverDados + #773, #3967
  static TelaGameOverDados + #774, #3967
  static TelaGameOverDados + #775, #3967
  static TelaGameOverDados + #776, #3967
  static TelaGameOverDados + #777, #3967
  static TelaGameOverDados + #778, #3967
  static TelaGameOverDados + #779, #3967
  static TelaGameOverDados + #780, #3967
  static TelaGameOverDados + #781, #3967
  static TelaGameOverDados + #782, #3967
  static TelaGameOverDados + #783, #3967
  static TelaGameOverDados + #784, #3967
  static TelaGameOverDados + #785, #3967
  static TelaGameOverDados + #786, #3967
  static TelaGameOverDados + #787, #3967
  static TelaGameOverDados + #788, #3967
  static TelaGameOverDados + #789, #3967
  static TelaGameOverDados + #790, #3967
  static TelaGameOverDados + #791, #3967
  static TelaGameOverDados + #792, #3967
  static TelaGameOverDados + #793, #3967
  static TelaGameOverDados + #794, #3967
  static TelaGameOverDados + #795, #3967
  static TelaGameOverDados + #796, #3967
  static TelaGameOverDados + #797, #3967
  static TelaGameOverDados + #798, #3967
  static TelaGameOverDados + #799, #3967

  ;Linha 20
  static TelaGameOverDados + #800, #3967
  static TelaGameOverDados + #801, #3967
  static TelaGameOverDados + #802, #3967
  static TelaGameOverDados + #803, #3967
  static TelaGameOverDados + #804, #3967
  static TelaGameOverDados + #805, #3967
  static TelaGameOverDados + #806, #3967
  static TelaGameOverDados + #807, #3967
  static TelaGameOverDados + #808, #3967
  static TelaGameOverDados + #809, #3967
  static TelaGameOverDados + #810, #3967
  static TelaGameOverDados + #811, #3967
  static TelaGameOverDados + #812, #3967
  static TelaGameOverDados + #813, #3967
  static TelaGameOverDados + #814, #3967
  static TelaGameOverDados + #815, #3074
  static TelaGameOverDados + #816, #3967
  static TelaGameOverDados + #817, #3967
  static TelaGameOverDados + #818, #3967
  static TelaGameOverDados + #819, #3967
  static TelaGameOverDados + #820, #3967
  static TelaGameOverDados + #821, #3967
  static TelaGameOverDados + #822, #3967
  static TelaGameOverDados + #823, #3967
  static TelaGameOverDados + #824, #3967
  static TelaGameOverDados + #825, #3967
  static TelaGameOverDados + #826, #3967
  static TelaGameOverDados + #827, #3967
  static TelaGameOverDados + #828, #3967
  static TelaGameOverDados + #829, #3967
  static TelaGameOverDados + #830, #3967
  static TelaGameOverDados + #831, #3967
  static TelaGameOverDados + #832, #3967
  static TelaGameOverDados + #833, #3967
  static TelaGameOverDados + #834, #3967
  static TelaGameOverDados + #835, #3967
  static TelaGameOverDados + #836, #3967
  static TelaGameOverDados + #837, #1792
  static TelaGameOverDados + #838, #3967
  static TelaGameOverDados + #839, #3967

  ;Linha 21
  static TelaGameOverDados + #840, #3967
  static TelaGameOverDados + #841, #3967
  static TelaGameOverDados + #842, #3967
  static TelaGameOverDados + #843, #3967
  static TelaGameOverDados + #844, #3967
  static TelaGameOverDados + #845, #3967
  static TelaGameOverDados + #846, #3156
  static TelaGameOverDados + #847, #3141
  static TelaGameOverDados + #848, #3150
  static TelaGameOverDados + #849, #3156
  static TelaGameOverDados + #850, #3137
  static TelaGameOverDados + #851, #3154
  static TelaGameOverDados + #852, #3967
  static TelaGameOverDados + #853, #3150
  static TelaGameOverDados + #854, #3151
  static TelaGameOverDados + #855, #3158
  static TelaGameOverDados + #856, #3137
  static TelaGameOverDados + #857, #3149
  static TelaGameOverDados + #858, #3141
  static TelaGameOverDados + #859, #3150
  static TelaGameOverDados + #860, #3156
  static TelaGameOverDados + #861, #3141
  static TelaGameOverDados + #862, #3967
  static TelaGameOverDados + #863, #3967
  static TelaGameOverDados + #864, #3163
  static TelaGameOverDados + #865, #3187
  static TelaGameOverDados + #866, #3165
  static TelaGameOverDados + #867, #3967
  static TelaGameOverDados + #868, #3130
  static TelaGameOverDados + #869, #3967
  static TelaGameOverDados + #870, #3163
  static TelaGameOverDados + #871, #3150
  static TelaGameOverDados + #872, #3165
  static TelaGameOverDados + #873, #3967
  static TelaGameOverDados + #874, #3967
  static TelaGameOverDados + #875, #3967
  static TelaGameOverDados + #876, #2350
  static TelaGameOverDados + #877, #3967
  static TelaGameOverDados + #878, #3967
  static TelaGameOverDados + #879, #3967

  ;Linha 22
  static TelaGameOverDados + #880, #3967
  static TelaGameOverDados + #881, #3967
  static TelaGameOverDados + #882, #2880
  static TelaGameOverDados + #883, #3967
  static TelaGameOverDados + #884, #3967
  static TelaGameOverDados + #885, #3967
  static TelaGameOverDados + #886, #3967
  static TelaGameOverDados + #887, #3967
  static TelaGameOverDados + #888, #3967
  static TelaGameOverDados + #889, #3967
  static TelaGameOverDados + #890, #3967
  static TelaGameOverDados + #891, #3967
  static TelaGameOverDados + #892, #3967
  static TelaGameOverDados + #893, #3967
  static TelaGameOverDados + #894, #3967
  static TelaGameOverDados + #895, #3967
  static TelaGameOverDados + #896, #3967
  static TelaGameOverDados + #897, #3967
  static TelaGameOverDados + #898, #3967
  static TelaGameOverDados + #899, #3967
  static TelaGameOverDados + #900, #3967
  static TelaGameOverDados + #901, #3967
  static TelaGameOverDados + #902, #3967
  static TelaGameOverDados + #903, #3967
  static TelaGameOverDados + #904, #3967
  static TelaGameOverDados + #905, #3967
  static TelaGameOverDados + #906, #3967
  static TelaGameOverDados + #907, #3967
  static TelaGameOverDados + #908, #3967
  static TelaGameOverDados + #909, #3967
  static TelaGameOverDados + #910, #3967
  static TelaGameOverDados + #911, #3967
  static TelaGameOverDados + #912, #3967
  static TelaGameOverDados + #913, #3967
  static TelaGameOverDados + #914, #3967
  static TelaGameOverDados + #915, #3967
  static TelaGameOverDados + #916, #3967
  static TelaGameOverDados + #917, #3371
  static TelaGameOverDados + #918, #3967
  static TelaGameOverDados + #919, #3967

  ;Linha 23
  static TelaGameOverDados + #920, #3967
  static TelaGameOverDados + #921, #3967
  static TelaGameOverDados + #922, #3967
  static TelaGameOverDados + #923, #1838
  static TelaGameOverDados + #924, #3967
  static TelaGameOverDados + #925, #3967
  static TelaGameOverDados + #926, #3967
  static TelaGameOverDados + #927, #3967
  static TelaGameOverDados + #928, #2350
  static TelaGameOverDados + #929, #2350
  static TelaGameOverDados + #930, #3967
  static TelaGameOverDados + #931, #3967
  static TelaGameOverDados + #932, #3371
  static TelaGameOverDados + #933, #3967
  static TelaGameOverDados + #934, #3967
  static TelaGameOverDados + #935, #3967
  static TelaGameOverDados + #936, #3967
  static TelaGameOverDados + #937, #3967
  static TelaGameOverDados + #938, #3967
  static TelaGameOverDados + #939, #3967
  static TelaGameOverDados + #940, #3967
  static TelaGameOverDados + #941, #3967
  static TelaGameOverDados + #942, #3967
  static TelaGameOverDados + #943, #3967
  static TelaGameOverDados + #944, #3967
  static TelaGameOverDados + #945, #3967
  static TelaGameOverDados + #946, #3967
  static TelaGameOverDados + #947, #1838
  static TelaGameOverDados + #948, #3967
  static TelaGameOverDados + #949, #3967
  static TelaGameOverDados + #950, #1838
  static TelaGameOverDados + #951, #3967
  static TelaGameOverDados + #952, #3967
  static TelaGameOverDados + #953, #3967
  static TelaGameOverDados + #954, #3967
  static TelaGameOverDados + #955, #3967
  static TelaGameOverDados + #956, #3967
  static TelaGameOverDados + #957, #3967
  static TelaGameOverDados + #958, #3967
  static TelaGameOverDados + #959, #3967

  ;Linha 24
  static TelaGameOverDados + #960, #3967
  static TelaGameOverDados + #961, #3967
  static TelaGameOverDados + #962, #3967
  static TelaGameOverDados + #963, #3967
  static TelaGameOverDados + #964, #3967
  static TelaGameOverDados + #965, #3967
  static TelaGameOverDados + #966, #3967
  static TelaGameOverDados + #967, #3967
  static TelaGameOverDados + #968, #3967
  static TelaGameOverDados + #969, #3967
  static TelaGameOverDados + #970, #3967
  static TelaGameOverDados + #971, #3967
  static TelaGameOverDados + #972, #3967
  static TelaGameOverDados + #973, #3967
  static TelaGameOverDados + #974, #3967
  static TelaGameOverDados + #975, #1792
  static TelaGameOverDados + #976, #3967
  static TelaGameOverDados + #977, #3967
  static TelaGameOverDados + #978, #3967
  static TelaGameOverDados + #979, #3967
  static TelaGameOverDados + #980, #1838
  static TelaGameOverDados + #981, #3967
  static TelaGameOverDados + #982, #3967
  static TelaGameOverDados + #983, #3967
  static TelaGameOverDados + #984, #3967
  static TelaGameOverDados + #985, #2350
  static TelaGameOverDados + #986, #2350
  static TelaGameOverDados + #987, #3967
  static TelaGameOverDados + #988, #3967
  static TelaGameOverDados + #989, #3967
  static TelaGameOverDados + #990, #3967
  static TelaGameOverDados + #991, #3967
  static TelaGameOverDados + #992, #3967
  static TelaGameOverDados + #993, #3371
  static TelaGameOverDados + #994, #3967
  static TelaGameOverDados + #995, #3967
  static TelaGameOverDados + #996, #3967
  static TelaGameOverDados + #997, #3967
  static TelaGameOverDados + #998, #3967
  static TelaGameOverDados + #999, #3967

  ;Linha 25
  static TelaGameOverDados + #1000, #3967
  static TelaGameOverDados + #1001, #3967
  static TelaGameOverDados + #1002, #3967
  static TelaGameOverDados + #1003, #3967
  static TelaGameOverDados + #1004, #3967
  static TelaGameOverDados + #1005, #3967
  static TelaGameOverDados + #1006, #3967
  static TelaGameOverDados + #1007, #1792
  static TelaGameOverDados + #1008, #3967
  static TelaGameOverDados + #1009, #3967
  static TelaGameOverDados + #1010, #3967
  static TelaGameOverDados + #1011, #3967
  static TelaGameOverDados + #1012, #3967
  static TelaGameOverDados + #1013, #3967
  static TelaGameOverDados + #1014, #3967
  static TelaGameOverDados + #1015, #2350
  static TelaGameOverDados + #1016, #3967
  static TelaGameOverDados + #1017, #3967
  static TelaGameOverDados + #1018, #3967
  static TelaGameOverDados + #1019, #3967
  static TelaGameOverDados + #1020, #3967
  static TelaGameOverDados + #1021, #3967
  static TelaGameOverDados + #1022, #3967
  static TelaGameOverDados + #1023, #1838
  static TelaGameOverDados + #1024, #3967
  static TelaGameOverDados + #1025, #3967
  static TelaGameOverDados + #1026, #3967
  static TelaGameOverDados + #1027, #3967
  static TelaGameOverDados + #1028, #3967
  static TelaGameOverDados + #1029, #2350
  static TelaGameOverDados + #1030, #3967
  static TelaGameOverDados + #1031, #3967
  static TelaGameOverDados + #1032, #3967
  static TelaGameOverDados + #1033, #3967
  static TelaGameOverDados + #1034, #3967
  static TelaGameOverDados + #1035, #3967
  static TelaGameOverDados + #1036, #3967
  static TelaGameOverDados + #1037, #3967
  static TelaGameOverDados + #1038, #3967
  static TelaGameOverDados + #1039, #3967

  ;Linha 26
  static TelaGameOverDados + #1040, #3967
  static TelaGameOverDados + #1041, #3967
  static TelaGameOverDados + #1042, #3967
  static TelaGameOverDados + #1043, #3967
  static TelaGameOverDados + #1044, #2350
  static TelaGameOverDados + #1045, #3967
  static TelaGameOverDados + #1046, #2350
  static TelaGameOverDados + #1047, #3967
  static TelaGameOverDados + #1048, #3967
  static TelaGameOverDados + #1049, #3967
  static TelaGameOverDados + #1050, #3967
  static TelaGameOverDados + #1051, #3967
  static TelaGameOverDados + #1052, #3967
  static TelaGameOverDados + #1053, #3967
  static TelaGameOverDados + #1054, #3967
  static TelaGameOverDados + #1055, #3967
  static TelaGameOverDados + #1056, #3967
  static TelaGameOverDados + #1057, #3967
  static TelaGameOverDados + #1058, #3371
  static TelaGameOverDados + #1059, #3967
  static TelaGameOverDados + #1060, #3967
  static TelaGameOverDados + #1061, #3967
  static TelaGameOverDados + #1062, #3967
  static TelaGameOverDados + #1063, #3074
  static TelaGameOverDados + #1064, #3967
  static TelaGameOverDados + #1065, #3967
  static TelaGameOverDados + #1066, #3967
  static TelaGameOverDados + #1067, #3967
  static TelaGameOverDados + #1068, #3967
  static TelaGameOverDados + #1069, #2350
  static TelaGameOverDados + #1070, #3967
  static TelaGameOverDados + #1071, #3967
  static TelaGameOverDados + #1072, #3967
  static TelaGameOverDados + #1073, #3967
  static TelaGameOverDados + #1074, #3967
  static TelaGameOverDados + #1075, #2350
  static TelaGameOverDados + #1076, #3967
  static TelaGameOverDados + #1077, #3967
  static TelaGameOverDados + #1078, #3967
  static TelaGameOverDados + #1079, #3074

  ;Linha 27
  static TelaGameOverDados + #1080, #3967
  static TelaGameOverDados + #1081, #3967
  static TelaGameOverDados + #1082, #3967
  static TelaGameOverDados + #1083, #3967
  static TelaGameOverDados + #1084, #3967
  static TelaGameOverDados + #1085, #3967
  static TelaGameOverDados + #1086, #1838
  static TelaGameOverDados + #1087, #3967
  static TelaGameOverDados + #1088, #3967
  static TelaGameOverDados + #1089, #3967
  static TelaGameOverDados + #1090, #3074
  static TelaGameOverDados + #1091, #3967
  static TelaGameOverDados + #1092, #3967
  static TelaGameOverDados + #1093, #3371
  static TelaGameOverDados + #1094, #3967
  static TelaGameOverDados + #1095, #3967
  static TelaGameOverDados + #1096, #3967
  static TelaGameOverDados + #1097, #2350
  static TelaGameOverDados + #1098, #3967
  static TelaGameOverDados + #1099, #3967
  static TelaGameOverDados + #1100, #1838
  static TelaGameOverDados + #1101, #3967
  static TelaGameOverDados + #1102, #3967
  static TelaGameOverDados + #1103, #3967
  static TelaGameOverDados + #1104, #3967
  static TelaGameOverDados + #1105, #1792
  static TelaGameOverDados + #1106, #3967
  static TelaGameOverDados + #1107, #3967
  static TelaGameOverDados + #1108, #3967
  static TelaGameOverDados + #1109, #3967
  static TelaGameOverDados + #1110, #3967
  static TelaGameOverDados + #1111, #3967
  static TelaGameOverDados + #1112, #1838
  static TelaGameOverDados + #1113, #3967
  static TelaGameOverDados + #1114, #3967
  static TelaGameOverDados + #1115, #3967
  static TelaGameOverDados + #1116, #3967
  static TelaGameOverDados + #1117, #3967
  static TelaGameOverDados + #1118, #3967
  static TelaGameOverDados + #1119, #3967

  ;Linha 28
  static TelaGameOverDados + #1120, #3967
  static TelaGameOverDados + #1121, #3967
  static TelaGameOverDados + #1122, #3967
  static TelaGameOverDados + #1123, #1838
  static TelaGameOverDados + #1124, #3967
  static TelaGameOverDados + #1125, #3967
  static TelaGameOverDados + #1126, #3967
  static TelaGameOverDados + #1127, #3967
  static TelaGameOverDados + #1128, #3967
  static TelaGameOverDados + #1129, #3967
  static TelaGameOverDados + #1130, #3967
  static TelaGameOverDados + #1131, #3967
  static TelaGameOverDados + #1132, #3967
  static TelaGameOverDados + #1133, #3967
  static TelaGameOverDados + #1134, #3967
  static TelaGameOverDados + #1135, #3967
  static TelaGameOverDados + #1136, #3967
  static TelaGameOverDados + #1137, #3967
  static TelaGameOverDados + #1138, #3967
  static TelaGameOverDados + #1139, #3967
  static TelaGameOverDados + #1140, #3967
  static TelaGameOverDados + #1141, #3967
  static TelaGameOverDados + #1142, #3967
  static TelaGameOverDados + #1143, #3967
  static TelaGameOverDados + #1144, #3967
  static TelaGameOverDados + #1145, #3967
  static TelaGameOverDados + #1146, #3967
  static TelaGameOverDados + #1147, #3967
  static TelaGameOverDados + #1148, #3967
  static TelaGameOverDados + #1149, #3967
  static TelaGameOverDados + #1150, #2350
  static TelaGameOverDados + #1151, #3967
  static TelaGameOverDados + #1152, #3967
  static TelaGameOverDados + #1153, #3967
  static TelaGameOverDados + #1154, #3967
  static TelaGameOverDados + #1155, #3967
  static TelaGameOverDados + #1156, #3967
  static TelaGameOverDados + #1157, #3967
  static TelaGameOverDados + #1158, #3967
  static TelaGameOverDados + #1159, #3967

  ;Linha 29
  static TelaGameOverDados + #1160, #3967
  static TelaGameOverDados + #1161, #3967
  static TelaGameOverDados + #1162, #3967
  static TelaGameOverDados + #1163, #3967
  static TelaGameOverDados + #1164, #3967
  static TelaGameOverDados + #1165, #3967
  static TelaGameOverDados + #1166, #3967
  static TelaGameOverDados + #1167, #3967
  static TelaGameOverDados + #1168, #3967
  static TelaGameOverDados + #1169, #3967
  static TelaGameOverDados + #1170, #3967
  static TelaGameOverDados + #1171, #3967
  static TelaGameOverDados + #1172, #3967
  static TelaGameOverDados + #1173, #3967
  static TelaGameOverDados + #1174, #3967
  static TelaGameOverDados + #1175, #3967
  static TelaGameOverDados + #1176, #3967
  static TelaGameOverDados + #1177, #3967
  static TelaGameOverDados + #1178, #3967
  static TelaGameOverDados + #1179, #3967
  static TelaGameOverDados + #1180, #3967
  static TelaGameOverDados + #1181, #3967
  static TelaGameOverDados + #1182, #3967
  static TelaGameOverDados + #1183, #3967
  static TelaGameOverDados + #1184, #3967
  static TelaGameOverDados + #1185, #3967
  static TelaGameOverDados + #1186, #3967
  static TelaGameOverDados + #1187, #3967
  static TelaGameOverDados + #1188, #3967
  static TelaGameOverDados + #1189, #3967
  static TelaGameOverDados + #1190, #3967
  static TelaGameOverDados + #1191, #3967
  static TelaGameOverDados + #1192, #3967
  static TelaGameOverDados + #1193, #3967
  static TelaGameOverDados + #1194, #3967
  static TelaGameOverDados + #1195, #3967
  static TelaGameOverDados + #1196, #3967
  static TelaGameOverDados + #1197, #3967
  static TelaGameOverDados + #1198, #3967
  static TelaGameOverDados + #1199, #3967

  ; ============ TELAS DOS NIVEIS ==========

nivel1-3 : var #1200
  ;Linha 0
  static nivel1-3 + #0, #3967
  static nivel1-3 + #1, #3967
  static nivel1-3 + #2, #3967
  static nivel1-3 + #3, #3967
  static nivel1-3 + #4, #3967
  static nivel1-3 + #5, #3967
  static nivel1-3 + #6, #3967
  static nivel1-3 + #7, #3967
  static nivel1-3 + #8, #3967
  static nivel1-3 + #9, #3967
  static nivel1-3 + #10, #3967
  static nivel1-3 + #11, #3967
  static nivel1-3 + #12, #3967
  static nivel1-3 + #13, #3967
  static nivel1-3 + #14, #3967
  static nivel1-3 + #15, #3967
  static nivel1-3 + #16, #3967
  static nivel1-3 + #17, #3967
  static nivel1-3 + #18, #3967
  static nivel1-3 + #19, #3967
  static nivel1-3 + #20, #3967
  static nivel1-3 + #21, #3967
  static nivel1-3 + #22, #3967
  static nivel1-3 + #23, #3967
  static nivel1-3 + #24, #3967
  static nivel1-3 + #25, #3967
  static nivel1-3 + #26, #3967
  static nivel1-3 + #27, #3967
  static nivel1-3 + #28, #3967
  static nivel1-3 + #29, #3967
  static nivel1-3 + #30, #3967
  static nivel1-3 + #31, #3967
  static nivel1-3 + #32, #3967
  static nivel1-3 + #33, #3967
  static nivel1-3 + #34, #3967
  static nivel1-3 + #35, #3967
  static nivel1-3 + #36, #3967
  static nivel1-3 + #37, #3967
  static nivel1-3 + #38, #3967
  static nivel1-3 + #39, #3967

  ;Linha 1
  static nivel1-3 + #40, #3967
  static nivel1-3 + #41, #3967
  static nivel1-3 + #42, #3967
  static nivel1-3 + #43, #3967
  static nivel1-3 + #44, #3967
  static nivel1-3 + #45, #3967
  static nivel1-3 + #46, #3967
  static nivel1-3 + #47, #3967
  static nivel1-3 + #48, #3967
  static nivel1-3 + #49, #3967
  static nivel1-3 + #50, #3967
  static nivel1-3 + #51, #3967
  static nivel1-3 + #52, #3967
  static nivel1-3 + #53, #3967
  static nivel1-3 + #54, #3967
  static nivel1-3 + #55, #3967
  static nivel1-3 + #56, #3967
  static nivel1-3 + #57, #3967
  static nivel1-3 + #58, #3967
  static nivel1-3 + #59, #3967
  static nivel1-3 + #60, #3967
  static nivel1-3 + #61, #3967
  static nivel1-3 + #62, #3967
  static nivel1-3 + #63, #3967
  static nivel1-3 + #64, #3072
  static nivel1-3 + #65, #3967
  static nivel1-3 + #66, #3967
  static nivel1-3 + #67, #3967
  static nivel1-3 + #68, #3967
  static nivel1-3 + #69, #3967
  static nivel1-3 + #70, #3967
  static nivel1-3 + #71, #3967
  static nivel1-3 + #72, #3967
  static nivel1-3 + #73, #3967
  static nivel1-3 + #74, #3967
  static nivel1-3 + #75, #3967
  static nivel1-3 + #76, #3074
  static nivel1-3 + #77, #3074
  static nivel1-3 + #78, #3967
  static nivel1-3 + #79, #3967

  ;Linha 2
  static nivel1-3 + #80, #3967
  static nivel1-3 + #81, #3967
  static nivel1-3 + #82, #3967
  static nivel1-3 + #83, #3967
  static nivel1-3 + #84, #3967
  static nivel1-3 + #85, #3967
  static nivel1-3 + #86, #3118
  static nivel1-3 + #87, #3118
  static nivel1-3 + #88, #3967
  static nivel1-3 + #89, #3967
  static nivel1-3 + #90, #3967
  static nivel1-3 + #91, #3967
  static nivel1-3 + #92, #3967
  static nivel1-3 + #93, #3967
  static nivel1-3 + #94, #3967
  static nivel1-3 + #95, #3114
  static nivel1-3 + #96, #3967
  static nivel1-3 + #97, #3967
  static nivel1-3 + #98, #3967
  static nivel1-3 + #99, #3967
  static nivel1-3 + #100, #3967
  static nivel1-3 + #101, #3967
  static nivel1-3 + #102, #3967
  static nivel1-3 + #103, #3967
  static nivel1-3 + #104, #3967
  static nivel1-3 + #105, #3967
  static nivel1-3 + #106, #3967
  static nivel1-3 + #107, #3967
  static nivel1-3 + #108, #3967
  static nivel1-3 + #109, #3967
  static nivel1-3 + #110, #3967
  static nivel1-3 + #111, #3118
  static nivel1-3 + #112, #3118
  static nivel1-3 + #113, #3118
  static nivel1-3 + #114, #3967
  static nivel1-3 + #115, #3967
  static nivel1-3 + #116, #3074
  static nivel1-3 + #117, #3074
  static nivel1-3 + #118, #3967
  static nivel1-3 + #119, #3967

  ;Linha 3
  static nivel1-3 + #120, #3967
  static nivel1-3 + #121, #3967
  static nivel1-3 + #122, #3967
  static nivel1-3 + #123, #3072
  static nivel1-3 + #124, #3967
  static nivel1-3 + #125, #3967
  static nivel1-3 + #126, #3967
  static nivel1-3 + #127, #3967
  static nivel1-3 + #128, #3967
  static nivel1-3 + #129, #3967
  static nivel1-3 + #130, #3967
  static nivel1-3 + #131, #3967
  static nivel1-3 + #132, #3967
  static nivel1-3 + #133, #3118
  static nivel1-3 + #134, #3967
  static nivel1-3 + #135, #3967
  static nivel1-3 + #136, #3967
  static nivel1-3 + #137, #3967
  static nivel1-3 + #138, #3967
  static nivel1-3 + #139, #3967
  static nivel1-3 + #140, #3967
  static nivel1-3 + #141, #3967
  static nivel1-3 + #142, #3118
  static nivel1-3 + #143, #3967
  static nivel1-3 + #144, #3967
  static nivel1-3 + #145, #3967
  static nivel1-3 + #146, #3967
  static nivel1-3 + #147, #3967
  static nivel1-3 + #148, #3967
  static nivel1-3 + #149, #3967
  static nivel1-3 + #150, #3967
  static nivel1-3 + #151, #3967
  static nivel1-3 + #152, #3967
  static nivel1-3 + #153, #3967
  static nivel1-3 + #154, #3967
  static nivel1-3 + #155, #3967
  static nivel1-3 + #156, #3967
  static nivel1-3 + #157, #3967
  static nivel1-3 + #158, #3967
  static nivel1-3 + #159, #3967

  ;Linha 4
  static nivel1-3 + #160, #3967
  static nivel1-3 + #161, #3967
  static nivel1-3 + #162, #3967
  static nivel1-3 + #163, #3967
  static nivel1-3 + #164, #3967
  static nivel1-3 + #165, #3967
  static nivel1-3 + #166, #3967
  static nivel1-3 + #167, #3967
  static nivel1-3 + #168, #3967
  static nivel1-3 + #169, #3967
  static nivel1-3 + #170, #3967
  static nivel1-3 + #171, #3967
  static nivel1-3 + #172, #3072
  static nivel1-3 + #173, #3967
  static nivel1-3 + #174, #3967
  static nivel1-3 + #175, #3967
  static nivel1-3 + #176, #3967
  static nivel1-3 + #177, #3967
  static nivel1-3 + #178, #3967
  static nivel1-3 + #179, #3114
  static nivel1-3 + #180, #3967
  static nivel1-3 + #181, #3967
  static nivel1-3 + #182, #3967
  static nivel1-3 + #183, #3967
  static nivel1-3 + #184, #3967
  static nivel1-3 + #185, #3967
  static nivel1-3 + #186, #3967
  static nivel1-3 + #187, #3967
  static nivel1-3 + #188, #3967
  static nivel1-3 + #189, #3967
  static nivel1-3 + #190, #3967
  static nivel1-3 + #191, #3967
  static nivel1-3 + #192, #3967
  static nivel1-3 + #193, #3967
  static nivel1-3 + #194, #3072
  static nivel1-3 + #195, #3967
  static nivel1-3 + #196, #3967
  static nivel1-3 + #197, #3967
  static nivel1-3 + #198, #3967
  static nivel1-3 + #199, #3967

  ;Linha 5
  static nivel1-3 + #200, #3967
  static nivel1-3 + #201, #3967
  static nivel1-3 + #202, #3967
  static nivel1-3 + #203, #3967
  static nivel1-3 + #204, #3967
  static nivel1-3 + #205, #3967
  static nivel1-3 + #206, #3118
  static nivel1-3 + #207, #3114
  static nivel1-3 + #208, #3967
  static nivel1-3 + #209, #3967
  static nivel1-3 + #210, #3967
  static nivel1-3 + #211, #3967
  static nivel1-3 + #212, #3967
  static nivel1-3 + #213, #3967
  static nivel1-3 + #214, #3967
  static nivel1-3 + #215, #3967
  static nivel1-3 + #216, #3967
  static nivel1-3 + #217, #3967
  static nivel1-3 + #218, #3967
  static nivel1-3 + #219, #3967
  static nivel1-3 + #220, #3967
  static nivel1-3 + #221, #3967
  static nivel1-3 + #222, #3967
  static nivel1-3 + #223, #3967
  static nivel1-3 + #224, #3967
  static nivel1-3 + #225, #3967
  static nivel1-3 + #226, #3967
  static nivel1-3 + #227, #3967
  static nivel1-3 + #228, #3967
  static nivel1-3 + #229, #3967
  static nivel1-3 + #230, #3967
  static nivel1-3 + #231, #3967
  static nivel1-3 + #232, #3967
  static nivel1-3 + #233, #3118
  static nivel1-3 + #234, #3967
  static nivel1-3 + #235, #3967
  static nivel1-3 + #236, #3967
  static nivel1-3 + #237, #3967
  static nivel1-3 + #238, #3967
  static nivel1-3 + #239, #3967

  ;Linha 6
  static nivel1-3 + #240, #3967
  static nivel1-3 + #241, #3967
  static nivel1-3 + #242, #3967
  static nivel1-3 + #243, #3967
  static nivel1-3 + #244, #3118
  static nivel1-3 + #245, #3967
  static nivel1-3 + #246, #3967
  static nivel1-3 + #247, #3967
  static nivel1-3 + #248, #3967
  static nivel1-3 + #249, #3967
  static nivel1-3 + #250, #3967
  static nivel1-3 + #251, #3967
  static nivel1-3 + #252, #3967
  static nivel1-3 + #253, #3967
  static nivel1-3 + #254, #3967
  static nivel1-3 + #255, #3967
  static nivel1-3 + #256, #3967
  static nivel1-3 + #257, #3967
  static nivel1-3 + #258, #3967
  static nivel1-3 + #259, #3967
  static nivel1-3 + #260, #3967
  static nivel1-3 + #261, #3967
  static nivel1-3 + #262, #3967
  static nivel1-3 + #263, #3967
  static nivel1-3 + #264, #3967
  static nivel1-3 + #265, #3967
  static nivel1-3 + #266, #3967
  static nivel1-3 + #267, #3967
  static nivel1-3 + #268, #3114
  static nivel1-3 + #269, #3967
  static nivel1-3 + #270, #3967
  static nivel1-3 + #271, #3967
  static nivel1-3 + #272, #3967
  static nivel1-3 + #273, #3967
  static nivel1-3 + #274, #3967
  static nivel1-3 + #275, #3967
  static nivel1-3 + #276, #3967
  static nivel1-3 + #277, #3967
  static nivel1-3 + #278, #3967
  static nivel1-3 + #279, #3967

  ;Linha 7
  static nivel1-3 + #280, #3967
  static nivel1-3 + #281, #3967
  static nivel1-3 + #282, #3118
  static nivel1-3 + #283, #3967
  static nivel1-3 + #284, #3967
  static nivel1-3 + #285, #3967
  static nivel1-3 + #286, #3967
  static nivel1-3 + #287, #3967
  static nivel1-3 + #288, #3967
  static nivel1-3 + #289, #3967
  static nivel1-3 + #290, #3967
  static nivel1-3 + #291, #3967
  static nivel1-3 + #292, #3967
  static nivel1-3 + #293, #3967
  static nivel1-3 + #294, #3967
  static nivel1-3 + #295, #3967
  static nivel1-3 + #296, #3967
  static nivel1-3 + #297, #3967
  static nivel1-3 + #298, #3967
  static nivel1-3 + #299, #3967
  static nivel1-3 + #300, #3967
  static nivel1-3 + #301, #3967
  static nivel1-3 + #302, #3967
  static nivel1-3 + #303, #3967
  static nivel1-3 + #304, #3967
  static nivel1-3 + #305, #3967
  static nivel1-3 + #306, #3967
  static nivel1-3 + #307, #3967
  static nivel1-3 + #308, #3967
  static nivel1-3 + #309, #3967
  static nivel1-3 + #310, #3967
  static nivel1-3 + #311, #3967
  static nivel1-3 + #312, #3967
  static nivel1-3 + #313, #3967
  static nivel1-3 + #314, #3967
  static nivel1-3 + #315, #3967
  static nivel1-3 + #316, #3967
  static nivel1-3 + #317, #3967
  static nivel1-3 + #318, #3967
  static nivel1-3 + #319, #3967

  ;Linha 8
  static nivel1-3 + #320, #3967
  static nivel1-3 + #321, #3967
  static nivel1-3 + #322, #3967
  static nivel1-3 + #323, #3967
  static nivel1-3 + #324, #3967
  static nivel1-3 + #325, #3967
  static nivel1-3 + #326, #3967
  static nivel1-3 + #327, #3967
  static nivel1-3 + #328, #3118
  static nivel1-3 + #329, #3967
  static nivel1-3 + #330, #3967
  static nivel1-3 + #331, #3967
  static nivel1-3 + #332, #3967
  static nivel1-3 + #333, #3118
  static nivel1-3 + #334, #3967
  static nivel1-3 + #335, #3967
  static nivel1-3 + #336, #3118
  static nivel1-3 + #337, #3967
  static nivel1-3 + #338, #3967
  static nivel1-3 + #339, #3114
  static nivel1-3 + #340, #3967
  static nivel1-3 + #341, #3967
  static nivel1-3 + #342, #3118
  static nivel1-3 + #343, #3118
  static nivel1-3 + #344, #3967
  static nivel1-3 + #345, #3967
  static nivel1-3 + #346, #3967
  static nivel1-3 + #347, #3118
  static nivel1-3 + #348, #3967
  static nivel1-3 + #349, #3967
  static nivel1-3 + #350, #3967
  static nivel1-3 + #351, #3967
  static nivel1-3 + #352, #3967
  static nivel1-3 + #353, #3967
  static nivel1-3 + #354, #3967
  static nivel1-3 + #355, #3967
  static nivel1-3 + #356, #3967
  static nivel1-3 + #357, #3967
  static nivel1-3 + #358, #3967
  static nivel1-3 + #359, #3967

  ;Linha 9
  static nivel1-3 + #360, #3967
  static nivel1-3 + #361, #3967
  static nivel1-3 + #362, #3967
  static nivel1-3 + #363, #3967
  static nivel1-3 + #364, #3967
  static nivel1-3 + #365, #3967
  static nivel1-3 + #366, #3967
  static nivel1-3 + #367, #3967
  static nivel1-3 + #368, #3967
  static nivel1-3 + #369, #3967
  static nivel1-3 + #370, #3967
  static nivel1-3 + #371, #3967
  static nivel1-3 + #372, #3967
  static nivel1-3 + #373, #3967
  static nivel1-3 + #374, #3967
  static nivel1-3 + #375, #3118
  static nivel1-3 + #376, #3967
  static nivel1-3 + #377, #3967
  static nivel1-3 + #378, #3967
  static nivel1-3 + #379, #3967
  static nivel1-3 + #380, #3967
  static nivel1-3 + #381, #3967
  static nivel1-3 + #382, #3118
  static nivel1-3 + #383, #3967
  static nivel1-3 + #384, #3967
  static nivel1-3 + #385, #3967
  static nivel1-3 + #386, #3967
  static nivel1-3 + #387, #3967
  static nivel1-3 + #388, #3967
  static nivel1-3 + #389, #3967
  static nivel1-3 + #390, #3967
  static nivel1-3 + #391, #3967
  static nivel1-3 + #392, #3967
  static nivel1-3 + #393, #3967
  static nivel1-3 + #394, #3967
  static nivel1-3 + #395, #3967
  static nivel1-3 + #396, #3967
  static nivel1-3 + #397, #3967
  static nivel1-3 + #398, #3967
  static nivel1-3 + #399, #3967

  ;Linha 10
  static nivel1-3 + #400, #3967
  static nivel1-3 + #401, #3967
  static nivel1-3 + #402, #3967
  static nivel1-3 + #403, #3967
  static nivel1-3 + #404, #3967
  static nivel1-3 + #405, #3967
  static nivel1-3 + #406, #3967
  static nivel1-3 + #407, #3967
  static nivel1-3 + #408, #3114
  static nivel1-3 + #409, #3967
  static nivel1-3 + #410, #3967
  static nivel1-3 + #411, #3967
  static nivel1-3 + #412, #3967
  static nivel1-3 + #413, #3967
  static nivel1-3 + #414, #3967
  static nivel1-3 + #415, #3967
  static nivel1-3 + #416, #3967
  static nivel1-3 + #417, #3967
  static nivel1-3 + #418, #3967
  static nivel1-3 + #419, #3967
  static nivel1-3 + #420, #3967
  static nivel1-3 + #421, #3967
  static nivel1-3 + #422, #3967
  static nivel1-3 + #423, #3967
  static nivel1-3 + #424, #3967
  static nivel1-3 + #425, #3967
  static nivel1-3 + #426, #3967
  static nivel1-3 + #427, #3967
  static nivel1-3 + #428, #3967
  static nivel1-3 + #429, #3967
  static nivel1-3 + #430, #3114
  static nivel1-3 + #431, #3967
  static nivel1-3 + #432, #3967
  static nivel1-3 + #433, #3967
  static nivel1-3 + #434, #3967
  static nivel1-3 + #435, #3967
  static nivel1-3 + #436, #3967
  static nivel1-3 + #437, #3967
  static nivel1-3 + #438, #3967
  static nivel1-3 + #439, #3967

  ;Linha 11
  static nivel1-3 + #440, #3967
  static nivel1-3 + #441, #3967
  static nivel1-3 + #442, #3114
  static nivel1-3 + #443, #3967
  static nivel1-3 + #444, #3967
  static nivel1-3 + #445, #3967
  static nivel1-3 + #446, #3967
  static nivel1-3 + #447, #3967
  static nivel1-3 + #448, #3967
  static nivel1-3 + #449, #3967
  static nivel1-3 + #450, #3967
  static nivel1-3 + #451, #3967
  static nivel1-3 + #452, #3967
  static nivel1-3 + #453, #3967
  static nivel1-3 + #454, #3967
  static nivel1-3 + #455, #3967
  static nivel1-3 + #456, #3967
  static nivel1-3 + #457, #3967
  static nivel1-3 + #458, #3967
  static nivel1-3 + #459, #3967
  static nivel1-3 + #460, #3967
  static nivel1-3 + #461, #3967
  static nivel1-3 + #462, #3967
  static nivel1-3 + #463, #3967
  static nivel1-3 + #464, #3967
  static nivel1-3 + #465, #3967
  static nivel1-3 + #466, #3967
  static nivel1-3 + #467, #3967
  static nivel1-3 + #468, #3967
  static nivel1-3 + #469, #3118
  static nivel1-3 + #470, #3967
  static nivel1-3 + #471, #3967
  static nivel1-3 + #472, #3967
  static nivel1-3 + #473, #3967
  static nivel1-3 + #474, #3967
  static nivel1-3 + #475, #3967
  static nivel1-3 + #476, #3114
  static nivel1-3 + #477, #3967
  static nivel1-3 + #478, #3967
  static nivel1-3 + #479, #3967

  ;Linha 12
  static nivel1-3 + #480, #3967
  static nivel1-3 + #481, #3967
  static nivel1-3 + #482, #3967
  static nivel1-3 + #483, #3967
  static nivel1-3 + #484, #3967
  static nivel1-3 + #485, #3967
  static nivel1-3 + #486, #3967
  static nivel1-3 + #487, #3118
  static nivel1-3 + #488, #3967
  static nivel1-3 + #489, #3967
  static nivel1-3 + #490, #3967
  static nivel1-3 + #491, #3967
  static nivel1-3 + #492, #3967
  static nivel1-3 + #493, #3967
  static nivel1-3 + #494, #3967
  static nivel1-3 + #495, #3967
  static nivel1-3 + #496, #3967
  static nivel1-3 + #497, #3967
  static nivel1-3 + #498, #3967
  static nivel1-3 + #499, #3967
  static nivel1-3 + #500, #3967
  static nivel1-3 + #501, #3967
  static nivel1-3 + #502, #3967
  static nivel1-3 + #503, #3967
  static nivel1-3 + #504, #3967
  static nivel1-3 + #505, #3118
  static nivel1-3 + #506, #3967
  static nivel1-3 + #507, #3967
  static nivel1-3 + #508, #3967
  static nivel1-3 + #509, #3967
  static nivel1-3 + #510, #3967
  static nivel1-3 + #511, #3967
  static nivel1-3 + #512, #3967
  static nivel1-3 + #513, #3967
  static nivel1-3 + #514, #3967
  static nivel1-3 + #515, #3967
  static nivel1-3 + #516, #3967
  static nivel1-3 + #517, #3967
  static nivel1-3 + #518, #3967
  static nivel1-3 + #519, #3967

  ;Linha 13
  static nivel1-3 + #520, #3967
  static nivel1-3 + #521, #3967
  static nivel1-3 + #522, #3967
  static nivel1-3 + #523, #3967
  static nivel1-3 + #524, #3967
  static nivel1-3 + #525, #3967
  static nivel1-3 + #526, #3967
  static nivel1-3 + #527, #3967
  static nivel1-3 + #528, #3967
  static nivel1-3 + #529, #3967
  static nivel1-3 + #530, #3967
  static nivel1-3 + #531, #3967
  static nivel1-3 + #532, #3118
  static nivel1-3 + #533, #3967
  static nivel1-3 + #534, #3118
  static nivel1-3 + #535, #3967
  static nivel1-3 + #536, #3967
  static nivel1-3 + #537, #3967
  static nivel1-3 + #538, #3967
  static nivel1-3 + #539, #3967
  static nivel1-3 + #540, #3072
  static nivel1-3 + #541, #3967
  static nivel1-3 + #542, #3967
  static nivel1-3 + #543, #3967
  static nivel1-3 + #544, #3967
  static nivel1-3 + #545, #3967
  static nivel1-3 + #546, #3967
  static nivel1-3 + #547, #3967
  static nivel1-3 + #548, #3967
  static nivel1-3 + #549, #3967
  static nivel1-3 + #550, #3967
  static nivel1-3 + #551, #3967
  static nivel1-3 + #552, #3967
  static nivel1-3 + #553, #3118
  static nivel1-3 + #554, #3967
  static nivel1-3 + #555, #3967
  static nivel1-3 + #556, #3967
  static nivel1-3 + #557, #3967
  static nivel1-3 + #558, #3967
  static nivel1-3 + #559, #3967

  ;Linha 14
  static nivel1-3 + #560, #3967
  static nivel1-3 + #561, #3967
  static nivel1-3 + #562, #3074
  static nivel1-3 + #563, #3074
  static nivel1-3 + #564, #3118
  static nivel1-3 + #565, #3967
  static nivel1-3 + #566, #3967
  static nivel1-3 + #567, #3967
  static nivel1-3 + #568, #3967
  static nivel1-3 + #569, #3967
  static nivel1-3 + #570, #3967
  static nivel1-3 + #571, #3967
  static nivel1-3 + #572, #3967
  static nivel1-3 + #573, #3967
  static nivel1-3 + #574, #3967
  static nivel1-3 + #575, #3967
  static nivel1-3 + #576, #3967
  static nivel1-3 + #577, #3967
  static nivel1-3 + #578, #3967
  static nivel1-3 + #579, #3118
  static nivel1-3 + #580, #3967
  static nivel1-3 + #581, #3967
  static nivel1-3 + #582, #3967
  static nivel1-3 + #583, #3967
  static nivel1-3 + #584, #3967
  static nivel1-3 + #585, #3967
  static nivel1-3 + #586, #3967
  static nivel1-3 + #587, #3967
  static nivel1-3 + #588, #3967
  static nivel1-3 + #589, #3967
  static nivel1-3 + #590, #3967
  static nivel1-3 + #591, #3967
  static nivel1-3 + #592, #3967
  static nivel1-3 + #593, #3967
  static nivel1-3 + #594, #3967
  static nivel1-3 + #595, #3967
  static nivel1-3 + #596, #3967
  static nivel1-3 + #597, #3967
  static nivel1-3 + #598, #3967
  static nivel1-3 + #599, #3967

  ;Linha 15
  static nivel1-3 + #600, #3967
  static nivel1-3 + #601, #3967
  static nivel1-3 + #602, #3074
  static nivel1-3 + #603, #3074
  static nivel1-3 + #604, #3967
  static nivel1-3 + #605, #3967
  static nivel1-3 + #606, #3967
  static nivel1-3 + #607, #3967
  static nivel1-3 + #608, #3967
  static nivel1-3 + #609, #3967
  static nivel1-3 + #610, #3967
  static nivel1-3 + #611, #3967
  static nivel1-3 + #612, #3967
  static nivel1-3 + #613, #3967
  static nivel1-3 + #614, #3967
  static nivel1-3 + #615, #3967
  static nivel1-3 + #616, #3967
  static nivel1-3 + #617, #3967
  static nivel1-3 + #618, #3967
  static nivel1-3 + #619, #3967
  static nivel1-3 + #620, #3967
  static nivel1-3 + #621, #3967
  static nivel1-3 + #622, #3967
  static nivel1-3 + #623, #3967
  static nivel1-3 + #624, #3967
  static nivel1-3 + #625, #3967
  static nivel1-3 + #626, #3967
  static nivel1-3 + #627, #3114
  static nivel1-3 + #628, #3967
  static nivel1-3 + #629, #3967
  static nivel1-3 + #630, #3967
  static nivel1-3 + #631, #3967
  static nivel1-3 + #632, #3967
  static nivel1-3 + #633, #3967
  static nivel1-3 + #634, #3967
  static nivel1-3 + #635, #3967
  static nivel1-3 + #636, #3967
  static nivel1-3 + #637, #3967
  static nivel1-3 + #638, #3967
  static nivel1-3 + #639, #3967

  ;Linha 16
  static nivel1-3 + #640, #3967
  static nivel1-3 + #641, #3967
  static nivel1-3 + #642, #3967
  static nivel1-3 + #643, #3967
  static nivel1-3 + #644, #3967
  static nivel1-3 + #645, #3967
  static nivel1-3 + #646, #3967
  static nivel1-3 + #647, #3967
  static nivel1-3 + #648, #3967
  static nivel1-3 + #649, #3967
  static nivel1-3 + #650, #3967
  static nivel1-3 + #651, #3967
  static nivel1-3 + #652, #3967
  static nivel1-3 + #653, #3967
  static nivel1-3 + #654, #3967
  static nivel1-3 + #655, #3967
  static nivel1-3 + #656, #3967
  static nivel1-3 + #657, #3114
  static nivel1-3 + #658, #3967
  static nivel1-3 + #659, #3967
  static nivel1-3 + #660, #3967
  static nivel1-3 + #661, #3967
  static nivel1-3 + #662, #3967
  static nivel1-3 + #663, #3967
  static nivel1-3 + #664, #3967
  static nivel1-3 + #665, #3967
  static nivel1-3 + #666, #3118
  static nivel1-3 + #667, #3967
  static nivel1-3 + #668, #3967
  static nivel1-3 + #669, #3967
  static nivel1-3 + #670, #3967
  static nivel1-3 + #671, #3967
  static nivel1-3 + #672, #3967
  static nivel1-3 + #673, #3967
  static nivel1-3 + #674, #3967
  static nivel1-3 + #675, #3967
  static nivel1-3 + #676, #3967
  static nivel1-3 + #677, #3967
  static nivel1-3 + #678, #3967
  static nivel1-3 + #679, #3967

  ;Linha 17
  static nivel1-3 + #680, #3967
  static nivel1-3 + #681, #3967
  static nivel1-3 + #682, #3967
  static nivel1-3 + #683, #3967
  static nivel1-3 + #684, #3967
  static nivel1-3 + #685, #3967
  static nivel1-3 + #686, #3967
  static nivel1-3 + #687, #3967
  static nivel1-3 + #688, #3967
  static nivel1-3 + #689, #3967
  static nivel1-3 + #690, #3967
  static nivel1-3 + #691, #3967
  static nivel1-3 + #692, #3967
  static nivel1-3 + #693, #3967
  static nivel1-3 + #694, #3967
  static nivel1-3 + #695, #3967
  static nivel1-3 + #696, #3967
  static nivel1-3 + #697, #3967
  static nivel1-3 + #698, #3118
  static nivel1-3 + #699, #3967
  static nivel1-3 + #700, #3967
  static nivel1-3 + #701, #3967
  static nivel1-3 + #702, #3967
  static nivel1-3 + #703, #3967
  static nivel1-3 + #704, #3967
  static nivel1-3 + #705, #3118
  static nivel1-3 + #706, #3118
  static nivel1-3 + #707, #3967
  static nivel1-3 + #708, #3967
  static nivel1-3 + #709, #3967
  static nivel1-3 + #710, #3967
  static nivel1-3 + #711, #3967
  static nivel1-3 + #712, #3967
  static nivel1-3 + #713, #3118
  static nivel1-3 + #714, #3967
  static nivel1-3 + #715, #3967
  static nivel1-3 + #716, #3967
  static nivel1-3 + #717, #3967
  static nivel1-3 + #718, #3967
  static nivel1-3 + #719, #3967

  ;Linha 18
  static nivel1-3 + #720, #3967
  static nivel1-3 + #721, #3967
  static nivel1-3 + #722, #3967
  static nivel1-3 + #723, #3967
  static nivel1-3 + #724, #3967
  static nivel1-3 + #725, #3118
  static nivel1-3 + #726, #3967
  static nivel1-3 + #727, #3967
  static nivel1-3 + #728, #3072
  static nivel1-3 + #729, #3967
  static nivel1-3 + #730, #3967
  static nivel1-3 + #731, #3967
  static nivel1-3 + #732, #3118
  static nivel1-3 + #733, #3118
  static nivel1-3 + #734, #3967
  static nivel1-3 + #735, #3967
  static nivel1-3 + #736, #3967
  static nivel1-3 + #737, #3967
  static nivel1-3 + #738, #3967
  static nivel1-3 + #739, #3967
  static nivel1-3 + #740, #3967
  static nivel1-3 + #741, #3967
  static nivel1-3 + #742, #3967
  static nivel1-3 + #743, #3967
  static nivel1-3 + #744, #3967
  static nivel1-3 + #745, #3967
  static nivel1-3 + #746, #3967
  static nivel1-3 + #747, #3118
  static nivel1-3 + #748, #3967
  static nivel1-3 + #749, #3967
  static nivel1-3 + #750, #3967
  static nivel1-3 + #751, #3967
  static nivel1-3 + #752, #3967
  static nivel1-3 + #753, #3967
  static nivel1-3 + #754, #3967
  static nivel1-3 + #755, #3967
  static nivel1-3 + #756, #3967
  static nivel1-3 + #757, #3967
  static nivel1-3 + #758, #3967
  static nivel1-3 + #759, #3967

  ;Linha 19
  static nivel1-3 + #760, #3967
  static nivel1-3 + #761, #3967
  static nivel1-3 + #762, #3967
  static nivel1-3 + #763, #3967
  static nivel1-3 + #764, #3967
  static nivel1-3 + #765, #3967
  static nivel1-3 + #766, #3967
  static nivel1-3 + #767, #3967
  static nivel1-3 + #768, #3967
  static nivel1-3 + #769, #3967
  static nivel1-3 + #770, #3967
  static nivel1-3 + #771, #3967
  static nivel1-3 + #772, #3967
  static nivel1-3 + #773, #3967
  static nivel1-3 + #774, #3967
  static nivel1-3 + #775, #3967
  static nivel1-3 + #776, #3967
  static nivel1-3 + #777, #3967
  static nivel1-3 + #778, #3967
  static nivel1-3 + #779, #3967
  static nivel1-3 + #780, #3967
  static nivel1-3 + #781, #3967
  static nivel1-3 + #782, #3967
  static nivel1-3 + #783, #3967
  static nivel1-3 + #784, #3967
  static nivel1-3 + #785, #3967
  static nivel1-3 + #786, #3967
  static nivel1-3 + #787, #3118
  static nivel1-3 + #788, #3967
  static nivel1-3 + #789, #3114
  static nivel1-3 + #790, #3967
  static nivel1-3 + #791, #3967
  static nivel1-3 + #792, #3967
  static nivel1-3 + #793, #3967
  static nivel1-3 + #794, #3967
  static nivel1-3 + #795, #3967
  static nivel1-3 + #796, #3967
  static nivel1-3 + #797, #3114
  static nivel1-3 + #798, #3967
  static nivel1-3 + #799, #3967

  ;Linha 20
  static nivel1-3 + #800, #3967
  static nivel1-3 + #801, #3967
  static nivel1-3 + #802, #3967
  static nivel1-3 + #803, #3967
  static nivel1-3 + #804, #3967
  static nivel1-3 + #805, #3967
  static nivel1-3 + #806, #3967
  static nivel1-3 + #807, #3967
  static nivel1-3 + #808, #3118
  static nivel1-3 + #809, #3967
  static nivel1-3 + #810, #3967
  static nivel1-3 + #811, #3967
  static nivel1-3 + #812, #3967
  static nivel1-3 + #813, #3967
  static nivel1-3 + #814, #3967
  static nivel1-3 + #815, #3967
  static nivel1-3 + #816, #3967
  static nivel1-3 + #817, #3967
  static nivel1-3 + #818, #3967
  static nivel1-3 + #819, #3967
  static nivel1-3 + #820, #3967
  static nivel1-3 + #821, #3967
  static nivel1-3 + #822, #3118
  static nivel1-3 + #823, #3967
  static nivel1-3 + #824, #3967
  static nivel1-3 + #825, #3967
  static nivel1-3 + #826, #3967
  static nivel1-3 + #827, #3967
  static nivel1-3 + #828, #3967
  static nivel1-3 + #829, #3967
  static nivel1-3 + #830, #3967
  static nivel1-3 + #831, #3967
  static nivel1-3 + #832, #3967
  static nivel1-3 + #833, #3967
  static nivel1-3 + #834, #3967
  static nivel1-3 + #835, #3967
  static nivel1-3 + #836, #3967
  static nivel1-3 + #837, #3967
  static nivel1-3 + #838, #3967
  static nivel1-3 + #839, #3967

  ;Linha 21
  static nivel1-3 + #840, #3072
  static nivel1-3 + #841, #3967
  static nivel1-3 + #842, #3967
  static nivel1-3 + #843, #3967
  static nivel1-3 + #844, #3967
  static nivel1-3 + #845, #3967
  static nivel1-3 + #846, #3967
  static nivel1-3 + #847, #3967
  static nivel1-3 + #848, #3967
  static nivel1-3 + #849, #3967
  static nivel1-3 + #850, #3967
  static nivel1-3 + #851, #3967
  static nivel1-3 + #852, #3967
  static nivel1-3 + #853, #3967
  static nivel1-3 + #854, #3967
  static nivel1-3 + #855, #3967
  static nivel1-3 + #856, #3967
  static nivel1-3 + #857, #3967
  static nivel1-3 + #858, #3967
  static nivel1-3 + #859, #3967
  static nivel1-3 + #860, #3967
  static nivel1-3 + #861, #3967
  static nivel1-3 + #862, #3967
  static nivel1-3 + #863, #3967
  static nivel1-3 + #864, #3967
  static nivel1-3 + #865, #3967
  static nivel1-3 + #866, #3967
  static nivel1-3 + #867, #3967
  static nivel1-3 + #868, #3967
  static nivel1-3 + #869, #3118
  static nivel1-3 + #870, #3967
  static nivel1-3 + #871, #3967
  static nivel1-3 + #872, #3967
  static nivel1-3 + #873, #3967
  static nivel1-3 + #874, #3967
  static nivel1-3 + #875, #3967
  static nivel1-3 + #876, #3967
  static nivel1-3 + #877, #3967
  static nivel1-3 + #878, #3967
  static nivel1-3 + #879, #3967

  ;Linha 22
  static nivel1-3 + #880, #3967
  static nivel1-3 + #881, #3967
  static nivel1-3 + #882, #3967
  static nivel1-3 + #883, #3967
  static nivel1-3 + #884, #3967
  static nivel1-3 + #885, #3967
  static nivel1-3 + #886, #3967
  static nivel1-3 + #887, #3967
  static nivel1-3 + #888, #3967
  static nivel1-3 + #889, #3967
  static nivel1-3 + #890, #3967
  static nivel1-3 + #891, #3967
  static nivel1-3 + #892, #3118
  static nivel1-3 + #893, #3967
  static nivel1-3 + #894, #3967
  static nivel1-3 + #895, #3967
  static nivel1-3 + #896, #3967
  static nivel1-3 + #897, #3114
  static nivel1-3 + #898, #3967
  static nivel1-3 + #899, #3967
  static nivel1-3 + #900, #3967
  static nivel1-3 + #901, #3967
  static nivel1-3 + #902, #3967
  static nivel1-3 + #903, #3967
  static nivel1-3 + #904, #3967
  static nivel1-3 + #905, #3967
  static nivel1-3 + #906, #3967
  static nivel1-3 + #907, #3967
  static nivel1-3 + #908, #3967
  static nivel1-3 + #909, #3967
  static nivel1-3 + #910, #3967
  static nivel1-3 + #911, #3967
  static nivel1-3 + #912, #3967
  static nivel1-3 + #913, #3967
  static nivel1-3 + #914, #3967
  static nivel1-3 + #915, #3967
  static nivel1-3 + #916, #3967
  static nivel1-3 + #917, #3967
  static nivel1-3 + #918, #3967
  static nivel1-3 + #919, #3967

  ;Linha 23
  static nivel1-3 + #920, #3967
  static nivel1-3 + #921, #3967
  static nivel1-3 + #922, #3967
  static nivel1-3 + #923, #3967
  static nivel1-3 + #924, #3967
  static nivel1-3 + #925, #3967
  static nivel1-3 + #926, #3967
  static nivel1-3 + #927, #3967
  static nivel1-3 + #928, #3967
  static nivel1-3 + #929, #3967
  static nivel1-3 + #930, #3967
  static nivel1-3 + #931, #3967
  static nivel1-3 + #932, #3967
  static nivel1-3 + #933, #3967
  static nivel1-3 + #934, #3967
  static nivel1-3 + #935, #3967
  static nivel1-3 + #936, #3967
  static nivel1-3 + #937, #3967
  static nivel1-3 + #938, #3967
  static nivel1-3 + #939, #3967
  static nivel1-3 + #940, #3967
  static nivel1-3 + #941, #3967
  static nivel1-3 + #942, #3967
  static nivel1-3 + #943, #3967
  static nivel1-3 + #944, #3967
  static nivel1-3 + #945, #3967
  static nivel1-3 + #946, #3967
  static nivel1-3 + #947, #3967
  static nivel1-3 + #948, #3967
  static nivel1-3 + #949, #3967
  static nivel1-3 + #950, #3967
  static nivel1-3 + #951, #3967
  static nivel1-3 + #952, #3967
  static nivel1-3 + #953, #3967
  static nivel1-3 + #954, #3967
  static nivel1-3 + #955, #3967
  static nivel1-3 + #956, #3967
  static nivel1-3 + #957, #3967
  static nivel1-3 + #958, #3967
  static nivel1-3 + #959, #3967

  ;Linha 24
  static nivel1-3 + #960, #3967
  static nivel1-3 + #961, #3967
  static nivel1-3 + #962, #3967
  static nivel1-3 + #963, #3967
  static nivel1-3 + #964, #3967
  static nivel1-3 + #965, #3967
  static nivel1-3 + #966, #3967
  static nivel1-3 + #967, #3967
  static nivel1-3 + #968, #3967
  static nivel1-3 + #969, #3967
  static nivel1-3 + #970, #3967
  static nivel1-3 + #971, #3967
  static nivel1-3 + #972, #3967
  static nivel1-3 + #973, #3967
  static nivel1-3 + #974, #3967
  static nivel1-3 + #975, #3967
  static nivel1-3 + #976, #3967
  static nivel1-3 + #977, #3967
  static nivel1-3 + #978, #3967
  static nivel1-3 + #979, #3967
  static nivel1-3 + #980, #3967
  static nivel1-3 + #981, #3967
  static nivel1-3 + #982, #3967
  static nivel1-3 + #983, #3967
  static nivel1-3 + #984, #3967
  static nivel1-3 + #985, #3967
  static nivel1-3 + #986, #3967
  static nivel1-3 + #987, #3967
  static nivel1-3 + #988, #3967
  static nivel1-3 + #989, #3967
  static nivel1-3 + #990, #3967
  static nivel1-3 + #991, #3967
  static nivel1-3 + #992, #3967
  static nivel1-3 + #993, #3967
  static nivel1-3 + #994, #3967
  static nivel1-3 + #995, #3072
  static nivel1-3 + #996, #3967
  static nivel1-3 + #997, #3967
  static nivel1-3 + #998, #3967
  static nivel1-3 + #999, #3967

  ;Linha 25
  static nivel1-3 + #1000, #3967
  static nivel1-3 + #1001, #3967
  static nivel1-3 + #1002, #3967
  static nivel1-3 + #1003, #3967
  static nivel1-3 + #1004, #3967
  static nivel1-3 + #1005, #3967
  static nivel1-3 + #1006, #3967
  static nivel1-3 + #1007, #3967
  static nivel1-3 + #1008, #3967
  static nivel1-3 + #1009, #3967
  static nivel1-3 + #1010, #3967
  static nivel1-3 + #1011, #3967
  static nivel1-3 + #1012, #3967
  static nivel1-3 + #1013, #3967
  static nivel1-3 + #1014, #3967
  static nivel1-3 + #1015, #3967
  static nivel1-3 + #1016, #3967
  static nivel1-3 + #1017, #3967
  static nivel1-3 + #1018, #3967
  static nivel1-3 + #1019, #3967
  static nivel1-3 + #1020, #3967
  static nivel1-3 + #1021, #3967
  static nivel1-3 + #1022, #3967
  static nivel1-3 + #1023, #3967
  static nivel1-3 + #1024, #3967
  static nivel1-3 + #1025, #3967
  static nivel1-3 + #1026, #3967
  static nivel1-3 + #1027, #3967
  static nivel1-3 + #1028, #3967
  static nivel1-3 + #1029, #3967
  static nivel1-3 + #1030, #3967
  static nivel1-3 + #1031, #3967
  static nivel1-3 + #1032, #3967
  static nivel1-3 + #1033, #3967
  static nivel1-3 + #1034, #3967
  static nivel1-3 + #1035, #3967
  static nivel1-3 + #1036, #3967
  static nivel1-3 + #1037, #3967
  static nivel1-3 + #1038, #3967
  static nivel1-3 + #1039, #3967

  ;Linha 26
  static nivel1-3 + #1040, #3967
  static nivel1-3 + #1041, #3967
  static nivel1-3 + #1042, #3967
  static nivel1-3 + #1043, #3967
  static nivel1-3 + #1044, #3967
  static nivel1-3 + #1045, #3967
  static nivel1-3 + #1046, #3967
  static nivel1-3 + #1047, #3967
  static nivel1-3 + #1048, #3967
  static nivel1-3 + #1049, #3967
  static nivel1-3 + #1050, #3967
  static nivel1-3 + #1051, #3967
  static nivel1-3 + #1052, #3967
  static nivel1-3 + #1053, #3967
  static nivel1-3 + #1054, #3967
  static nivel1-3 + #1055, #3967
  static nivel1-3 + #1056, #3967
  static nivel1-3 + #1057, #3967
  static nivel1-3 + #1058, #3967
  static nivel1-3 + #1059, #3967
  static nivel1-3 + #1060, #3967
  static nivel1-3 + #1061, #3967
  static nivel1-3 + #1062, #3967
  static nivel1-3 + #1063, #3967
  static nivel1-3 + #1064, #3967
  static nivel1-3 + #1065, #3967
  static nivel1-3 + #1066, #3967
  static nivel1-3 + #1067, #3967
  static nivel1-3 + #1068, #3967
  static nivel1-3 + #1069, #3967
  static nivel1-3 + #1070, #3967
  static nivel1-3 + #1071, #3967
  static nivel1-3 + #1072, #3967
  static nivel1-3 + #1073, #3967
  static nivel1-3 + #1074, #3118
  static nivel1-3 + #1075, #3967
  static nivel1-3 + #1076, #3967
  static nivel1-3 + #1077, #3967
  static nivel1-3 + #1078, #3967
  static nivel1-3 + #1079, #3967

  ;Linha 27
  static nivel1-3 + #1080, #3967
  static nivel1-3 + #1081, #3967
  static nivel1-3 + #1082, #3967
  static nivel1-3 + #1083, #3967
  static nivel1-3 + #1084, #3967
  static nivel1-3 + #1085, #3967
  static nivel1-3 + #1086, #3967
  static nivel1-3 + #1087, #3967
  static nivel1-3 + #1088, #3967
  static nivel1-3 + #1089, #3967
  static nivel1-3 + #1090, #3967
  static nivel1-3 + #1091, #3967
  static nivel1-3 + #1092, #3967
  static nivel1-3 + #1093, #3967
  static nivel1-3 + #1094, #3967
  static nivel1-3 + #1095, #3967
  static nivel1-3 + #1096, #3967
  static nivel1-3 + #1097, #3967
  static nivel1-3 + #1098, #3967
  static nivel1-3 + #1099, #3967
  static nivel1-3 + #1100, #3967
  static nivel1-3 + #1101, #3967
  static nivel1-3 + #1102, #3967
  static nivel1-3 + #1103, #3967
  static nivel1-3 + #1104, #3967
  static nivel1-3 + #1105, #3967
  static nivel1-3 + #1106, #3967
  static nivel1-3 + #1107, #3967
  static nivel1-3 + #1108, #3967
  static nivel1-3 + #1109, #3967
  static nivel1-3 + #1110, #3967
  static nivel1-3 + #1111, #3967
  static nivel1-3 + #1112, #3967
  static nivel1-3 + #1113, #3967
  static nivel1-3 + #1114, #3967
  static nivel1-3 + #1115, #3967
  static nivel1-3 + #1116, #3967
  static nivel1-3 + #1117, #3967
  static nivel1-3 + #1118, #3967
  static nivel1-3 + #1119, #3967

  ;Linha 28
  static nivel1-3 + #1120, #3967
  static nivel1-3 + #1121, #3967
  static nivel1-3 + #1122, #3967
  static nivel1-3 + #1123, #3967
  static nivel1-3 + #1124, #3967
  static nivel1-3 + #1125, #3967
  static nivel1-3 + #1126, #3967
  static nivel1-3 + #1127, #3967
  static nivel1-3 + #1128, #3967
  static nivel1-3 + #1129, #3967
  static nivel1-3 + #1130, #3967
  static nivel1-3 + #1131, #3967
  static nivel1-3 + #1132, #3967
  static nivel1-3 + #1133, #3967
  static nivel1-3 + #1134, #3967
  static nivel1-3 + #1135, #3967
  static nivel1-3 + #1136, #3967
  static nivel1-3 + #1137, #3967
  static nivel1-3 + #1138, #3967
  static nivel1-3 + #1139, #3967
  static nivel1-3 + #1140, #3967
  static nivel1-3 + #1141, #3967
  static nivel1-3 + #1142, #3967
  static nivel1-3 + #1143, #3967
  static nivel1-3 + #1144, #3967
  static nivel1-3 + #1145, #3967
  static nivel1-3 + #1146, #3967
  static nivel1-3 + #1147, #3967
  static nivel1-3 + #1148, #3967
  static nivel1-3 + #1149, #3967
  static nivel1-3 + #1150, #3967
  static nivel1-3 + #1151, #3967
  static nivel1-3 + #1152, #3967
  static nivel1-3 + #1153, #3967
  static nivel1-3 + #1154, #3967
  static nivel1-3 + #1155, #3967
  static nivel1-3 + #1156, #3967
  static nivel1-3 + #1157, #3967
  static nivel1-3 + #1158, #3967
  static nivel1-3 + #1159, #3967

  ;Linha 29
  static nivel1-3 + #1160, #3967
  static nivel1-3 + #1161, #3967
  static nivel1-3 + #1162, #3967
  static nivel1-3 + #1163, #3967
  static nivel1-3 + #1164, #3967
  static nivel1-3 + #1165, #3967
  static nivel1-3 + #1166, #3967
  static nivel1-3 + #1167, #3967
  static nivel1-3 + #1168, #3967
  static nivel1-3 + #1169, #3967
  static nivel1-3 + #1170, #3967
  static nivel1-3 + #1171, #3967
  static nivel1-3 + #1172, #3967
  static nivel1-3 + #1173, #3967
  static nivel1-3 + #1174, #3967
  static nivel1-3 + #1175, #3967
  static nivel1-3 + #1176, #3967
  static nivel1-3 + #1177, #3967
  static nivel1-3 + #1178, #3967
  static nivel1-3 + #1179, #3967
  static nivel1-3 + #1180, #3967
  static nivel1-3 + #1181, #3967
  static nivel1-3 + #1182, #3967
  static nivel1-3 + #1183, #3967
  static nivel1-3 + #1184, #3967
  static nivel1-3 + #1185, #3967
  static nivel1-3 + #1186, #3967
  static nivel1-3 + #1187, #3967
  static nivel1-3 + #1188, #3967
  static nivel1-3 + #1189, #3967
  static nivel1-3 + #1190, #3967
  static nivel1-3 + #1191, #3967
  static nivel1-3 + #1192, #3967
  static nivel1-3 + #1193, #3967
  static nivel1-3 + #1194, #3967
  static nivel1-3 + #1195, #3967
  static nivel1-3 + #1196, #3967
  static nivel1-3 + #1197, #3967
  static nivel1-3 + #1198, #3967
  static nivel1-3 + #1199, #3967





nivel4-6 : var #1200
  ;Linha 0
  static nivel4-6 + #0, #127
  static nivel4-6 + #1, #127
  static nivel4-6 + #2, #127
  static nivel4-6 + #3, #127
  static nivel4-6 + #4, #127
  static nivel4-6 + #5, #127
  static nivel4-6 + #6, #127
  static nivel4-6 + #7, #127
  static nivel4-6 + #8, #127
  static nivel4-6 + #9, #127
  static nivel4-6 + #10, #127
  static nivel4-6 + #11, #127
  static nivel4-6 + #12, #127
  static nivel4-6 + #13, #127
  static nivel4-6 + #14, #127
  static nivel4-6 + #15, #127
  static nivel4-6 + #16, #558
  static nivel4-6 + #17, #127
  static nivel4-6 + #18, #127
  static nivel4-6 + #19, #127
  static nivel4-6 + #20, #127
  static nivel4-6 + #21, #127
  static nivel4-6 + #22, #127
  static nivel4-6 + #23, #127
  static nivel4-6 + #24, #127
  static nivel4-6 + #25, #127
  static nivel4-6 + #26, #127
  static nivel4-6 + #27, #127
  static nivel4-6 + #28, #127
  static nivel4-6 + #29, #127
  static nivel4-6 + #30, #127
  static nivel4-6 + #31, #127
  static nivel4-6 + #32, #127
  static nivel4-6 + #33, #127
  static nivel4-6 + #34, #127
  static nivel4-6 + #35, #127
  static nivel4-6 + #36, #127
  static nivel4-6 + #37, #127
  static nivel4-6 + #38, #127
  static nivel4-6 + #39, #127

  ;Linha 1
  static nivel4-6 + #40, #127
  static nivel4-6 + #41, #127
  static nivel4-6 + #42, #573
  static nivel4-6 + #43, #514
  static nivel4-6 + #44, #514
  static nivel4-6 + #45, #514
  static nivel4-6 + #46, #514
  static nivel4-6 + #47, #514
  static nivel4-6 + #48, #514
  static nivel4-6 + #49, #514
  static nivel4-6 + #50, #573
  static nivel4-6 + #51, #127
  static nivel4-6 + #52, #127
  static nivel4-6 + #53, #127
  static nivel4-6 + #54, #3967
  static nivel4-6 + #55, #127
  static nivel4-6 + #56, #127
  static nivel4-6 + #57, #127
  static nivel4-6 + #58, #127
  static nivel4-6 + #59, #127
  static nivel4-6 + #60, #127
  static nivel4-6 + #61, #127
  static nivel4-6 + #62, #127
  static nivel4-6 + #63, #127
  static nivel4-6 + #64, #127
  static nivel4-6 + #65, #127
  static nivel4-6 + #66, #127
  static nivel4-6 + #67, #127
  static nivel4-6 + #68, #558
  static nivel4-6 + #69, #127
  static nivel4-6 + #70, #127
  static nivel4-6 + #71, #127
  static nivel4-6 + #72, #127
  static nivel4-6 + #73, #127
  static nivel4-6 + #74, #558
  static nivel4-6 + #75, #127
  static nivel4-6 + #76, #127
  static nivel4-6 + #77, #127
  static nivel4-6 + #78, #558
  static nivel4-6 + #79, #127

  ;Linha 2
  static nivel4-6 + #80, #127
  static nivel4-6 + #81, #127
  static nivel4-6 + #82, #127
  static nivel4-6 + #83, #127
  static nivel4-6 + #84, #127
  static nivel4-6 + #85, #127
  static nivel4-6 + #86, #127
  static nivel4-6 + #87, #127
  static nivel4-6 + #88, #127
  static nivel4-6 + #89, #127
  static nivel4-6 + #90, #127
  static nivel4-6 + #91, #127
  static nivel4-6 + #92, #127
  static nivel4-6 + #93, #552
  static nivel4-6 + #94, #553
  static nivel4-6 + #95, #127
  static nivel4-6 + #96, #127
  static nivel4-6 + #97, #558
  static nivel4-6 + #98, #127
  static nivel4-6 + #99, #127
  static nivel4-6 + #100, #127
  static nivel4-6 + #101, #127
  static nivel4-6 + #102, #558
  static nivel4-6 + #103, #127
  static nivel4-6 + #104, #558
  static nivel4-6 + #105, #127
  static nivel4-6 + #106, #558
  static nivel4-6 + #107, #558
  static nivel4-6 + #108, #127
  static nivel4-6 + #109, #127
  static nivel4-6 + #110, #512
  static nivel4-6 + #111, #512
  static nivel4-6 + #112, #127
  static nivel4-6 + #113, #558
  static nivel4-6 + #114, #127
  static nivel4-6 + #115, #127
  static nivel4-6 + #116, #127
  static nivel4-6 + #117, #127
  static nivel4-6 + #118, #127
  static nivel4-6 + #119, #127

  ;Linha 3
  static nivel4-6 + #120, #127
  static nivel4-6 + #121, #127
  static nivel4-6 + #122, #127
  static nivel4-6 + #123, #127
  static nivel4-6 + #124, #127
  static nivel4-6 + #125, #127
  static nivel4-6 + #126, #127
  static nivel4-6 + #127, #558
  static nivel4-6 + #128, #127
  static nivel4-6 + #129, #127
  static nivel4-6 + #130, #558
  static nivel4-6 + #131, #127
  static nivel4-6 + #132, #127
  static nivel4-6 + #133, #127
  static nivel4-6 + #134, #558
  static nivel4-6 + #135, #558
  static nivel4-6 + #136, #127
  static nivel4-6 + #137, #127
  static nivel4-6 + #138, #127
  static nivel4-6 + #139, #127
  static nivel4-6 + #140, #127
  static nivel4-6 + #141, #3967
  static nivel4-6 + #142, #3967
  static nivel4-6 + #143, #558
  static nivel4-6 + #144, #3967
  static nivel4-6 + #145, #3967
  static nivel4-6 + #146, #3967
  static nivel4-6 + #147, #127
  static nivel4-6 + #148, #127
  static nivel4-6 + #149, #127
  static nivel4-6 + #150, #512
  static nivel4-6 + #151, #512
  static nivel4-6 + #152, #127
  static nivel4-6 + #153, #127
  static nivel4-6 + #154, #127
  static nivel4-6 + #155, #127
  static nivel4-6 + #156, #570
  static nivel4-6 + #157, #127
  static nivel4-6 + #158, #127
  static nivel4-6 + #159, #127

  ;Linha 4
  static nivel4-6 + #160, #127
  static nivel4-6 + #161, #127
  static nivel4-6 + #162, #558
  static nivel4-6 + #163, #127
  static nivel4-6 + #164, #127
  static nivel4-6 + #165, #127
  static nivel4-6 + #166, #127
  static nivel4-6 + #167, #127
  static nivel4-6 + #168, #127
  static nivel4-6 + #169, #127
  static nivel4-6 + #170, #127
  static nivel4-6 + #171, #127
  static nivel4-6 + #172, #127
  static nivel4-6 + #173, #127
  static nivel4-6 + #174, #127
  static nivel4-6 + #175, #127
  static nivel4-6 + #176, #127
  static nivel4-6 + #177, #127
  static nivel4-6 + #178, #127
  static nivel4-6 + #179, #558
  static nivel4-6 + #180, #127
  static nivel4-6 + #181, #127
  static nivel4-6 + #182, #3967
  static nivel4-6 + #183, #3967
  static nivel4-6 + #184, #3967
  static nivel4-6 + #185, #3967
  static nivel4-6 + #186, #3967
  static nivel4-6 + #187, #3967
  static nivel4-6 + #188, #3967
  static nivel4-6 + #189, #127
  static nivel4-6 + #190, #127
  static nivel4-6 + #191, #558
  static nivel4-6 + #192, #127
  static nivel4-6 + #193, #127
  static nivel4-6 + #194, #127
  static nivel4-6 + #195, #127
  static nivel4-6 + #196, #127
  static nivel4-6 + #197, #127
  static nivel4-6 + #198, #127
  static nivel4-6 + #199, #127

  ;Linha 5
  static nivel4-6 + #200, #127
  static nivel4-6 + #201, #127
  static nivel4-6 + #202, #127
  static nivel4-6 + #203, #127
  static nivel4-6 + #204, #127
  static nivel4-6 + #205, #558
  static nivel4-6 + #206, #127
  static nivel4-6 + #207, #127
  static nivel4-6 + #208, #558
  static nivel4-6 + #209, #127
  static nivel4-6 + #210, #558
  static nivel4-6 + #211, #127
  static nivel4-6 + #212, #127
  static nivel4-6 + #213, #127
  static nivel4-6 + #214, #127
  static nivel4-6 + #215, #127
  static nivel4-6 + #216, #558
  static nivel4-6 + #217, #127
  static nivel4-6 + #218, #127
  static nivel4-6 + #219, #127
  static nivel4-6 + #220, #127
  static nivel4-6 + #221, #127
  static nivel4-6 + #222, #127
  static nivel4-6 + #223, #127
  static nivel4-6 + #224, #127
  static nivel4-6 + #225, #127
  static nivel4-6 + #226, #127
  static nivel4-6 + #227, #127
  static nivel4-6 + #228, #558
  static nivel4-6 + #229, #3967
  static nivel4-6 + #230, #3967
  static nivel4-6 + #231, #127
  static nivel4-6 + #232, #127
  static nivel4-6 + #233, #127
  static nivel4-6 + #234, #127
  static nivel4-6 + #235, #127
  static nivel4-6 + #236, #573
  static nivel4-6 + #237, #127
  static nivel4-6 + #238, #127
  static nivel4-6 + #239, #127

  ;Linha 6
  static nivel4-6 + #240, #127
  static nivel4-6 + #241, #127
  static nivel4-6 + #242, #127
  static nivel4-6 + #243, #127
  static nivel4-6 + #244, #127
  static nivel4-6 + #245, #127
  static nivel4-6 + #246, #127
  static nivel4-6 + #247, #127
  static nivel4-6 + #248, #127
  static nivel4-6 + #249, #127
  static nivel4-6 + #250, #127
  static nivel4-6 + #251, #127
  static nivel4-6 + #252, #558
  static nivel4-6 + #253, #127
  static nivel4-6 + #254, #127
  static nivel4-6 + #255, #127
  static nivel4-6 + #256, #127
  static nivel4-6 + #257, #558
  static nivel4-6 + #258, #127
  static nivel4-6 + #259, #127
  static nivel4-6 + #260, #127
  static nivel4-6 + #261, #127
  static nivel4-6 + #262, #558
  static nivel4-6 + #263, #127
  static nivel4-6 + #264, #127
  static nivel4-6 + #265, #558
  static nivel4-6 + #266, #3967
  static nivel4-6 + #267, #3967
  static nivel4-6 + #268, #3967
  static nivel4-6 + #269, #558
  static nivel4-6 + #270, #3967
  static nivel4-6 + #271, #127
  static nivel4-6 + #272, #127
  static nivel4-6 + #273, #127
  static nivel4-6 + #274, #127
  static nivel4-6 + #275, #127
  static nivel4-6 + #276, #514
  static nivel4-6 + #277, #127
  static nivel4-6 + #278, #127
  static nivel4-6 + #279, #127

  ;Linha 7
  static nivel4-6 + #280, #127
  static nivel4-6 + #281, #127
  static nivel4-6 + #282, #558
  static nivel4-6 + #283, #127
  static nivel4-6 + #284, #558
  static nivel4-6 + #285, #127
  static nivel4-6 + #286, #127
  static nivel4-6 + #287, #127
  static nivel4-6 + #288, #127
  static nivel4-6 + #289, #127
  static nivel4-6 + #290, #127
  static nivel4-6 + #291, #127
  static nivel4-6 + #292, #127
  static nivel4-6 + #293, #127
  static nivel4-6 + #294, #127
  static nivel4-6 + #295, #127
  static nivel4-6 + #296, #127
  static nivel4-6 + #297, #127
  static nivel4-6 + #298, #127
  static nivel4-6 + #299, #558
  static nivel4-6 + #300, #127
  static nivel4-6 + #301, #127
  static nivel4-6 + #302, #3967
  static nivel4-6 + #303, #3967
  static nivel4-6 + #304, #3967
  static nivel4-6 + #305, #558
  static nivel4-6 + #306, #3967
  static nivel4-6 + #307, #127
  static nivel4-6 + #308, #127
  static nivel4-6 + #309, #127
  static nivel4-6 + #310, #127
  static nivel4-6 + #311, #127
  static nivel4-6 + #312, #127
  static nivel4-6 + #313, #558
  static nivel4-6 + #314, #127
  static nivel4-6 + #315, #127
  static nivel4-6 + #316, #514
  static nivel4-6 + #317, #127
  static nivel4-6 + #318, #127
  static nivel4-6 + #319, #127

  ;Linha 8
  static nivel4-6 + #320, #127
  static nivel4-6 + #321, #127
  static nivel4-6 + #322, #127
  static nivel4-6 + #323, #127
  static nivel4-6 + #324, #570
  static nivel4-6 + #325, #127
  static nivel4-6 + #326, #127
  static nivel4-6 + #327, #570
  static nivel4-6 + #328, #127
  static nivel4-6 + #329, #127
  static nivel4-6 + #330, #558
  static nivel4-6 + #331, #127
  static nivel4-6 + #332, #127
  static nivel4-6 + #333, #127
  static nivel4-6 + #334, #558
  static nivel4-6 + #335, #127
  static nivel4-6 + #336, #127
  static nivel4-6 + #337, #127
  static nivel4-6 + #338, #127
  static nivel4-6 + #339, #127
  static nivel4-6 + #340, #127
  static nivel4-6 + #341, #558
  static nivel4-6 + #342, #127
  static nivel4-6 + #343, #127
  static nivel4-6 + #344, #127
  static nivel4-6 + #345, #127
  static nivel4-6 + #346, #127
  static nivel4-6 + #347, #127
  static nivel4-6 + #348, #127
  static nivel4-6 + #349, #127
  static nivel4-6 + #350, #127
  static nivel4-6 + #351, #127
  static nivel4-6 + #352, #570
  static nivel4-6 + #353, #127
  static nivel4-6 + #354, #127
  static nivel4-6 + #355, #127
  static nivel4-6 + #356, #514
  static nivel4-6 + #357, #127
  static nivel4-6 + #358, #127
  static nivel4-6 + #359, #127

  ;Linha 9
  static nivel4-6 + #360, #127
  static nivel4-6 + #361, #127
  static nivel4-6 + #362, #127
  static nivel4-6 + #363, #127
  static nivel4-6 + #364, #127
  static nivel4-6 + #365, #127
  static nivel4-6 + #366, #127
  static nivel4-6 + #367, #127
  static nivel4-6 + #368, #127
  static nivel4-6 + #369, #127
  static nivel4-6 + #370, #127
  static nivel4-6 + #371, #127
  static nivel4-6 + #372, #127
  static nivel4-6 + #373, #127
  static nivel4-6 + #374, #570
  static nivel4-6 + #375, #558
  static nivel4-6 + #376, #127
  static nivel4-6 + #377, #127
  static nivel4-6 + #378, #127
  static nivel4-6 + #379, #127
  static nivel4-6 + #380, #127
  static nivel4-6 + #381, #127
  static nivel4-6 + #382, #127
  static nivel4-6 + #383, #127
  static nivel4-6 + #384, #127
  static nivel4-6 + #385, #127
  static nivel4-6 + #386, #127
  static nivel4-6 + #387, #127
  static nivel4-6 + #388, #127
  static nivel4-6 + #389, #127
  static nivel4-6 + #390, #127
  static nivel4-6 + #391, #127
  static nivel4-6 + #392, #127
  static nivel4-6 + #393, #127
  static nivel4-6 + #394, #127
  static nivel4-6 + #395, #127
  static nivel4-6 + #396, #514
  static nivel4-6 + #397, #127
  static nivel4-6 + #398, #127
  static nivel4-6 + #399, #127

  ;Linha 10
  static nivel4-6 + #400, #127
  static nivel4-6 + #401, #127
  static nivel4-6 + #402, #127
  static nivel4-6 + #403, #127
  static nivel4-6 + #404, #514
  static nivel4-6 + #405, #127
  static nivel4-6 + #406, #127
  static nivel4-6 + #407, #127
  static nivel4-6 + #408, #127
  static nivel4-6 + #409, #127
  static nivel4-6 + #410, #127
  static nivel4-6 + #411, #127
  static nivel4-6 + #412, #570
  static nivel4-6 + #413, #127
  static nivel4-6 + #414, #127
  static nivel4-6 + #415, #127
  static nivel4-6 + #416, #127
  static nivel4-6 + #417, #127
  static nivel4-6 + #418, #127
  static nivel4-6 + #419, #127
  static nivel4-6 + #420, #127
  static nivel4-6 + #421, #127
  static nivel4-6 + #422, #127
  static nivel4-6 + #423, #127
  static nivel4-6 + #424, #558
  static nivel4-6 + #425, #127
  static nivel4-6 + #426, #127
  static nivel4-6 + #427, #127
  static nivel4-6 + #428, #127
  static nivel4-6 + #429, #558
  static nivel4-6 + #430, #127
  static nivel4-6 + #431, #127
  static nivel4-6 + #432, #127
  static nivel4-6 + #433, #127
  static nivel4-6 + #434, #127
  static nivel4-6 + #435, #558
  static nivel4-6 + #436, #514
  static nivel4-6 + #437, #127
  static nivel4-6 + #438, #127
  static nivel4-6 + #439, #127

  ;Linha 11
  static nivel4-6 + #440, #127
  static nivel4-6 + #441, #127
  static nivel4-6 + #442, #127
  static nivel4-6 + #443, #127
  static nivel4-6 + #444, #514
  static nivel4-6 + #445, #514
  static nivel4-6 + #446, #127
  static nivel4-6 + #447, #127
  static nivel4-6 + #448, #127
  static nivel4-6 + #449, #127
  static nivel4-6 + #450, #127
  static nivel4-6 + #451, #127
  static nivel4-6 + #452, #127
  static nivel4-6 + #453, #127
  static nivel4-6 + #454, #127
  static nivel4-6 + #455, #127
  static nivel4-6 + #456, #127
  static nivel4-6 + #457, #127
  static nivel4-6 + #458, #558
  static nivel4-6 + #459, #127
  static nivel4-6 + #460, #127
  static nivel4-6 + #461, #127
  static nivel4-6 + #462, #127
  static nivel4-6 + #463, #127
  static nivel4-6 + #464, #127
  static nivel4-6 + #465, #127
  static nivel4-6 + #466, #127
  static nivel4-6 + #467, #127
  static nivel4-6 + #468, #127
  static nivel4-6 + #469, #127
  static nivel4-6 + #470, #127
  static nivel4-6 + #471, #127
  static nivel4-6 + #472, #558
  static nivel4-6 + #473, #127
  static nivel4-6 + #474, #127
  static nivel4-6 + #475, #127
  static nivel4-6 + #476, #127
  static nivel4-6 + #477, #127
  static nivel4-6 + #478, #127
  static nivel4-6 + #479, #127

  ;Linha 12
  static nivel4-6 + #480, #127
  static nivel4-6 + #481, #127
  static nivel4-6 + #482, #127
  static nivel4-6 + #483, #127
  static nivel4-6 + #484, #514
  static nivel4-6 + #485, #127
  static nivel4-6 + #486, #127
  static nivel4-6 + #487, #127
  static nivel4-6 + #488, #127
  static nivel4-6 + #489, #127
  static nivel4-6 + #490, #127
  static nivel4-6 + #491, #127
  static nivel4-6 + #492, #127
  static nivel4-6 + #493, #558
  static nivel4-6 + #494, #127
  static nivel4-6 + #495, #127
  static nivel4-6 + #496, #127
  static nivel4-6 + #497, #127
  static nivel4-6 + #498, #127
  static nivel4-6 + #499, #127
  static nivel4-6 + #500, #127
  static nivel4-6 + #501, #127
  static nivel4-6 + #502, #127
  static nivel4-6 + #503, #127
  static nivel4-6 + #504, #127
  static nivel4-6 + #505, #127
  static nivel4-6 + #506, #127
  static nivel4-6 + #507, #127
  static nivel4-6 + #508, #127
  static nivel4-6 + #509, #558
  static nivel4-6 + #510, #127
  static nivel4-6 + #511, #127
  static nivel4-6 + #512, #127
  static nivel4-6 + #513, #127
  static nivel4-6 + #514, #127
  static nivel4-6 + #515, #127
  static nivel4-6 + #516, #127
  static nivel4-6 + #517, #127
  static nivel4-6 + #518, #127
  static nivel4-6 + #519, #127

  ;Linha 13
  static nivel4-6 + #520, #127
  static nivel4-6 + #521, #127
  static nivel4-6 + #522, #127
  static nivel4-6 + #523, #127
  static nivel4-6 + #524, #127
  static nivel4-6 + #525, #127
  static nivel4-6 + #526, #127
  static nivel4-6 + #527, #570
  static nivel4-6 + #528, #127
  static nivel4-6 + #529, #558
  static nivel4-6 + #530, #127
  static nivel4-6 + #531, #127
  static nivel4-6 + #532, #127
  static nivel4-6 + #533, #127
  static nivel4-6 + #534, #127
  static nivel4-6 + #535, #127
  static nivel4-6 + #536, #127
  static nivel4-6 + #537, #127
  static nivel4-6 + #538, #127
  static nivel4-6 + #539, #127
  static nivel4-6 + #540, #127
  static nivel4-6 + #541, #127
  static nivel4-6 + #542, #127
  static nivel4-6 + #543, #127
  static nivel4-6 + #544, #127
  static nivel4-6 + #545, #127
  static nivel4-6 + #546, #127
  static nivel4-6 + #547, #127
  static nivel4-6 + #548, #127
  static nivel4-6 + #549, #127
  static nivel4-6 + #550, #127
  static nivel4-6 + #551, #127
  static nivel4-6 + #552, #127
  static nivel4-6 + #553, #127
  static nivel4-6 + #554, #127
  static nivel4-6 + #555, #127
  static nivel4-6 + #556, #127
  static nivel4-6 + #557, #127
  static nivel4-6 + #558, #127
  static nivel4-6 + #559, #127

  ;Linha 14
  static nivel4-6 + #560, #127
  static nivel4-6 + #561, #127
  static nivel4-6 + #562, #512
  static nivel4-6 + #563, #127
  static nivel4-6 + #564, #127
  static nivel4-6 + #565, #127
  static nivel4-6 + #566, #127
  static nivel4-6 + #567, #127
  static nivel4-6 + #568, #127
  static nivel4-6 + #569, #127
  static nivel4-6 + #570, #127
  static nivel4-6 + #571, #127
  static nivel4-6 + #572, #127
  static nivel4-6 + #573, #512
  static nivel4-6 + #574, #127
  static nivel4-6 + #575, #127
  static nivel4-6 + #576, #127
  static nivel4-6 + #577, #127
  static nivel4-6 + #578, #127
  static nivel4-6 + #579, #127
  static nivel4-6 + #580, #512
  static nivel4-6 + #581, #127
  static nivel4-6 + #582, #127
  static nivel4-6 + #583, #558
  static nivel4-6 + #584, #127
  static nivel4-6 + #585, #127
  static nivel4-6 + #586, #127
  static nivel4-6 + #587, #127
  static nivel4-6 + #588, #127
  static nivel4-6 + #589, #127
  static nivel4-6 + #590, #127
  static nivel4-6 + #591, #127
  static nivel4-6 + #592, #127
  static nivel4-6 + #593, #127
  static nivel4-6 + #594, #127
  static nivel4-6 + #595, #127
  static nivel4-6 + #596, #127
  static nivel4-6 + #597, #127
  static nivel4-6 + #598, #127
  static nivel4-6 + #599, #127

  ;Linha 15
  static nivel4-6 + #600, #127
  static nivel4-6 + #601, #127
  static nivel4-6 + #602, #127
  static nivel4-6 + #603, #127
  static nivel4-6 + #604, #127
  static nivel4-6 + #605, #127
  static nivel4-6 + #606, #127
  static nivel4-6 + #607, #127
  static nivel4-6 + #608, #127
  static nivel4-6 + #609, #127
  static nivel4-6 + #610, #127
  static nivel4-6 + #611, #127
  static nivel4-6 + #612, #127
  static nivel4-6 + #613, #127
  static nivel4-6 + #614, #127
  static nivel4-6 + #615, #127
  static nivel4-6 + #616, #127
  static nivel4-6 + #617, #127
  static nivel4-6 + #618, #127
  static nivel4-6 + #619, #127
  static nivel4-6 + #620, #127
  static nivel4-6 + #621, #127
  static nivel4-6 + #622, #127
  static nivel4-6 + #623, #127
  static nivel4-6 + #624, #127
  static nivel4-6 + #625, #127
  static nivel4-6 + #626, #127
  static nivel4-6 + #627, #558
  static nivel4-6 + #628, #127
  static nivel4-6 + #629, #127
  static nivel4-6 + #630, #127
  static nivel4-6 + #631, #127
  static nivel4-6 + #632, #127
  static nivel4-6 + #633, #127
  static nivel4-6 + #634, #127
  static nivel4-6 + #635, #127
  static nivel4-6 + #636, #127
  static nivel4-6 + #637, #127
  static nivel4-6 + #638, #127
  static nivel4-6 + #639, #127

  ;Linha 16
  static nivel4-6 + #640, #127
  static nivel4-6 + #641, #127
  static nivel4-6 + #642, #127
  static nivel4-6 + #643, #558
  static nivel4-6 + #644, #127
  static nivel4-6 + #645, #127
  static nivel4-6 + #646, #127
  static nivel4-6 + #647, #127
  static nivel4-6 + #648, #127
  static nivel4-6 + #649, #127
  static nivel4-6 + #650, #127
  static nivel4-6 + #651, #127
  static nivel4-6 + #652, #558
  static nivel4-6 + #653, #127
  static nivel4-6 + #654, #127
  static nivel4-6 + #655, #127
  static nivel4-6 + #656, #558
  static nivel4-6 + #657, #127
  static nivel4-6 + #658, #127
  static nivel4-6 + #659, #127
  static nivel4-6 + #660, #127
  static nivel4-6 + #661, #127
  static nivel4-6 + #662, #127
  static nivel4-6 + #663, #127
  static nivel4-6 + #664, #127
  static nivel4-6 + #665, #127
  static nivel4-6 + #666, #127
  static nivel4-6 + #667, #127
  static nivel4-6 + #668, #127
  static nivel4-6 + #669, #127
  static nivel4-6 + #670, #127
  static nivel4-6 + #671, #558
  static nivel4-6 + #672, #127
  static nivel4-6 + #673, #127
  static nivel4-6 + #674, #127
  static nivel4-6 + #675, #127
  static nivel4-6 + #676, #127
  static nivel4-6 + #677, #127
  static nivel4-6 + #678, #558
  static nivel4-6 + #679, #127

  ;Linha 17
  static nivel4-6 + #680, #127
  static nivel4-6 + #681, #127
  static nivel4-6 + #682, #127
  static nivel4-6 + #683, #127
  static nivel4-6 + #684, #127
  static nivel4-6 + #685, #127
  static nivel4-6 + #686, #127
  static nivel4-6 + #687, #127
  static nivel4-6 + #688, #127
  static nivel4-6 + #689, #127
  static nivel4-6 + #690, #127
  static nivel4-6 + #691, #127
  static nivel4-6 + #692, #127
  static nivel4-6 + #693, #127
  static nivel4-6 + #694, #127
  static nivel4-6 + #695, #127
  static nivel4-6 + #696, #127
  static nivel4-6 + #697, #127
  static nivel4-6 + #698, #127
  static nivel4-6 + #699, #127
  static nivel4-6 + #700, #127
  static nivel4-6 + #701, #558
  static nivel4-6 + #702, #127
  static nivel4-6 + #703, #127
  static nivel4-6 + #704, #127
  static nivel4-6 + #705, #127
  static nivel4-6 + #706, #127
  static nivel4-6 + #707, #127
  static nivel4-6 + #708, #127
  static nivel4-6 + #709, #127
  static nivel4-6 + #710, #127
  static nivel4-6 + #711, #127
  static nivel4-6 + #712, #127
  static nivel4-6 + #713, #127
  static nivel4-6 + #714, #127
  static nivel4-6 + #715, #127
  static nivel4-6 + #716, #127
  static nivel4-6 + #717, #127
  static nivel4-6 + #718, #127
  static nivel4-6 + #719, #127

  ;Linha 18
  static nivel4-6 + #720, #127
  static nivel4-6 + #721, #127
  static nivel4-6 + #722, #127
  static nivel4-6 + #723, #127
  static nivel4-6 + #724, #127
  static nivel4-6 + #725, #127
  static nivel4-6 + #726, #127
  static nivel4-6 + #727, #127
  static nivel4-6 + #728, #127
  static nivel4-6 + #729, #127
  static nivel4-6 + #730, #127
  static nivel4-6 + #731, #127
  static nivel4-6 + #732, #127
  static nivel4-6 + #733, #127
  static nivel4-6 + #734, #127
  static nivel4-6 + #735, #127
  static nivel4-6 + #736, #127
  static nivel4-6 + #737, #127
  static nivel4-6 + #738, #127
  static nivel4-6 + #739, #127
  static nivel4-6 + #740, #127
  static nivel4-6 + #741, #558
  static nivel4-6 + #742, #127
  static nivel4-6 + #743, #127
  static nivel4-6 + #744, #127
  static nivel4-6 + #745, #127
  static nivel4-6 + #746, #127
  static nivel4-6 + #747, #127
  static nivel4-6 + #748, #127
  static nivel4-6 + #749, #127
  static nivel4-6 + #750, #127
  static nivel4-6 + #751, #127
  static nivel4-6 + #752, #127
  static nivel4-6 + #753, #127
  static nivel4-6 + #754, #127
  static nivel4-6 + #755, #127
  static nivel4-6 + #756, #558
  static nivel4-6 + #757, #127
  static nivel4-6 + #758, #127
  static nivel4-6 + #759, #127

  ;Linha 19
  static nivel4-6 + #760, #127
  static nivel4-6 + #761, #127
  static nivel4-6 + #762, #127
  static nivel4-6 + #763, #127
  static nivel4-6 + #764, #127
  static nivel4-6 + #765, #558
  static nivel4-6 + #766, #512
  static nivel4-6 + #767, #127
  static nivel4-6 + #768, #127
  static nivel4-6 + #769, #127
  static nivel4-6 + #770, #127
  static nivel4-6 + #771, #127
  static nivel4-6 + #772, #127
  static nivel4-6 + #773, #127
  static nivel4-6 + #774, #127
  static nivel4-6 + #775, #127
  static nivel4-6 + #776, #127
  static nivel4-6 + #777, #127
  static nivel4-6 + #778, #127
  static nivel4-6 + #779, #127
  static nivel4-6 + #780, #127
  static nivel4-6 + #781, #127
  static nivel4-6 + #782, #127
  static nivel4-6 + #783, #558
  static nivel4-6 + #784, #127
  static nivel4-6 + #785, #127
  static nivel4-6 + #786, #127
  static nivel4-6 + #787, #127
  static nivel4-6 + #788, #127
  static nivel4-6 + #789, #127
  static nivel4-6 + #790, #127
  static nivel4-6 + #791, #127
  static nivel4-6 + #792, #127
  static nivel4-6 + #793, #127
  static nivel4-6 + #794, #127
  static nivel4-6 + #795, #127
  static nivel4-6 + #796, #127
  static nivel4-6 + #797, #127
  static nivel4-6 + #798, #127
  static nivel4-6 + #799, #127

  ;Linha 20
  static nivel4-6 + #800, #127
  static nivel4-6 + #801, #127
  static nivel4-6 + #802, #127
  static nivel4-6 + #803, #127
  static nivel4-6 + #804, #127
  static nivel4-6 + #805, #127
  static nivel4-6 + #806, #127
  static nivel4-6 + #807, #127
  static nivel4-6 + #808, #127
  static nivel4-6 + #809, #127
  static nivel4-6 + #810, #127
  static nivel4-6 + #811, #127
  static nivel4-6 + #812, #127
  static nivel4-6 + #813, #127
  static nivel4-6 + #814, #127
  static nivel4-6 + #815, #127
  static nivel4-6 + #816, #127
  static nivel4-6 + #817, #127
  static nivel4-6 + #818, #558
  static nivel4-6 + #819, #127
  static nivel4-6 + #820, #127
  static nivel4-6 + #821, #127
  static nivel4-6 + #822, #127
  static nivel4-6 + #823, #127
  static nivel4-6 + #824, #127
  static nivel4-6 + #825, #127
  static nivel4-6 + #826, #127
  static nivel4-6 + #827, #127
  static nivel4-6 + #828, #127
  static nivel4-6 + #829, #558
  static nivel4-6 + #830, #127
  static nivel4-6 + #831, #127
  static nivel4-6 + #832, #127
  static nivel4-6 + #833, #127
  static nivel4-6 + #834, #127
  static nivel4-6 + #835, #127
  static nivel4-6 + #836, #127
  static nivel4-6 + #837, #127
  static nivel4-6 + #838, #127
  static nivel4-6 + #839, #127

  ;Linha 21
  static nivel4-6 + #840, #127
  static nivel4-6 + #841, #127
  static nivel4-6 + #842, #127
  static nivel4-6 + #843, #127
  static nivel4-6 + #844, #127
  static nivel4-6 + #845, #127
  static nivel4-6 + #846, #127
  static nivel4-6 + #847, #127
  static nivel4-6 + #848, #127
  static nivel4-6 + #849, #127
  static nivel4-6 + #850, #127
  static nivel4-6 + #851, #127
  static nivel4-6 + #852, #127
  static nivel4-6 + #853, #558
  static nivel4-6 + #854, #127
  static nivel4-6 + #855, #127
  static nivel4-6 + #856, #127
  static nivel4-6 + #857, #127
  static nivel4-6 + #858, #127
  static nivel4-6 + #859, #127
  static nivel4-6 + #860, #127
  static nivel4-6 + #861, #127
  static nivel4-6 + #862, #127
  static nivel4-6 + #863, #127
  static nivel4-6 + #864, #127
  static nivel4-6 + #865, #127
  static nivel4-6 + #866, #127
  static nivel4-6 + #867, #127
  static nivel4-6 + #868, #127
  static nivel4-6 + #869, #127
  static nivel4-6 + #870, #127
  static nivel4-6 + #871, #127
  static nivel4-6 + #872, #127
  static nivel4-6 + #873, #127
  static nivel4-6 + #874, #558
  static nivel4-6 + #875, #127
  static nivel4-6 + #876, #127
  static nivel4-6 + #877, #127
  static nivel4-6 + #878, #127
  static nivel4-6 + #879, #127

  ;Linha 22
  static nivel4-6 + #880, #127
  static nivel4-6 + #881, #127
  static nivel4-6 + #882, #558
  static nivel4-6 + #883, #127
  static nivel4-6 + #884, #127
  static nivel4-6 + #885, #127
  static nivel4-6 + #886, #127
  static nivel4-6 + #887, #127
  static nivel4-6 + #888, #127
  static nivel4-6 + #889, #127
  static nivel4-6 + #890, #127
  static nivel4-6 + #891, #127
  static nivel4-6 + #892, #127
  static nivel4-6 + #893, #127
  static nivel4-6 + #894, #127
  static nivel4-6 + #895, #127
  static nivel4-6 + #896, #127
  static nivel4-6 + #897, #127
  static nivel4-6 + #898, #127
  static nivel4-6 + #899, #127
  static nivel4-6 + #900, #127
  static nivel4-6 + #901, #127
  static nivel4-6 + #902, #127
  static nivel4-6 + #903, #127
  static nivel4-6 + #904, #127
  static nivel4-6 + #905, #127
  static nivel4-6 + #906, #127
  static nivel4-6 + #907, #127
  static nivel4-6 + #908, #127
  static nivel4-6 + #909, #127
  static nivel4-6 + #910, #127
  static nivel4-6 + #911, #127
  static nivel4-6 + #912, #127
  static nivel4-6 + #913, #127
  static nivel4-6 + #914, #127
  static nivel4-6 + #915, #127
  static nivel4-6 + #916, #127
  static nivel4-6 + #917, #127
  static nivel4-6 + #918, #127
  static nivel4-6 + #919, #127

  ;Linha 23
  static nivel4-6 + #920, #127
  static nivel4-6 + #921, #127
  static nivel4-6 + #922, #127
  static nivel4-6 + #923, #127
  static nivel4-6 + #924, #127
  static nivel4-6 + #925, #127
  static nivel4-6 + #926, #127
  static nivel4-6 + #927, #127
  static nivel4-6 + #928, #127
  static nivel4-6 + #929, #127
  static nivel4-6 + #930, #127
  static nivel4-6 + #931, #127
  static nivel4-6 + #932, #127
  static nivel4-6 + #933, #127
  static nivel4-6 + #934, #127
  static nivel4-6 + #935, #127
  static nivel4-6 + #936, #127
  static nivel4-6 + #937, #127
  static nivel4-6 + #938, #127
  static nivel4-6 + #939, #127
  static nivel4-6 + #940, #127
  static nivel4-6 + #941, #127
  static nivel4-6 + #942, #127
  static nivel4-6 + #943, #558
  static nivel4-6 + #944, #127
  static nivel4-6 + #945, #127
  static nivel4-6 + #946, #127
  static nivel4-6 + #947, #127
  static nivel4-6 + #948, #127
  static nivel4-6 + #949, #127
  static nivel4-6 + #950, #127
  static nivel4-6 + #951, #127
  static nivel4-6 + #952, #127
  static nivel4-6 + #953, #127
  static nivel4-6 + #954, #127
  static nivel4-6 + #955, #127
  static nivel4-6 + #956, #127
  static nivel4-6 + #957, #127
  static nivel4-6 + #958, #127
  static nivel4-6 + #959, #127

  ;Linha 24
  static nivel4-6 + #960, #127
  static nivel4-6 + #961, #127
  static nivel4-6 + #962, #127
  static nivel4-6 + #963, #127
  static nivel4-6 + #964, #127
  static nivel4-6 + #965, #127
  static nivel4-6 + #966, #127
  static nivel4-6 + #967, #127
  static nivel4-6 + #968, #127
  static nivel4-6 + #969, #127
  static nivel4-6 + #970, #127
  static nivel4-6 + #971, #127
  static nivel4-6 + #972, #127
  static nivel4-6 + #973, #127
  static nivel4-6 + #974, #127
  static nivel4-6 + #975, #127
  static nivel4-6 + #976, #127
  static nivel4-6 + #977, #127
  static nivel4-6 + #978, #127
  static nivel4-6 + #979, #127
  static nivel4-6 + #980, #127
  static nivel4-6 + #981, #127
  static nivel4-6 + #982, #127
  static nivel4-6 + #983, #127
  static nivel4-6 + #984, #127
  static nivel4-6 + #985, #127
  static nivel4-6 + #986, #127
  static nivel4-6 + #987, #127
  static nivel4-6 + #988, #127
  static nivel4-6 + #989, #127
  static nivel4-6 + #990, #127
  static nivel4-6 + #991, #558
  static nivel4-6 + #992, #127
  static nivel4-6 + #993, #512
  static nivel4-6 + #994, #127
  static nivel4-6 + #995, #127
  static nivel4-6 + #996, #127
  static nivel4-6 + #997, #127
  static nivel4-6 + #998, #127
  static nivel4-6 + #999, #127

  ;Linha 25
  static nivel4-6 + #1000, #127
  static nivel4-6 + #1001, #127
  static nivel4-6 + #1002, #127
  static nivel4-6 + #1003, #127
  static nivel4-6 + #1004, #127
  static nivel4-6 + #1005, #127
  static nivel4-6 + #1006, #127
  static nivel4-6 + #1007, #127
  static nivel4-6 + #1008, #127
  static nivel4-6 + #1009, #127
  static nivel4-6 + #1010, #558
  static nivel4-6 + #1011, #127
  static nivel4-6 + #1012, #127
  static nivel4-6 + #1013, #127
  static nivel4-6 + #1014, #127
  static nivel4-6 + #1015, #127
  static nivel4-6 + #1016, #127
  static nivel4-6 + #1017, #127
  static nivel4-6 + #1018, #127
  static nivel4-6 + #1019, #127
  static nivel4-6 + #1020, #127
  static nivel4-6 + #1021, #127
  static nivel4-6 + #1022, #127
  static nivel4-6 + #1023, #127
  static nivel4-6 + #1024, #127
  static nivel4-6 + #1025, #127
  static nivel4-6 + #1026, #127
  static nivel4-6 + #1027, #127
  static nivel4-6 + #1028, #127
  static nivel4-6 + #1029, #127
  static nivel4-6 + #1030, #127
  static nivel4-6 + #1031, #127
  static nivel4-6 + #1032, #127
  static nivel4-6 + #1033, #127
  static nivel4-6 + #1034, #127
  static nivel4-6 + #1035, #127
  static nivel4-6 + #1036, #127
  static nivel4-6 + #1037, #127
  static nivel4-6 + #1038, #127
  static nivel4-6 + #1039, #127

  ;Linha 26
  static nivel4-6 + #1040, #127
  static nivel4-6 + #1041, #127
  static nivel4-6 + #1042, #127
  static nivel4-6 + #1043, #127
  static nivel4-6 + #1044, #127
  static nivel4-6 + #1045, #127
  static nivel4-6 + #1046, #127
  static nivel4-6 + #1047, #127
  static nivel4-6 + #1048, #127
  static nivel4-6 + #1049, #127
  static nivel4-6 + #1050, #127
  static nivel4-6 + #1051, #127
  static nivel4-6 + #1052, #127
  static nivel4-6 + #1053, #127
  static nivel4-6 + #1054, #127
  static nivel4-6 + #1055, #127
  static nivel4-6 + #1056, #127
  static nivel4-6 + #1057, #127
  static nivel4-6 + #1058, #127
  static nivel4-6 + #1059, #127
  static nivel4-6 + #1060, #127
  static nivel4-6 + #1061, #127
  static nivel4-6 + #1062, #127
  static nivel4-6 + #1063, #127
  static nivel4-6 + #1064, #127
  static nivel4-6 + #1065, #127
  static nivel4-6 + #1066, #127
  static nivel4-6 + #1067, #127
  static nivel4-6 + #1068, #127
  static nivel4-6 + #1069, #127
  static nivel4-6 + #1070, #127
  static nivel4-6 + #1071, #127
  static nivel4-6 + #1072, #127
  static nivel4-6 + #1073, #127
  static nivel4-6 + #1074, #127
  static nivel4-6 + #1075, #127
  static nivel4-6 + #1076, #127
  static nivel4-6 + #1077, #127
  static nivel4-6 + #1078, #127
  static nivel4-6 + #1079, #127

  ;Linha 27
  static nivel4-6 + #1080, #127
  static nivel4-6 + #1081, #127
  static nivel4-6 + #1082, #127
  static nivel4-6 + #1083, #127
  static nivel4-6 + #1084, #127
  static nivel4-6 + #1085, #127
  static nivel4-6 + #1086, #127
  static nivel4-6 + #1087, #127
  static nivel4-6 + #1088, #127
  static nivel4-6 + #1089, #127
  static nivel4-6 + #1090, #127
  static nivel4-6 + #1091, #127
  static nivel4-6 + #1092, #127
  static nivel4-6 + #1093, #127
  static nivel4-6 + #1094, #127
  static nivel4-6 + #1095, #127
  static nivel4-6 + #1096, #127
  static nivel4-6 + #1097, #127
  static nivel4-6 + #1098, #127
  static nivel4-6 + #1099, #127
  static nivel4-6 + #1100, #127
  static nivel4-6 + #1101, #127
  static nivel4-6 + #1102, #127
  static nivel4-6 + #1103, #127
  static nivel4-6 + #1104, #127
  static nivel4-6 + #1105, #127
  static nivel4-6 + #1106, #127
  static nivel4-6 + #1107, #127
  static nivel4-6 + #1108, #127
  static nivel4-6 + #1109, #127
  static nivel4-6 + #1110, #127
  static nivel4-6 + #1111, #127
  static nivel4-6 + #1112, #127
  static nivel4-6 + #1113, #127
  static nivel4-6 + #1114, #127
  static nivel4-6 + #1115, #127
  static nivel4-6 + #1116, #127
  static nivel4-6 + #1117, #127
  static nivel4-6 + #1118, #127
  static nivel4-6 + #1119, #127

  ;Linha 28
  static nivel4-6 + #1120, #127
  static nivel4-6 + #1121, #127
  static nivel4-6 + #1122, #127
  static nivel4-6 + #1123, #127
  static nivel4-6 + #1124, #127
  static nivel4-6 + #1125, #127
  static nivel4-6 + #1126, #127
  static nivel4-6 + #1127, #127
  static nivel4-6 + #1128, #127
  static nivel4-6 + #1129, #127
  static nivel4-6 + #1130, #127
  static nivel4-6 + #1131, #127
  static nivel4-6 + #1132, #127
  static nivel4-6 + #1133, #127
  static nivel4-6 + #1134, #127
  static nivel4-6 + #1135, #127
  static nivel4-6 + #1136, #127
  static nivel4-6 + #1137, #127
  static nivel4-6 + #1138, #127
  static nivel4-6 + #1139, #127
  static nivel4-6 + #1140, #127
  static nivel4-6 + #1141, #127
  static nivel4-6 + #1142, #127
  static nivel4-6 + #1143, #127
  static nivel4-6 + #1144, #127
  static nivel4-6 + #1145, #127
  static nivel4-6 + #1146, #127
  static nivel4-6 + #1147, #127
  static nivel4-6 + #1148, #127
  static nivel4-6 + #1149, #127
  static nivel4-6 + #1150, #127
  static nivel4-6 + #1151, #127
  static nivel4-6 + #1152, #127
  static nivel4-6 + #1153, #127
  static nivel4-6 + #1154, #127
  static nivel4-6 + #1155, #127
  static nivel4-6 + #1156, #127
  static nivel4-6 + #1157, #127
  static nivel4-6 + #1158, #127
  static nivel4-6 + #1159, #127

  ;Linha 29
  static nivel4-6 + #1160, #127
  static nivel4-6 + #1161, #127
  static nivel4-6 + #1162, #127
  static nivel4-6 + #1163, #127
  static nivel4-6 + #1164, #127
  static nivel4-6 + #1165, #127
  static nivel4-6 + #1166, #127
  static nivel4-6 + #1167, #127
  static nivel4-6 + #1168, #127
  static nivel4-6 + #1169, #127
  static nivel4-6 + #1170, #127
  static nivel4-6 + #1171, #127
  static nivel4-6 + #1172, #127
  static nivel4-6 + #1173, #127
  static nivel4-6 + #1174, #127
  static nivel4-6 + #1175, #127
  static nivel4-6 + #1176, #127
  static nivel4-6 + #1177, #127
  static nivel4-6 + #1178, #127
  static nivel4-6 + #1179, #127
  static nivel4-6 + #1180, #127
  static nivel4-6 + #1181, #127
  static nivel4-6 + #1182, #127
  static nivel4-6 + #1183, #127
  static nivel4-6 + #1184, #127
  static nivel4-6 + #1185, #127
  static nivel4-6 + #1186, #127
  static nivel4-6 + #1187, #127
  static nivel4-6 + #1188, #127
  static nivel4-6 + #1189, #127
  static nivel4-6 + #1190, #127
  static nivel4-6 + #1191, #127
  static nivel4-6 + #1192, #127
  static nivel4-6 + #1193, #127
  static nivel4-6 + #1194, #127
  static nivel4-6 + #1195, #127
  static nivel4-6 + #1196, #127
  static nivel4-6 + #1197, #127
  static nivel4-6 + #1198, #127
  static nivel4-6 + #1199, #127




nivel7-9 : var #1200
  ;Linha 0
  static nivel7-9 + #0, #127
  static nivel7-9 + #1, #127
  static nivel7-9 + #2, #127
  static nivel7-9 + #3, #127
  static nivel7-9 + #4, #127
  static nivel7-9 + #5, #127
  static nivel7-9 + #6, #127
  static nivel7-9 + #7, #127
  static nivel7-9 + #8, #127
  static nivel7-9 + #9, #127
  static nivel7-9 + #10, #127
  static nivel7-9 + #11, #127
  static nivel7-9 + #12, #127
  static nivel7-9 + #13, #127
  static nivel7-9 + #14, #127
  static nivel7-9 + #15, #127
  static nivel7-9 + #16, #127
  static nivel7-9 + #17, #2350
  static nivel7-9 + #18, #127
  static nivel7-9 + #19, #127
  static nivel7-9 + #20, #127
  static nivel7-9 + #21, #127
  static nivel7-9 + #22, #127
  static nivel7-9 + #23, #127
  static nivel7-9 + #24, #127
  static nivel7-9 + #25, #127
  static nivel7-9 + #26, #46
  static nivel7-9 + #27, #127
  static nivel7-9 + #28, #127
  static nivel7-9 + #29, #127
  static nivel7-9 + #30, #127
  static nivel7-9 + #31, #127
  static nivel7-9 + #32, #127
  static nivel7-9 + #33, #127
  static nivel7-9 + #34, #127
  static nivel7-9 + #35, #127
  static nivel7-9 + #36, #127
  static nivel7-9 + #37, #127
  static nivel7-9 + #38, #127
  static nivel7-9 + #39, #127

  ;Linha 1
  static nivel7-9 + #40, #127
  static nivel7-9 + #41, #127
  static nivel7-9 + #42, #127
  static nivel7-9 + #43, #127
  static nivel7-9 + #44, #127
  static nivel7-9 + #45, #127
  static nivel7-9 + #46, #127
  static nivel7-9 + #47, #127
  static nivel7-9 + #48, #127
  static nivel7-9 + #49, #127
  static nivel7-9 + #50, #127
  static nivel7-9 + #51, #127
  static nivel7-9 + #52, #127
  static nivel7-9 + #53, #127
  static nivel7-9 + #54, #46
  static nivel7-9 + #55, #127
  static nivel7-9 + #56, #127
  static nivel7-9 + #57, #127
  static nivel7-9 + #58, #127
  static nivel7-9 + #59, #127
  static nivel7-9 + #60, #127
  static nivel7-9 + #61, #127
  static nivel7-9 + #62, #127
  static nivel7-9 + #63, #127
  static nivel7-9 + #64, #127
  static nivel7-9 + #65, #2350
  static nivel7-9 + #66, #127
  static nivel7-9 + #67, #127
  static nivel7-9 + #68, #127
  static nivel7-9 + #69, #127
  static nivel7-9 + #70, #127
  static nivel7-9 + #71, #2304
  static nivel7-9 + #72, #127
  static nivel7-9 + #73, #127
  static nivel7-9 + #74, #127
  static nivel7-9 + #75, #2350
  static nivel7-9 + #76, #127
  static nivel7-9 + #77, #127
  static nivel7-9 + #78, #127
  static nivel7-9 + #79, #127

  ;Linha 2
  static nivel7-9 + #80, #127
  static nivel7-9 + #81, #127
  static nivel7-9 + #82, #2304
  static nivel7-9 + #83, #2350
  static nivel7-9 + #84, #46
  static nivel7-9 + #85, #127
  static nivel7-9 + #86, #46
  static nivel7-9 + #87, #46
  static nivel7-9 + #88, #2344
  static nivel7-9 + #89, #2345
  static nivel7-9 + #90, #46
  static nivel7-9 + #91, #127
  static nivel7-9 + #92, #127
  static nivel7-9 + #93, #127
  static nivel7-9 + #94, #127
  static nivel7-9 + #95, #46
  static nivel7-9 + #96, #46
  static nivel7-9 + #97, #127
  static nivel7-9 + #98, #2350
  static nivel7-9 + #99, #127
  static nivel7-9 + #100, #127
  static nivel7-9 + #101, #127
  static nivel7-9 + #102, #127
  static nivel7-9 + #103, #127
  static nivel7-9 + #104, #2350
  static nivel7-9 + #105, #127
  static nivel7-9 + #106, #127
  static nivel7-9 + #107, #127
  static nivel7-9 + #108, #2350
  static nivel7-9 + #109, #127
  static nivel7-9 + #110, #127
  static nivel7-9 + #111, #127
  static nivel7-9 + #112, #127
  static nivel7-9 + #113, #127
  static nivel7-9 + #114, #127
  static nivel7-9 + #115, #127
  static nivel7-9 + #116, #127
  static nivel7-9 + #117, #127
  static nivel7-9 + #118, #46
  static nivel7-9 + #119, #127

  ;Linha 3
  static nivel7-9 + #120, #127
  static nivel7-9 + #121, #127
  static nivel7-9 + #122, #127
  static nivel7-9 + #123, #127
  static nivel7-9 + #124, #46
  static nivel7-9 + #125, #127
  static nivel7-9 + #126, #46
  static nivel7-9 + #127, #127
  static nivel7-9 + #128, #127
  static nivel7-9 + #129, #127
  static nivel7-9 + #130, #127
  static nivel7-9 + #131, #127
  static nivel7-9 + #132, #127
  static nivel7-9 + #133, #127
  static nivel7-9 + #134, #127
  static nivel7-9 + #135, #127
  static nivel7-9 + #136, #46
  static nivel7-9 + #137, #127
  static nivel7-9 + #138, #127
  static nivel7-9 + #139, #127
  static nivel7-9 + #140, #127
  static nivel7-9 + #141, #127
  static nivel7-9 + #142, #127
  static nivel7-9 + #143, #127
  static nivel7-9 + #144, #127
  static nivel7-9 + #145, #127
  static nivel7-9 + #146, #127
  static nivel7-9 + #147, #127
  static nivel7-9 + #148, #127
  static nivel7-9 + #149, #127
  static nivel7-9 + #150, #46
  static nivel7-9 + #151, #2350
  static nivel7-9 + #152, #127
  static nivel7-9 + #153, #127
  static nivel7-9 + #154, #127
  static nivel7-9 + #155, #2350
  static nivel7-9 + #156, #127
  static nivel7-9 + #157, #127
  static nivel7-9 + #158, #127
  static nivel7-9 + #159, #127

  ;Linha 4
  static nivel7-9 + #160, #127
  static nivel7-9 + #161, #127
  static nivel7-9 + #162, #127
  static nivel7-9 + #163, #127
  static nivel7-9 + #164, #127
  static nivel7-9 + #165, #127
  static nivel7-9 + #166, #46
  static nivel7-9 + #167, #127
  static nivel7-9 + #168, #127
  static nivel7-9 + #169, #127
  static nivel7-9 + #170, #127
  static nivel7-9 + #171, #127
  static nivel7-9 + #172, #2350
  static nivel7-9 + #173, #127
  static nivel7-9 + #174, #127
  static nivel7-9 + #175, #127
  static nivel7-9 + #176, #127
  static nivel7-9 + #177, #127
  static nivel7-9 + #178, #127
  static nivel7-9 + #179, #2350
  static nivel7-9 + #180, #127
  static nivel7-9 + #181, #46
  static nivel7-9 + #182, #2350
  static nivel7-9 + #183, #127
  static nivel7-9 + #184, #127
  static nivel7-9 + #185, #127
  static nivel7-9 + #186, #2350
  static nivel7-9 + #187, #127
  static nivel7-9 + #188, #127
  static nivel7-9 + #189, #127
  static nivel7-9 + #190, #127
  static nivel7-9 + #191, #46
  static nivel7-9 + #192, #127
  static nivel7-9 + #193, #127
  static nivel7-9 + #194, #2350
  static nivel7-9 + #195, #127
  static nivel7-9 + #196, #127
  static nivel7-9 + #197, #127
  static nivel7-9 + #198, #127
  static nivel7-9 + #199, #127

  ;Linha 5
  static nivel7-9 + #200, #127
  static nivel7-9 + #201, #46
  static nivel7-9 + #202, #46
  static nivel7-9 + #203, #127
  static nivel7-9 + #204, #127
  static nivel7-9 + #205, #127
  static nivel7-9 + #206, #127
  static nivel7-9 + #207, #2350
  static nivel7-9 + #208, #127
  static nivel7-9 + #209, #127
  static nivel7-9 + #210, #127
  static nivel7-9 + #211, #127
  static nivel7-9 + #212, #46
  static nivel7-9 + #213, #127
  static nivel7-9 + #214, #127
  static nivel7-9 + #215, #127
  static nivel7-9 + #216, #2350
  static nivel7-9 + #217, #2350
  static nivel7-9 + #218, #127
  static nivel7-9 + #219, #127
  static nivel7-9 + #220, #127
  static nivel7-9 + #221, #127
  static nivel7-9 + #222, #127
  static nivel7-9 + #223, #127
  static nivel7-9 + #224, #127
  static nivel7-9 + #225, #46
  static nivel7-9 + #226, #127
  static nivel7-9 + #227, #127
  static nivel7-9 + #228, #127
  static nivel7-9 + #229, #127
  static nivel7-9 + #230, #127
  static nivel7-9 + #231, #2350
  static nivel7-9 + #232, #127
  static nivel7-9 + #233, #127
  static nivel7-9 + #234, #127
  static nivel7-9 + #235, #127
  static nivel7-9 + #236, #127
  static nivel7-9 + #237, #127
  static nivel7-9 + #238, #127
  static nivel7-9 + #239, #127

  ;Linha 6
  static nivel7-9 + #240, #127
  static nivel7-9 + #241, #127
  static nivel7-9 + #242, #127
  static nivel7-9 + #243, #2350
  static nivel7-9 + #244, #127
  static nivel7-9 + #245, #127
  static nivel7-9 + #246, #297
  static nivel7-9 + #247, #127
  static nivel7-9 + #248, #127
  static nivel7-9 + #249, #46
  static nivel7-9 + #250, #2350
  static nivel7-9 + #251, #127
  static nivel7-9 + #252, #127
  static nivel7-9 + #253, #127
  static nivel7-9 + #254, #127
  static nivel7-9 + #255, #46
  static nivel7-9 + #256, #127
  static nivel7-9 + #257, #127
  static nivel7-9 + #258, #127
  static nivel7-9 + #259, #46
  static nivel7-9 + #260, #127
  static nivel7-9 + #261, #127
  static nivel7-9 + #262, #127
  static nivel7-9 + #263, #127
  static nivel7-9 + #264, #127
  static nivel7-9 + #265, #127
  static nivel7-9 + #266, #127
  static nivel7-9 + #267, #2350
  static nivel7-9 + #268, #127
  static nivel7-9 + #269, #127
  static nivel7-9 + #270, #127
  static nivel7-9 + #271, #127
  static nivel7-9 + #272, #127
  static nivel7-9 + #273, #127
  static nivel7-9 + #274, #2344
  static nivel7-9 + #275, #2345
  static nivel7-9 + #276, #2365
  static nivel7-9 + #277, #2365
  static nivel7-9 + #278, #2365
  static nivel7-9 + #279, #2365

  ;Linha 7
  static nivel7-9 + #280, #127
  static nivel7-9 + #281, #127
  static nivel7-9 + #282, #127
  static nivel7-9 + #283, #2350
  static nivel7-9 + #284, #127
  static nivel7-9 + #285, #127
  static nivel7-9 + #286, #127
  static nivel7-9 + #287, #127
  static nivel7-9 + #288, #2350
  static nivel7-9 + #289, #127
  static nivel7-9 + #290, #127
  static nivel7-9 + #291, #127
  static nivel7-9 + #292, #127
  static nivel7-9 + #293, #127
  static nivel7-9 + #294, #46
  static nivel7-9 + #295, #127
  static nivel7-9 + #296, #2350
  static nivel7-9 + #297, #127
  static nivel7-9 + #298, #127
  static nivel7-9 + #299, #127
  static nivel7-9 + #300, #127
  static nivel7-9 + #301, #127
  static nivel7-9 + #302, #127
  static nivel7-9 + #303, #2350
  static nivel7-9 + #304, #127
  static nivel7-9 + #305, #127
  static nivel7-9 + #306, #127
  static nivel7-9 + #307, #46
  static nivel7-9 + #308, #127
  static nivel7-9 + #309, #2350
  static nivel7-9 + #310, #127
  static nivel7-9 + #311, #127
  static nivel7-9 + #312, #127
  static nivel7-9 + #313, #127
  static nivel7-9 + #314, #127
  static nivel7-9 + #315, #127
  static nivel7-9 + #316, #127
  static nivel7-9 + #317, #127
  static nivel7-9 + #318, #127
  static nivel7-9 + #319, #127

  ;Linha 8
  static nivel7-9 + #320, #127
  static nivel7-9 + #321, #127
  static nivel7-9 + #322, #127
  static nivel7-9 + #323, #2350
  static nivel7-9 + #324, #127
  static nivel7-9 + #325, #127
  static nivel7-9 + #326, #127
  static nivel7-9 + #327, #127
  static nivel7-9 + #328, #127
  static nivel7-9 + #329, #127
  static nivel7-9 + #330, #127
  static nivel7-9 + #331, #127
  static nivel7-9 + #332, #127
  static nivel7-9 + #333, #2350
  static nivel7-9 + #334, #127
  static nivel7-9 + #335, #127
  static nivel7-9 + #336, #127
  static nivel7-9 + #337, #127
  static nivel7-9 + #338, #127
  static nivel7-9 + #339, #127
  static nivel7-9 + #340, #127
  static nivel7-9 + #341, #46
  static nivel7-9 + #342, #46
  static nivel7-9 + #343, #127
  static nivel7-9 + #344, #127
  static nivel7-9 + #345, #127
  static nivel7-9 + #346, #2350
  static nivel7-9 + #347, #127
  static nivel7-9 + #348, #127
  static nivel7-9 + #349, #127
  static nivel7-9 + #350, #2350
  static nivel7-9 + #351, #127
  static nivel7-9 + #352, #127
  static nivel7-9 + #353, #2350
  static nivel7-9 + #354, #127
  static nivel7-9 + #355, #127
  static nivel7-9 + #356, #127
  static nivel7-9 + #357, #127
  static nivel7-9 + #358, #127
  static nivel7-9 + #359, #127

  ;Linha 9
  static nivel7-9 + #360, #127
  static nivel7-9 + #361, #127
  static nivel7-9 + #362, #127
  static nivel7-9 + #363, #127
  static nivel7-9 + #364, #127
  static nivel7-9 + #365, #127
  static nivel7-9 + #366, #127
  static nivel7-9 + #367, #127
  static nivel7-9 + #368, #2350
  static nivel7-9 + #369, #127
  static nivel7-9 + #370, #127
  static nivel7-9 + #371, #46
  static nivel7-9 + #372, #127
  static nivel7-9 + #373, #127
  static nivel7-9 + #374, #127
  static nivel7-9 + #375, #127
  static nivel7-9 + #376, #127
  static nivel7-9 + #377, #127
  static nivel7-9 + #378, #2350
  static nivel7-9 + #379, #127
  static nivel7-9 + #380, #2350
  static nivel7-9 + #381, #127
  static nivel7-9 + #382, #127
  static nivel7-9 + #383, #127
  static nivel7-9 + #384, #127
  static nivel7-9 + #385, #127
  static nivel7-9 + #386, #127
  static nivel7-9 + #387, #127
  static nivel7-9 + #388, #127
  static nivel7-9 + #389, #2304
  static nivel7-9 + #390, #127
  static nivel7-9 + #391, #127
  static nivel7-9 + #392, #127
  static nivel7-9 + #393, #127
  static nivel7-9 + #394, #127
  static nivel7-9 + #395, #127
  static nivel7-9 + #396, #127
  static nivel7-9 + #397, #2350
  static nivel7-9 + #398, #127
  static nivel7-9 + #399, #127

  ;Linha 10
  static nivel7-9 + #400, #127
  static nivel7-9 + #401, #127
  static nivel7-9 + #402, #2350
  static nivel7-9 + #403, #127
  static nivel7-9 + #404, #127
  static nivel7-9 + #405, #127
  static nivel7-9 + #406, #127
  static nivel7-9 + #407, #127
  static nivel7-9 + #408, #127
  static nivel7-9 + #409, #127
  static nivel7-9 + #410, #127
  static nivel7-9 + #411, #127
  static nivel7-9 + #412, #2350
  static nivel7-9 + #413, #127
  static nivel7-9 + #414, #127
  static nivel7-9 + #415, #2304
  static nivel7-9 + #416, #127
  static nivel7-9 + #417, #127
  static nivel7-9 + #418, #127
  static nivel7-9 + #419, #127
  static nivel7-9 + #420, #127
  static nivel7-9 + #421, #127
  static nivel7-9 + #422, #127
  static nivel7-9 + #423, #2350
  static nivel7-9 + #424, #127
  static nivel7-9 + #425, #2350
  static nivel7-9 + #426, #127
  static nivel7-9 + #427, #127
  static nivel7-9 + #428, #127
  static nivel7-9 + #429, #2350
  static nivel7-9 + #430, #127
  static nivel7-9 + #431, #127
  static nivel7-9 + #432, #127
  static nivel7-9 + #433, #127
  static nivel7-9 + #434, #127
  static nivel7-9 + #435, #127
  static nivel7-9 + #436, #127
  static nivel7-9 + #437, #127
  static nivel7-9 + #438, #127
  static nivel7-9 + #439, #127

  ;Linha 11
  static nivel7-9 + #440, #127
  static nivel7-9 + #441, #127
  static nivel7-9 + #442, #3967
  static nivel7-9 + #443, #3967
  static nivel7-9 + #444, #3967
  static nivel7-9 + #445, #127
  static nivel7-9 + #446, #127
  static nivel7-9 + #447, #127
  static nivel7-9 + #448, #127
  static nivel7-9 + #449, #127
  static nivel7-9 + #450, #127
  static nivel7-9 + #451, #127
  static nivel7-9 + #452, #127
  static nivel7-9 + #453, #127
  static nivel7-9 + #454, #127
  static nivel7-9 + #455, #2350
  static nivel7-9 + #456, #127
  static nivel7-9 + #457, #127
  static nivel7-9 + #458, #127
  static nivel7-9 + #459, #127
  static nivel7-9 + #460, #127
  static nivel7-9 + #461, #127
  static nivel7-9 + #462, #127
  static nivel7-9 + #463, #127
  static nivel7-9 + #464, #127
  static nivel7-9 + #465, #127
  static nivel7-9 + #466, #127
  static nivel7-9 + #467, #127
  static nivel7-9 + #468, #127
  static nivel7-9 + #469, #127
  static nivel7-9 + #470, #127
  static nivel7-9 + #471, #127
  static nivel7-9 + #472, #127
  static nivel7-9 + #473, #127
  static nivel7-9 + #474, #127
  static nivel7-9 + #475, #127
  static nivel7-9 + #476, #127
  static nivel7-9 + #477, #127
  static nivel7-9 + #478, #127
  static nivel7-9 + #479, #127

  ;Linha 12
  static nivel7-9 + #480, #127
  static nivel7-9 + #481, #127
  static nivel7-9 + #482, #127
  static nivel7-9 + #483, #2365
  static nivel7-9 + #484, #2365
  static nivel7-9 + #485, #2365
  static nivel7-9 + #486, #2365
  static nivel7-9 + #487, #2344
  static nivel7-9 + #488, #2345
  static nivel7-9 + #489, #127
  static nivel7-9 + #490, #127
  static nivel7-9 + #491, #127
  static nivel7-9 + #492, #127
  static nivel7-9 + #493, #127
  static nivel7-9 + #494, #127
  static nivel7-9 + #495, #127
  static nivel7-9 + #496, #127
  static nivel7-9 + #497, #127
  static nivel7-9 + #498, #127
  static nivel7-9 + #499, #127
  static nivel7-9 + #500, #2350
  static nivel7-9 + #501, #127
  static nivel7-9 + #502, #127
  static nivel7-9 + #503, #127
  static nivel7-9 + #504, #127
  static nivel7-9 + #505, #127
  static nivel7-9 + #506, #127
  static nivel7-9 + #507, #127
  static nivel7-9 + #508, #127
  static nivel7-9 + #509, #127
  static nivel7-9 + #510, #127
  static nivel7-9 + #511, #127
  static nivel7-9 + #512, #2350
  static nivel7-9 + #513, #127
  static nivel7-9 + #514, #127
  static nivel7-9 + #515, #127
  static nivel7-9 + #516, #127
  static nivel7-9 + #517, #2350
  static nivel7-9 + #518, #127
  static nivel7-9 + #519, #127

  ;Linha 13
  static nivel7-9 + #520, #127
  static nivel7-9 + #521, #127
  static nivel7-9 + #522, #127
  static nivel7-9 + #523, #127
  static nivel7-9 + #524, #127
  static nivel7-9 + #525, #127
  static nivel7-9 + #526, #127
  static nivel7-9 + #527, #127
  static nivel7-9 + #528, #127
  static nivel7-9 + #529, #127
  static nivel7-9 + #530, #127
  static nivel7-9 + #531, #127
  static nivel7-9 + #532, #2350
  static nivel7-9 + #533, #127
  static nivel7-9 + #534, #127
  static nivel7-9 + #535, #127
  static nivel7-9 + #536, #127
  static nivel7-9 + #537, #127
  static nivel7-9 + #538, #127
  static nivel7-9 + #539, #127
  static nivel7-9 + #540, #127
  static nivel7-9 + #541, #127
  static nivel7-9 + #542, #127
  static nivel7-9 + #543, #127
  static nivel7-9 + #544, #127
  static nivel7-9 + #545, #127
  static nivel7-9 + #546, #127
  static nivel7-9 + #547, #2350
  static nivel7-9 + #548, #127
  static nivel7-9 + #549, #2350
  static nivel7-9 + #550, #127
  static nivel7-9 + #551, #127
  static nivel7-9 + #552, #127
  static nivel7-9 + #553, #127
  static nivel7-9 + #554, #127
  static nivel7-9 + #555, #127
  static nivel7-9 + #556, #127
  static nivel7-9 + #557, #127
  static nivel7-9 + #558, #127
  static nivel7-9 + #559, #127

  ;Linha 14
  static nivel7-9 + #560, #127
  static nivel7-9 + #561, #127
  static nivel7-9 + #562, #127
  static nivel7-9 + #563, #127
  static nivel7-9 + #564, #127
  static nivel7-9 + #565, #127
  static nivel7-9 + #566, #127
  static nivel7-9 + #567, #127
  static nivel7-9 + #568, #46
  static nivel7-9 + #569, #127
  static nivel7-9 + #570, #127
  static nivel7-9 + #571, #127
  static nivel7-9 + #572, #127
  static nivel7-9 + #573, #46
  static nivel7-9 + #574, #2350
  static nivel7-9 + #575, #127
  static nivel7-9 + #576, #127
  static nivel7-9 + #577, #2350
  static nivel7-9 + #578, #127
  static nivel7-9 + #579, #127
  static nivel7-9 + #580, #127
  static nivel7-9 + #581, #127
  static nivel7-9 + #582, #2350
  static nivel7-9 + #583, #2350
  static nivel7-9 + #584, #127
  static nivel7-9 + #585, #2350
  static nivel7-9 + #586, #127
  static nivel7-9 + #587, #127
  static nivel7-9 + #588, #127
  static nivel7-9 + #589, #127
  static nivel7-9 + #590, #127
  static nivel7-9 + #591, #2350
  static nivel7-9 + #592, #127
  static nivel7-9 + #593, #127
  static nivel7-9 + #594, #127
  static nivel7-9 + #595, #127
  static nivel7-9 + #596, #127
  static nivel7-9 + #597, #127
  static nivel7-9 + #598, #127
  static nivel7-9 + #599, #127

  ;Linha 15
  static nivel7-9 + #600, #127
  static nivel7-9 + #601, #127
  static nivel7-9 + #602, #127
  static nivel7-9 + #603, #2350
  static nivel7-9 + #604, #127
  static nivel7-9 + #605, #127
  static nivel7-9 + #606, #127
  static nivel7-9 + #607, #127
  static nivel7-9 + #608, #127
  static nivel7-9 + #609, #2350
  static nivel7-9 + #610, #127
  static nivel7-9 + #611, #127
  static nivel7-9 + #612, #127
  static nivel7-9 + #613, #127
  static nivel7-9 + #614, #127
  static nivel7-9 + #615, #127
  static nivel7-9 + #616, #127
  static nivel7-9 + #617, #127
  static nivel7-9 + #618, #127
  static nivel7-9 + #619, #127
  static nivel7-9 + #620, #127
  static nivel7-9 + #621, #127
  static nivel7-9 + #622, #127
  static nivel7-9 + #623, #127
  static nivel7-9 + #624, #127
  static nivel7-9 + #625, #127
  static nivel7-9 + #626, #127
  static nivel7-9 + #627, #127
  static nivel7-9 + #628, #127
  static nivel7-9 + #629, #127
  static nivel7-9 + #630, #127
  static nivel7-9 + #631, #127
  static nivel7-9 + #632, #127
  static nivel7-9 + #633, #127
  static nivel7-9 + #634, #127
  static nivel7-9 + #635, #127
  static nivel7-9 + #636, #127
  static nivel7-9 + #637, #127
  static nivel7-9 + #638, #127
  static nivel7-9 + #639, #127

  ;Linha 16
  static nivel7-9 + #640, #127
  static nivel7-9 + #641, #127
  static nivel7-9 + #642, #127
  static nivel7-9 + #643, #127
  static nivel7-9 + #644, #46
  static nivel7-9 + #645, #127
  static nivel7-9 + #646, #127
  static nivel7-9 + #647, #127
  static nivel7-9 + #648, #127
  static nivel7-9 + #649, #127
  static nivel7-9 + #650, #127
  static nivel7-9 + #651, #127
  static nivel7-9 + #652, #127
  static nivel7-9 + #653, #127
  static nivel7-9 + #654, #127
  static nivel7-9 + #655, #127
  static nivel7-9 + #656, #127
  static nivel7-9 + #657, #127
  static nivel7-9 + #658, #127
  static nivel7-9 + #659, #127
  static nivel7-9 + #660, #127
  static nivel7-9 + #661, #127
  static nivel7-9 + #662, #127
  static nivel7-9 + #663, #127
  static nivel7-9 + #664, #127
  static nivel7-9 + #665, #127
  static nivel7-9 + #666, #127
  static nivel7-9 + #667, #127
  static nivel7-9 + #668, #127
  static nivel7-9 + #669, #2350
  static nivel7-9 + #670, #127
  static nivel7-9 + #671, #127
  static nivel7-9 + #672, #127
  static nivel7-9 + #673, #127
  static nivel7-9 + #674, #127
  static nivel7-9 + #675, #127
  static nivel7-9 + #676, #127
  static nivel7-9 + #677, #127
  static nivel7-9 + #678, #127
  static nivel7-9 + #679, #127

  ;Linha 17
  static nivel7-9 + #680, #127
  static nivel7-9 + #681, #127
  static nivel7-9 + #682, #127
  static nivel7-9 + #683, #127
  static nivel7-9 + #684, #127
  static nivel7-9 + #685, #127
  static nivel7-9 + #686, #127
  static nivel7-9 + #687, #127
  static nivel7-9 + #688, #127
  static nivel7-9 + #689, #127
  static nivel7-9 + #690, #127
  static nivel7-9 + #691, #127
  static nivel7-9 + #692, #2350
  static nivel7-9 + #693, #127
  static nivel7-9 + #694, #2350
  static nivel7-9 + #695, #127
  static nivel7-9 + #696, #127
  static nivel7-9 + #697, #2304
  static nivel7-9 + #698, #2350
  static nivel7-9 + #699, #127
  static nivel7-9 + #700, #127
  static nivel7-9 + #701, #127
  static nivel7-9 + #702, #127
  static nivel7-9 + #703, #2350
  static nivel7-9 + #704, #127
  static nivel7-9 + #705, #127
  static nivel7-9 + #706, #127
  static nivel7-9 + #707, #127
  static nivel7-9 + #708, #127
  static nivel7-9 + #709, #127
  static nivel7-9 + #710, #127
  static nivel7-9 + #711, #127
  static nivel7-9 + #712, #2304
  static nivel7-9 + #713, #127
  static nivel7-9 + #714, #127
  static nivel7-9 + #715, #127
  static nivel7-9 + #716, #2350
  static nivel7-9 + #717, #127
  static nivel7-9 + #718, #127
  static nivel7-9 + #719, #127

  ;Linha 18
  static nivel7-9 + #720, #127
  static nivel7-9 + #721, #127
  static nivel7-9 + #722, #2350
  static nivel7-9 + #723, #127
  static nivel7-9 + #724, #127
  static nivel7-9 + #725, #127
  static nivel7-9 + #726, #127
  static nivel7-9 + #727, #2350
  static nivel7-9 + #728, #127
  static nivel7-9 + #729, #127
  static nivel7-9 + #730, #127
  static nivel7-9 + #731, #127
  static nivel7-9 + #732, #46
  static nivel7-9 + #733, #127
  static nivel7-9 + #734, #127
  static nivel7-9 + #735, #127
  static nivel7-9 + #736, #127
  static nivel7-9 + #737, #127
  static nivel7-9 + #738, #127
  static nivel7-9 + #739, #127
  static nivel7-9 + #740, #127
  static nivel7-9 + #741, #127
  static nivel7-9 + #742, #127
  static nivel7-9 + #743, #127
  static nivel7-9 + #744, #127
  static nivel7-9 + #745, #127
  static nivel7-9 + #746, #2350
  static nivel7-9 + #747, #127
  static nivel7-9 + #748, #127
  static nivel7-9 + #749, #127
  static nivel7-9 + #750, #127
  static nivel7-9 + #751, #127
  static nivel7-9 + #752, #127
  static nivel7-9 + #753, #127
  static nivel7-9 + #754, #127
  static nivel7-9 + #755, #127
  static nivel7-9 + #756, #127
  static nivel7-9 + #757, #127
  static nivel7-9 + #758, #127
  static nivel7-9 + #759, #127

  ;Linha 19
  static nivel7-9 + #760, #127
  static nivel7-9 + #761, #46
  static nivel7-9 + #762, #127
  static nivel7-9 + #763, #127
  static nivel7-9 + #764, #127
  static nivel7-9 + #765, #127
  static nivel7-9 + #766, #127
  static nivel7-9 + #767, #127
  static nivel7-9 + #768, #127
  static nivel7-9 + #769, #127
  static nivel7-9 + #770, #127
  static nivel7-9 + #771, #127
  static nivel7-9 + #772, #2350
  static nivel7-9 + #773, #127
  static nivel7-9 + #774, #127
  static nivel7-9 + #775, #127
  static nivel7-9 + #776, #127
  static nivel7-9 + #777, #127
  static nivel7-9 + #778, #127
  static nivel7-9 + #779, #2350
  static nivel7-9 + #780, #127
  static nivel7-9 + #781, #127
  static nivel7-9 + #782, #127
  static nivel7-9 + #783, #127
  static nivel7-9 + #784, #127
  static nivel7-9 + #785, #127
  static nivel7-9 + #786, #127
  static nivel7-9 + #787, #127
  static nivel7-9 + #788, #127
  static nivel7-9 + #789, #127
  static nivel7-9 + #790, #127
  static nivel7-9 + #791, #127
  static nivel7-9 + #792, #127
  static nivel7-9 + #793, #127
  static nivel7-9 + #794, #127
  static nivel7-9 + #795, #127
  static nivel7-9 + #796, #127
  static nivel7-9 + #797, #127
  static nivel7-9 + #798, #127
  static nivel7-9 + #799, #127

  ;Linha 20
  static nivel7-9 + #800, #127
  static nivel7-9 + #801, #127
  static nivel7-9 + #802, #2304
  static nivel7-9 + #803, #127
  static nivel7-9 + #804, #2350
  static nivel7-9 + #805, #127
  static nivel7-9 + #806, #127
  static nivel7-9 + #807, #2350
  static nivel7-9 + #808, #127
  static nivel7-9 + #809, #127
  static nivel7-9 + #810, #127
  static nivel7-9 + #811, #127
  static nivel7-9 + #812, #127
  static nivel7-9 + #813, #127
  static nivel7-9 + #814, #127
  static nivel7-9 + #815, #127
  static nivel7-9 + #816, #127
  static nivel7-9 + #817, #127
  static nivel7-9 + #818, #127
  static nivel7-9 + #819, #2350
  static nivel7-9 + #820, #127
  static nivel7-9 + #821, #127
  static nivel7-9 + #822, #127
  static nivel7-9 + #823, #127
  static nivel7-9 + #824, #2350
  static nivel7-9 + #825, #127
  static nivel7-9 + #826, #127
  static nivel7-9 + #827, #127
  static nivel7-9 + #828, #127
  static nivel7-9 + #829, #2350
  static nivel7-9 + #830, #127
  static nivel7-9 + #831, #127
  static nivel7-9 + #832, #127
  static nivel7-9 + #833, #127
  static nivel7-9 + #834, #127
  static nivel7-9 + #835, #127
  static nivel7-9 + #836, #127
  static nivel7-9 + #837, #127
  static nivel7-9 + #838, #127
  static nivel7-9 + #839, #127

  ;Linha 21
  static nivel7-9 + #840, #127
  static nivel7-9 + #841, #127
  static nivel7-9 + #842, #2350
  static nivel7-9 + #843, #127
  static nivel7-9 + #844, #127
  static nivel7-9 + #845, #127
  static nivel7-9 + #846, #46
  static nivel7-9 + #847, #127
  static nivel7-9 + #848, #127
  static nivel7-9 + #849, #127
  static nivel7-9 + #850, #2350
  static nivel7-9 + #851, #127
  static nivel7-9 + #852, #127
  static nivel7-9 + #853, #127
  static nivel7-9 + #854, #2350
  static nivel7-9 + #855, #127
  static nivel7-9 + #856, #127
  static nivel7-9 + #857, #127
  static nivel7-9 + #858, #127
  static nivel7-9 + #859, #127
  static nivel7-9 + #860, #127
  static nivel7-9 + #861, #127
  static nivel7-9 + #862, #127
  static nivel7-9 + #863, #127
  static nivel7-9 + #864, #127
  static nivel7-9 + #865, #2350
  static nivel7-9 + #866, #127
  static nivel7-9 + #867, #127
  static nivel7-9 + #868, #127
  static nivel7-9 + #869, #127
  static nivel7-9 + #870, #127
  static nivel7-9 + #871, #127
  static nivel7-9 + #872, #127
  static nivel7-9 + #873, #127
  static nivel7-9 + #874, #127
  static nivel7-9 + #875, #127
  static nivel7-9 + #876, #127
  static nivel7-9 + #877, #2350
  static nivel7-9 + #878, #127
  static nivel7-9 + #879, #2350

  ;Linha 22
  static nivel7-9 + #880, #127
  static nivel7-9 + #881, #127
  static nivel7-9 + #882, #127
  static nivel7-9 + #883, #127
  static nivel7-9 + #884, #127
  static nivel7-9 + #885, #127
  static nivel7-9 + #886, #127
  static nivel7-9 + #887, #127
  static nivel7-9 + #888, #46
  static nivel7-9 + #889, #127
  static nivel7-9 + #890, #127
  static nivel7-9 + #891, #127
  static nivel7-9 + #892, #127
  static nivel7-9 + #893, #127
  static nivel7-9 + #894, #2350
  static nivel7-9 + #895, #127
  static nivel7-9 + #896, #127
  static nivel7-9 + #897, #127
  static nivel7-9 + #898, #2350
  static nivel7-9 + #899, #46
  static nivel7-9 + #900, #127
  static nivel7-9 + #901, #127
  static nivel7-9 + #902, #127
  static nivel7-9 + #903, #127
  static nivel7-9 + #904, #127
  static nivel7-9 + #905, #127
  static nivel7-9 + #906, #127
  static nivel7-9 + #907, #127
  static nivel7-9 + #908, #127
  static nivel7-9 + #909, #127
  static nivel7-9 + #910, #127
  static nivel7-9 + #911, #127
  static nivel7-9 + #912, #127
  static nivel7-9 + #913, #127
  static nivel7-9 + #914, #127
  static nivel7-9 + #915, #127
  static nivel7-9 + #916, #127
  static nivel7-9 + #917, #127
  static nivel7-9 + #918, #127
  static nivel7-9 + #919, #127

  ;Linha 23
  static nivel7-9 + #920, #127
  static nivel7-9 + #921, #127
  static nivel7-9 + #922, #127
  static nivel7-9 + #923, #2350
  static nivel7-9 + #924, #127
  static nivel7-9 + #925, #127
  static nivel7-9 + #926, #127
  static nivel7-9 + #927, #127
  static nivel7-9 + #928, #2350
  static nivel7-9 + #929, #127
  static nivel7-9 + #930, #127
  static nivel7-9 + #931, #127
  static nivel7-9 + #932, #127
  static nivel7-9 + #933, #127
  static nivel7-9 + #934, #127
  static nivel7-9 + #935, #127
  static nivel7-9 + #936, #127
  static nivel7-9 + #937, #127
  static nivel7-9 + #938, #127
  static nivel7-9 + #939, #127
  static nivel7-9 + #940, #127
  static nivel7-9 + #941, #127
  static nivel7-9 + #942, #127
  static nivel7-9 + #943, #127
  static nivel7-9 + #944, #127
  static nivel7-9 + #945, #127
  static nivel7-9 + #946, #127
  static nivel7-9 + #947, #127
  static nivel7-9 + #948, #127
  static nivel7-9 + #949, #127
  static nivel7-9 + #950, #127
  static nivel7-9 + #951, #127
  static nivel7-9 + #952, #127
  static nivel7-9 + #953, #127
  static nivel7-9 + #954, #127
  static nivel7-9 + #955, #127
  static nivel7-9 + #956, #127
  static nivel7-9 + #957, #127
  static nivel7-9 + #958, #127
  static nivel7-9 + #959, #127

  ;Linha 24
  static nivel7-9 + #960, #127
  static nivel7-9 + #961, #127
  static nivel7-9 + #962, #127
  static nivel7-9 + #963, #127
  static nivel7-9 + #964, #127
  static nivel7-9 + #965, #2350
  static nivel7-9 + #966, #127
  static nivel7-9 + #967, #127
  static nivel7-9 + #968, #127
  static nivel7-9 + #969, #127
  static nivel7-9 + #970, #127
  static nivel7-9 + #971, #127
  static nivel7-9 + #972, #127
  static nivel7-9 + #973, #127
  static nivel7-9 + #974, #127
  static nivel7-9 + #975, #127
  static nivel7-9 + #976, #127
  static nivel7-9 + #977, #2350
  static nivel7-9 + #978, #127
  static nivel7-9 + #979, #127
  static nivel7-9 + #980, #127
  static nivel7-9 + #981, #127
  static nivel7-9 + #982, #2350
  static nivel7-9 + #983, #127
  static nivel7-9 + #984, #127
  static nivel7-9 + #985, #127
  static nivel7-9 + #986, #127
  static nivel7-9 + #987, #127
  static nivel7-9 + #988, #127
  static nivel7-9 + #989, #127
  static nivel7-9 + #990, #127
  static nivel7-9 + #991, #2350
  static nivel7-9 + #992, #2350
  static nivel7-9 + #993, #127
  static nivel7-9 + #994, #127
  static nivel7-9 + #995, #127
  static nivel7-9 + #996, #127
  static nivel7-9 + #997, #127
  static nivel7-9 + #998, #127
  static nivel7-9 + #999, #127

  ;Linha 25
  static nivel7-9 + #1000, #127
  static nivel7-9 + #1001, #127
  static nivel7-9 + #1002, #127
  static nivel7-9 + #1003, #2350
  static nivel7-9 + #1004, #127
  static nivel7-9 + #1005, #127
  static nivel7-9 + #1006, #127
  static nivel7-9 + #1007, #127
  static nivel7-9 + #1008, #127
  static nivel7-9 + #1009, #127
  static nivel7-9 + #1010, #127
  static nivel7-9 + #1011, #127
  static nivel7-9 + #1012, #127
  static nivel7-9 + #1013, #2350
  static nivel7-9 + #1014, #127
  static nivel7-9 + #1015, #127
  static nivel7-9 + #1016, #127
  static nivel7-9 + #1017, #127
  static nivel7-9 + #1018, #127
  static nivel7-9 + #1019, #127
  static nivel7-9 + #1020, #127
  static nivel7-9 + #1021, #127
  static nivel7-9 + #1022, #127
  static nivel7-9 + #1023, #127
  static nivel7-9 + #1024, #127
  static nivel7-9 + #1025, #127
  static nivel7-9 + #1026, #127
  static nivel7-9 + #1027, #127
  static nivel7-9 + #1028, #127
  static nivel7-9 + #1029, #127
  static nivel7-9 + #1030, #127
  static nivel7-9 + #1031, #127
  static nivel7-9 + #1032, #127
  static nivel7-9 + #1033, #127
  static nivel7-9 + #1034, #127
  static nivel7-9 + #1035, #127
  static nivel7-9 + #1036, #2350
  static nivel7-9 + #1037, #127
  static nivel7-9 + #1038, #127
  static nivel7-9 + #1039, #127

  ;Linha 26
  static nivel7-9 + #1040, #127
  static nivel7-9 + #1041, #2350
  static nivel7-9 + #1042, #127
  static nivel7-9 + #1043, #127
  static nivel7-9 + #1044, #127
  static nivel7-9 + #1045, #127
  static nivel7-9 + #1046, #127
  static nivel7-9 + #1047, #127
  static nivel7-9 + #1048, #2350
  static nivel7-9 + #1049, #127
  static nivel7-9 + #1050, #127
  static nivel7-9 + #1051, #127
  static nivel7-9 + #1052, #127
  static nivel7-9 + #1053, #127
  static nivel7-9 + #1054, #127
  static nivel7-9 + #1055, #127
  static nivel7-9 + #1056, #127
  static nivel7-9 + #1057, #127
  static nivel7-9 + #1058, #2350
  static nivel7-9 + #1059, #127
  static nivel7-9 + #1060, #127
  static nivel7-9 + #1061, #127
  static nivel7-9 + #1062, #127
  static nivel7-9 + #1063, #127
  static nivel7-9 + #1064, #127
  static nivel7-9 + #1065, #2350
  static nivel7-9 + #1066, #127
  static nivel7-9 + #1067, #127
  static nivel7-9 + #1068, #127
  static nivel7-9 + #1069, #127
  static nivel7-9 + #1070, #127
  static nivel7-9 + #1071, #127
  static nivel7-9 + #1072, #127
  static nivel7-9 + #1073, #127
  static nivel7-9 + #1074, #127
  static nivel7-9 + #1075, #127
  static nivel7-9 + #1076, #127
  static nivel7-9 + #1077, #127
  static nivel7-9 + #1078, #127
  static nivel7-9 + #1079, #127

  ;Linha 27
  static nivel7-9 + #1080, #127
  static nivel7-9 + #1081, #127
  static nivel7-9 + #1082, #127
  static nivel7-9 + #1083, #127
  static nivel7-9 + #1084, #127
  static nivel7-9 + #1085, #127
  static nivel7-9 + #1086, #127
  static nivel7-9 + #1087, #127
  static nivel7-9 + #1088, #127
  static nivel7-9 + #1089, #127
  static nivel7-9 + #1090, #127
  static nivel7-9 + #1091, #127
  static nivel7-9 + #1092, #127
  static nivel7-9 + #1093, #127
  static nivel7-9 + #1094, #127
  static nivel7-9 + #1095, #127
  static nivel7-9 + #1096, #127
  static nivel7-9 + #1097, #127
  static nivel7-9 + #1098, #127
  static nivel7-9 + #1099, #127
  static nivel7-9 + #1100, #127
  static nivel7-9 + #1101, #127
  static nivel7-9 + #1102, #127
  static nivel7-9 + #1103, #127
  static nivel7-9 + #1104, #127
  static nivel7-9 + #1105, #127
  static nivel7-9 + #1106, #127
  static nivel7-9 + #1107, #127
  static nivel7-9 + #1108, #127
  static nivel7-9 + #1109, #127
  static nivel7-9 + #1110, #127
  static nivel7-9 + #1111, #127
  static nivel7-9 + #1112, #127
  static nivel7-9 + #1113, #127
  static nivel7-9 + #1114, #127
  static nivel7-9 + #1115, #127
  static nivel7-9 + #1116, #127
  static nivel7-9 + #1117, #127
  static nivel7-9 + #1118, #127
  static nivel7-9 + #1119, #127

  ;Linha 28
  static nivel7-9 + #1120, #127
  static nivel7-9 + #1121, #127
  static nivel7-9 + #1122, #127
  static nivel7-9 + #1123, #127
  static nivel7-9 + #1124, #127
  static nivel7-9 + #1125, #127
  static nivel7-9 + #1126, #127
  static nivel7-9 + #1127, #127
  static nivel7-9 + #1128, #127
  static nivel7-9 + #1129, #127
  static nivel7-9 + #1130, #127
  static nivel7-9 + #1131, #127
  static nivel7-9 + #1132, #127
  static nivel7-9 + #1133, #127
  static nivel7-9 + #1134, #127
  static nivel7-9 + #1135, #127
  static nivel7-9 + #1136, #127
  static nivel7-9 + #1137, #127
  static nivel7-9 + #1138, #127
  static nivel7-9 + #1139, #127
  static nivel7-9 + #1140, #127
  static nivel7-9 + #1141, #127
  static nivel7-9 + #1142, #127
  static nivel7-9 + #1143, #127
  static nivel7-9 + #1144, #127
  static nivel7-9 + #1145, #127
  static nivel7-9 + #1146, #127
  static nivel7-9 + #1147, #127
  static nivel7-9 + #1148, #127
  static nivel7-9 + #1149, #127
  static nivel7-9 + #1150, #127
  static nivel7-9 + #1151, #127
  static nivel7-9 + #1152, #127
  static nivel7-9 + #1153, #127
  static nivel7-9 + #1154, #127
  static nivel7-9 + #1155, #127
  static nivel7-9 + #1156, #127
  static nivel7-9 + #1157, #127
  static nivel7-9 + #1158, #127
  static nivel7-9 + #1159, #127

  ;Linha 29
  static nivel7-9 + #1160, #127
  static nivel7-9 + #1161, #127
  static nivel7-9 + #1162, #127
  static nivel7-9 + #1163, #127
  static nivel7-9 + #1164, #127
  static nivel7-9 + #1165, #127
  static nivel7-9 + #1166, #127
  static nivel7-9 + #1167, #127
  static nivel7-9 + #1168, #127
  static nivel7-9 + #1169, #127
  static nivel7-9 + #1170, #127
  static nivel7-9 + #1171, #127
  static nivel7-9 + #1172, #127
  static nivel7-9 + #1173, #127
  static nivel7-9 + #1174, #127
  static nivel7-9 + #1175, #127
  static nivel7-9 + #1176, #127
  static nivel7-9 + #1177, #127
  static nivel7-9 + #1178, #127
  static nivel7-9 + #1179, #127
  static nivel7-9 + #1180, #127
  static nivel7-9 + #1181, #127
  static nivel7-9 + #1182, #127
  static nivel7-9 + #1183, #127
  static nivel7-9 + #1184, #127
  static nivel7-9 + #1185, #127
  static nivel7-9 + #1186, #127
  static nivel7-9 + #1187, #127
  static nivel7-9 + #1188, #127
  static nivel7-9 + #1189, #127
  static nivel7-9 + #1190, #127
  static nivel7-9 + #1191, #127
  static nivel7-9 + #1192, #127
  static nivel7-9 + #1193, #127
  static nivel7-9 + #1194, #127
  static nivel7-9 + #1195, #127
  static nivel7-9 + #1196, #127
  static nivel7-9 + #1197, #127
  static nivel7-9 + #1198, #127
  static nivel7-9 + #1199, #127

