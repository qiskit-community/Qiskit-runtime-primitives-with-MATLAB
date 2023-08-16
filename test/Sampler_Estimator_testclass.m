% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Sampler_Estimator_testclass < matlab.unittest.TestCase
    
    properties (ClassSetupParameter)
       params_Sampler = struct('params_Sampler', 1) ,
       params_Estimator = struct('params_Estimator', 1) ,
       hubinfo_sampler = struct('hubinfo_sampler', 1),
       hubinfo_estimator = struct('hubinfo_estimator', 1),
       circuits = struct('circuits', 1),
       observables = struct('observables', 1), 
    end
    
    methods (TestClassSetup)
        function testmockjobinfo (~,params_Sampler,params_Estimator,hubinfo_sampler,hubinfo_estimator,circuits,observables)
            
        end
        
    
    end

    methods (Test)
        function testsamplerRun (testCase,params_Sampler,hubinfo_sampler)

            %%%%%% Run the circuit on IBM Quantum Sampler program

            %%%% Submit the job
            jobinfo = Sampler.run(params_Sampler,hubinfo_sampler);
            testCase.verifyGreaterThan(size(jobinfo.id,2),0)
            % testcase.verifyNotEmpty(jobinfo.id);
        end

        function testsubmitJob_Sampler (testCase,params_Sampler,hubinfo_sampler)

            %%%%%% Run the circuit on IBM Quantum Sampler program

            %%%% Submit the job
            jobinfo = Job.submitJob(params_Sampler,hubinfo_sampler);
            testCase.verifyGreaterThan(size(jobinfo.id,2),0)
            % testcase.verifyNotEmpty(jobinfo.id);
        end

        function testretrieveResults_Sampler (testCase,params_Sampler,hubinfo_sampler)

            %%%%%% Run the circuit on IBM Quantum Sampler program

            %%%% Submit the job
            jobinfo = Job.submitJob(params_Sampler,hubinfo_sampler);
            Results = Job.retrieveResults(jobinfo.id,hubinfo_sampler.Access_API);
            testCase.verifyNotEmpty(Results)
            % testcase.verifyNotEmpty(jobinfo.id);
        end

        function testestimatorRun (testCase,params_Estimator,hubinfo_estimator)

            %%%%%% Run the circuit on IBM Quantum Estimator program

            %%%% Submit the job
            jobinfo = Estimator.run(params_Estimator,hubinfo_estimator);
            testCase.verifyGreaterThan(size(jobinfo.id,2),0)
           
        end
        
        %%
    end


end

