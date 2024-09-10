clc;
clear;
close all;
%% Setup IBM Quantum Platform credentials
channel = "ibm_quantum";
apiToken = "MY_IBM_QUANTUM_TOKEN";

%% Define backend and access
backend="ibm_kyoto";

%% 1. Build Bell State circuit, transpile it using TranspilerService and create a qasm3 string
c1 = quantumCircuit([hGate(1) cxGate(1,2)]); 

plot(c1)
qasm= generateQASM(c1);

%% 2. TranspilationOptions for the transpilerService, this would be optional input to the TranspilerService
%%% Default values: 
%           transpilationOptions.optimization_level=1
%           ranspilationOptions.ai = false
%           transpilationOptions.coupling_map = [];
%           transpilationOptions.qiskit_transpile_options = []; 
%           transpilationOptions.ai_layout_mode  = []; 

transpilationOptions.ai = false;
transpilationOptions.optimization_level = 1;
transpilationOptions.coupling_map = [];
transpilationOptions.qiskit_transpile_options = []; %% 
transpilationOptions.ai_layout_mode  = 'OPTIMIZE'; %% 'KEEP', 'OPTIMIZE', 'IMPROVE'

%% Authentication parameters
authParams.token = apiToken;
authParams.channel = channel;

%%% 2.1 Transpile the circuit
%%% Define the Service using your Authentications (Token and access channel)
cloud_transpiler_service = TranspilerService(authParams); 

%%%% Execute the transpiler Service
transpiled_circuit = cloud_transpiler_service.run(qasm, backend,transpilationOptions); 

%%
service = QiskitRuntimeService(channel,apiToken,[]);

%% Define backend and access
service.Start_session = true; %set to true to enable Qiskit Runtime Session 
if service.Start_session ==true
    service.session_mode = "batch";
end

service.hub = "your-hub";
service.group = "your-group";
service.project = "your-project";
%% 1. Enable the session and Sampler
session = Session(service, backend);


service.Start_session = 1;


sampler = Sampler(session);
sampler.options.twirling.enable_gates = false;


%%%% Circuit 1 to be executed
circuit1 =transpiled_circuit.qasm;
param_values1 = [];
shots1 = 200;


%% 4. Execute the transpiled circuit using sampler primititve
job1 = sampler.run({circuit1,param_values1,shots1});

if isfield(job1,'session_id')
    sampler.session.service.session_id = job1.session_id;
end


%% 4.1 Retrieve the results back
Results = sampler.Results(job1.id);
Results
