/*************************************************************
@Name: APTSMD_JITNotificationMaxResponse
******************************************************************/
Public class APTSMD_JITNotificationMaxResponse{
        
    Public String message;
    Public String customObjectName;
    Public String customNotificationType;
    Public List<NotificationInfo> notificationList;
    Public String notificationSequenceId;
    
    public class NotificationInfo {
        public String title;
        public String body;
        public String userId;
        public String targetId;
        Public List<CustomObjectParams> customObjectParamList;
}
    
    public class CustomObjectParams {
        public String fieldName;
        public String fieldValue;
    }
}