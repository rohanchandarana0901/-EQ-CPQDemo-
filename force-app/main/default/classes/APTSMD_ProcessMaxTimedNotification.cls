public class APTSMD_ProcessMaxTimedNotification implements Queueable {
    @TestVisible static Boolean makeCallout = true;
    @TestVisible static List<APTSMD_NotificationMaxInput.MaxUserNotification> testNotification;
    @TestVisible static String testSequenceId = 'test';
    
    private String notificationType;
    private String soqlQuery;
    private List<String> fieldsToSave;
    private String maxToken;
    private String objectName;
    private String notificationSequenceId;
    private sObject previousResult;            //only for jit notifications, otherwise null
    private String notificationTriggerType;
    private List<APTSMD_MaxQueryResponse.DeltaObject> delta;
    
    public APTSMD_ProcessMaxTimedNotification(APTSMD_MaxQueryResponse response) {
        this.notificationType = response.notificationType;
        this.fieldsToSave = response.fieldsToSave;
        this.soqlQuery = response.query;
        this.objectName = response.objectName;
        this.notificationSequenceId = response.notificationSequenceId;
        this.previousResult = response.previousResult;
        this.notificationTriggerType = response.notificationTriggerType;
        this.delta = response.delta;
        
        Blob data = Blob.valueOf(Label.APTSMD_MAX_Token);
        Blob hash = Crypto.generateDigest('SHA-256', data);
        this.maxToken = EncodingUtil.base64Encode(hash);
    }
    
    public void execute(QueueableContext context) {
        APTSMD_NotificationMaxInput notificationInfo = new APTSMD_NotificationMaxInput();
        List<APTSMD_NotificationMaxInput.MaxUserNotification> notifList = new List<APTSMD_NotificationMaxInput.MaxUserNotification>();
            
        //List<String> userIdList = new List<String>();
        //List<String> recordList = new List<String>();
        
        notificationInfo.BaseUrl = URL.getOrgDomainUrl().toExternalForm();
        notificationInfo.MaxToken = this.maxToken;
        notificationInfo.NotificationType = this.notificationType;
        notificationInfo.ObjectName = this.objectName;
        notificationInfo.NotificationSequenceId = this.notificationSequenceId;
        notificationInfo.NotificationTriggerType = this.notificationTriggerType;
        notificationInfo.Delta = this.delta;
       
        system.debug('############# notificationSequenceId: '+this.notificationSequenceId);
        system.debug('############# notificationType: '+this.notificationType);
        system.debug('############# soqlQuery: '+this.soqlQuery);
        
        if (this.soqlQuery == null) {
            System.debug('######## NULL soql query, so we cannot query');
            testSequenceId = 'null query';
            return;
        }
        
        //Query for the object, and loop through to collect users
        for (Sobject tmp : Database.query(this.soqlQuery)) {
            for (String userField : this.fieldsToSave) {
                try {
                    Id suserid = (Id)tmp.get(userField);
                    if (suserid == null)
                        continue;
                    if (suserid.getSObjectType() != User.sobjecttype) {
                        System.debug('###### got a group so will use createdbyid instead for record ' + (String)tmp.get('Id'));
                        userField = 'CreatedById';
                    }
                    //userIdList.add((String)tmp.get(userField));
                
                    //recordList.add((String)tmp.get('Id'));
                    
                    APTSMD_NotificationMaxInput.MaxUserNotification maxNotif = new APTSMD_NotificationMaxInput.MaxUserNotification();
                    maxNotif.UserId = (String)tmp.get(userField);
                    maxNotif.RecordId = (String)tmp.get('Id');
                    maxNotif.lookupResult = tmp;
                    maxNotif.previousResult = this.previousResult;
                    notifList.add(maxNotif);
                
                } catch (Exception e) {
                    System.debug('###### Got exception for record ' + (String)tmp.get('Id') + ': ' + e.getMessage());
                }
            }
        }
       
        testNotification = notifList;
        notificationInfo.NotificationInfoList = notifList;
        system.debug('############# number of records to send to Max: '+notifList.size());
        
        String JSONRequest = JSON.serialize(notificationInfo , true);
        system.debug('############# JSONRequest: '+JSONRequest);
      
        sendRequest(JSONRequest);
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
            oHTTPRequest.setEndpoint(Label.APTSMD_MAX_End_Point+'/messages/notification');
            oHTTPRequest.setBody(jsonString);
            oHTTPRequest.setTimeout(Integer.valueOf(Label.APTSMD_Max_Time));
            oHTTPRequest.setMethod(Label.APTSMD_HTTP_Method);
            oHTTPRequest.setHeader(Label.APTSMD_HTTP_Header_Key,Label.APTSMD_HTTP_Header_Value);
            System.debug(oHTTPRequest);
            oHTTPResponse = oHTTPHandler.send(oHTTPRequest);
            String JSONResponse = (oHTTPResponse.getBody());
            system.debug('########### JSONResponse'+JSONResponse);
            
            APTSMD_JITNotificationMaxResponse maxResponse = (APTSMD_JITNotificationMaxResponse)JSON.deserialize(JSONResponse, APTSMD_JITNotificationMaxResponse.class);
            testSequenceId = maxResponse.notificationSequenceId;
            APTSMD_SendMaxNotification notifyJob = new APTSMD_SendMaxNotification(maxResponse);
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
}