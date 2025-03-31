global class generateDocument implements Apttus_WebStore.RemoteDispatcher.DispatchInterface{
   /**
     * 
     */
    global Apttus_WebStore.RemoteDispatcher.DispatchResponse dispatch(String method, Object jsonData){
        Map<String, Object> data = (Map<String, Object>) jsonData;
        if(method == 'createCustomDocument')
            return this.createCustomDocument(data);
        else
            return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(false, 'Invalid Endpoint: ' + method);
    }

    public Apttus_WebStore.RemoteDispatcher.DispatchResponse createCustomDocument(Map<String, Object> data){
             Id templateId = (String) data.get('templateId');
            Id recordId = (String) data.get('recordId');
            String sObjectType = (String) data.get('sObjectType');
            String format = (String) data.get('format');
            String accessLevel = (String) data.get('accessLevel');
            String baseUrl=Apttus__ComplySystemProperties__c.getvalues('System Properties').Apttus__InstanceUrl__c; 
            String serverUrl = baseUrl+'/services/Soap/class/Apttus/MergeWebService';
            String sessionId = userInfo.getSessionId();
            Boolean isDraft = (Boolean) data.get('isDraft');
            system.debug('sessionid=>'+sessionId);
            Id response = Apttus.MergeWebService.generateCustomDoc(templateId,
                                                                   recordId,
                                                                   sObjectType,
                                                                   accessLevel,
                                                                   format,
                                                                   isDraft,
                                                                   sessionId,
                                                                   serverUrl);
                                                               
            return new Apttus_WebStore.RemoteDispatcher.DispatchResponse(true, response);  
    }
    
   
}