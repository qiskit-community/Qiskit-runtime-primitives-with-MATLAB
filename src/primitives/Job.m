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
            if hubinfo.channel == "ibm_cloud"
              authorization = weboptions(...
                    'MediaType', 'application/x-www-form-urlencoded',...
                    'HeaderFields', {
                        'x-qx-client-application' append(var.matlab_version,version)
                        'Authorization' append(hubinfo.tokenType,' ', hubinfo.Access_API) 
                        'Service-CRN' hubinfo.instance
                        
                    }...
                );
               url = var.urljob_crn;
            
               if isempty(hubinfo.session_id)
                    start_session = true;
                    txt = '{"program_id":"'+hubinfo.program_id+'","start_session":'+start_session+', "tags": [],"backend":"'+hubinfo.backend+'","params":'+params+'}';
               else
                    txt = '{"program_id":"'+hubinfo.program_id+'","session_id":"'+hubinfo.session_id+'", "tags": [],"backend":"'+hubinfo.backend+'","params":'+params+'}';
               end

            else
               authorization = weboptions(...
                'ContentType', 'json',...
                'MediaType', 'application/x-www-form-urlencoded',...
                'HeaderFields', {
                    'x-qx-client-application' append(var.matlab_version,version)
                    'x-access-token' hubinfo.Access_API
                }...
                );
               url = var.urljob_iqp;

               if isempty(hubinfo.session_id)
                    start_session = true;
                    txt = '{"program_id":"'+hubinfo.program_id+'","hub":"'+hubinfo.hub+'","group":"'+hubinfo.group+'","start_session":'+start_session+',"project":"'+hubinfo.project+'", "tags": [],"backend":"'+hubinfo.backend+'","params":'+params+'}';
               else
                    txt = '{"program_id":"'+hubinfo.program_id+'","hub":"'+hubinfo.hub+'","group":"'+hubinfo.group+'","session_id":"'+hubinfo.session_id+'","project":"'+hubinfo.project+'", "tags": [],"backend":"'+hubinfo.backend+'","params":'+params+'}';
    
               end

            end %%% End of "ibm_cloud"
                       
            authorization.Timeout = var.timeout;
            job = webwrite(url, txt, authorization);
            
            job_info.id = job.id;
            job_info.backend = job.backend;
            job_info.session_id = job.session_id;
      end
%%
      function results = retrieveResults(varargin)
        job_id  = varargin{1,1};
        service = varargin{1,2};
        var = constants;
        status = '~'; %anything not empty so the loop starts

        while ~isempty(status)
            %%%% Read the Job status
            if service.channel == "ibm_cloud"
                url = append(var.urljob_crn,job_id);
                options = weboptions(...
                        'HeaderFields', {
                          'Service-CRN' service.instance
                          'Authorization' append(service.tokenType,' ', service.Access_API) 
                    }...
                    );
                options.Timeout = var.timeout;
                response = webread(url, options);
                status = response.status; 

            else
                url = append(var.urljob_iqp,job_id);
                options = weboptions(...
                        'HeaderFields', {
                        'x-access-token' service.Access_API
                    }...
                    );
            
                options.Timeout = var.timeout;
                response = webread(url, options);
                status = response.status; 
            end
            if status== "Completed"
                %%%% Read the results
                status
                if service.channel == "ibm_cloud"
                    url = append(append(var.urljob_crn,job_id),"/results");
                else
                    url = append(append(var.urljob_iqp,job_id),"/results");
                end
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