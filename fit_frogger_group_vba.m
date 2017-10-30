%loads in subjects' data and fits SCEPTIC models using VBA;

close all;
clear;
%curpath = fileparts(mfilename('fullpath'));

%load data

cd '/Users/mnh5174/Data_Analysis/frogger_rl_vba'
load '/Users/mnh5174/Data_Analysis/frogger_rl_vba/data/alldata.mat'

%multinomial = false; %not currently used (should be binomial since choice are always binary)
free_x0 = true; %estimate initial Q values from the data
multisession = false; %whether to allow parameters and/or initial values to vary by run
fixed_params_across_runs = true;
fixed_x0_across_runs = true;
save_results = true;
show_graphics=false; %do not show fitting in progress (slows things down, even if useful)


%% main loop
%sorry, this use of free_x0 is clunky. In principle, you should think of the above settings as an n-dimensional simulation matrix:
% model x free_x0 x fixed_params_across_runs x fixed_x0_across_runs
% and fit all of those and flatten into a 2-d matrix of log evidence for BMC

models={'base', 'twolr', 'decay', 'base_free_x0', 'twolr_free_x0', 'decay_free_x0'};

%matrix of log evidence from each model (models x subjects)
L = NaN(length(models), length(alldata));

%for use in an HPC cluster environment
ncpus=getenv('matlab_cpus');
if strcmpi(ncpus, '')
    ncpus=4;
    fprintf('defaulting to %d cpus because matlab_cpus not set\n', ncpus);
else
    ncpus=str2double(ncpus);
end

poolobj=parpool('local',ncpus); %just use shared pool for now since it seems not to matter (no collisions)

for m = 1:length(models)
    thismodel = models{m};
    if contains(thismodel, '_free_x0')
        free_x0=true;
        thismodel = strrep(thismodel, '_free_x0', ''); %remove suffix
    else
        free_x0=false;
    end

    parfor sub = 1:length(alldata)
    %for sub = 1:length(alldata)
        fprintf('Fitting subject %d id: %s \r', sub, char(alldata(sub).subj));
        
        [posterior,out] = fit_frogger_subject_vba(alldata(sub), thismodel, free_x0, multisession, fixed_params_across_runs, fixed_x0_across_runs, save_results, show_graphics);
        L(m, sub) = out.F;
    end    
end

delete(poolobj);

save('frogger_log_evidence.mat', 'L', 'models');

%Group BMC on models
[group_posterior, group_out] = VBA_groupBMC(L);

%model attributions to subject (probability that each subject comes from each model)
group_posterior.r

%Redisplay a single subject
%load('fits/11455_20170615_twolr_fxz0_ms0_msfp1_msfxz1.mat')
%VBA_ReDisplay(posterior, out)
