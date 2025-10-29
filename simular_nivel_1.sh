#!/bin/bash
#
# Script para compilar, executar e visualizar a simulação do 'Nivel 1 - Elevador'
#

# --- Configuração ---
# Define o "strict mode". O script irá parar se qualquer comando falhar.
set -e

# O nome da sua entidade de testbench
TB_ENTITY="tb_nivel_1_elevador"

# O nome do arquivo .vcd de saída
VCD_FILE="simulacao_nivel_1.vcd"

# O diretório onde os arquivos do Nível 1 estão
DIR_NIVEL_1="Nível 1 - Elevador"

# --- Execução ---

echo "Iniciando script de simulação VHDL..."

# 1. Navega para o diretório de compilação
echo "Navegando para $DIR_NIVEL_1/..."
cd "$DIR_NIVEL_1"

echo "Compilando componentes (peças) do 'src'..."

# 2. Compila TODAS as 7 "peças" (componentes) do diretório 'src'
#    na ordem de dependência (opcional, mas boa prática)
ghdl -a src/det_andar.vhd
ghdl -a src/door.vhd
ghdl -a src/motor.vhd
ghdl -a src/bcd_to_7seg.vhd
ghdl -a src/displays.vhd
ghdl -a src/floor_controller.vhd
ghdl -a src/queue_registers.vhd
ghdl -a src/elevator_controller.vhd

echo "Compilando 'nivel_1_elevador' (Top-Level)..."
# 3. Compila o arquivo "top-level" que junta todas as peças
ghdl -a src/nivel_1_elevador.vhd

echo "Compilando testbench '$TB_ENTITY'..."
# 4. Compila o testbench para o "top-level"
ghdl -a tbs/tb_nivel_1_elevador.vhd

echo "Elaborando testbench '$TB_ENTITY'..."
# 5. Elabora o testbench
ghdl -e $TB_ENTITY

echo "Executando simulação e gerando '$VCD_FILE'..."
# 6. Executa e cria o arquivo VCD
ghdl -r $TB_ENTITY --vcd=$VCD_FILE

echo "Abrindo GTKWave..."
# 7. Abre o resultado no GTKWave
gtkwave $VCD_FILE

echo "Script concluído com sucesso."