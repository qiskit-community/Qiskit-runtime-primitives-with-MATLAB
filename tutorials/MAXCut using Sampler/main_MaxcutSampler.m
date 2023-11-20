% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.

clc;
clear;
close all;
clearvars -global;

global session_id;
%% Generate a graph
s = [1 1 2 3 3 4];
t = [2 5 3 4 5 5];
weights = [1 1 1 1 1 1];
G = graph(s,t,weights);

%% Plot the graph
figure;
h = plot(G);
highlight(h,1:numnodes(G),'MarkerSize',20)

%% Solve the MaxCut problem Classically
[sol,fval] = classical_optimizer(G);

%% Solve the Maxcut problem using Qiskit Estimator Primitive

%% Setup IBM Quantum cloud credentials

% channel = "ibm_cloud"; 
% apiToken = 'MY_IBM_CLOUD_API_KEY';
% crn_service = 'MY_IBM_CLOUD_CRN';
% 
% service = QiskitRuntimeService(channel,apiToken,crn_service);


%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "MY_IBM_QUANTUM_TOKEN";

service = QiskitRuntimeService(channel,apiToken,[]);

%%
service.Start_session = true; %set to true to enable Qiskit Runtime Session 
backend="ibm_lagos";

% service.hub = "your-hub"
% service.group = "your-group"
% service.project = "your-project"
%% 1. Enable the session and Sampler
session = Session(service, backend);

options = Options();
options.transpilation_settings.skip_transpilation = true;
sampler = Sampler(session,options);

%% 1. Choosing the ansatz circuit/s
circuit.reps=4;
circuit.entanglement = "linear";
circuit.number_qubits = numnodes(G);
circuit.rotation_blocks = ["ry","rx"];
circuit.num_parameters = ((circuit.reps+1)*size(circuit.rotation_blocks,2))*circuit.number_qubits;

%% Arguments for the optimizer 
arg.circuit     = circuit;
arg.sampler     = sampler; 
arg.G = G;

%% Define the cost function
cost_func = @(theta) cost_function(theta,arg);

%% Set the parameters for MATLAB surrogateopt global optimizer
x0 = -1*ones(circuit.num_parameters,1);
max_iter = 40;

lower_bound = repmat(-2*pi,circuit.num_parameters,1);
upper_bound = repmat( 2*pi,circuit.num_parameters,1);


op_options = optimoptions("surrogateopt",...
    "MaxFunctionEvaluations",max_iter, ...
    "PlotFcn","optimplotfval",...
    "InitialPoints",x0);

%% 2. Executing the quantum VQE algorithm using the qiskit Sampler primititve and MATLAB 
% optimizer to solve Maxcut problem

rng default %% For reproducibility

[angles,minEnergy] = surrogateopt(cost_func,lower_bound,upper_bound,op_options);

%% 3. Find the solution which is the bitstring with the highest probability
%%% We need to run the circuit with the acheived optimized parameters usng
%%% sampler primititve

ansatz = Twolocal(circuit, angles);

job = sampler.run(ansatz);
results = sampler.Results(job.id);
%%% extract the Bitstring
string_data = string(fieldnames(results.quasi_dists));
bitstring_data = replace(string_data,"x","");
%%% Extract the probabilitites
probabilities = cell2mat(struct2cell(results.quasi_dists));

%%% Find the bitstring with the highest probability
bitstring_maxprobability = string_data(find(probabilities==max(probabilities)));
fprintf('The quantum solution for maxcut is: [ %s ]\n', bitstring_maxprobability);

%%%% plot the results and color the graph using the received bit-string
%%%% (solution)
Maxcut.plot_results(G,bitstring_data,probabilities, 'c');


%% Define the cost function to calculate the expectation value of the retreived bit-strings
function energy = cost_function (parameters,arg)
    
    global session_id    
    %%%% Construct the variational circuit 
    ansatz = Twolocal(arg.circuit, parameters);
    %%%% Run Sampler primitive
    sampler = arg.sampler;
    if sampler.session.service.Start_session
        sampler.session.service.session_id = session_id;
    end

    job     = sampler.run(ansatz);
    %%%% Retrieve the results back
    if isfield(job,'session_id')
        session_id = job.session_id;
    end
    
    results = sampler.Results(job.id);
    
    %%%%extract the Bitstring
    string_data = string(fieldnames(results.quasi_dists));
    %%%% Extract the probabilitites
    probabilities = cell2mat(struct2cell(results.quasi_dists));
    %%%% Find the bitstring with the highest probability
    bits_max = string_data(find(probabilities==max(probabilities)));
    % Convert bitstring to a binary vecotr
    x_m = bits_max{1}-'0';
    x_m(1) = [];
    % Reverse the order of qubits
    x = x_m(length(x_m):-1:1);
    disp(x)
    %%%% Calculate the expectation value using the bit string with the
    %%%% highest probability
    energy = - evaluate_fcn(x,arg.G);

    end
%%
function expectation_value = evaluate_fcn(x_value,G)
        W = full(adjacency(G,'weighted'));
        %%% Create the objective function
        for i=1:length(x_value)
            for j=1:length(x_value)
                T(i,j) = W(i,j)*x_value(i)*(1-x_value(j));
            end
        end
        obj = sum(sum(T));
        expectation_value = obj;      
end
