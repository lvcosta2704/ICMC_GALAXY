# ICMC_GALAXY

**ICMC_GALAXY** é um jogo desenvolvido em **Assembly** no contexto da disciplina **Arquitetura e Organização de Computadores**. O projeto tem como finalidade explorar, na prática, os principais conceitos estudados durante a disciplina, incluindo:

- Manipulação de registradores e instruções de baixo nível
- Controle de fluxo e lógica de decisão
- Acesso e gerenciamento de memória
- Interação com dispositivos de entrada e saída
- Modelagem de algoritmos em linguagem Assembly
- Teste de executáveis ASM 

O jogo foi projetado para demonstrar como estruturas de software podem ser implementadas diretamente sobre a arquitetura MIPS, aproximando o estudante da relação entre **hardware** e **software**.

## 📁 Conteúdo do repositório
- Código-fonte do jogo em Assembly totalmente documentado.
- Arquivos de teste das intruções do Processador ICMC (cpuram4.mif e TestaCPUmodificado.asm).
- Implementação em C do Processador ICMC (simple_simulalator_template.c).
- Charmap.mif modificado com caracteres especiais criados pelo grupo no SOftware de Criação de Telas em Assembly.
- 

## ▶️ Como executar
1. Tenha em mãos o simulador e o montador do processador ICMC funcionando.
2. Monte de forma correta o .asm para um .mif.
3. Execute o .mif com o Charmap.mif disponibilizado no Repositório
4. Jogue o jogo e aproveite!!

## 🎮 Como Jogar
### 🎮 Controles do Jogo

| Ação            | Tecla        |
|-----------------|--------------|
| Mover à direita | **D**        |
| Mover à esquerda| **A**        |
| Atirar          | **Espaço**   |

### 🖥️ Mudança de Telas por Nível

As cores das telas variam conforme o nível alcançado pelo jogador:

- **Níveis 1 a 3:** Tela **azul**
- **Níveis 4 a 6:** Tela **verde**
- **Níveis 7 a 9:** Tela **vermelha**

### 📸 Screenshots

Aqui estão algumas imagens das telas do nosso jogo:

![Tela de início](/screenshots_icmc_galaxy/TelaInicioFinal.png)
![Tela de GameOver](/screenshots_icmc_galaxy/GameOver.png)
![Tela de Vencer](/screenshots_icmc_galaxy/telawin.png)
![Tela de Nível 1-3](/screenshots_icmc_galaxy/nivel1-3.png)
![Tela de Nível 4-6](/screenshots_icmc_galaxy/nivel4-6.png)
![Tela de Nível 7-9](/screenshots_icmc_galaxy/nivel7-9.png)


## 🎯 Objetivo educacional
Este projeto reforça o entendimento de como conceitos de organização e arquitetura de computadores se traduzem em implementações práticas, tornando evidente a relação entre instruções em baixo nível e o comportamento do software. Além disso o jogo criado explora uma diversidade de funcionalidades que são muito importantes no mundo dos jogos, como colisão, movimento. lógicas de nível, controle de variáveis e muito mais.

---
Sinta-se à vontade para contribuir, melhorar o código ou adaptar o jogo para novas funcionalidades!
