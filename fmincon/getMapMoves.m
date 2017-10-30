function moves = getMapMoves(maptest)

    nfinal = length(maptest);
    
    for i = 1:nfinal
        if isfield(maptest(i), 'resp') && ~isempty(maptest(i).resp)
            moves(i) = maptest(i).resp;
        else
            moves(i) = NaN;
        end
        
    end
