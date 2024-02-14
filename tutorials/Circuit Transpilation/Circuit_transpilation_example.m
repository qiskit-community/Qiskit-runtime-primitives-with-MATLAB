clc;
clear;
close all;
%%

%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "Token";

%%
backend="ibm_cairo";

%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

qasm= generateQASM(c1);

params.ai = true;
params.optimization_level = 3;
params.coupling_map = [];
params.qiskit_transpile_options = []; %% Find the keys and values of this Dic!
params.ai_layout_mode  = 'KEEP'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

channelInfo.token = apiToken;
channelInfo.channel = channel;

%% Transpile a circuit using Transpile Service
cloud_transpiler_service = TranspilerService(params, backend, channelInfo);
transpiled_circuit = cloud_transpiler_service.run(qasm);



