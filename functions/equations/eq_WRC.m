function WRC = eq_WRC(x,Ts,P)
    % Estados atuais
    WTD=x(1);  WQA=x(2);
    WRC=x(3);  WAP=x(4);

    % Extrai constantes dos parâmetros
    Ktd=P(1);     Kqa=P(2);      Krc=P(3);      Kap=P(4);
    Ptd=P(5);     Pqa=P(6);      Prc=P(7);      Pap=P(8);
    Aqa=P(9);     Arc=P(10);     Aap=P(11);

    % Entrada é a vazão de saida do tanque WQA, descontados os retrabalhos de QA
    Qin=(1-Aqa)*Kqa*sqrt(WQA+Pqa);  

    % Fluxo de saida de QRC
    Qout=Krc*sqrt(WRC+Prc);  % Saida para avaliar aprovação pelo cliente ou retrabalho

    % Expressão da Eq.Diferencial
    Derivada = Qin - Qout;

    % Atualização do Estado
    WRC = WRC + Ts*Derivada;

    % Proteção, já que não faz sentido quantidades negativas para reciclos
    WRC=max(WRC,0);
end