public class APTSMD_JITNotificationInput {
    public String notificationType;        //notification type that will be passed to Max
    
    public List<String> fieldsToNotify;    //Fields for users that will be notified
    
    public String objectId;                //Id of the object that was triggered

    public String objectName;              //e.g., quote, agreement

    public sObject lookupResult;
    public sObject previousResult;        //object before update
    
    public static Boolean isFirstTime = true;
   
}