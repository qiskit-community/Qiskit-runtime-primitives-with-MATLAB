% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


%% Solve the Maxcut problem Classically
function [sol,fval] =  classical_optimizer(G)
    %%%%% Number of Nodes in the graph
    N = numnodes(G);
    %%%%% Adjacency matrix
    W = full(adjacency(G,'weighted'));
    
    %%% Define binary variables 
    x = optimvar("x",N,1,Type="integer",LowerBound=0,UpperBound=1);
    prob = optimproblem;
    %%% Create the objective function based on the graph info
    for i=1:length(x)
        for j=1:length(x)
            T(i,j) = W(i,j)*x(i)*(1-x(j));
        end
    end
    
    OBJ = sum(sum(T));
    %%% Solve the problem classically
    prob.Objective = -OBJ;
    rng default % For reproducibility
    options = optimoptions('ga','Display','off');
    [sol,fval] = solve(prob,'Options',options); 

end