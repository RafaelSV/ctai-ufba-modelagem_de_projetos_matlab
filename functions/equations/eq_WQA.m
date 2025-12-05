function WQA = eq_WQA(x,Ts,P)
    % Estados atuais
    WTD=x(1);  WQA=x(2);
    WRC=x(3);  WAP=x(4);

    % Extrai constantes dos parâmetros
    Ktd=P(1);     Kqa=P(2);      Krc=P(3);      Kap=P(4);
    Ptd=P(5);     Pqa=P(6);      Prc=P(7);      Pap=P(8);
    Aqa=P(9);     Arc=P(10);     Aap=P(11);

    % Entrada é a vazão de saida do WTD
    Qin=Ktd*sqrt(WTD+Ptd);  

    % Fluxo de saida de QA
    Qout=Kqa*sqrt(WQA+Pqa);  % Saida para avaliar boa qualidade ou retrabalho

    % Expressão da Eq.Diferencial
    Derivada = Qin - Qout;

    % Atualização do Estado
    WQA = WQA + Ts*Derivada;

    % Proteção, já que não faz sentido quantidades negativas para reciclos
    WQA=max(WQA,0);
end