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
%% Setup IBM Quantum cloud credentials

% channel = "ibm_cloud";
% apiToken = 'MY_IBM_CLOUD_API_KEY';
% crn_service = 'MY_IBM_CLOUD_CRN';
% 
% service = QiskitRuntimeService(channel,apiToken,crn_service);

%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "MY_IBM_QUANTUM_TOKEN";

%%
service = QiskitRuntimeService(channel,apiToken,[]);

%% Define backend and access
service.Start_session = false; %set to true to enable Qiskit Runtime Session 
if service.Start_session ==true;
    service.session_mode = "batch";
end

backend="ibm_bangkok";

% service.hub = "your-hub"
% service.group = "your-group"
% service.project = "your-project"


%% 1. Enable the session and Estimator
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

estimator = Estimator(session);

estimator.options.dynamical_decoupling.sequence_type = 'XpXm';
%% 2. Mapping the problem (H2 molecule) to qubits/Quantum Hamiltonian
%%% The Hamiltonian (Pauli terms and coefficients) for a bonding distance
%%% of 0.72 Angstrom will be:
hydrogen_Pauli = {"II","IZ","ZI","ZZ","XX"};
coeffs = {-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119};

Pauli_str =[hydrogen_Pauli;coeffs];
hamiltonian = struct(Pauli_str{:});


%% 3. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2) ]); 

qasm= generateQASM(c1);

%% 4. TranspilationOptions for the transpilerService, this would be optional input to the TranspilerService
transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

%% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%%% 4.1 Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(qasm, backend,transpilationOptions); 
%%

%%%% Circuit 1 to be executed
circuit1 =transpiled_circuit.qasm;
observables1 = hamiltonian;
param_values1 = [];
precision1 = 0.01;

%%%% Circuit 2 to be executed
circuit2 =transpiled_circuit.qasm;
observables2 = hamiltonian;
param_values2 = [];
precision2 = 0.06;

%% 5. Execute the circuit using estimator primititve
job1 = estimator.run({circuit1,observables1,param_values1,precision1}, {circuit2,observables2,param_values2,precision2});

if isfield(job1,'session_id')
    estimator.session.service.session_id = job1.session_id;
end
%% 5.1 Retrieve the results back
[Results, exps] = estimator.Results(job1.id);

