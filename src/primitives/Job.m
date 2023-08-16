% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef Job
   properties
       Session,
       Options,
       circuits,
       parameters,
   end
   methods(Static)
       function obj = Job(Session,Options)
            obj.Session = Session;
            obj.Options = Options;
       end

       function job_info = submitJob(varargin)
            params    = varargin{1,1};
            hubinfo    = varargin{1,2};
            var = constants;
            authorization = weboptions(...
                'ContentType', 'json',...
                'MediaType', 'application/x-www-form-urlencoded',...
                'HeaderFields', {
                    'x-qx-client-application' append(var.matlab_version,version)
                    'x-access-token' hubinfo.Access_API
                }...
            );
            url = var.urljob;
            % Submit the first job to create a session
            
            if isempty(hubinfo.session_id)
                start_session = true;
                txt = ['{"program_id":"'+hubinfo.program_id+'","hub":"'+hubinfo.hub+'","group":"'+hubinfo.group+'","start_session":'+start_session+',"project":"'+hubinfo.project+'", "tags": [],"backend":"'+hubinfo.backend+'","params":'+params+'}'];
            else
                txt = ['{"program_id":"'+hubinfo.program_id+'","hub":"'+hubinfo.hub+'","group":"'+hubinfo.group+'","session_id":"'+hubinfo.session_id+'","project":"'+hubinfo.project+'", "tags": [],"backend":"'+hubinfo.backend+'","params":'+params+'}'];
                
            end
            job = webwrite(url, txt, authorization)
            
            job_info.id = job.id
            job_info.backend = job.backend
            job_info.session_id = job.session_id
      end
%%
      function results = retrieveResults(varargin)
        job_id = varargin{1,1};
        Access_API  = varargin{1,2};
        var = constants;
        status = '~'; %anything not empty so the loop starts
        while ~isempty(status)
            %%%% Read the Job status
            
            url = append(var.urljob,job_id);
            options = weboptions(...
                    'HeaderFields', {
                    'x-access-token' Access_API
                }...
                );
        
        
            response = webread(url, options);
            status = response.status; 

            if status== "Completed"
                %%%% Read the results
                status
                url = append(append(var.urljob,job_id),"/results");
                options = weboptions(...
                        'HeaderFields', {
                        'x-access-token' Access_API
                    }...
                    );
        
        
                response = webread(url, options);
        
                response = eraseBetween(response, 1, "{");
                results = jsondecode(response);
                
                break;
            elseif status == "Failed"
                status
                results = "The job status is Failed";
                break;
            end
            pause(1);
        end  %% End of While loop

    end  %% End of RetrieveResult Function

      
   end
end