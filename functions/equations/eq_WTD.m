function [KeepWaiting,WTD] = eq_WTD(Waiting,enable,task_wu,x,Ts,P)
    % Estados atuais
    WTD=x(1);  WQA=x(2);
    WRC=x(3);  WAP=x(4);

    if Waiting & enable & sum(x)==0 % Valeu só para condição incial
        WTD=task_wu;    % Força condição inicial igual ao WU da respectiva atividade
        KeepWaiting=0;  % Não precisa mais esperar
    else
        KeepWaiting=1;  % Continuar esperando o ENABLE
    end

    % Extrai constantes dos parâmetros
    Ktd=P(1);     Kqa=P(2);      Krc=P(3);      Kap=P(4);
    Ptd=P(5);     Pqa=P(6);      Prc=P(7);      Pap=P(8);
    Aqa=P(9);     Arc=P(10);     Aap=P(11);

    % Calcula as entradas por retrabalho
    ReQA=Aqa*Kqa*sqrt(WQA+Pqa);  % Por revisão interna
    ReRC=Arc*Krc*sqrt(WRC+Prc);  % Por solicitação do cliente
    ReAP=Aap*Kap*sqrt(WAP+Pap);  % Por não aprovação final
    ReWork=ReQA+ReRC+ReAP;          % Total de retrabalho

    % Expressão da Eq.Diferencial
    Derivada = - Ktd*sqrt(WTD+Ptd) + ReWork;

    % Atualização do Estado
    WTD = WTD + Ts*Derivada;

    % Proteção, já que não faz sentido quantidades negativas para reciclos
    WTD=max(WTD,0);
end