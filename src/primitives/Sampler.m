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
       options,
       circuits,
       parameters,
   end
   methods

       function obj = Sampler(session,options)
            options.service.program_id = "sampler";
            obj.session = session;
            obj.options = options;
       end

 %%
       function jobinfo = run(varargin)
            circuit    = varargin{1,2};
            hubinfo    = varargin{1,1}.options.service;

            %%%%%% Run the circuit on IBM Quantum Sampler program
            params = Options.SetOptions(circuit,0,[]);
            %%%% Submit the job
            jobinfo = Job.submitJob(params, hubinfo);

      end
 %%     
      function result = Results(varargin)
            job_id = varargin{1,2};
            service  = varargin{1, 1}.options.service;

            result = Job.retrieveResults(job_id, service);

      end

   end

end