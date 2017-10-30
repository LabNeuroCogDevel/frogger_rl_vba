function [fitBy, rlParams] = fitAllRL(subj, alle)
    %addpath(sprintf('%s/rl_model/', pwd))
    
    models = {'nubeta','decay','invNweight'};
    actualMoves = getResponses(alle);
    options = optimoptions('fmincon', 'display', 'off');
    nreps = 20;
    
    fitby = [];
    
    for modeli = 1:length(models)
        
        
        model = models{modeli};
        
        switch model
            
            case 'nubeta'
                %     nu    beta
                lb = [0.01  0.1];
                ub = [0.8   10 ];
                range = ub-lb;
                rlfit = @(p) -1*nansum(log(1 - abs(actualMoves - doRL(alle, p))));
                
            case 'decay'
                %     nu    beta   decayrate
                lb = [0.01  0.1    0.01];
                ub = [0.8   10     0.8];
                range = ub-lb;
                rlfit = @(p) -1*nansum(log(1 - abs(actualMoves - doRL_decay(alle, p))));
                
            case 'invNweight'
                %     nu    beta   invNweight
                lb = [0.01  0.1    -0.8];
                ub = [0.8   10     0.8];
                range = ub-lb;
                rlfit = @(p) -1*nansum(log(1 - abs(actualMoves - doRL_invNweight(alle, p))));

        end
        

        thisparams = [];
        thisfit = [];
        for repi = 1:nreps
            
            thisx0 = range.*rand(size(lb))+lb;
            thisx0 = min(thisx0, ub);
            thisx0 = max(thisx0, lb);

            [p,fval,exitflag,output] = fmincon(rlfit, thisx0, [], [], [], [], lb, ub, [], options);
            thisparams(repi,:) = p;
            
            [rlMoveP, choiceProb] = doRL(alle, thisparams(repi,:));
            rlMoves = round(rlMoveP);

            thisfit(repi).Moves_rl_p = sum( (actualMoves - rlMoveP).^2 );
            thisfit(repi).Moves_rl = nanmean(actualMoves == rlMoves);
            thisfit(repi).loglik = -1*nansum(log(1 - abs(actualMoves - rlMoveP)));


            n = numel(actualMoves);
            k = length(range); % free parameters
            [aic,bic] = aicbic(thisfit(repi).loglik, k, n);
            thisfit(repi).BIC = bic;

            thisfit(repi).chanceLoglik = -1*nansum(log(.5*ones(n,1)));
            [aic,bic] = aicbic(thisfit(repi).chanceLoglik, k, n);
            thisfit(repi).chanceBIC = bic;


            thisfit(repi).AIC = 2*k - 2*nansum(log(choiceProb));
            thisfit(repi).chanceAIC = 2*k - 2*nansum(log(.5*ones(n,1)));
            
        end
        
        [bestloglik, besti] = min([thisfit.loglik]);
        fitBy.(model) = thisfit(besti);
        rlParams.(model) = thisparams(besti,:);
        

    end