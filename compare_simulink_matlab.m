function compare_simulink_matlab(sim, excelFile)
% ---------------------------------------------------------
% Comparação MATLAB x Simulink
% Agora: curvas no mesmo gráfico + Delta separado
% ---------------------------------------------------------

    % ---------------------------
    % Carregar dados
    % ---------------------------
    T_enable   = readtable(excelFile, 'Sheet', 'Enable');
    T_finished = readtable(excelFile, 'Sheet', 'Finished');
    T_work     = readtable(excelFile, 'Sheet', 'Work');

    time_simulink = T_enable.time;

    Enable_sim   = T_enable{:,2:end};
    Finished_sim = T_finished{:,2:end};
    Work_sim     = T_work{:,2:end};    % 5 colunas

    % MATLAB
    time_mat = sim.time(:);
    Enable_mat   = sim.hist.enable;
    Finished_mat = sim.hist.fin;
    Work_mat     = squeeze(sim.hist.W);   % steps x tasks x 5
    Work_mat_total = squeeze(sum(Work_mat,2)); % steps x 5

    nTasks = size(Enable_mat, 2);

    % Ajustar tempo se necessário
    if ~isequal(time_simulink, time_mat)
        warning('Tempo diferente — ajustando via interp1');
        Enable_sim   = interp1(time_simulink, Enable_sim,   time_mat, 'nearest','extrap');
        Finished_sim = interp1(time_simulink, Finished_sim, time_mat, 'nearest','extrap');
        Work_sim     = interp1(time_simulink, Work_sim,     time_mat, 'linear','extrap');
        time_simulink = time_mat;
    end

    % ================================================================
    % 1) ENABLE — MATLAB + Simulink (mesmo gráfico)
    % ================================================================
    figure('Name','Enable — MATLAB x Simulink','Color','w');
    tiledlayout(nTasks, 2, 'TileSpacing','compact');

    for t = 1:nTasks
        
        % --- MATLAB + Simulink juntos ---
        nexttile;
        plot(time_mat, Enable_mat(:,t),'LineWidth',1.5); hold on;
        plot(time_simulink, Enable_sim(:,t),'--','LineWidth',1.5);
        title(sprintf('Enable — T%02d', t));
        legend('MATLAB','Simulink','Location','best');
        ylim([-0.1 1.1]); yticks([0 1]);
        grid on;

        % --- Delta ---
        nexttile;
        delta = Enable_mat(:,t) - Enable_sim(:,t);
        plot(time_mat, delta,'LineWidth',1.5);
        title(sprintf('Δ Enable — T%02d', t));
        ylim([-1.1 1.1]); yticks([-1 0 1]);
        grid on;
    end


    % ================================================================
    % 2) FINISHED — MATLAB + Simulink
    % ================================================================
    figure('Name','Finished — MATLAB x Simulink','Color','w');
    tiledlayout(nTasks, 2, 'TileSpacing','compact');

    for t = 1:nTasks
        
        % --- MATLAB + Simulink ---
        nexttile;
        plot(time_mat, Finished_mat(:,t),'LineWidth',1.5); hold on;
        plot(time_simulink, Finished_sim(:,t),'--','LineWidth',1.5);
        title(sprintf('Finished — T%02d', t));
        legend('MATLAB','Simulink','Location','best');
        ylim([-0.1 1.1]); yticks([0 1]);
        grid on;

        % --- Delta ---
        nexttile;
        delta = Finished_mat(:,t) - Finished_sim(:,t);
        plot(time_mat, delta,'LineWidth',1.5);
        title(sprintf('Δ Finished — T%02d', t));
        ylim([-1.1 1.1]); yticks([-1 0 1]);
        grid on;
    end


    % ================================================================
    % 3) WORK UNITS — MATLAB total + Simulink total
    % ================================================================
    Wnames = ["WTD","WQA","WRC","WAP","WD"];

    figure('Name','Work Units — MATLAB x Simulink','Color','w');
    tiledlayout(5, 2, 'TileSpacing','compact');

    for w = 1:5

        % --- MATLAB + Simulink ---
        nexttile;
        plot(time_mat, Work_mat_total(:,w),'LineWidth',1.7); hold on;
        plot(time_simulink, Work_sim(:,w),'--','LineWidth',1.7);
        title(sprintf('%s — MATLAB x Simulink', Wnames(w)));
        legend('MATLAB','Simulink','Location','best');
        grid on;

        % --- Delta ---
        nexttile;
        deltaW = Work_mat_total(:,w) - Work_sim(:,w);
        plot(time_mat, deltaW,'LineWidth',1.7);
        title(sprintf('Δ %s', Wnames(w)));
        grid on;
    end

    fprintf("\nPlot combinado MATLAB x Simulink gerado.\n");

    w = 5; % coluna de WD

    deltaW   = Work_mat_total(:,w) - Work_sim(:,w);
    maxDelta = max(abs(deltaW));
    maxWD    = max(Work_mat_total(:,w));
    relErr   = maxDelta / maxWD;
    
    fprintf('Max |ΔWD| = %.4f\n', maxDelta);
    fprintf('Max WD   = %.4f\n', maxWD);
    fprintf('Erro relativo máximo = %.6f (%.4f %%)\n', relErr, 100*relErr);

end
