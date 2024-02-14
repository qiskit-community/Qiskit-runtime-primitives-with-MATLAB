clc;
clear;
close all;
%%

%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "7d37efbcf8493c120b1a377a5488598dccedcece7291dfc23ded72067d9f15c4a22151274edc408236167c7edd24e9a3f442076dc70222e54cda4d570c734944";

%%
backend="ibm_cairo";



%% 2. Build Bell State circuit
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

qasm= generateQASM(c1);

params.ai = false;
params.optimization_level = 1;
params.coupling_map = NaN;
params.qiskit_transpile_options = NaN;
params.ai_layout_mode  = NaN;

channelInfo.token = apiToken;
channelInfo.channel = channel;

%%
transpiled_circuit = transpile.run(qasm,params,backend,channelInfo);



