function Tasks = project_tasks(project_id)
% Carrega a planilha e retorna somente as rows do projeto informado.

    % Detecta importação e força 'predecessors' como string
    opts = detectImportOptions("TabelaProjetos.xlsx", 'Sheet', "Atividades");
    if any(strcmp(opts.VariableNames, 'predecessors'))
        opts = setvartype(opts, 'predecessors', 'char');
    end
    T = readtable("TabelaProjetos.xlsx", opts);

    % Seleciona as task do projeto selecionado
    colName = 'project_id';
    pid = string(project_id);
    if ismember(colName, T.Properties.VariableNames)
        if iscellstr(T.(colName)) || isstring(T.(colName))
            Tasks = T(string(T.(colName)) == pid, :);
        else
            Tasks = T(T.(colName) == str2double(regexprep(pid,'\D','')), :);
        end
    else
        Tasks = T;
    end

    disp("Tarefas carregadas para o projeto " + pid);
end