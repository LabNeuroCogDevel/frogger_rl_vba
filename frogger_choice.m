function  [ gx ] = frogger_choice(x_t,phi,u,inG)
% INPUT
% - x_t : Q-values (9x1)
% - phi : temperature (1x1)
% - u :   input vector (used for identifying available choices on this trial
% - inG : contains information about the ordering of inputs
% OUTPUT
% - gx : p(chosen|x_t) or RT

beta = exp(phi); %exponentiate temporature parameter

%x_t contains hidden state values for all actions on this trial
%but we need to choose between available actions

%handle first trial, which appears to evaluate despite skipf
if u(inG.o1pos) == 0
    gx = zeros(size(x_t));
    return;
end

%choose between actions available on the current trial (t)
c1 = u(inG.o1pos); %first choice
c2 = u(inG.o2pos); %second choice

Q = x_t([c1 c2]); %vector of actions values available on trial t

%sofmtax choice rule
p_choice = ( exp((Q - max(Q))/beta) ) / (sum( exp((Q - max(Q))/beta) )); %Divide by temperature

%populate full vector of action probabilities, but with unavailable actions set at zero probability
gx = zeros(size(x_t));
gx(c1) = p_choice(1);
gx(c2) = p_choice(2);

end
