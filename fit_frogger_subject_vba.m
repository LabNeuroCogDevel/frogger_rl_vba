function [posterior,out] = fit_frogger_subject_vba(data, model, free_x0, multisession, fixed_params_across_runs, fixed_x0_across_runs, saveresults, graphics)
% fits Q-learning model to single-subject frogger data using VBA toolbox
% example call:
% [posterior,out] = fit_frogger_subject_vba(alldata(1),'modelname',nbasis,multinomial,multisession,fixed_params_across_runs,fit_propsrpead)
% data:         a struct from the frogger alldata object for one subject
% model:        which model to fit to the data ('base')
% multisession: 1/0 to indicate whether to treats runs/conditions as separate, helps fit (do not allow X0 to vary though)

% fixed_params_across_runs: 1/0 to indicate whether to estimate unique parameters by run
% fixed_x0_across_runs: 1/0 to indicate whether to estimate unique initial values (X0) for each run

close all

if nargin < 2, model='base'; end
if nargin < 3, free_x0=false; end %whether to estimate initial Q values (X0)
if nargin < 4, multisession=false; end
if nargin < 5, fixed_params_across_runs=true; end
if nargin < 6, fixed_x0_across_runs=false; end
if nargin < 7, saveresults = true; end
if nargin < 8, graphics = 0; end

alle = data.alle; %this is the pertinent data structure

%in y we should have 0/1 for choice among 9
%in u we should have information about choices, reinforcement, and choice eligibility (binary)

%Setup a u structure where we have n_actions x n_trials with the outcome of
%the chosen action (0, 1, 5 points) in the correct row of u. On the last
%three rows, add 1) option1, 2) option2, 3) chosen option to help resolve
%update rules inside evolution and observation functions.
[u, y] = setup_data(alle, 0);

[priors, options, dim] = initialize_frogger_vba(alle, model, free_x0, graphics);
[priors, dim] = initialize_frogger_parameters(priors, dim, model);

%Handle multisession setup
%this allows you to estimate unique parameters or unique initial values on Q for each block

if multisession
    %denote trials per run
    options.multisession.split = cellfun(@length, data.trialsByRun);
    
    %whether to fix learning and choice parameters across runs
    if fixed_params_across_runs
        options.multisession.fixed.theta = 'all';
        options.multisession.fixed.phi = 'all';
    end
    
    % whether to set initial values of Q (called X0 in VBA) to be the same in each run
    if fixed_x0_across_runs        
        options.multisession.fixed.X0 = 'all';
    end
end

% Evolution function (learning rule)
f_name = @frogger_learning;

% Observation function (choice rule)
g_name = @frogger_choice;

%copy priors into options structure for use inside VBA
options.priors = priors;

%fit subject
[posterior,out] = VBA_NLStateSpaceModel(y, u, f_name, g_name, dim, options);

%store transformed parameters (in expected units, not Gaussian-distributed VBA params)
if strcmpi(model, 'base')
    posterior.transformed.alpha = sigmoid(posterior.muTheta(1));
    posterior.transformed.beta = exp(posterior.muPhi(1));
elseif strcmpi(model, 'twolr')
    posterior.transformed.alpha_plus = sigmoid(posterior.muTheta(1));
    posterior.transformed.alpha_minus = sigmoid(posterior.muTheta(2));
    posterior.transformed.beta = exp(posterior.muPhi(1));
elseif strcmpi(model, 'decay')
    posterior.transformed.alpha = sigmoid(posterior.muTheta(1));
    posterior.transformed.gamma = sigmoid(posterior.muTheta(2));
    posterior.transformed.beta = exp(posterior.muPhi(1));
end
    
    

if saveresults
    save(sprintf('fits/%s_%s_fxz%d_ms%d_msfp%d_msfxz%d', data.subj, model, free_x0, multisession, fixed_params_across_runs, fixed_x0_across_runs), ...
        'data', 'posterior', 'out');
    
    % h = figure(1);
    % savefig(h,sprintf('results/%s_%s_multinomial%d_multisession%d_fixedParams%d', id,model,multinomial,multisession,fixed_params_across_runs))
end