function Dep = build_dependencies(Tasks)
% Cria matriz de dependências Dep(i,j)

    if ~ismember('predecessors', Tasks.Properties.VariableNames)
        error("A tabela não contém a coluna 'predecessors'.");
    end

    if ~ismember('task_id', Tasks.Properties.VariableNames)
        error("A tabela não contém a coluna 'task_id'.");
    end

    task_ids = Tasks.task_id;
    n = numel(task_ids);
    Dep = zeros(n);

    for i = 1:n
        raw = Tasks.predecessors(i);

        if iscell(raw)
            raw = raw{1};
        end
        
        % Skip caso não tenha predecessores
        if ~isempty(raw)
            % Converte para string e limpa caracteres estranhos
            raw = string(raw);
            raw = strrep(raw, ' ', '');
            raw = strrep(raw, ';', ',');
            raw = strrep(raw, '.', ',');
            raw = regexprep(raw, '[^0-9,]', ''); % mantém apenas dígitos e vírgula
    
            if raw == "" || raw == "0"
                continue;
            end
        end

        % Divide e converte em números (para tasks com varias precedencias)
        parts = split(raw, ',');
        precedencies = str2double(parts);
        precedencies = precedencies(~isnan(precedencies) & precedencies > 0);

        % Marca dependências
        for p = precedencies'
            idx = find(task_ids == p, 1);
            if ~isempty(idx)
                Dep(i, idx) = 1;
            else
                warning('Predecessor %d não encontrado para a task %d.', p, task_ids(i));
            end
        end
    end
end