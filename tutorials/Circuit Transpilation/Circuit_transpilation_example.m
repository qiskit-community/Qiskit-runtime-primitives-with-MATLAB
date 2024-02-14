clc;
clear;
close all;
%%

%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "token";

%%
backend="ibm_cairo";

%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

qasm= generateQASM(c1);

params.ai = true;
params.optimization_level = 3;
params.coupling_map = NaN;
params.qiskit_transpile_options = NaN;
params.ai_layout_mode  = NaN;

channelInfo.token = apiToken;
channelInfo.channel = channel;

%%
transpiled_circuit = transpile.run(qasm,params,backend,channelInfo);



