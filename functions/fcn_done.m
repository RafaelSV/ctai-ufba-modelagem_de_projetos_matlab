function Done = fcn_done(enable, Work)
  if (enable) && (sum(Work(1:4))==0) % Habilitado mas não tem mais nada para fazer
    Done = 1; % Trabalho feito
  else
    Done = 0; % Ainda há trabalho por fazer
  end
end
