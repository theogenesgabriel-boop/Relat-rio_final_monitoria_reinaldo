# Monitoria de Sistemas Digitais - EmbarcaTech 🚀

Este repositório contém o conjunto de projetos desenvolvidos durante a monitoria da disciplina de Sistemas Digitais, como parte da residência em FPGAs do programa **EmbarcaTech**.

O foco principal foi o desenvolvimento de sistemas complexos utilizando FPGAs, explorando processamento de vídeo, protocolos de comunicação e integração de processadores *soft-core*.

## 🛠️ Tecnologias e Ferramentas

* **Hardware:** FPGAs (Xilinx/AMD).
* **Linguagens de Descrição de Hardware (HDL):** Verilog.
* **Processador Soft-Core:** MicroBlaze (arquitetura RISC).
* **Linguagens de Programação:** C (para firmware e controle de periféricos).
* **Ferramentas de Desenvolvimento:** Vivado Design Suite / Vitis.

---

## 📂 Projetos Desenvolvidos

### 1. Processamento de Vídeo via HDMI

Implementação de interfaces de vídeo para geração e manipulação de sinais em tempo real.

* Geração de padrões de cores e sincronismo.
* Mapeamento de sinais para pinos físicos de saída de vídeo.

### 2. Integração de Sensores (MPU6050)

Leitura de dados inerciais (acelerômetro e giroscópio) utilizando o protocolo **I2C**.

* Implementação do mestre I2C em Verilog.
* Tratamento de dados brutos para monitoramento de movimento.

### 3. Captura de Imagem (Câmera OV7670)

Interfaceamento com o módulo de câmera CMOS para captura de frames.

* Configuração via SCCB (variante do I2C).
* Sincronismo de sinais `href`, `vsync` e `pclk`.

### 4. Comunicação Serial UART

Desenvolvimento de um módulo UART (Universal Asynchronous Receiver-Transmitter) completo para depuração e troca de dados com o PC.

* Módulos de recepção (`rx`) e transmissão (`tx`).
* Configuração de *baud rate* e bits de controle (*start/stop*).

### 5. Arquitetura MicroBlaze

Uso da sinergia entre hardware e software através da implementação de um processador MicroBlaze na FPGA.

* Instanciação de periféricos customizados.
* Desenvolvimento de drivers em C para controle de hardware.

---

## 🏗️ Estrutura do Módulo de Integração (`top`)

O projeto utiliza uma estrutura modular, centralizada em um arquivo `top` que gerencia:

* **Clock Management:** Sincronização via `sys_clk`.
* **Resets:** Lógica de `n_rst`.
* **I/O Mapping:** Conexão de sinais internos aos pinos físicos (LEDs, botões, sensores e pinos de comunicação).

---

Para manter o padrão visual e profissional do seu repositório de monitoria, adicionei uma seção de **Demonstrações Práticas**. Esta seção é ideal para mostrar os sistemas em funcionamento, o que agrega muito valor ao portfólio de um monitor.

Aqui está o trecho para você copiar e colar no seu `README.md`:

---

## 🎥 Demonstrações Práticas

Nesta seção, apresentamos o funcionamento integrado dos módulos desenvolvidos.
[![Assista ao vídeo](https://img.youtube.com/vi/wkxP92w58_g/0.jpg)](https://www.youtube.com/watch?v=wkxP92w58_g)
---



## 👨‍💻 Autor

**Theógenes Gabriel Araújo de Andrade** Orientador: **Reinaldo Götz de Oliveira Junior** *Juazeiro - BA, 2026*

---

> **Nota:** Este projeto foi desenvolvido sob o contexto do programa **CEPEDI / EmbarcaTech**.
