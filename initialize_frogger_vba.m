function [priors, options, dim] = initialize_frogger_vba(alle, model, free_x0, graphics)
%This functions sets up the priors, options, and dim structs based on the data
%Model-specific parameter setup occurs downstream in initialize_frogger_parameters.m

n_actions = 9; %hard coded for now
n_t = length(alle); %number of trials

options = []; %start from scratch
priors = [];

%whether to display graphics during fitting process
if ~graphics
    options.DisplayWin = 0;
    options.GnFigs = 0;
end


%% options structure

%the input matrix (u) contains information about:
% 1) option 1 on trial t (choice rule)
% 2) option 2 on trial t (choice rule)
% 3) chosen option on trial t-1 (learning rule)
% 4) reward obtained from chosen option on trial t-1 (learning rule)

%copy the indices of u into fields of the inF and inG structures so that the learning
%and choice rules can determine which positions within u to access for learning and choice
options.inF.o1pos = 1; %position of first option on trial t (see setup_data)
options.inF.o2pos = 2;
options.inF.p_cpos = 3;
options.inF.p_rpos = 4;

options.inG.o1pos = 1; %position of first option on trial t (see setup_data)
options.inG.o2pos = 2;
options.inG.p_cpos = 3;
options.inG.p_rpos = 4;

%fitting tolerances
options.TolFun = 1e-6;
options.GnTolFun = 1e-6;
options.verbose=1; %detailed fitting info

%copy model into inF and inG structures for learning and choice rules to dissect
options.inF.model = model;
options.inG.model = model;

% skip first trial in learning rule since no feedback has been obtained yet
options.skipf = zeros(1,n_t);
options.skipf(1) = 1; %identity mapping from x0 to x1

options.binomial = 1; %choices are binary (choice probabilities for two available actions)

% test multinomial? because there are only two actions available on a trial, this should not offer any advantage
%options.sources(1).out  = 1:9;
%options.sources(1).type = 2;


%% setup priors

%set priors on state and measurement noise
priors.a_alpha = Inf;   % infinite precision prior on state noise (deterministic fitting)
priors.b_alpha = 0;
%priors.a_alpha = 1;    %for binary data, no advantage to stochastic estimation
%priors.b_alpha = 1;
priors.a_sigma = 1;     % Jeffrey's prior on measurement noise
priors.b_sigma = 1;     % Jeffrey's prior

priors.muX0 = zeros(n_actions,1); %vector of 9 hidden states. Start at 0 Q value
if free_x0
    priors.SigmaX0 = eye(n_actions); %variance of 1 on initial values
else
    priors.SigmaX0 = zeros(n_actions); %force Q values to initial value of zero by disallowing variance
end



%% setup dim structure
%n is number of hidden states (should be 9)
%n_t is number of trials (140)
dim = struct('n',n_actions, 'n_t',n_t);

end