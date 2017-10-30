function [priors, dim] = initialize_frogger_parameters(priors, dim, model)
%This function is for setting up the priors on the evolution (learning) and observation (choice) parameters
%The coding is currently a bit redundant, but let's each model be setup independently within its 'if' block.
%Feel free to abstract the elements common to all/most models to streamline the code
%In general, I've initialized all parameters to be normal with mean = 0 and variance of 10 (SD ~ 3.16).
%VBA works with Gaussian variates, but these can be transformed inside the choice or learning rules.
%At the moment, all params are transformed to 0..1 according to an inverse sigmoid.

if strcmpi(model, 'base')
    dim.n_theta = 1; %alpha (learning rate)
    dim.n_phi = 1; %beta (temperature)
    
    %priors for evolution (learning) function parameters (learning rates)
    priors.muTheta = zeros(dim.n_theta,1); % sigmoid transform on learning rate
    priors.SigmaTheta = 1e1*eye(dim.n_theta); %variance of 10 on Gaussian param that controls LR
    
    %priors for observation (choice) function parameters (temperature)
    priors.muPhi = zeros(dim.n_phi,1); % exp tranform on temperature
    priors.SigmaPhi = 1e1*eye(dim.n_phi);

elseif strcmpi(model, 'twolr')
    dim.n_theta = 2; %alpha_pe+, alpha_pe- (two learning rates)
    dim.n_phi = 1; %beta (temperature)
    
    %priors for evolution (learning) function parameters (learning rates)
    priors.muTheta = zeros(dim.n_theta,1); % sigmoid transform on learning rate
    priors.SigmaTheta = 1e1*eye(dim.n_theta); %variance of 10 on Gaussian param that controls LR
    
    %priors for observation (choice) function parameters (temperature)
    priors.muPhi = zeros(dim.n_phi,1); % exp tranform on temperature
    priors.SigmaPhi = 1e1*eye(dim.n_phi);
elseif strcmpi(model, 'decay')
    dim.n_theta = 2; %alpha (learning rate), gamma (decay rate)
    dim.n_phi = 1; %beta (temperature)
    
    %priors for evolution (learning) function parameters (learning rates)
    priors.muTheta = zeros(dim.n_theta,1); % sigmoid transform on learning rate
    priors.SigmaTheta = 1e1*eye(dim.n_theta); %variance of 10 on Gaussian param that controls LR
    
    %priors for observation (choice) function parameters (temperature)
    priors.muPhi = zeros(dim.n_phi,1); % exp tranform on temperature
    priors.SigmaPhi = 1e1*eye(dim.n_phi);
else    
    error(['unknown model', model]);
end

end
