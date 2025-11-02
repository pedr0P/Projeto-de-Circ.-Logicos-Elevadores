# Projeto-de-Circ.-Logicos-Elevadores
Como compilar os dois níveis (independentemente).

## Nível 1:
    - Execução do `simular_nivel_1.sh`
## Nível 2:
    - (Dentro da pasta: Nível 2 - Escalonador), execute os seguintes comandos e analise as saídas do gerador_saida no GTKWAVE:
        ``` bash
        mkdir work ;
        ghdl -a --workdir=work src/call_disp.vhdl ;
        ghdl -a --workdir=work src/comparador_custo.vhd ;
        ghdl -a --workdir=work src/cost_calculator.vhd ;
        ghdl -a --workdir=work src/custo_distancia.vhdl ;
        ghdl -a --workdir=work src/fila.vhdl ;
        ghdl -a --workdir=work src/gerador_saida.vhd ;

        ghdl -e --workdir=work call_disp ;
        ghdl -e --workdir=work comparador_custo ;
        ghdl -e --workdir=work cost_calculator ;
        ghdl -e --workdir=work custo_distancia ;
        ghdl -e --workdir=work fila ;
        ghdl -e --workdir=work gerador_saida ;

        ghdl -a --workdir=work src/nivel_2.vhdl ;
        ghdl -e --workdir=work nivel_2 ;

        ghdl -a --workdir=work tbs/tb_nivel_2.vhdl ;
        ghdl -e --workdir=work tb_nivel_2 ;
        ghdl -r --workdir=work tb_nivel_2 --vcd=nivel_2.vcd ;
        gtkwave nivel_2.vcd
        ```
