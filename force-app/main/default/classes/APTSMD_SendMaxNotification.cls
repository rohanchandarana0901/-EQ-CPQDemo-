public class APTSMD_SendMaxNotification implements Queueable {
    @TestVisible static Boolean makeCallout = true;
    @TestVisible static Database.SaveResult testResult;
    
    private String customNotifType;
    private List<APTSMD_JITNotificationMaxResponse.NotificationInfo> notifList;
    private String customObjectName;
    private String notificationSequenceId;

    public APTSMD_SendMaxNotification(APTSMD_JITNotificationMaxResponse response) {
        this.customNotifType = response.customNotificationType;
        this.notifList = response.notificationList;
        this.customObjectName = response.customObjectName;
        this.notificationSequenceId = response.notificationSequenceId;
    }
    
    public void execute(QueueableContext context) {  
        if (this.customObjectName != null && this.notifList != null) {
            System.debug('####### Start to send sfdc notifications for id = ' + this.notificationSequenceId);
            
            //Flow is called for notifications
            List<CustomNotificationType> customNotifs = [SELECT Id,MasterLabel FROM CustomNotificationType WHERE MasterLabel = :customNotifType];
            if (customNotifs == null || customNotifs.size() == 0)
                return;
            System.debug('####### Number of notifications to send out = ' + this.notifList.size());
            //Collect a list of CongaEvents, then insert list
            List<sObject> congaEvents = new List<sObject>();
            for (Integer i = 0; i < this.notifList.size(); i++) {
                //try {
                    //Create custom object for each notification
                    List<APTSMD_JITNotificationMaxResponse.CustomObjectParams> paramList = this.notifList[i].customObjectParamList;
                    
                    SObject sObj = Schema.getGlobalDescribe().get(this.customObjectName).newSObject();
                    for (Integer j = 0; paramList != null && j < paramList.size(); j++) {
                        sObj.put(paramList[j].fieldName, paramList[j].fieldValue);
                    }
                    //sObj.put('Name', 'TestName');
                    //insert sObj;
                    System.debug('##### #' + i + ': record id = ' + this.notifList[i].targetId + ', userid = ' + this.notifList[i].userId);
                    congaEvents.add(sObj);
                    
                    /*Map<String, Object> inputs = new Map<String, Object>();
                    inputs.put('NotifBody', this.notifList[i].body);
                    inputs.put('NotifTitle', this.notifList[i].title);
                    inputs.put('NotifRecipients', this.notifList[i].userId);
                    //inputs.put('NotifTarget', this.notifList[i].targetId);
                    inputs.put('NotifTarget', (String)sObj.get('Id'));
                    inputs.put('NotifTypeId', customNotifs[0].Id);
                      
                    Flow.Interview.SendCustomMaxNotification notifFlow = new Flow.Interview.SendCustomMaxNotification(inputs);
                    notifFlow.start();
                
                } catch (DmlException e) {
                    System.debug('####### The following exception has occurred: ' + e.getMessage());
                }*/
            }
            try {
                System.debug('####### Inserting # conga events : ' + congaEvents.size());
                //insert congaEvents;
                List<Database.SaveResult> sResList = Database.insert(congaEvents, false);
                if (sResList.size() > 0)
                    testResult = sResList[0];
            } catch (DmlException e) {
                System.debug('####### The following exception has occurred: ' + e.getMessage());
            }
            for (Integer j=0; j < this.notifList.size(); j++) {
                try {
                Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('NotifBody', this.notifList[j].body);
                inputs.put('NotifTitle', this.notifList[j].title);
                inputs.put('NotifRecipients', this.notifList[j].userId);
                inputs.put('NotifTarget', (String)congaEvents[j].get('Id'));
                inputs.put('NotifTypeId', customNotifs[0].Id);
                  
                Flow.Interview.SendCustomMaxNotification notifFlow = new Flow.Interview.SendCustomMaxNotification(inputs);
                notifFlow.start();
                } catch(Exception e) {
                    System.debug('####### The following exception has occurred while calling flow on record # ' + j + ': ' + e.getMessage());
                }
            }
        }
    }
    
}