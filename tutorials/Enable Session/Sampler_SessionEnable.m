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
%%
% Setup IBM Quantum cloud credentials
% channel = "ibm_cloud";
% apiToken = 'MY_IBM_CLOUD_API_KEY';
% crn_service = 'MY_IBM_CLOUD_CRN';

% service = QiskitRuntimeService(channel,apiToken,crn_service);


%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "MY_IBM_QUANTUM_TOKEN";

service = QiskitRuntimeService(channel,apiToken,[]);

%% Define backend and access
service.Start_session = false; %set to true to enable Qiskit Runtime Session 
if service.Start_session ==true;
    service.session_mode = "batch";
end

backend="ibm_hanoi";

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
%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

qasm= generateQASM(c1);

%% 3. TranspilationOptions for the transpilerService, this would be optional input to the TranspilerService
transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

%%% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%%% 3.1 Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(qasm, backend,transpilationOptions); 
%%
%%%% Circuit 1 to be executed
circuit1 =transpiled_circuit.qasm;
param_values1 = [];
shots1 = 200;

%%%% Circuit 2 to be executed
circuit2 = transpiled_circuit.qasm;
param_values2 = [];
shots2 = 400;

%% 4. Execute the circuit using sampler primititve
job1 = sampler.run({circuit1,param_values1,shots1});

if isfield(job1,'session_id')
    sampler.session.service.session_id = job1.session_id;
end 


%% 4.1 Retrieve the results back
Results = sampler.Results(job1.id);

Counts = double (decode_and_deserialize(Results.x__value__.pub_results.x__value__.data.x__value__.fields.c.x__value__.array.x__value__,1));
[Bitstring,~,Sorted_prob] = unique(Counts);
Probs = accumarray(Sorted_prob,1).';

bar (Bitstring,Probs)
xlabel('Bitstring')
ylabel('Counts')


