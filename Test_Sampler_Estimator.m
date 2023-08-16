% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.

function results = Test_Sampler_Estimator(apitoken)
    
    runtime_apiToken = LoginAPI(apitoken);
    
    hubinfo = {};
    hubinfo.hub = "ibm-q";
    hubinfo.group = "open";
    hubinfo.project = "main";
    hubinfo.program_id = "sampler";
    hubinfo.Access_API = runtime_apiToken.id;
    hubinfo.backend = "ibmq_qasm_simulator";
    hubinfo.Start_session = [];
    hubinfo.session_id = [];
    % Build some circuits
    c1 = quantumCircuit([hGate(1) cxGate(1,2)]);
    params_Sampler = Options.SetOptions(c1,hubinfo, []);
    observables.Pauli_Term = ["II","IZ","ZI","ZZ","XX"];
    observables.Coeffs = string([-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119]);

    
    params_Sampler = struct('params_Sampler', params_Sampler);
    hubinfo_sampler = struct('hubinfo', hubinfo);

    hubinfo.program_id = "estimator";
    params_Estimator = Options.SetOptions(c1,hubinfo,observables);
    params_Estimator = struct('params_Estimator', params_Estimator);
    hubinfo_estimator = struct('hubinfo', hubinfo);

    circuits = struct('circuits', c1);
    observables = struct('observables', observables);
    
    
    P1 = matlab.unittest.parameters.Parameter.fromData('params_Sampler', params_Sampler);
    P2 = matlab.unittest.parameters.Parameter.fromData('params_Estimator', params_Estimator);
    P3 = matlab.unittest.parameters.Parameter.fromData('hubinfo_sampler', hubinfo_sampler);
    P4 = matlab.unittest.parameters.Parameter.fromData('hubinfo_estimator', hubinfo_estimator);
    P5 = matlab.unittest.parameters.Parameter.fromData('circuits', circuits);
    P6 = matlab.unittest.parameters.Parameter.fromData('observables', observables);
    
    suite_Sampler_Estimator = matlab.unittest.TestSuite.fromClass(?Sampler_Estimator_testclass, ...
        'ExternalParameters', [P1,P2,P3,P4,P5,P6]);
    
    r1 = run(suite_Sampler_Estimator)

    %% TestTwolocal
    circuitinfo = {};
    circuitinfo.reps=4;
    circuitinfo.entanglement = "linear";
    circuitinfo.number_qubits = 5;
    circuitinfo.num_parameters = (circuitinfo.reps+1)*circuitinfo.number_qubits;
    
    parameters = -5*ones(circuitinfo.num_parameters,1);
    
    circuitinfo = struct('circuitinfo', circuitinfo);
    parameters = struct('parameters', parameters);
    
    P1 = matlab.unittest.parameters.Parameter.fromData('circuitinfo', circuitinfo);
    P2 = matlab.unittest.parameters.Parameter.fromData('parameters', parameters);
      
    suite_Twolocal = matlab.unittest.TestSuite.fromClass(?TestTowlocal, ...
            'ExternalParameters', [P1,P2]);
        
    r2 = run(suite_Twolocal);

    %% TestMaxcutToIsing
    %%% Create the graph 
    s = [1 1 2 3 3 4];
    t = [2 5 3 4 5 5];
    weights = [1 1 1 1 1 1];
    G = graph(s,t,weights);
    
    Graph = struct('Graph', G); 
    
    P1 = matlab.unittest.parameters.Parameter.fromData('Graph', Graph);
    
    suite_TestMaxCutToIsing = matlab.unittest.TestSuite.fromClass(?TestMaxCutToIsing, ...
            'ExternalParameters', P1);
        
    r3  = run(suite_TestMaxCutToIsing);
    results = [r1, r2, r3];
end