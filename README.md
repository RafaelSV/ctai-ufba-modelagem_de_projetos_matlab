# Modelagem de Projetos em MATLAB
Simulacao em MATLAB que reimplementa o modelo original do Simulink ('Modelos.slx') para avaliar a execucao de projetos usando equacoes diferenciais e relações de precedências entre atividades.

## Visao geral
- Entrada: planilha 'TabelaProjetos.xlsx' (aba "Atividades") com tarefas, parametros e precedencias do projeto; Além disso carrega baseline de 'BaseLine_sim_matlab.xlsx' para comparação.
- Core: 'main_simulation.m' constroi as tarefas, aplica as dinamicas (WTD, WQA, WRC, WAP, WD) e roda a simulacao.
- Saida: graficos que mostram progresso por tarefa, finalizacao do projeto e comparacao com baseline. Opcionalmente salva um baseline em 'BaseLine_sim_matlab.xlsx' para comparação.

## Estrutura dos arquivos
- 'main_simulation.m': script principal; instancia tarefas, roda o loop e plota resultados.
- 'CarregaDados.m': carrega dados, define parametros globais 'P' e escolhe o projeto ativo em 'P.Projects'.
- 'functions/project_tasks.m': le 'TabelaProjetos.xlsx' e filtra o projeto pela coluna 'project_id'.
- 'functions/build_dependencies.m': monta matriz de precedencias a partir da coluna 'predecessors'.
- 'functions/update_dependencies.m': habilita tarefas quando predecessoras estao finalizadas.
- 'functions/run_task.m': avanca estados da tarefa usando as equacoes em 'functions/equations'.
- 'functions/plot_project_results.m': gera graficos de progresso, finalizacao e comparacao com baseline.
- 'BaseLine.xlsx', 'Baseline_Agregado.xlsx': referencias para comparacao de execucoes.
- 'Modelos.slx': modelo original em Simulink (mantido como referencia).

## Requisitos de dados
A planilha 'TabelaProjetos.xlsx' deve ter, no minimo, as colunas:
- 'project_id', 'task_id', 'predecessors'
- 'wu', 'Ktd', 'Kqa', 'Krc', 'Kap', 'Ptd', 'Pqa', 'Prc', 'Pap', 'Aqa', 'Arc', 'Aap'
- 'expected_date_ini', 'expected_date_end' (datas usadas para calcular 'P.Tsim')

Regras de precedencia: 'predecessors' pode listar IDs separados por virgula, ponto-e-virgula ou ponto; vazio ou "0" significa sem predecessores.

## Como executar a simulacao
1) Abrir o MATLAB no diretorio raiz do projeto.
2) Se quiser trocar o projeto, edite 'P.Projects' em 'CarregaDados.m' e garanta que o ID existe na planilha.
3) Executar 'main_simulation.m'.
4) Conferir os graficos gerados. Em 'main_simulation.m', voce pode ajustar:
   - 'baselineFile': caminho do baseline para comparar.
   - 'saveBaseline': 'true' para salvar o baseline da execucao atual.

## Comparar MATLAB vs Simulink
- Ja existe um arquivo de exemplo no repositorio para ver a comparacao pronta.
- Para gerar do zero: 
  1) rode a simulacao no Simulink ('Modelos.slx'); 
  2) execute 'export.m' para salvar os resultados do Simulink; 
  3) execute 'main_simulation.m', que vai gerar os graficos originais mais as curvas lado a lado das duas simulacoes.

## Saidas esperadas
- Work Done (WD) acumulado por tarefa e total do projeto.
- Sinais de 'Enable' e 'Finished' de cada tarefa ao longo do tempo.
- Linha do tempo do projeto com instantes de habilitacao e conclusao.
- Graficos Execucao Atual vs Baseline (5 Ws e duracao total).
- Garficos de comparação dos Enables, Finisheds e Works