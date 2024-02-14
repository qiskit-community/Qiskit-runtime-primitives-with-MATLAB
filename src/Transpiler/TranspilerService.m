% This code is part of MATLAB-Qiskit Runtime Primitives.
% (C) Copyright IBM 2023.
% This code is licensed under the Apache License, Version 2.0. You may
% obtain a copy of this license in the LICENSE.txt file in the root directory
% of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
% 
% Any modifications or derivative works of this code must retain this
% copyright notice, and modified files need to carry a notice indicating
% that they have been altered from the originals.


classdef TranspilerService
   properties
 
       channelInfo,
       backend,
       params
   end
   methods

       function obj = TranspilerService(params, backend, channelInfo)
           obj.backend = backend;
           obj.channelInfo = channelInfo;
           if ~isempty(params)
                obj.params = params;
           else
                params.ai = false;
                params.optimization_level = 3;
                params.coupling_map = NaN;
                params.qiskit_transpile_options = NaN;
                params.ai_layout_mode  = NaN;
                obj.params = params;
           end

       end
      
       
       function transpile_circuit = run(varargin)
            circuit = varargin{1,2};
            data     = varargin{1, 1}.params;
            
            parameters.backend = varargin{1, 1}.backend;
            parameters.optimization_level = data.optimization_level;
            parameters.use_ai = data.ai;

            body.qasm_circuits = extractBefore(circuit,"c = ");


            if isfield(data,'ai_layout_mode') && ~isempty(data.ai_layout_mode)
                parameters.ai_layout_mode = data.ai_layout_mode;
            end
            if isfield(data,'qiskit_transpile_options') && ~isempty(data.qiskit_transpile_options)
                body.qiskit_transpile_options = data.qiskit_transpile_options;
            end
            if isfield(data,'coupling_map') && ~isempty(data.coupling_map)
                body.backend_coupling_map = data.coupling_map;
            end


            var = constants;
            authorization =  varargin{1, 1}.channelInfo;
            
            %%%% Transpiler Service with ibm_cloud needs attention!!!!
            if varargin{1, 1}.channelInfo.channel == "ibm_cloud"
               authorization.crn = hubinfo.instance;
               authorization.token = append(hubinfo.tokenType,' ', hubinfo.Access_API);
               uri = var.urltranspile;
       
            else
               uri = var.urltranspile;
               
            end %%% End of "ibm_cloud"
            
            method = matlab.net.http.RequestMethod.POST;
            resp = TranspilerService.do_request (method,uri,body,authorization,var.timeout,parameters);

            task_id = resp.task_id;

            method = matlab.net.http.RequestMethod.GET;
            uri = append(uri,'/',task_id);
            
            transpiled_info.state = '';
            while transpiled_info.state ~= "SUCCESS"
                transpiled_info = TranspilerService.do_request (method,uri,[],authorization,var.timeout,[]); 
            end

            transpile_circuit = transpiled_info.result;
            %% Adding the measurement to the transpiled circuit
            transpile_circuit.qasm = extractAfter(transpile_circuit.qasm,'q;');
            transpile_circuit.qasm = insertAfter(transpile_circuit.qasm,";",newline);
              
            for i = 1:length(transpile_circuit.layout.final)
                 sorted_index = sort(transpile_circuit.layout.final);
                 measure = strcat('c[', num2str(i-1),'] = measure q[',num2str(sorted_index(i)), '];');
                 transpile_circuit.qasm = [transpile_circuit.qasm measure newline];
            end

            transpile_circuit.qasm = ['OPENQASM 3;' newline 'include "stdgates.inc";' newline ...
                'bit[', num2str(length(transpile_circuit.layout.final)) '] c;' newline ...
                'qubit[' num2str(length(transpile_circuit.layout.initial)) '] q;' newline ...
                transpile_circuit.qasm];


    
       end
      
   end
 
   %%
   methods(Static)

       function response = do_request (method,uri,body,authorization,timeout,params)
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
                    token = matlab.net.http.HeaderField('Authorization', 'Bearer ' + authorization.token);
                    headers = [acceptField, token, contentTypeField];
                end
                
                if ~isempty(params)
                    % Create a QueryParameter array
                    queryParams = matlab.net.QueryParameter(params);
    
                    % Add the query parameters to the URI
                    uri = matlab.net.URI(uri);
                    uri.Query = queryParams;
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

   end
end