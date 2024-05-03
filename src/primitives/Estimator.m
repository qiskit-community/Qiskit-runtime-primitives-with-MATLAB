% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Estimator
   properties
        session,
        circuits,
        Hamiltonian,
        options  

   end
   methods

       function obj = Estimator(session)
            session.service.program_id = "estimator";
            obj.session = session;

            options.resilience.measure_mitigation = true;
            % options.resilience.measure_noise_learning = NaN;
            options.resilience.zne_mitigation = false;
            options.resilience.zne.extrapolator = ["exponential", "linear"];
            options.resilience.zne.noise_factors = [1, 3, 5];
            % options.resilience.pec_mitigation = false;
            % options.resilience.pec = NaN;
            % options.resilience.layer_noise_learning = NaN;
            
            options.default_shots = 1024;
            
            options.dynamical_decoupling.enable = true ;
            options.dynamical_decoupling.sequence_type = "XX";
            options.dynamical_decoupling.extra_slack_distribution= "middle";
            options.dynamical_decoupling.scheduling_method= "alap";
            
            options.twirling.enable_gates = false;
            options.twirling.enable_measure = true;
            options.twirling.num_randomizations = "auto";
            options.twirling.shots_per_randomization = "auto";
            options.twirling.strategy = "active-accum"; %% 

            options.resilience_level= 0;

            obj.options = options;

       end
       %%%% Submit the job through Estimator Primitives
       function jobinfo = run(varargin)

            circuit    = varargin(1,2:end);
            hubinfo    = varargin{1, 1}.session.service;
            
            params = varargin{1, 1}.setparams(circuit);
    
            
            %% Run the circuit on IBM Quantum Estimator primitive
            %%%% Submit the job
            jobinfo = Job.submitJob(params, hubinfo);

        end
        %%%% retrieve the Estimator results using the job id 
        function [result, exps] = Results(varargin)
            job_id      = varargin{1,2};
            service  = varargin{1, 1}.session.service;
    
            result = Job.retrieveResults(job_id, service);
            
            %%% decode and deserialize the Pub results
            exp_val = zeros(1,length(result.x__value__.pub_results));
            stds    = zeros(1,length(result.x__value__.pub_results));
            
            for k =1: length(result.x__value__.pub_results)

                exp_val(k) = double(decode_and_deserialize(result.x__value__.pub_results(k).x__value__.data.x__value__.fields.evs.x__value__,1));
                result.x__value__.pub_results(k).x__value__.data.x__value__.fields.evs.x__value__ = exp_val(k);
                
                stds(k) = double(decode_and_deserialize(result.x__value__.pub_results(k).x__value__.data.x__value__.fields.stds.x__value__,1));
                result.x__value__.pub_results(k).x__value__.data.x__value__.fields.stds.x__value__ = stds(k);

            end
            exps = exp_val;

        end
        
        %%% Set the options for Estimator
        function params = setparams (varargin)
        
            estimator = varargin{1,1};
            circuit     = varargin(1,2);
            
            params = struct;
            params.pubs ={};
    
            for j = 1: length(circuit{1, 1})
                params.pubs = [params.pubs circuit{1,1}(1,j)];
            end
            
            params.version = 2;
            params.support_qiskit= true;        
            params.resilience_level= estimator.options.resilience_level; 
            params.options = rmfield(estimator.options  ,"resilience_level");


       end

   end
end
