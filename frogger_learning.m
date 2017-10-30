function  [fx] = frogger_learning(x_t, theta, u, inF)
% evolution function (learning rule) of frogger RL model
%
% IN:
%   - x_t : Q values (actions x 1)
%   - theta : theta(1) = learning rate
%   - u : vector of inputs
%   - inF : struct of input options, contains information about order of inputs
% OUT:
%   - fx: evolved Q values (actions x 1)

Q_new = x_t; %current action values
choice = u(inF.p_cpos); %position of choice on prior trial (t-1) in state vector (1-9)

%on trial 1, we have a '0' choice because the model cannot fit it.
%skip any learning (this should be captured by skipf(1) but the function still fires)
if choice == 0, return; end

Q_current = x_t(choice); %current value of the chosen action
outcome = u(inF.p_rpos); %reward received from choice on t-1

%update value of chosen action
%note that learning rule is computed on the chosen action and outcome of the previous trial (t-1)
if strcmpi(inF.model, 'base')
    alpha = sigmoid(theta(1)); %learning rate (transformed from Gaussian to 0..1)
    Q_new(choice) = Q_current + alpha .* (outcome - Q_current);
elseif strcmpi(inF.model, 'twoLR')
    alpha_plus = sigmoid(theta(1)); %learning rate (transformed from Gaussian to 0..1)
    alpha_minus = sigmoid(theta(2)); %learning rate (transformed from Gaussian to 0..1)
    if (outcome - Q_current) > 0
        Q_new(choice) = Q_current + alpha_plus .* (outcome - Q_current); %learn from positive PEs
    else
        Q_new(choice) = Q_current + alpha_minus .* (outcome - Q_current); %learn from negative PEs
    end
elseif strcmpi(inF.model, 'decay')
    alpha = sigmoid(theta(1)); %learning rate (transformed from Gaussian to 0..1)
    gamma = sigmoid(theta(2)); %decay rate (transformed from Gaussian to 0..1)
    Q_new(choice) = Q_current + alpha .* (outcome - Q_current);
    others = find(1:length(Q_new) ~= choice); %positions of unchosen Q elements
    
    %decay of unchosen actions
    Q_new(others) = Q_new(others) - gamma .* Q_new(others); %proportionate decay
end    

%return Q value vector with updated value of chosen action
fx=Q_new;

end
