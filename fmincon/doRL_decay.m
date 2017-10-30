function [predictedResp, choiceProb, V] = doRL_decay(alle, p)
    
    % parameters
    nu = p(1);
    beta = p(2);
    decayrate = p(3);
    
    % constants
    values.null = 0;
    values.low = 0.5;
    values.high = 1;
   
    
    nTrials = numel(alle);
    
    % Initialize expected value array
    V = zeros(3,3);
    
    % Loop through trials
    for ei = 1:nTrials

        % get movement options
        mx = [alle(ei).moveOpts(1).x alle(ei).moveOpts(2).x];
        my = [alle(ei).moveOpts(1).y alle(ei).moveOpts(2).y];
        
        % did subject respond?
        gaveResponse = ~isnan(alle(ei).times.moveResponse);
        
        % if not, set vectors to NaN so they don't contribute to
        % loglikelihood
        if ~gaveResponse
            predictedResp(ei) = NaN;
            choiceProb(ei) = 1;
        end
        
        % what do we think the subject will do
        V1 = V(mx(1), my(1));
        V2 = V(mx(2), my(2));
        
        % softmax decision point
        %   pick a continuous variable between 1 and 2
        %   where 1 and 2 represent high confidence in each
        %   choice
       predictedResp(ei) = 2 - ( 1 ./ (1 + exp(-1*beta*(V1-V2))) );  

        % what did subject do
        if alle(ei).map.currentLocation.x == alle(ei).moveOpts(1).x && alle(ei).map.currentLocation.y == alle(ei).moveOpts(1).y
            moveChoice = 1;
            evDiff = V1 - V2;
        elseif alle(ei).map.currentLocation.x == alle(ei).moveOpts(2).x && alle(ei).map.currentLocation.y == alle(ei).moveOpts(2).y
            moveChoice = 2;
            evDiff = V2 - V1;
        else
            % debug, this shouldn't happen
            alle(ei).map.currentLocation
            alle(ei).moveOpts(1)
            alle(ei).moveOpts(2)
            
        end
        
        % probability of model picking subject's choice
        choiceProb(ei) = 1 ./ (1 + exp(-1*beta*(evDiff)));
        
        % update expectation regressor based on expected value of their
        % choice
        EVs = [V1 V2];
        expectRegressor(ei) = EVs(moveChoice);
        
        % what was outcome
        if ~alle(ei).reward
            outcome = 'null';
            outcomeNum = -1;
            thisnu = nu;
        elseif alle(ei).rewType == 1
            outcome = 'low';
            outcomeNum = 1;
            thisnu = nu;
        else
            outcome = 'high';
            outcomeNum = 5;
            thisnu = nu;
        end

        % update RL
        moveMap = zeros(3,3);
        moveMap(mx(moveChoice), my(moveChoice)) = outcomeNum;
        
        V(mx(moveChoice), my(moveChoice)) = ...     % new expected value for chosen location
            V(mx(moveChoice), my(moveChoice)) + ... % previous expected value
            thisnu*(values.(outcome) - V(mx(moveChoice), my(moveChoice))); % update based on difference from expected
        
        % decay to 0
        V = (1-decayrate)*V; % decay everything
        V(mx(moveChoice), my(moveChoice)) = V(mx(moveChoice), my(moveChoice))/(1-decayrate); % undo decay on chosen location

    end
    
    

