clc
clear all
close all

% Configuração do path
addpath(genpath(fileparts(mfilename('fullpath'))));

% PARÂMETROS DA SIMULAÇÃO (TODOS NA VARIÁVEL "P")
P=struct;

% Numero de projetos na simulação (Só preparando o terreno para termos
% ambiente de análise de vários projetos
P.Projects={"EV-00000","EV-01307","EV-01632","EV-01324"};      

% Nomes das variáveis padrão, as quais agrupam todos os parâmetros de
% simulação de uma atividade específica em qualquer projeto
P.NomesVariaveis={'Tempo','Enable','Finished','WTD','WQA','WRC','WAP','WD'};

% Carrega parâmetros de simulação com base na tabela de atividades do projeto
P.Tasks=project_tasks(P.Projects{1});  % Atividades do projeto selecionado

% Campos esperados na Tabela 'P.Tasks'
reqCols = {'task_id','wu','Ktd','Kqa','Krc','Kap','Ptd','Pqa','Prc','Pap','Aqa','Arc','Aap'};
missing = setdiff(reqCols, string(P.Tasks.Properties.VariableNames));
if ~isempty(missing)
    error("Faltam colunas na planilha TabelaProjetos.xlsx: %s", strjoin(missing,', '));
end

% Nossa unidade de tempo será "TU" (time unit), por exemplo, dia
P.Ts=0.01;      % Sample Time 0.01 TU   (estas 100 medidas em uma TU é apenas para evitar erros numéricos pela integração)
%P.Tsim=200;    % Tempo para a simulação (em TU)

% Resgata número de dias do projeto, com base nos registros de data_ini e data_fim
Tsim=days(max(P.Tasks.expected_date_end)-min(P.Tasks.expected_date_ini));   
P.Tsim=Tsim*1.5;   % 50% a mais que o tempo aprovado para o projeto

% Usamos uma tabela salva de simulação anterior para ser o BaseLine
P.BaseLine=readtable("BaseLine.XLSX");  % Para ser guardada como referência | APENAS PARA EXECUÇÃO DO SIMULINK
BaseLine=table2array(P.BaseLine);       % Será também ilustrada na simulação corrente