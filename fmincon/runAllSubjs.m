%% Load all data
force = 1;

if ~exist('alldata.mat', 'file') || force
    % if we don't already have all trial-by-trial data loaded, read the
    % individual files to generate
    subjdir = '/Volumes/Phillips/mMR_PETDA/subjs';
    subjs = dir(sprintf('%s/1*', subjdir));
    
    alldata = [];
    for i = 1:length(subjs)
        subj = subjs(i).name;
        basedir = '/Volumes/Phillips/mMR_PETDA/subjs';
        [alle, maptest, trialsByRun] = loadSubj(subj, fullfile(basedir, subj, '1d'));

        if length(alle) <= 1
            continue
        end
        
        % remove visit outcomes field; it's HUGE and not needed here
        for ei = 1:length(alle)
            alle(ei).map = rmfield(alle(ei).map, 'visitOutcomes');
        end

        alldata(end+1).subj = subj;
        alldata(end).alle = alle;
        alldata(end).maptest = maptest;
        alldata(end).trialsByRun = trialsByRun;
        
    end
    save('alldata.mat', 'alldata');
    
else
    % if we've got them, just load the data structure
    load('alldata.mat');
end
    
%% Run all subjects

all = []; % hold all model fits & statistics

for i = 1:length(alldata)
    subj = alldata(i).subj;
    alle = alldata(i).alle;
    maptest = alldata(i).maptest;
    trialsByRun = alldata(i).trialsByRun;
    all(i).subj = subj;
    
    if isempty(alle)
        fprintf(1, 'No events found');
        all(i).fitBy = NaN;
        all(i).rlParams = NaN;

    end

    [fitBy, rlParams] = fitRL(subj, alle);
    
    all(i).fitBy = fitBy;
    all(i).rlParams = rlParams;

    fprintf(1, '%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', all(i).subj, all(i).fitBy.BIC, all(i).fitBy.chanceBIC, all(i).fitBy.BIC-all(i).fitBy.chanceBIC, all(i).rlParams); 

end        

%% Print summary
fprintf(1, '\n\nSubj\tBIC\tchanceBIC\tnu\tbeta\n');
d = [];
for i = 1:length(all)
    if isnan(all(i).rlParams)
        continue
    end
    fprintf(1, '%s\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n', all(i).subj, all(i).fitBy.BIC, all(i).fitBy.chanceBIC, all(i).fitBy.BIC-all(i).fitBy.chanceBIC, all(i).rlParams); 
    d = [d; all(i).fitBy.BIC, all(i).fitBy.chanceBIC, all(i).fitBy.BIC-all(i).fitBy.chanceBIC, all(i).rlParams];
end