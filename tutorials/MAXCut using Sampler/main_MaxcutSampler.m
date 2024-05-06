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

%% Define backend and access
service.Start_session = true; %set to true to enable Qiskit Runtime Session 
if service.Start_session ==true;
    service.session_mode = "batch";
end

backend="ibm_bangkok";

% service.hub = "your-hub"
% service.group = "your-group"
% service.project = "your-project"
%% 1. Enable the session and Sampler
session = Session(service, backend);

% options = {};
% options.transpilation.optimization_level = 1;
% options.twirling.enable_gates = true;
% options.dynamical_decoupling.enable = true;
% options.dynamical_decoupling.sequence_type = 'XpXm';
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

sampler = Sampler(session);
sampler.options.twirling.enable_gates = false;
%% 2. Creating ansatz circuit/s
circuit.reps=4;
circuit.entanglement = "linear";
circuit.number_qubits = numnodes(G);
circuit.rotation_blocks = ["ry","rx"];
circuit.num_parameters = ((circuit.reps+1)*size(circuit.rotation_blocks,2))*circuit.number_qubits;

[ansatz, parameterized_ansatz] = Twolocal(circuit);

%% 2.1 transpilationOptions for the transpilerService, this would be optional input to the TranspilerService
transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%%%% Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(parameterized_ansatz, backend,transpilationOptions); 

%% Arguments for the optimizer 
arg.circuit     = transpiled_circuit;
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

%% 3. Executing the quantum VQE algorithm using the qiskit Sampler primititve and MATLAB 
% optimizer to solve Maxcut problem

rng default %% For reproducibility

[angles,minEnergy] = surrogateopt(cost_func,lower_bound,upper_bound,op_options);

%% 4. Find the solution which is the bitstring with the highest probability
%%% We need to run the circuit with the acheived optimized parameters usng
%%% sampler primititve

shots = 200;
job     = sampler.run({transpiled_circuit.qasm,angles,shots});

results = sampler.Results(job.id);

num_qubits = length(arg.circuit.layout.final); 

num_qubits = length(arg.circuit.layout.final); 

Counts = results.results.data.c.samples;
[Bitstring,~,Sorted_prob] = unique(Counts);
probabilities = accumarray(Sorted_prob,1).';

%%%%extract the Bitstring with the highest probability
Bit_max = Bitstring(find(probabilities==max(probabilities)));
Bit_max = cell2mat(Bit_max(1));

Bit_max = dec2bin(hex2dec(Bit_max(1,:)),num_qubits);
% Reverse the order of qubits
x = Bit_max(length(Bit_max):-1:1);

fprintf('The quantum solution for maxcut problem is: [ %s ]\n', x);

%%%% plot the results and color the graph using the received bit-string
%%%% (solution)
Maxcut.plot_results(G,Bitstring,probabilities, 'c');


%% Define the cost function to calculate the expectation value of the retreived bit-strings
function energy = cost_function (parameters,arg)
    
    global session_id   

    ansatz = arg.circuit.qasm;
    %%%% Run Sampler primitive
    sampler = arg.sampler;
    if sampler.session.service.Start_session
        sampler.session.service.session_id = session_id;
    end
    
    shots = 200;
    job     = sampler.run({ansatz,parameters,shots});

    %%%% Retrieve the results back
    if isfield(job,'session_id')
        session_id = job.session_id;
    end
    
    results = sampler.Results(job.id);

    num_qubits = length(arg.circuit.layout.final); 

    Counts = results.results.data.c.samples;
    [Bitstring,~,Sorted_prob] = unique(Counts);
    probabilities = accumarray(Sorted_prob,1).';
    
    %%%%extract the Bitstring with the highest probability
    Bit_max = Bitstring(find(probabilities==max(probabilities)));
    Bit_max = cell2mat(Bit_max(1));

    Bit_max = dec2bin(hex2dec(Bit_max(1,:)),num_qubits);
    % Reverse the order of qubits
    x = Bit_max(length(Bit_max):-1:1);
    fprintf('The x value is: %s\n' , x)
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
                T(i,j) = W(i,j)*str2double(x_value(i))*(1-str2double(x_value(j)));
            end
        end
        obj = sum(sum(T));
        expectation_value = obj;      
end
