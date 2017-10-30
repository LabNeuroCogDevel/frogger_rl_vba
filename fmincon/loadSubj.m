function [alle, maptest, trialsByRun] = loadSubj(subj, matdir)

    if nargin < 2 || isempty(matdir)
        matdir = '../allmat';
    end
    
    trialsByRun = {};
    
    
    firstfile = sprintf('%s/results_%s_%d.mat', matdir, subj, 1);
    if ~exist(firstfile, 'file')
        % try version without the date
        subjParts = strsplit(subj, '_');
        subjName = subjParts{1};
        firstfile2 = sprintf('%s/results_%s_%d.mat', matdir, subjName, 1);
        if ~exist(firstfile2, 'file')
            fprintf(1, 'No results files for %s!\n\n', subj);
            alle = 0;
            maptest = 0;
            trialsByRun = 0;
            return;
        else
            fprintf(1, 'Using subject name only for %s (%s)\n\n', subj, subjName);
        end
    else
        subjName = subj;
    end

    
    for i = 1:6
        fprintf(1, 'Loading %s ...\n', sprintf('%s/results_%s_%d.mat', matdir, subjName, i));
        res(i) = load(sprintf('%s/results_%s_%d.mat', matdir, subjName, i));
    end

    alle = [];
    alleErr = 0;
    try
        for i = 1:6
            trialsByRun{i} = [length(alle)+1:length(alle)+length(res(i).e)];
            for ei = 1:length(res(i).e)
                res(i).e(ei).block = i;
            end
            alle = [alle res(i).e];
        end
    catch
        alleErr = 1;
    end
    
    if alleErr || isempty(alle) || length(res)<6 || isempty(res(6).finalMaptestResults)
        maptest = [];
        return
    end
    
    maptest = res(6).finalMaptestResults;
    