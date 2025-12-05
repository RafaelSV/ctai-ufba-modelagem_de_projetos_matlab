function Tasks = update_dependencies(Tasks, taskDependencies, startProject)
% Ativa 'Enable' quando todas as atividades predecessoras estão 'Finished'.
% Se startProject = true, ativa as tasks que não têm predecessores.

    n = numel(Tasks);

    for i = 1:n
        precedencies = find(taskDependencies(i,:) ~= 0);

        if isempty(precedencies)
            if startProject
                Tasks(i).Enable = 1;
            end
        else
            if all([Tasks(precedencies).Finished])
                Tasks(i).Enable = 1;
            end
        end
    end
end