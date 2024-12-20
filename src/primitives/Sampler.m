% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Sampler
   properties
       session,
       circuits,
       options
   end
   methods

       function obj = Sampler(session)
            session.service.program_id = "sampler";
            obj.session = session;


            options.default_shots = 1024;
    
            % options.dynamical_decoupling.enable = true ;
            % options.dynamical_decoupling.sequence_type = 'XpXm';
            % options.dynamical_decoupling.extra_slack_distribution= 'middle';
            % options.dynamical_decoupling.scheduling_method= 'alap';
            
            options.twirling.enable_gates = true;
            options.twirling.enable_measure = true;
            options.twirling.num_randomizations = "auto";
            options.twirling.shots_per_randomization = "auto";
            options.twirling.strategy = "active-accum"; %% 

            % options.transpilation.optimization_level = 1;

            obj.options = options;
       end

 %%
       function jobinfo = run(varargin)
            circuit    = varargin(1,2:end);
            hubinfo    = varargin{1, 1}.session.service;
            

            params = varargin{1, 1}.setparams(circuit);
            
            %%%% Submit the job
            jobinfo = Job.submitJob(params, hubinfo);

      end
 %%     
      function result = Results(varargin)
            job_id = varargin{1,2};
            service  = varargin{1, 1}.session.service;

            result = Job.retrieveResults(job_id, service);

      end
%%
      function params = setparams (varargin)
        
        sampler = varargin{1,1};
        circuit     = varargin(1,2);
        
        params = struct;
        params.pubs ={};

        for j = 1: length(circuit{1, 1})
            params.pubs = [params.pubs {circuit{1, 1}{1,j}}];
        end
        
        params.version = 2;
        params.support_qiskit= false;        
        params.options = sampler.options;

       end

   end

end