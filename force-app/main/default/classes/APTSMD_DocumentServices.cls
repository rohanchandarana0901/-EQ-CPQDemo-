global class APTSMD_DocumentServices {

    // Variables
    global static APTSMD_Presales_Config_Metadata__mdt documentServiceMetadata = APTSMD_Presales_Config_Metadata__mdt.getInstance('Default');

    // Methods

    // getComposerAuthToken() - Get Composer Auth Token
    global static string getComposerAuthToken(){
        try {
            HttpRequest req = new HttpRequest();            
            String postBody = 'grant_type='+ documentServiceMetadata.APTSMD_Conga_Composer_Grant_Type__c +'&scope='+ documentServiceMetadata.APTSMD_Conga_Composer_Auth_Scope__c +'&client_id=' + documentServiceMetadata.APTSMD_Conga_Composer_Client_ID__c + '&client_secret=' + documentServiceMetadata.APTSMD_Conga_Composer_Client_Secret__c;
            req.setBody(postBody);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');            
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Composer_Auth_Endpoint__c);
            req.setMethod('POST');
            req.setTimeout(30000);
            HttpResponse res = new Http().send(req);
            System.debug('Req JSON >>' + req);
            system.debug('getComposerAuthToken response >>' + res.getBody());
            return res.getBody();
        } catch(Exception e) {
            throw e;
        }
    }
    
    global static string getCongaPlatformUserSpecificAuthToken(){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint(documentServiceMetadata.APTSMD_Conga_Platform_Auth_Endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            String payload = 'client_id='+EncodingUtil.urlEncode(documentServiceMetadata.APTSMD_Conga_Composer_Client_ID__c ,'UTF-8')+
                '&client_secret='+EncodingUtil.urlEncode(documentServiceMetadata.APTSMD_Conga_Composer_Client_Secret__c ,'UTF-8')+
                '&user-id='+EncodingUtil.urlEncode(documentServiceMetadata.APTSMD_Conga_Platform_Admin_User_ID__c ,'UTF-8')+
                '&organization-id='+EncodingUtil.urlEncode(documentServiceMetadata.APTSMD_Conga_Platform_Org_ID__c,'UTF-8')+
                '&organization-fid='+EncodingUtil.urlEncode(documentServiceMetadata.APTSMD_Conga_Platform_Org_FID__c,'UTF-8')+
                '&grant_type='+EncodingUtil.urlEncode(documentServiceMetadata.APTSMD_Conga_Composer_Grant_Type__c ,'UTF-8');
            System.debug(payload);
            
            request.setBody(payload);
            HttpResponse response = http.send(request);
            // Parse the JSON response
            if (response.getStatusCode() != 200) {
              System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {              
              Map<String, Object> responseJSON = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
              string access_token = responseJSON.get('access_token').toString();
              System.debug(access_token);
              return access_token;
            }
            return null;
        } catch(Exception e) {
            throw e;
        }
    }

    // getSalesforceAuthToken - Get Salesforce Auth Token
    global static string getSalesforceAuthToken(){
        try {
            HttpRequest req = new HttpRequest();            
            String postBody = 'grant_type='+ documentServiceMetadata.APTSMD_Salesforce_Grant_Type__c +'&username=' + documentServiceMetadata.APTSMD_Salesforce_Username__c + '&password=' + documentServiceMetadata.APTSMD_Salesforce_Password__c + '&client_id=' + documentServiceMetadata.APTSMD_Salesforce_Client_Id__c + '&client_secret=' + documentServiceMetadata.APTSMD_Salesforce_Client_Secret__c;
            req.setBody(postBody);
            req.setHeader('Content-Length', String.valueOf(postBody.Length()));
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setEndpoint(documentServiceMetadata.APTSMD_Salesforce_Auth_Endpoint__c);
            req.setMethod('POST');
            req.setTimeout(30000);
            System.debug('req >> '+ req);
            HttpResponse res = new Http().send(req);
            System.debug('Req JSON >>' + req);
            System.debug('getSalesforceAuthToken response >> ' + res.getBody());
            return res.getBody();
        } catch(Exception e) {
            throw e;
        }
    }

    // generateDocument() - Generate the document
    global static string generateDocument(String documentName, String documentJSONData, String salesforceMasterId, String salesforceComposerTemplateId){
        try {
            // Get Composer Auth Token
            string composerAuthResponse = getComposerAuthToken();
            System.debug('composerAuthResponse >>'+ composerAuthResponse);
            String congaComposerAccessToken = ((Map<String, Object>)JSON.deserializeUntyped(composerAuthResponse)).get('access_token').toString();

            // Get Salesforce Auth Token
            string salesforceAuthResponse = getSalesforceAuthToken();
            System.debug('salesforceAuthResponse >>'+ salesforceAuthResponse);
            Map<String, Object> salesforceAccessTokenResponseMap = (Map<String, Object>)JSON.deserializeUntyped(salesforceAuthResponse);
            String salesforceAccessToken = (salesforceAccessTokenResponseMap).get('access_token').toString();
            String salesforceInstanceUrl = (salesforceAccessTokenResponseMap).get('instance_url').toString();
            system.debug('salesforceAccessToken:' + salesforceAccessToken);
            system.debug('salesforceInstanceUrl:' + salesforceInstanceUrl);

            HttpRequest req = new HttpRequest();
            string ofn = documentName;
            System.debug('JSON >> ' + documentJSONData);
            system.debug('JSON >> ' + documentJSONData.replaceAll('"', '\'').replace('\\\'', '\"'));
            String postBody = '{' +
                '"SalesforceRequest": {' +
                '"SessionId": "'+ salesforceAccessToken + '",' +
                '"TemplateId": "' + salesforceComposerTemplateId + '",' +
                '"MasterId": "' + salesforceMasterId + '",' +
                '"ServerUrl": "'+ salesforceInstanceUrl + '/services/Soap/u/50.0/' + UserInfo.getOrganizationId() +'",' +
                '}, "LegacyOptions": { "sc0": "1", "sc1": "SalesforceFile", "DefaultPDF": "1", "OFN" : "' + ofn + ' "}, "output": {"generateDocumentDownload": true}, ' +
                '"jsonData": "'+ documentJSONData.replaceAll('"', '\'').replace('\\\'', '\"') +'"' +
                '}';
            req.setBody(postBody);
            System.debug('postBody >> '+ postBody);
            req.setHeader('Content-Length', String.valueOf(postBody.Length()));
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer ' + congaComposerAccessToken);
            
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Composer_Merge_Endpoint__c +'/api/ingress/v1/Merge');
            req.setMethod('POST');
            req.setTimeout(30000);
            System.debug('Req JSON >>' + req);
            HttpResponse res = new Http().send(req);
            return res.getBody();
        } catch (Exception e) {
            throw e;
        }
    }

    // checkDocGenStatus() - Check document generation status
    global static string checkDocGenStatus(String correlationId){
        try {
            // Get Composer Auth Token
            string composerAuthResponse = getComposerAuthToken();
            System.debug('composerAuthResponse >>'+ composerAuthResponse);
            String congaComposerAccessToken = ((Map<String, Object>)JSON.deserializeUntyped(composerAuthResponse)).get('access_token').toString();

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + congaComposerAccessToken);
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Composer_Merge_Endpoint__c + '/api/status/v1/status/' + correlationId);
            req.setMethod('GET');
            req.setTimeout(30000);
            HttpResponse res = new Http().send(req);
            return res.getBody();
        } catch (Exception e) {
            throw e;
        }
    }

    // getGeneratedDocURL() - get generated document url
    global static string getGeneratedDocURL(String correlationId){
        try {
            // Get Composer Auth Token
            string composerAuthResponse = getComposerAuthToken();
            System.debug('composerAuthResponse >>'+ composerAuthResponse);
            String congaComposerAccessToken = ((Map<String, Object>)JSON.deserializeUntyped(composerAuthResponse)).get('access_token').toString();

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + congaComposerAccessToken);
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Composer_Merge_Endpoint__c + '/api/presigned/v1/presignedservice/' + correlationId);
            req.setMethod('GET');
            req.setTimeout(30000);
            HttpResponse res = new Http().send(req);
            return res.getBody();
        } catch (Exception e) {
            throw e;
        }
    }

    // getGeneratedDoc() - get generated document
    global static HttpResponse getGeneratedDoc(String generatedDocURL){
        try {
            // Get Composer Auth Token
            string composerAuthResponse = getComposerAuthToken();
            System.debug('composerAuthResponse >>'+ composerAuthResponse);
            String congaComposerAccessToken = ((Map<String, Object>)JSON.deserializeUntyped(composerAuthResponse)).get('access_token').toString();

            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + congaComposerAccessToken);
            req.setEndpoint(generatedDocURL);
            req.setMethod('GET');
            req.setTimeout(30000);
            HttpResponse res = new Http().send(req);
            return res;
        } catch (Exception e) {
            throw e;
        }
    }

    // getSignAuthToken() - Get Composer Auth Token
    global static string getSignAuthToken(){
        try {
            HttpRequest req = new HttpRequest();            
            String postBody = 'grant_type='+ documentServiceMetadata.APTSMD_Conga_Composer_Grant_Type__c +'&scope='+ documentServiceMetadata.APTSMD_Conga_Sign_Auth_Scope__c +'&client_id=' + documentServiceMetadata.APTSMD_Conga_Composer_Client_ID__c + '&client_secret=' + documentServiceMetadata.APTSMD_Conga_Composer_Client_Secret__c;
            req.setBody(postBody);            
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');            
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Sign_Auth_Endpoint__c);
            req.setMethod('POST');
            req.setTimeout(30000);
            HttpResponse res = new Http().send(req);
            System.debug('Req JSON >>' + req);
            system.debug('getSignAuthToken response >>' + res.getBody());
            return res.getBody();
        } catch(Exception e) {
            throw e;
        }
    }

    global static string sendDocumentForCongaSign(String packageName, String firstName, String lastname, String email, String companyName, blob file){
        try {
            // Get Conga Sign Auth Token
            string composerAuthResponse = getSignAuthToken();
            System.debug('composerAuthResponse >>'+ composerAuthResponse);
            String congaSignAccessToken = ((Map<String, Object>)JSON.deserializeUntyped(composerAuthResponse)).get('access_token').toString();

            // Create Conga Sign Payload
            CongaSignPayload payload = new CongaSignPayload();
            payload.name = packageName;
            payload.type = 'PACKAGE';
            payload.language = 'en';
            payload.emailMessage = '';
            payload.description = 'New Package';
            payload.autocomplete = true;
            payload.status = 'SENT';
            payload.documents = new List<CongaSignDocument>();
            payload.roles = new List<CongasignRole>();

            CongaSignApproval approvals = new CongaSignApproval();
            approvals.fromFile = false;
            approvals.role = 'Signer1';

            CongaSignDocument document = new CongaSignDocument();
            document.name = packageName;
            // document.approvals = new List<CongaSignApproval>();
            // document.approvals.add(approvals);         
            payload.documents.add(document);

            CongaSignSigner signer1 = new CongaSignSigner();
            signer1.firstName = firstName;
            signer1.lastName = lastname;
            signer1.email = email;
            signer1.company = companyName;

            CongasignRole role = new CongasignRole();
            role.id = 'Signer1';
            role.signers = new List<CongaSignSigner>();
            role.signers.add(signer1);
            
            payload.roles.add(role);
            
            System.debug('payload >> ' + payload);

            // Create HTTPFormBuilder Request
            String body = '';
            body += APTSMD_HttpBuilder.append('payload', JSON.serialize(payload));

            Map<String,String> formData = new Map<String, String>();
            formData.put('payload', JSON.serialize(payload));
            //blob finalBody = APTSMD_HttpBuilder.createFormDataBlob(formData, contentVersionData.VersionData, payload.name + '.pdf', 'file');//APTSMD_HttpBuilder.makeBlobWithFile('file', contentVersionData.VersionData,'Document For Signature' , body);
            blob finalBody = APTSMD_HttpBuilder.makeBlobWithFile('file', file ,'Document For Signature' , body);
            System.debug('finalBody >> ' + finalBody);
            string contentLength = string.valueOf(finalBody.size());

            HttpRequest req = new HttpRequest();
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Sign_Endpoint__c);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Authorization', 'Bearer ' + congaSignAccessToken);
            req.setHeader('Content-Length', contentLength);
            req.setHeader('Content-Type',APTSMD_HttpBuilder.GetContentType());
            req.setMethod('POST');
            req.setTimeout(120000); 
            req.setBodyAsBlob(finalBody);
            System.debug('sendForsignReq >> ' + req);
            HttpResponse res = new Http().send(req);
            System.debug('sendDocumentForCongaSign response >>' + res.getBody());
            
            return res.getBody();
        } catch(Exception e) {
            throw e;
        }
    }

    global static string getCongaSignSigningURL(String packageId, String roleId){
        try {
            // Get Conga Sign Auth Token
            string composerAuthResponse = getSignAuthToken();
            System.debug('composerAuthResponse >>'+ composerAuthResponse);
            String congaSignAccessToken = ((Map<String, Object>)JSON.deserializeUntyped(composerAuthResponse)).get('access_token').toString();            

            HttpRequest req = new HttpRequest();
            req.setEndpoint(documentServiceMetadata.APTSMD_Conga_Sign_Endpoint__c+'/'+packageId+'/roles/'+roleId+'/signingUrl');
            req.setHeader('Accept', 'application/json');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Authorization', 'Bearer ' + congaSignAccessToken);
            req.setMethod('GET');
            req.setTimeout(120000);
            System.debug('sendForsignReq >> ' + req);
            HttpResponse res = new Http().send(req);
            System.debug('sendDocumentForCongaSign response >>' + res.getBody());
            
            return res.getBody();
        } catch(Exception e) {
            throw e;
        }
    }


    // Helper Class

    public class CongaSignPayload{
        public List<CongaSignRole> roles {get;set;}
        public List<CongaSignDocument> documents {get;set;}
        public string name {get;set;}
        public string type {get;set;}
        public string language {get;set;}
        public string emailMessage {get;set;}
        public string description {get;set;}
        public string status {get;set;}
        public boolean autocomplete {get;set;}
    }
    
    public class CongasignRole{
        public string id {get;set;}
        public List<CongaSignSigner> signers {get;set;}
    }
    
    public class CongaSignSigner{
        public string firstName {get;set;}
        public string lastName {get;set;}
        public string email {get;set;}
        public string company {get;set;}
    }
    
    public class CongaSignDocument{
        public string name {get;set;}
        //public List<CongaSignApproval> approvals {get;set;}
    }

    public class CongaSignApproval{
        public Boolean fromFile;
        public String role; //Role1
        public CongaSignField[] fields;
    }

    public class CongaSignField{
        public Integer page;	//0
        public Integer top;	//300
        public String subtype;	//FULLNAME
        public Integer height;	//50
        public Integer left;	//100
        public Integer width;	//200
        public String type;	//SIGNATURE
        public String value;
        public String name;
    }

    
}