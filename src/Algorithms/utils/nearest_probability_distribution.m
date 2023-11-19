%%%%
% Takes a quasiprobability distribution and maps
% it to the closest probability distribution as defined by
% the L2-norm.
% 
% Parameters:
%     return_distance (bool): Return the L2 distance between distributions.
% 
% Returns:
%     ProbDistribution: Nearest probability distribution.
%     float: Euclidean (L2) distance of distributions.
% 
% Notes:
%     Method from Smolin et al., Phys. Rev. Lett. 108, 070502 (2012).
%%%%

function [new_probs, distance] = nearest_probability_distribution(obj, return_distance)
    if nargin < 2
        return_distance = false;
    end
    
    [value_sort,I]= sort(obj.values);
    sorted_probs = containers.Map(obj.keys(I), value_sort);
    num_elems = length(sorted_probs);

    beta = 0;
    diff = 0;

    new_probs.values = [];
    new_probs.keys = "";
    k = 1;

    keys = sorted_probs.keys;
    values = sorted_probs.values;

    for i = 1:num_elems
        key = keys{i};
        val = values{i};
        temp = val + beta / num_elems;
        if temp < 0
            beta = beta + val;
            num_elems = num_elems - 1;
            diff = diff + val * val;
        else
            diff = diff + (beta / num_elems) * (beta / num_elems);
            new_probs.values(k)= sorted_probs(key) + beta / num_elems;
            new_probs.keys(k)= string(key);
            k = k+1;
        end
    end
    
    if return_distance
        distance = sqrt(diff);
    else
        distance = [];
    end
end

