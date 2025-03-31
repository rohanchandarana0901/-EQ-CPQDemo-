/*************************************************************
@Name: APTS_QueryAndSendToMax
@Authors: Apttus
@CreateDate:14/03/2018
@ModifiedDate: 8 Oct 2018
@purpose: This class is use to notify Max of a proactive notification.
******************************************************************/

Public class APTS_QueryAndSendToMax{
    
    @InvocableMethod
    public static List<List<String>> prepareNotification(List<APTSMD_NotificationObject> reminders) {
        APTS_MaxNotification notificationInfo = new APTS_MaxNotification();
        
        String notificationTask = '';
        
        Set<String> filteredList = new Set<String>();
        List<String> convertedList = new List<String>();
        
        for (APTSMD_NotificationObject reminder : reminders) {
            notificationInfo.NotificationTask = reminder.notificationType;
            system.debug('############# Got a notification for: '+reminder.notificationType);
            
            //Query for the object, and loop through to collect users
            for (Sobject tmp : Database.query(reminder.query)) {
                //Add the user id field to a set, which will collect only the unique values
                filteredList.add((String)tmp.get(reminder.fieldToSave));
            }
            
            convertedList.addAll(filteredList);
            notificationInfo.UserIds = convertedList;
      
            String JSONRequest = JSON.serialize(notificationInfo , true);
            system.debug('############# JSONRequest: '+JSONRequest);
      
            sendRequest(JSONRequest);
      }
    
      List<List<String>> resultList = new List<List<String>>();
      try {
          resultList.add(convertedList);
      } catch(Exception e) {
          system.debug('############# Exception '+e.getMessage());
          system.debug('############# getStackTraceString '+e.getStackTraceString());
      }
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
            oHTTPRequest.setEndpoint(Label.APTSMD_MAX_End_Point+'/notify');
            oHTTPRequest.setBody(jsonString);
            oHTTPRequest.setTimeout(Integer.valueOf(Label.APTSMD_Max_Time));
            oHTTPRequest.setMethod(Label.APTSMD_HTTP_Method);
            oHTTPRequest.setHeader(Label.APTSMD_HTTP_Header_Key,Label.APTSMD_HTTP_Header_Value);
            System.debug(oHTTPRequest);
            oHTTPResponse = oHTTPHandler.send(oHTTPRequest);
            String JSONResponse = (oHTTPResponse.getBody());
            system.debug('########### JSONResponse'+JSONResponse);
            //system.debug('########### JSONResponse'+);
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