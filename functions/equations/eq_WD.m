function WD = eq_WD(x,Ts,P)
    % Estados atuais
    WTD=x(1);  WQA=x(2);
    WRC=x(3);  WAP=x(4);
    WD=x(5);

    % Extrai constantes dos parâmetros
    Ktd=P(1);     Kqa=P(2);      Krc=P(3);      Kap=P(4);
    Ptd=P(5);     Pqa=P(6);      Prc=P(7);      Pap=P(8);
    Aqa=P(9);     Arc=P(10);     Aap=P(11);

    % Entrada é a vazão de saida do tanque WAP, descontados os retrabalhos de AP
    Qin=(1-Aap)*Kap*sqrt(WAP+Pap);  

    % Expressão da Eq.Diferencial
    Derivada = Qin;    % Só acumula infinitamente o trabalho realizado

    % Atualização do Estado
    WD = WD + Ts*Derivada;

    % Proteção, já que não faz sentido quantidades negativas para reciclos
    WD=max(WD,0);
end