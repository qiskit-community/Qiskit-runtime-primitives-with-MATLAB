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
       
       function response = do_request (method,uri,body,authorization,timeout,caller)
            response = [];
            statuscode = []; 
            retry = 1;
            while isempty(statuscode) || statuscode==500 || isempty(response)
                options = matlab.net.http.HTTPOptions('ConnectTimeout',timeout);
                type_json = matlab.net.http.MediaType('application/json');
                contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
                acceptField = matlab.net.http.field.AcceptField([type_json]);
                
                if authorization.channel == "ibm_cloud" 
                    crn = matlab.net.http.HeaderField('Service-CRN', authorization.crn);
                    token = matlab.net.http.HeaderField('Authorization', authorization.token);
                    headers = [acceptField, contentTypeField, token,crn];
                else
                    token = matlab.net.http.HeaderField('x-access-token', authorization.token);
                    headers = [acceptField, contentTypeField, token];
                end

                if exist('caller','var')
                    caller_header = matlab.net.http.HeaderField('x-qx-client-application', caller);
                    headers = [headers,caller_header];
                end
                
                body_encoded = matlab.net.http.MessageBody(body);
                request = matlab.net.http.RequestMessage(method, headers,body_encoded);
                r = send(request,uri,options);
             
                statuscode = int32(r.StatusCode);
                if r.StatusCode ~= matlab.net.http.StatusCode.OK
                    disp(["Error Code: ", string(statuscode), ': ', getReasonPhrase(getClass(r.StatusCode)),': ',getReasonPhrase(r.StatusCode)])
                    disp(r.Body.Data.errors)
                end

                response = r.Body.Data;
                retry = retry+1;
                if (retry==4)
                    break;
                end
            end
        end
       
       function job_info = submitJob(varargin)
            params    = varargin{1,1};
            hubinfo    = varargin{1,2};
 
            var = constants;
            authorization.channel =  hubinfo.channel ;

            body.program_id = hubinfo.program_id;
            body.backend = hubinfo.backend;
            body.params = params;
            caller = append(var.matlab_version,version);

            if hubinfo.channel == "ibm_cloud"
               authorization.crn = hubinfo.instance;
               authorization.token = append(hubinfo.tokenType,' ', hubinfo.Access_API);
               uri = var.urljob_crn;
       
            else
               authorization.token = hubinfo.Access_API;
               uri = var.urljob_iqp;
               body.hub = hubinfo.hub;
               body.group = hubinfo.group;
               body.project = hubinfo.project;
               
            end %%% End of "ibm_cloud"
            
            if isempty(hubinfo.session_id)
                   if hubinfo.Start_session==0
                        start_session = false;
                   else 
                        start_session = true;
                   end

                    body.start_session = start_session;
               else
                    body.session_id = hubinfo.session_id;
            end
            
            
            method = matlab.net.http.RequestMethod.POST;
            job = Job.do_request (method,uri,body,authorization,var.timeout,caller);
            
            job_info.id = job.id;
            job_info.backend = job.backend;
            if isfield(job,'session_id')
                job_info.session_id = job.session_id;
            end

      end
%%
      function results = retrieveResults(varargin)
        job_id  = varargin{1,1};
        service = varargin{1,2};
        var = constants;
        status = '~'; %anything not empty so the loop starts
        authorization.channel =  service.channel ;
        
        while ~isempty(status)
            %%%% Read the Job status
            if service.channel == "ibm_cloud"
                uri = append(var.urljob_crn,job_id);
                authorization.crn = service.instance;
                authorization.token = append(service.tokenType,' ', service.Access_API);

            else
                uri = append(var.urljob_iqp,job_id);
                authorization.token = service.Access_API;
            end

            method = matlab.net.http.RequestMethod.GET;
            response = Job.do_request (method,uri,[],authorization,var.timeout);
            status = response.status; 

            if status== "Completed"
                %%%% Read the results
                status
                if service.channel == "ibm_cloud"
                    uri = append(append(var.urljob_crn,job_id),"/results");
                else
                    uri = append(append(var.urljob_iqp,job_id),"/results");
                end
                response = Job.do_request(method,uri,[],authorization,var.timeout);
        
                response = eraseBetween(response, 1, "{");
                results = jsondecode(response);
                results.status = status;
                break;
            elseif status == "Failed"
                disp("The job status is Failed");
                disp(response.state)
                results.status = status;
                break;
            end
            pause(1);
           
        end  %% End of While loop

    end  %% End of RetrieveResult Function

      
   end
end