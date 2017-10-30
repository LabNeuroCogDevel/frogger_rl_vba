function [u,y] = setup_data(alle, usemag)

if nargin < 2, usemag=1; end %whether to use raw magnitude scaling or 0, 0.5, 1 scaling
    
n_actions = 9;
n_inputs = 4;
n_trials = length(alle);
u=zeros(n_inputs, n_trials);
y=zeros(n_actions, n_trials);

opt1index = 1; %row of u containing first eligible action on trial t (choice rule)
opt2index = 2; %row of u containing second eligible action on trial t (choice rule)
%p_opt1index = 3; %row of u containing first eligible action on trial t-1 (learning rule)
%p_opt2index = 4; %row of u containing second eligible action on trial t-1 (learning rule)
p_choiceindex = 3; %row of u containing index of chosen action on trial t-1 (learning rule)
p_rewardindex = 4; %row of u containing index of obtained reward on trial t-1 (learning rule)

for i = 1:n_trials
    opt1pos=flatten_xy(alle(i).moveOpts(1).x, alle(i).moveOpts(1).y);
    opt2pos=flatten_xy(alle(i).moveOpts(2).x, alle(i).moveOpts(2).y);
    u(opt1index, i) = opt1pos;
    u(opt2index, i) = opt2pos;
    
    if alle(i).map.currentLocation.x == alle(i).moveOpts(1).x && alle(i).map.currentLocation.y == alle(i).moveOpts(1).y
        choice = opt1pos;
    elseif alle(i).map.currentLocation.x == alle(i).moveOpts(2).x && alle(i).map.currentLocation.y == alle(i).moveOpts(2).y
        choice = opt2pos;
    else
        error('unmatched choice');
    end
    
    u(p_choiceindex, i) = choice;
    y(choice,i) = 1; %binary choice on trial t
       
    % put outcome into relevant element of u
    % come back to support different scaling (using raw mag for now)
    if ~alle(i).reward
        reward = 0; %technically unnecessary since we initialize with zeros
    elseif usemag
        if alle(i).rewType == 1, reward = 1; else, reward = 5; end
    else
        if alle(i).rewType == 1, reward = 0.5; else, reward = 1; end
    end
    
    u(p_rewardindex,i) = reward;
    %u(5,i) = i; %trial index for now
end

%setup lagged version (dropping a trial for the moment)
%no reason to track prior trial available actions. all we need is to learn from chosen action
%u(p_opt1index,:) = [0 u(opt1index, 1:end-1)];
%u(p_opt2index,:) = [0 u(opt2index, 1:end-1)];

%shift reward and choice vectors to reflect t-1 so that we learn on t-1 and choose on t
u(p_rewardindex,:) = [0 u(p_rewardindex, 1:end-1)];
u(p_choiceindex,:) = [0 u(p_choiceindex, 1:end-1)];
end

%convert x, y into a vector by row
% 1,1 1,2 1,3
% 2,1 2,2 2,3
% 3,1 3,2 3,3
%
% becomes
% 1,2,3
% 4,5,6
% 7,8,9
%
% currently only setup for 3x3 grid
function pos = flatten_xy(x,y)
    offset = (y-1)*3;
    pos = x + offset;
end