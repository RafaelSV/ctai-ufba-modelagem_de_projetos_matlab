function [Task, Done] = run_task(Task, Ts)
% Atualiza os estados da Task e calcula Finished

    % Estados atuais em vetor
    W = [Task.WTD, Task.WQA, Task.WRC, Task.WAP, Task.WD];

    % Equações
    [keep, WTD] = eq_WTD(Task.Waiting, Task.Enable, Task.wu, W, Ts, Task.Params);
    Task.WTD    = WTD;
    Task.Waiting= keep; % realimenta "Waiting"

    Task.WQA = eq_WQA([Task.WTD, Task.WQA, Task.WRC, Task.WAP, Task.WD], Ts, Task.Params);
    Task.WRC = eq_WRC([Task.WTD, Task.WQA, Task.WRC, Task.WAP, Task.WD], Ts, Task.Params);
    Task.WAP = eq_WAP([Task.WTD, Task.WQA, Task.WRC, Task.WAP, Task.WD], Ts, Task.Params);
    Task.WD  = eq_WD ([Task.WTD, Task.WQA, Task.WRC, Task.WAP, Task.WD], Ts, Task.Params);

    % Seta o Done
    Done = fcn_done(Task.Enable, [Task.WTD, Task.WQA, Task.WRC, Task.WAP]);
end