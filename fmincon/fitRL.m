function [fitBy, rlParams] = fitRL(subj, alle)
    %addpath(sprintf('%s/rl_model/', pwd))
    
    %     nu    beta
    lb = [0.01  0.1];
    ub = [0.8   10 ];
    range = ub-lb;
    x0 = range.*rand(size(lb))+lb;
    options = optimoptions('fmincon', 'display', 'off');
    
        
    fitby = [];

    actualMoves = getResponses(alle);
   %shuffledMoves = Shuffle(actualMoves);

    rlfit = @(p) -1*nansum(log(1 - abs(actualMoves - doRL(alle, p))));

    thisx0 = (1+.1*randn(size(x0))).*x0;
    thisx0 = min(thisx0, ub);
    thisx0 = max(thisx0, lb);

    [rlParams,fval,exitflag,output] = fmincon(rlfit, thisx0, [], [], [], [], lb, ub, [], options);

    [rlMoveP, choiceProb] = doRL(alle, rlParams);
    rlMoves = round(rlMoveP);

    fitBy.Moves_rl_p = sum( (actualMoves - rlMoveP).^2 );
    fitBy.Moves_rl = nanmean(actualMoves == rlMoves);
    fitBy.loglik = -1*nansum(log(1 - abs(actualMoves - rlMoveP)));
    
    
    n = numel(actualMoves);
    k = length(range); % free parameters
    [aic,bic] = aicbic(fitBy.loglik, k, n);
    fitBy.BIC = bic;
    
    fitBy.chanceLoglik = -1*nansum(log(.5*ones(n,1)));
    [aic,bic] = aicbic(fitBy.chanceLoglik, k, n);
    fitBy.chanceBIC = bic;
    
    
    fitBy.AIC = 2*k - 2*nansum(log(choiceProb));
    fitBy.chanceAIC = 2*k - 2*nansum(log(.5*ones(n,1)));
    %aicc = aic + (2*k*(k+1))/(length(alle)-k-1);
