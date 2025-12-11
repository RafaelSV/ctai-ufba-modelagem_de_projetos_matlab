% ------------------------------------------------------
% Exportar resultados do Simulink (struct "out") para Excel
% ------------------------------------------------------

% Nome do arquivo a ser gerado
xlsFile = 'Simulink_Output.xlsx';

% Extrair variáveis do Simulink
Enable   = out.Enable;     % [steps x nTasks]
Finished = out.Finished;   % [steps x nTasks]
W        = out.W;          % [steps x 5]
time     = out.tout(:);    % vetor coluna

% Criar tabela para Enable
T_enable = array2table([time, Enable], ...
    'VariableNames', ['time', strcat("T", string(1:size(Enable,2)))]);

% Criar tabela para Finished
T_finished = array2table([time, Finished], ...
    'VariableNames', ['time', strcat("T", string(1:size(Finished,2)))]);

% Criar tabela para Work Units
WU_names = ["WTD","WQA","WRC","WAP","WD"];
T_W = array2table([time, W], ...
    'VariableNames', ['time', WU_names]);

% Gravar no Excel
writetable(T_enable,   xlsFile, 'Sheet', 'Enable');
writetable(T_finished, xlsFile, 'Sheet', 'Finished');
writetable(T_W,        xlsFile, 'Sheet', 'Work');

fprintf('Arquivo Excel gerado: %s\n', xlsFile);