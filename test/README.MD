Here we showed how to test the classes that execute sampler, estimator, etc. separately on your local machine:
## 1. Test Sampler, Estimator, submit the job and retreive the final result classes


In order to test these classes on your local MATLAB, first initiate the required information such as hub information, program, etc.

```
runtime_apiToken = LoginAPI("put your IBM Quantum API token here");


%%% Add the required information
hubinfo = {};
hubinfo.hub = "ibm-q";
hubinfo.group = "open";
hubinfo.project = "main";
hubinfo.program_id = "sampler";
hubinfo.Access_API = runtime_apiToken.id;
hubinfo.backend = "ibmq_qasm_simulator";
hubinfo.Start_session = [];
hubinfo.session_id = [];

%%% Build some circuits
circuit = quantumCircuit([hGate(1) cxGate(1,2)]);

%%% Set the options for the submitted job
params_Sampler = Options.SetOptions(circuit,hubinfo, []);

%%% An example of Observables to test the Estimator
observables.Pauli_Term = ["II","IZ","ZI","ZZ","XX"];
observables.Coeffs = string([-1.0523732, 0.39793742, -0.3979374 , -0.0112801, 0.18093119]);

%%% Convert the variables to the corresponding structure to be used by the class
params_Sampler = struct('params_Sampler', params_Sampler);
hubinfo_sampler = struct('hubinfo', hubinfo);

hubinfo.program_id = "estimator";
params_Estimator = Options.SetOptions(circuit,hubinfo,observables);
params_Estimator = struct('params_Estimator', params_Estimator);
hubinfo_estimator = struct('hubinfo', hubinfo);

circuits = struct('circuits', circuit);
observables = struct('observables', observables);

%%%% Set the variables to TestSuite function to test  "Sampler_Estimator_testclass" class:

P1 = matlab.unittest.parameters.Parameter.fromData('params_Sampler', params_Sampler);
P2 = matlab.unittest.parameters.Parameter.fromData('params_Estimator', params_Estimator);
P3 = matlab.unittest.parameters.Parameter.fromData('hubinfo_sampler', hubinfo_sampler);
P4 = matlab.unittest.parameters.Parameter.fromData('hubinfo_estimator', hubinfo_estimator);
P5 = matlab.unittest.parameters.Parameter.fromData('circuits', circuits);
P6 = matlab.unittest.parameters.Parameter.fromData('observables', observables);

%%%% Execute this to test  "Sampler_Estimator_testclass" class!
suite_Sampler_Estimator = matlab.unittest.TestSuite.fromClass(?Sampler_Estimator_testclass, ...
    'ExternalParameters', [P1,P2,P3,P4,P5,P6]);

r1 = run(suite_Sampler_Estimator)

```

By running ```run(suite_Sampler_Estimator)``` all the following classes run and the job executed on IBM QUantum Qasm Simulator and the results are retreived using the submitted JobId

```
Sampler.run()
Job.submitJob()
Job.retrieveResults()
Estimator.run()
```
output would be as follows:
```
Running Sampler_Estimator_testclass

 1×4 TestResult array with properties:

    Name
    Passed
    Failed
    Incomplete
    Duration
    Details

Totals:
   4 Passed, 0 Failed, 0 Incomplete.
   9.2046 seconds testing time.

```
## 2. Twolocal circuit

To test the ```Twolocal``` function you can run the following steps:

```
%% information to create a Twolocal circuit 
circuitinfo = {};
circuitinfo.reps=4; %%% Number of required repetitions
circuitinfo.entanglement = "linear"; %%% define the entanglement
circuitinfo.number_qubits = 5; %%% Number of qubits
circuitinfo.num_parameters = (circuitinfo.reps+1)*circuitinfo.number_qubits;

parameters = -5*ones(circuitinfo.num_parameters,1); %%% Initiate the circuit parameters

%%% Set the parameters for ```TestSuite``` to initiate the test!
circuitinfo = struct('circuitinfo', circuitinfo);
parameters = struct('parameters', parameters);

P1 = matlab.unittest.parameters.Parameter.fromData('circuitinfo', circuitinfo);
P2 = matlab.unittest.parameters.Parameter.fromData('parameters', parameters);
  
suite_Twolocal = matlab.unittest.TestSuite.fromClass(?TestTowlocal, ...
        'ExternalParameters', [P1,P2]);
    
r2 = run(suite_Twolocal);
```

## 3. MaxCutToIsing
You can do the same for the ```MaxCutToIsing``` function as follows:

```
%% TestMaxcutToIsing
%%% Create an example graph to be tested for maxcut problem
s = [1 1 2 3 3 4];
t = [2 5 3 4 5 5];
weights = [1 1 1 1 1 1];
G = graph(s,t,weights);

%%% Set the parameters to initiate TestSuite function to start the test!
Graph = struct('Graph', G); 

P1 = matlab.unittest.parameters.Parameter.fromData('Graph', Graph);

suite_TestMaxCutToIsing = matlab.unittest.TestSuite.fromClass(?TestMaxCutToIsing, ...
        'ExternalParameters', P1);
    
r3  = run(suite_TestMaxCutToIsing);

```

