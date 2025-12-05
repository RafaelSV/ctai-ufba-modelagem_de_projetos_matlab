function plot_project_results(sim, Tasks, proj_enable_flag, proj_finished_flag, baselineFile, saveBaseline)

    nTasks = numel(Tasks);
    varNames = {'WTD','WQA','WRC','WAP','WD'};
    sumW = squeeze(sum(sim.hist.W, 2));  % soma por coluna (WTD..WD)
    
    %% ============================================================
    % Work Done acumulado por Task
    %% ============================================================
    figure('Name','Progresso das Tasks','Color','w');
    tiledlayout(nTasks,1,'TileSpacing','tight');
    
    for i = 1:nTasks
        nexttile;
        plot(sim.time, squeeze(sim.hist.W(:,i,5)), 'LineWidth', 1.6);
        grid on; ylabel(sprintf('T%02d', i), 'FontWeight','bold');
        if i == 1
            title('Work Done (acumulado)','FontWeight','bold');
        end
        if i < nTasks
            set(gca,'XTickLabel',[]);
        else
            xlabel('Tempo (TU)');
        end
    end
    
    
    %% ============================================================
    % Flags de Finished
    %% ============================================================
    figure('Name','Conclusão das Tasks','Color','w');
    tiledlayout(nTasks,1,'TileSpacing','tight');
    
    for i = 1:nTasks
        nexttile;
        plot(sim.time, sim.hist.fin(:,i), 'LineWidth', 1.6);
        ylim([-0.1 1.1]);
        yticks([0 1]);
        yticklabels({'Ativa','Concluída'});
        grid on;
        ylabel(sprintf('T%02d', i), 'FontWeight','bold');
        if i == 1
            title('Sinal "Finished" das Tasks','FontWeight','bold');
        end
        if i < nTasks
            set(gca,'XTickLabel',[]);
        else
            xlabel('Tempo (TU)');
        end
    end
    
    
    %% ============================================================
    % W's por Task (detalhado)
    %% ============================================================
    for i = 1:nTasks
        figure('Name', sprintf("Progresso dos W's - Task %02d", i), 'Color', 'w');
        tiledlayout(5,1,'TileSpacing','tight');
        for j = 1:5
            nexttile;
            plot(sim.time, squeeze(sim.hist.W(:,i,j)), 'LineWidth', 1.6);
            grid on;
            ylabel(varNames{j}, 'FontWeight','bold');
            if j == 1
                title(sprintf('Task %02d - Progresso Work Units', i), 'FontWeight','bold');
            end
            if j < 5
                set(gca,'XTickLabel',[]);
            else
                xlabel('Tempo (TU)');
            end
        end
    end
    
    
    %% ============================================================
    % Work Units acumulados do projeto
    %% ============================================================
    figure('Name','Progresso geral do projeto','Color','w');
    tiledlayout(5,1,'TileSpacing','tight');
    
    for j = 1:5
        nexttile;
        plot(sim.time, sumW(:,j), 'LineWidth', 1.8);
        grid on;
        ylabel(varNames{j}, 'FontWeight','bold');
        if j == 1
            title('Progresso Work Units acumulado do projeto','FontWeight','bold');
        end
        if j < 5
            set(gca,'XTickLabel',[]);
        else
            xlabel('Tempo (TU)');
        end
    end
    
    
    %% ============================================================
    % Timeline do Projeto (Enable → Finished)
    %% ============================================================
    figure('Name','Linha do tempo do Projeto','Color','w');
    plot(sim.time, sumW(:,5), 'LineWidth', 2);
    grid on; hold on;
    
    xline(proj_enable_flag,  '--g','Enable Projeto',  'LineWidth',1.6,'LabelOrientation','horizontal');
    xline(proj_finished_flag,'--r','Finished Projeto','LineWidth',1.6,'LabelOrientation','horizontal');
    
    title('Timeline do Projeto (Enable → Finished)','FontWeight','bold');
    xlabel('Tempo (TU)');
    ylabel('WD Total');
    
    
    %% ============================================================
    % Salvar baseline (opcional)
    %% ============================================================
    if saveBaseline
        Tbaseline = table(sim.time, sumW(:,1), sumW(:,2), sumW(:,3), sumW(:,4), sumW(:,5), ...
            'VariableNames', {'time','WTD','WQA','WRC','WAP','WD'});
    
        Tbaseline.EnableProjeto   = repmat(proj_enable_flag, sim.steps, 1);
        Tbaseline.FinishedProjeto = repmat(proj_finished_flag, sim.steps, 1);
    
        writetable(Tbaseline, baselineFile);
        fprintf('\nBaseline salva em: %s\n', baselineFile);
    end
    
    
    %% ============================================================
    % Execução Atual vs Baseline (5 W's)
    %% ============================================================
    loadBaseline = true;
    
    if loadBaseline && isfile(baselineFile)
    
        BL = readtable(baselineFile);
    
        BL_interp = array2table(sim.time, 'VariableNames', {'time'});
        for j = 1:5
            BL_interp.(varNames{j}) = interp1(BL.time, BL.(varNames{j}), sim.time, 'linear', 'extrap');
        end
    
        BL_enable   = BL.EnableProjeto(1);
        BL_finished = BL.FinishedProjeto(1);
    
        figure('Name','Execução Atual vs Baseline','Color','w');
        tiledlayout(5,1,'TileSpacing','compact');
    
        for j = 1:5
            nexttile;
            plot(sim.time, sumW(:,j), 'LineWidth', 1.6); hold on;
            plot(sim.time, BL_interp.(varNames{j}), '--', 'LineWidth', 1.4);
            grid on;
            ylabel(varNames{j});
    
            if j == 1
                title('Execução Atual vs Baseline','FontWeight','bold');
                legend('Atual','Baseline','Location','best');
            end
    
            if j < 5
                set(gca,'XTickLabel',[]);
            else
                xlabel('Tempo (TU)');
            end
        end
    
    
        %% ============================================================
        % Comparação Atual x Baseline
        %% ============================================================
        figure('Name','Timeline do Projeto — Atual x Baseline','Color','w');
        hold on; grid on;
    
        title('Timeline do Projeto — Atual x Baseline','FontWeight','bold');
        xlabel('Tempo (TU)');
        ylim([0.5 2.5]);
        yticks([1 2]);
        yticklabels({'Execução Atual','Baseline'});
    
        c_atual = [0.15 0.55 1];
        c_base  = [1 0.30 0.65];
    
        duration_atual = proj_finished_flag - proj_enable_flag;
        duration_base  = BL_finished - BL_enable;
        bar_height = 0.25;
    
        rectangle('Position',[proj_enable_flag, 0.85, duration_atual, bar_height], ...
                  'FaceColor', c_atual, 'EdgeColor','k','LineWidth',1.2);
        text(proj_enable_flag + duration_atual/2, 1.20, sprintf('Duração = %.1f', duration_atual), ...
             'HorizontalAlignment','center','FontWeight','bold','Color',c_atual);
    
        rectangle('Position',[BL_enable, 1.85, duration_base, bar_height], ...
                  'FaceColor', c_base, 'EdgeColor','k','LineWidth',1.2);
        text(BL_enable + duration_base/2, 2.20, sprintf('Duração = %.1f', duration_base), ...
             'HorizontalAlignment','center','FontWeight','bold','Color',c_base);
    
        left  = min(proj_enable_flag, BL_enable);
        right = max(proj_finished_flag, BL_finished);
        margin = max(1, 0.1 * (right - left));
        xlim([left - margin, right + margin]);
    
        xl = xlim;
        dx = xl(2) - xl(1);
    
        text(xl(1) + dx*0.02, 2.0, ...
             sprintf('ΔStart = %.1f', proj_enable_flag - BL_enable), ...
             'HorizontalAlignment','left','FontWeight','bold');
    
        text(xl(2) - dx*0.20, 1.0, ...
             sprintf('ΔEnd = %.1f', proj_finished_flag - BL_finished), ...
             'HorizontalAlignment','left','FontWeight','bold');
    
    end

end
