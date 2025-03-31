/*************************************************************
@Name: APTSMD_MaxResolveQuery
@Authors: Apttus
@CreateDate:14/03/2018
@ModifiedDate: 8 Oct 2018
@purpose: This class is use to send an NL query to Max.
******************************************************************/

Public class APTSMD_MaxResolveQuery{
    @TestVisible static String testId = 'test';
    
    @InvocableMethod
    public static List<List<String>> resolveQuery(List<APTSMD_NotificationObject> inputs) {
        MaxQueryInput queryInput = new MaxQueryInput();
        queryInput.notificationSequenceId = generateUUID();
        queryInput.baseUrl = URL.getOrgDomainUrl().toExternalForm();
        
        system.debug('############# Start of scheduled notification for id: ' + queryInput.notificationSequenceId);
       
        List<String> tempList = new List<String>();
        for (APTSMD_NotificationObject input : inputs) {
            Blob data = Blob.valueOf(Label.APTSMD_MAX_Token);
            Blob hash = Crypto.generateDigest('SHA-256', data);
            queryInput.maxToken = EncodingUtil.base64Encode(hash);
            
            List<String> userFields = new List<String>();
            userFields.add(input.fieldToSave);
            
            queryInput.nlQuery = input.query;
            queryInput.notificationType = input.notificationType;
            queryInput.fieldNames = userFields;
            system.debug('############# Got an NL query to send to Max: ' + input.query);
            
            tempList.add(queryInput.notificationSequenceId);
            
            String JSONRequest = JSON.serialize(queryInput , true);
            system.debug('############# JSONRequest: '+JSONRequest);
      
            sendRequest(JSONRequest);
        }
    
        List<List<String>> resultList = new List<List<String>>();
        resultList.add(tempList);

        return resultList;
    }
    
    public static List<List<String>> resolveReferenceQuery(List<APTSMD_JITNotificationInput> inputs) {
        MaxQueryInput queryInput = new MaxQueryInput();
        queryInput.notificationSequenceId = generateUUID();
        queryInput.baseUrl = URL.getOrgDomainUrl().toExternalForm();
        
        system.debug('############# Start of JIT notification for id: ' + queryInput.notificationSequenceId);
        
        List<String> tempList = new List<String>();
        for (APTSMD_JITNotificationInput input : inputs) {
       
            Blob data = Blob.valueOf(Label.APTSMD_MAX_Token);
            Blob hash = Crypto.generateDigest('SHA-256', data);
            queryInput.maxToken = EncodingUtil.base64Encode(hash);
            
            queryInput.nlQuery = null;
            //queryInput.notificationType = input.notificationType;
            queryInput.objectName = input.objectName;
            //queryInput.fieldNames = input.fieldsToNotify;
            queryInput.lookupResult = input.lookupResult;
            queryInput.previousResult = input.previousResult;
            queryInput.objectId = input.objectId;
            system.debug('############# Doing a reference query to send to Max for ' + input.objectName);
            
            tempList.add(queryInput.notificationSequenceId);
            
            String JSONRequest = JSON.serialize(queryInput , true);
            system.debug('############# JSONRequest: '+JSONRequest);
      
            sendRequest(JSONRequest);
        }
    
        List<List<String>> resultList = new List<List<String>>();
        resultList.add(tempList);

        return resultList;
    }
    
    
    /***************************************************************
    Name: invoke
    purpose: This method is use to send a request to MAX end point,
        which will have the list of users to notify and which
        notification type it is for
    ****************************************************************/
    @future(callout = true)
    public static void sendRequest(string jsonString) {
        system.debug('########### sendRequest input: '+jsonString);
        HttpRequest oHTTPRequest =  new HttpRequest();
        HttpResponse oHTTPResponse =  new HttpResponse();
        Http oHTTPHandler =  new Http();
        try {
            oHTTPRequest.setEndpoint(Label.APTSMD_MAX_End_Point+'/resolveQuery');
            oHTTPRequest.setBody(jsonString);
            oHTTPRequest.setTimeout(Integer.valueOf(Label.APTSMD_Max_Time));
            oHTTPRequest.setMethod(Label.APTSMD_HTTP_Method);
            oHTTPRequest.setHeader(Label.APTSMD_HTTP_Header_Key,Label.APTSMD_HTTP_Header_Value);
            System.debug(oHTTPRequest);
            oHTTPResponse = oHTTPHandler.send(oHTTPRequest);
            String JSONResponse = (oHTTPResponse.getBody());
            system.debug('########### JSONResponse'+JSONResponse);
            
            if (oHTTPResponse.getStatusCode() != 200) {
                system.debug('############# Bad response '+oHTTPResponse.getStatusCode());
                return;
            }
            
            APTSMD_MaxQueryResponse maxResponse = (APTSMD_MaxQueryResponse)JSON.deserialize(JSONResponse, APTSMD_MaxQueryResponse.class);
            testId = maxResponse.notificationSequenceId;
            system.debug('############# Got a response with notificationSequenceId =  '+maxResponse.notificationSequenceId);
            APTSMD_ProcessMaxTimedNotification notifyJob = new APTSMD_ProcessMaxTimedNotification(maxResponse);
            // enqueue the job for processing
            ID jobID = System.enqueueJob(notifyJob);
            
        } catch (CalloutException e) {
            system.debug('############# CallOutException '+e.getMessage());
            system.debug('############# getStackTraceString '+e.getStackTraceString());
            
        } catch (JSONException e) { 
            system.debug('############# JSONException '+e.getMessage());
            system.debug('############# getStackTraceString '+e.getStackTraceString());
        } catch(Exception e) {
            system.debug('############# Exception '+e.getMessage());
            system.debug('############# getStackTraceString '+e.getStackTraceString());
        }
        
    }

    private class MaxQueryInput
    {
        public String nlQuery;
        public String notificationType;
        public List<String> fieldNames;
        public String maxToken;
        public String objectName;
        public sObject lookupResult;
        public sObject previousResult;
        public List<String> userIds;
        public String objectId;
        public String notificationSequenceId;
        public String baseUrl;
    }
    
    private static String generateUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
}