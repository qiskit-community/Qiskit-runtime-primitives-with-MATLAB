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
s = [1 2 3 4 4];
t = [2 3 4 1 2];
weights = [1 1 1 1 1];
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

%% Define backend and access
service.Start_session = true; %set to true to enable Qiskit Runtime Session 
if service.Start_session ==true;
    service.session_mode = "batch";
end

backend="ibm_hanoi";

% service.hub = "your-hub"
% service.group = "your-group"
% service.project = "your-project"

%% 1. Enable the session and Estimator
session = Session(service, backend);  

% options = {};
% options.transpilation.optimization_level = 1;
% options.twirling.enable_gates = true;
% options.twirling.enable_measure = true;
% options.twirling.num_randomizations = "auto";
% options.twirling.shots_per_randomization = "auto";   
% options.twirling.strategy = "active-accum";
% 
% options.dynamical_decoupling.enable = true;
% options.dynamical_decoupling.sequence_type = 'XpXm';
% options.dynamical_decoupling.extra_slack_distribution= 'middle';
% options.dynamical_decoupling.scheduling_method= 'alap';

estimator = Estimator(session);
estimator.options.dynamical_decoupling.sequence_type = 'XpXm';

%% 2. Mapping the problem (Maxcut problem) to qubits/Quantum Hamiltonian 
%%% Convert the Maxcut problem into an Ising Hamiltonian
[Hamiltonian.Pauli_Term,Hamiltonian.Coeffs,Offset_value, Offset_string] = Maxcut.ToIsing (G);

Pauli_str =[num2cell(Hamiltonian.Pauli_Term);num2cell(Hamiltonian.Coeffs)];
hamiltonian = struct(Pauli_str{:});

%% 3. Creating the ansatz circuit/s
circuit.reps=4;
circuit.entanglement = "pairwise";
circuit.number_qubits = strlength(Hamiltonian.Pauli_Term(1));
circuit.rotation_blocks = ["ry","rx"];
circuit.num_parameters = ((circuit.reps+1)*size(circuit.rotation_blocks,2))*circuit.number_qubits;

[ansatz, parameterized_ansatz] = Twolocal(circuit);


%% 3.1 transpilationOptions for the transpilerService, this would be optional input to the TranspilerService
transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%%% 3.2 Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(parameterized_ansatz, backend,transpilationOptions); 

%% Arguments for the optimizer 
arg.hamiltonian = hamiltonian;
arg.circuit     = transpiled_circuit.qasm;
arg.estimator   = estimator;

%% Define the cost function
cost_func = @(theta) cost_function(theta,arg);

%% Set the parameters for MATLAB surrogateopt global optimizer 
x0 = -5*ones(circuit.num_parameters,1);
max_iter = 80;

lower_bound = repmat(-2*pi,circuit.num_parameters,1);
upper_bound = repmat( 2*pi,circuit.num_parameters,1);

op_options = optimoptions("surrogateopt",...
    "MaxFunctionEvaluations",max_iter, ...
    "PlotFcn","optimplotfval",...
    "InitialPoints",x0);

%% 4. Executing the quantum VQE algorithm using the qiskit Estimator primititve and MATLAB 
% optimizer to solve Maxcut problem

rng default %% For reproducibility 

[angles,minEnergy] = surrogateopt(cost_func,lower_bound,upper_bound,op_options);

%% 5. Find the solution which is the bitstring with the highest probability
%%% We need to run the circuit with the acheived optimized parameters usng
%%% sampler primititve
sampler = Sampler(session);

shots = 200;
job     = sampler.run({transpiled_circuit.qasm,angles,shots});

results = sampler.Results(job.id);

num_qubits = length(transpiled_circuit.layout.final); 

Counts = double (decode_and_deserialize(results.x__value__.pub_results.x__value__.data.x__value__.fields.c.x__value__.array.x__value__,1));
[Bitstring,~,Sorted_prob] = unique(Counts);
probabilities = accumarray(Sorted_prob,1).';
%%%%extract the Bitstring with the highest probability
bits_max = Bitstring(find(probabilities==max(probabilities)));
bits_max = dec2bin(bits_max(1),num_qubits);
% Reverse the order of qubits
x = bits_max(length(bits_max):-1:1);

fprintf('The quantum solution for maxcut is: [ %s ]\n', x);

%%%% plot the results and color the graph using the received bit-string
%%%% (solution)
Maxcut.plot_results(G,Bitstring,probabilities, 'c');


%% Define the cost function to calculate the expectation value of the derived Hamiltonian
function [energy] = cost_function(parameters,arg)    

    global session_id
    
    ansatz =arg.circuit;
    observables = arg.hamiltonian;
    param_values = parameters;
    precision = 0.01;

    estimator = arg.estimator; 

    if estimator.session.service.Start_session
        estimator.session.service.session_id = session_id;
    end

    job       = estimator.run({ansatz,observables,param_values,precision});
    
    if isfield(job,'session_id')
        session_id = job.session_id;
    end
    %%%% Retrieve the results back
    [Results, exps] = estimator.Results(job.id);
    energy    = exps;
end
