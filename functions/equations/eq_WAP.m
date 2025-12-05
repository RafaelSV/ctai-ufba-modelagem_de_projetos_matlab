function WAP = eq_WAP(x,Ts,P)
    % Estados atuais
    WTD=x(1);  WQA=x(2);
    WRC=x(3);  WAP=x(4);

    % Extrai constantes dos parâmetros
    Ktd=P(1);     Kqa=P(2);      Krc=P(3);      Kap=P(4);
    Ptd=P(5);     Pqa=P(6);      Prc=P(7);      Pap=P(8);
    Aqa=P(9);     Arc=P(10);     Aap=P(11);

    % Entrada é a vazão de saida do tanque WRC, descontados os retrabalhos de RC
    Qin=(1-Arc)*Krc*sqrt(WRC+Prc);  

    % Fluxo de saida de QAP
    Qout=Kap*sqrt(WAP+Pap);  % Saida para avaliar trabalho aprovado ou retrabalho por não aprovação

    % Expressão da Eq.Diferencial
    Derivada = Qin - Qout;

    % Atualização do Estado
    WAP = WAP + Ts*Derivada;

    % Proteção, já que não faz sentido quantidades negativas para reciclos
    WAP=max(WAP,0);
end