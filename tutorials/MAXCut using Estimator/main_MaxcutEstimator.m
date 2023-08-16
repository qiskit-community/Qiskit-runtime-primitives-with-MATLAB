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
% [sol,fval] = classical_optimizer(G);
% 
% %% Solve the Maxcut problem using Qiskit Estimator Primitive
% apiToken= 'Put your IBM Quantum API Token here';
% 
% service = QiskitRuntimeService(apiToken);
% service.program_id = "estimator";
% service.Start_session = true;
% 
% backend="ibmq_qasm_simulator"; 

%% Enable the session and Estimator
% session = Session(service, backend);  
% estimator = Estimator(session=session);

%% 1. Mapping the problem (Maxcut problem) to qubits/Quantum Hamiltonian 
%%% Convert the Maxcut problem into an Ising Hamiltonian
[hamiltonian.Pauli_Term,hamiltonian.Coeffs,Offset_value, Offset_string] = Maxcut.ToIsing (G);

%% 2. Choosing the ansatz circuit/s
circuit.reps=2;
circuit.entanglement = "linear";
circuit.number_qubits = numnodes(G);
circuit.num_parameters = (circuit.reps+1)*circuit.number_qubits;

%% Arguments for the optimizer 
arg.hamiltonian = hamiltonian;
arg.circuit     = circuit;
arg.estimator   = estimator;

%% Define the cost function
cost_func = @(theta) cost_function(theta,arg);

%% Set the parameters for MATLAB surrogateopt global optimizer 
x0 = -5*ones(circuit.num_parameters,1);
max_iter = 80;

lower_bound = repmat(-2*pi,circuit.num_parameters,1);
upper_bound = repmat( 2*pi,circuit.num_parameters,1);

options = optimoptions("surrogateopt",...
    "MaxFunctionEvaluations",max_iter, ...
    "PlotFcn","optimplotfval",...
    "InitialPoints",x0);

%% 3. Executing the quantum VQE algorithm using the qiskit Estimator primititve and MATLAB 
% optimizer to solve Maxcut problem

rng default %% For reproducibility

[angles,minEnergy] = surrogateopt(cost_func,lower_bound,upper_bound,options);

%% 4. Find the solution which is the bitstring with the highest probability
%%% We need to run the circuit with the acheived optimized parameters usng
%%% sampler primititve

ansatz = Twolocal(circuit, angles);

sampler = Sampler (session=session);

job = sampler.run(ansatz,sampler.options.service);
results = Job.retrieveResults(job.id,sampler.options.service.Access_API);
%%% extract the bitstring
string_data = string(fieldnames(results.quasi_dists));
bitstring_data = replace(string_data,"x","");
%%% Extract the probabilitites
probabilities = cell2mat(struct2cell(results.quasi_dists));

%%% Find the bitstring with the highest probability
bitstring_maxprobability = string_data(find(probabilities==max(probabilities)));
fprintf('The quantum solution for maxcut is: [ %s ]\n', bitstring_maxprobability);

%%%% plot the results and color the graph using the received bit-string
%%%% (solution)
Maxcut.plot_results(G,bitstring_data,probabilities);


%% Define the cost function to calculate the expectation value of the derived Hamiltonian
function [energy] = cost_function(parameters,arg)    

    % Construct the variational circuit 
    ansatz = Twolocal(arg.circuit, parameters);

    estimator = arg.estimator;
    job       = estimator.run(ansatz,arg.estimator.options.service,arg.hamiltonian);

    %%%% Retrieve the results back
    results = Job.retrieveResults(job.id,arg.estimator.options.service.Access_API);
    energy  = results.values;
end

