function choices = getResponses(alle)

    nTrials = numel(alle);

    for ei = 1:nTrials

        % get choices
        mx = [alle(ei).moveOpts(1).x alle(ei).moveOpts(2).x];
        my = [alle(ei).moveOpts(1).y alle(ei).moveOpts(2).y];

        % what did subject do
        if alle(ei).map.currentLocation.x == alle(ei).moveOpts(1).x && alle(ei).map.currentLocation.y == alle(ei).moveOpts(1).y
            moveChoice = 1;
        elseif alle(ei).map.currentLocation.x == alle(ei).moveOpts(2).x && alle(ei).map.currentLocation.y == alle(ei).moveOpts(2).y
            moveChoice = 2;
        else
            alle(ei).map.currentLocation
            alle(ei).moveOpts(1)
            alle(ei).moveOpts(2)
            keyboard
        end
        
        choices(ei) = moveChoice;

    end