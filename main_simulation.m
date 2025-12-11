%% ---------------------------
% Inicialização
% ----------------------------

CarregaDados

T = P.Tasks; % linhas = tasks
nTasks = height(T);

%% ---------------------------
% Setup de variaveis gerais
% ----------------------------
sim.Ts       = P.Ts;
sim.Tsim     = P.Tsim;
sim.delay    = 10; % atraso so pra ficar igual o modelo (da pra ajustar pra ser de fato um delay nos enable)
sim.steps    = floor(sim.Tsim/sim.Ts) + 1;
sim.time     = ((0:sim.steps-1)' * sim.Ts);
sim.nMetrics = 5; % [WTD,WQA,WRC,WAP,WD]

% Seta variaveis de históricos
sim.hist.W   = zeros(sim.steps, nTasks, sim.nMetrics); % WTD,WQA,WRC,WAP,WD
sim.hist.fin = zeros(sim.steps, nTasks); % Finished (0/1)
sim.hist.enable = zeros(sim.steps, nTasks); % Enable (0/1)

%% ---------------------------
% Construção das Tasks
% ----------------------------

Tasks = repmat(struct(), nTasks,1);

for i = 1:nTasks
    Tasks(i).id        = T.task_id(i);
    Tasks(i).Enable    = 0;
    Tasks(i).Finished  = 0;

    % Estados
    Tasks(i).WTD = 0; Tasks(i).WQA = 0; Tasks(i).WRC = 0; Tasks(i).WAP = 0; Tasks(i).WD = 0;

    % Waiting/KeepWaiting (para condição inicial do WTD = wu)
    Tasks(i).Waiting = 1; % começa "esperando"
    Tasks(i).wu = T.wu(i); % work-up-front da atividade

    % Vetor de parâmetros (11 constantes por task)
    Tasks(i).Params = [ ...
        T.Ktd(i),  T.Kqa(i),  T.Krc(i),  T.Kap(i), ...
        T.Ptd(i),  T.Pqa(i),  T.Prc(i),  T.Pap(i), ...
        T.Aqa(i),  T.Arc(i),  T.Aap(i) ...
    ];
end

% Cria as relações de precedencias com base na TabelaProjetos
taskDependencies = build_dependencies(T);

% Tarefas sem predecessores começam habilitadas
% Tasks = update_dependencies(Tasks, taskDependencies, true);
proj_started = false;

%% ---------------------------
% Loop de simulação
% ----------------------------
for k = 1:sim.steps

    if ~proj_started && sim.time(k) >= sim.delay
        Tasks = update_dependencies(Tasks, taskDependencies, true);
        proj_started = true;
    end

    % Executa cada task habilitada
    for i = 1:nTasks
        if Tasks(i).Enable && ~Tasks(i).Finished
            [Tasks(i), Tasks(i).Finished] = run_task(Tasks(i), sim.Ts);
        end
    end

    % Atualiza Enables a partir das dependências
    Tasks = update_dependencies(Tasks, taskDependencies, false);

    % Guarda histórico
    for i = 1:nTasks
        sim.hist.W(k,i,:)   = [Tasks(i).WTD, Tasks(i).WQA, Tasks(i).WRC, Tasks(i).WAP, Tasks(i).WD];
        sim.hist.fin(k,i)   = Tasks(i).Finished;
        sim.hist.enable(k,i) = Tasks(i).Enable;
    end

    % Projeto habilitado quando qualquer task é habilitada pela primeira vez
    if k == 1
        proj_enable_flag = 0;
    end
    if proj_enable_flag == 0 && any([Tasks.Enable] == 1)
        proj_enable_flag = sim.time(k);   % registra instante de habilitação
    end
    
    % Projeto finaliza quando TODAS as tasks estão finished
    if k == 1
        proj_enable_flag   = 0;
        proj_finished_flag = 0;
    end
    if proj_enable_flag == 0 && any([Tasks.Enable] == 1)
        proj_enable_flag = sim.time(k);   % registra instante de habilitação
    end
    if proj_finished_flag == 0 && all([Tasks.Finished] == 1)
        proj_finished_flag = sim.time(k); % registra instante final
    end

end

%% ---------------------------
% Plot
% ----------------------------

% plot_project_results
baselineFile = 'Baseline_sim_matlab.xlsx';
saveBaseline = false;
plot_project_results(sim, Tasks, proj_enable_flag, proj_finished_flag, baselineFile, saveBaseline);