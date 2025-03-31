/**
 * Company      : Apttus Inc.
 * Description  : Rest class to get systemProperties
 * History      :
 * [29.April.2020]: Max Team
 */

@RestResource(urlMapping='/max/system-properties')
global class APTSMD_GetProperties {

   /*****************************************************************

       @param objectName - String - required
       @param fieldsToGet - List - required
       @param lt - Integer - optional

   ******************************************************************/

    @HttpPost
    global Static void getProperties(String objectName,List<string> fieldsToGet,Integer lt){
        //check if mandatory params received
        if(objectName == null || objectName == ''){
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide system objectName.');
        }
        if(fieldsToGet.isEmpty()){
            RestContext.response.responseBody = APTSMD_API_CommonUtils.sendErrorMessage('Please provide the list of fields to get from object.');
        }
        if(lt == null || lt == 0){
            lt = 1;
        }

        try{
            if (Schema.describeSObjects(new String[]{objectName})[0].isAccessible()) {
                //form the query
                String q = 'Select';
                for(String field: fieldsToGet){
                    if(hasSObjectField(field, objectName)){
                        q += ' ' + field+ ',';
                    }
                }
                q = q.removeEnd(',');
                q+= ' FROM ' + objectName+ ' LIMIT '+ lt;
                System.debug('getsystem properties query: '+ q);
                List<sObject> obj = Database.query(q);
                System.debug('getsystem properties query result: '+JSON.serialize(obj));
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(obj));
            }
            else {
             throw new IllegalArgumentException('The object is not accesible');
            }
        }catch(Exception ex){
            System.debug('Exception: '+ ex);
            RestContext.response.responseBody = APTSMD_API_CommonUtils.getExceptionMessage(ex);
        }

    }

    public static boolean hasSObjectField(String fieldName, String objectName){
                return Schema.describeSObjects(new String[]{objectName})[0].fields.getMap().keySet().contains(fieldName.toLowerCase());
    }
    public static Map<id,Attachment> getAttachemnts(List<String> attachmentIds){
        return new Map<id,Attachment>([select id,body,name,ContentType,Description,lastmodifiedDate from Attachment where id  in :attachmentIds]);
    }
}