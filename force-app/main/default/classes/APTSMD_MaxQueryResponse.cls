public class APTSMD_MaxQueryResponse {
    public String notificationType;
    
    public List<String> fieldsToSave;
    
    public String query;

    public String objectName;

    public String recordId;
    
    public String objectId;
    
    public String notificationSequenceId;
    
    public String notificationTriggerType;
    
    public sObject previousResult; 
    
    public List<DeltaObject> delta;
    
    public class DeltaObject {
        public String key;
        public String dbField;
        public String oldValue;
        public String newValue;
        public String label;
        public String operation;
    }
}