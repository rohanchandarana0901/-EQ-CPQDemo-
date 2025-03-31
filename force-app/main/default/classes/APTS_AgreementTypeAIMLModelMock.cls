global class APTS_AgreementTypeAIMLModelMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HTTPResponse res = new HTTPResponse();
        if (req.getEndpoint().endsWith('projects')) {
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"project_id": 100}');
            res.setStatusCode(201);
            return res;
        } else if (req.getEndpoint().endsWith('fields=project_name')) {
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"project_id": 100,"project_name": "MSA"},{"project_id": 101,"project_name": "NDA"}]');
            res.setStatusCode(200);
            return res;
        }else if (req.getEndpoint().endsWith('fields=template_name')) {
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"template_id": 76,"is_default": true,"fields": [{"field_id": 4,"field_name": "Assignment"},{"field_id": 301,"field_name": "End Date"}]}]');
            res.setStatusCode(200);
            return res;
        } else if (req.getEndpoint().contains('project_name')) {
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{}');
            res.setStatusCode(204);
            return res;
        }else if (req.getEndpoint().endsWith('/fields')) {
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"add_ids":[301],"remove_ids": [4]}');
            res.setStatusCode(204);
            return res;
        } else{
            
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
        }
        
        return res;
        
    }

}