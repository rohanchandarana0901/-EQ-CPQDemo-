/*
 *Author: Mayur Soni
 *Date: 10-Dec-2015  
 *Purpose: This class is used to fetch custom fields of all the custom settings available in the org. 
********************************************************************************************
 *Author: Jigar Naik
 *Date: 06-Apr-2017  
 *Change: Refactored the code and added functionality to display custom setting values also. 
********************************************************************************************
 *Author: Jeetu Agrawal
 *Date: 13-Dec-2018  
 *Change: Migrate.
********************************************************************************************
 *Author: Varun Mehtani
 *Date: 24-Nov-2020
 *Change: Added the functionality to upsert the modified values. 
********************************************************************************************
*/
global class APTSMD_CustomSettingController{
    public Map<String,List<LabelName>> csNameVsFieldsMap;
    public Map<String,String> csNameVsValueTitleMap;
    public Map<String,String> csNameVsURLMap;
    public static String recordInsertedOrModified; 
    public String csNameVsValueTitleJSON{
        get{
            
            return JSON.serialize(csNameVsValueTitleMap);
        }set;
    }
    public String csNameVsURLJSON{
        get{
            return JSON.serialize(csNameVsURLMap);
        }set;
    }
    public String customSettingData{
        get{
            return JSON.serialize(csNameVsFieldsMap);
        }set;
    }
    public static String recordInsertedOrModifiedJSON{
        get{
            return JSON.serialize(recordInsertedOrModified);
        }set;
    }
    
    public APTSMD_CustomSettingController(){
        Integer loopCount = 0;
        Map<String,Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<Schema.SObjectType> sobjects = schemaMap.values();
        Schema.DescribeSObjectResult objDescribe;
        List<Schema.SObjectType> customSettings = new List<Schema.SObjectType>();
        for(Schema.SObjectType objType : sobjects)
        {
            objDescribe = objType.getDescribe();
            if(objDescribe.isCustomSetting()){
                customSettings.add(objType);
            }
        }
        csNameVsFieldsMap = new Map<String,List<LabelName>>();
        csNameVsValueTitleMap = new Map<String,String>();
        csNameVsURLMap = new Map<String,String>();
        
        for(Schema.SObjectType objType : customSettings)
        {   
            objDescribe = objType.getDescribe();
            String name,prefix;
            
            
            prefix = objDescribe.getKeyPrefix();
            
            name = objDescribe.getLabel() + ' (' +objDescribe.getName() + ')';
            
            String soqlQuery = getAllFieldsSOQL(objDescribe.getName());
            List<sObject> queryResult = (List<sObject>)Database.query(soqlQuery);//SOQL in loop is written only due to the unavailability of relevant metadata API.
            sObject sObjectToDisplay = null;
            csNameVsValueTitleMap.put(name, '');
            csNameVsURLMap.put(name, '/setup/ui/listCustomSettingsData.apexp?id=' + prefix);
            
            if(queryResult != null && queryResult.size() >= 1){
                sObjectToDisplay = queryResult[0];
                csNameVsValueTitleMap.put(name, 'Field Value');
                csNameVsURLMap.put(name, '/setup/ui/viewCustomSettingsData.apexp?setupid=CustomSettings&id=' + sObjectToDisplay.Id);
            }
            
            List<LabelName> fields = getFieldMetaData(objDescribe, sObjectToDisplay);
            csNameVsFieldsMap.put(name,fields);
            
            loopCount++;
            if(loopCount == 100){
                break;
            }
        }
          
    }
    
    @RemoteAction
    public static String updateCustomSettingRecords (String objectName,List<LabelName> customSettingList){
        //Trimming the object name to avoid extra things apart from Object API Name
        String trim_string = objectName.substringAfter('(');
        String trim_string_again = trim_string.substringBefore(')');
        String soqlQuery ;
        //Calling the class as its a non-static method
        APTSMD_CustomSettingController csc = new APTSMD_CustomSettingController();
        soqlQuery=csc.getAllFieldsSOQL(trim_string_again);
        List<sObject> queryResult = (List<sObject>)Database.query(soqlQuery);
        //Initializing maps only to get the Field Data type
        String objType=trim_string_again;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        //this block is for insertion of custom setting record 
        if(queryResult.isEmpty() ){
            sObject sObj = Schema.getGlobalDescribe().get(trim_string_again).newSObject();
            sobj.put('Name','System Properties');
            // sobj.Name='System Properties';
            for(LabelName wrapper_var : customSettingList){
                            //Accessing the Field Data type
                            String fieldLabel = fieldMap.get(wrapper_var.Name).getDescribe().getLabel();
                            Schema.DisplayType fielddataType = fieldMap.get(wrapper_var.Name).getDescribe().getType();
                            string fieldType = fieldMap.get(wrapper_var.Name).getDescribe().getType().name().ToLowerCase();
                            //Checking if the values are modified
                            if(wrapper_var.ischanged){
                                 //Checking if the datatype of the field modified is Double/Percentage/Decimal/Currency :
                                if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal' )
                                {
                                        Double dec=0;
                                        If( wrapper_var.value == null)
                                        {
                                            dec=0;
                                        }
                                        else{
                                            try{
                                                String ObjToString = (String) wrapper_var.value;
                                                dec=Double.valueOf(ObjToString);
                                            }
                                            catch(Exception e){
                                                System.debug('The exception is :' + e.getMessage());
                                              }
                                        }
                                        sObj.put(wrapper_var.Name,dec); 
                                }
                                //Checking if the datatype of the field modified is Boolean :
                                
                                else if(fieldType == 'boolean')
                                {
                                        Boolean valueInBoolean;
                                        If( wrapper_var.value == null)
                                        {
                                            valueInBoolean = false;
                                        }
                                        else{
                                            try{
                                                String ObjToString = (String) wrapper_var.value;
                                                valueInBoolean=Boolean.valueOf(ObjToString);
                                            }
                                            catch(Exception e){
                                                System.debug('The exception is :' + e.getMessage());
                                            }
                                        }
                                        sObj.put(wrapper_var.Name,valueInBoolean); 
                                }
                                else {
                                        String valueInString;
                                        If( wrapper_var.value == null)
                                        {
                                            valueInString = '';
                                        }
                                        else{
                                            try{
                                                String ObjToString = (String) wrapper_var.value;
                                                valueInString=ObjToString;
                                            }
                                            catch(Exception e){
                                                System.debug('The exception is :' + e.getMessage());
                                            }
                                        }
                                        sObj.put(wrapper_var.Name,valueInString); 
                                }
                           }
                                
                        }
            insert sObj;
            recordInsertedOrModified='Record(s) inserted';
        }
        //this block is for updating custom setting record 
        if(!queryResult.isEmpty() && queryResult.size() > 0){
           for (sObject sobj_var : queryResult){
               //Iterating through the wrapper class containing updated values
              if(!customSettingList.isEmpty() && customSettingList.size() > 0){
                        for(LabelName wrapper_var : customSettingList){
                            //Accessing the Field Data type
                            String fieldLabel = fieldMap.get(wrapper_var.Name).getDescribe().getLabel();
                            Schema.DisplayType fielddataType = fieldMap.get(wrapper_var.Name).getDescribe().getType();
                            string fieldType = fieldMap.get(wrapper_var.Name).getDescribe().getType().name().ToLowerCase();
                            //Checking if the values are modified
                            if(wrapper_var.ischanged){
                                //Checking if the datatype of the field modified is Double/Percentage/Decimal/Currency :
                                if(fieldType == 'currency' || fieldType == 'double' || fieldType == 'percent' || fieldType == 'decimal' )
                                {
                                        Double dec;
                                        If( wrapper_var.value == null)
                                        {
                                            dec=0;
                                        }
                                        else{
                                            try{
                                                String ObjToString = (String) wrapper_var.value;
                                                dec=Double.valueOf(ObjToString);
                                            }
                                            catch(Exception e){
                                                System.debug('Error occured while converting to Double datatype  :' + e.getMessage());
                                              }
                                        }
                                        sobj_var.put(wrapper_var.Name,dec); 
                                }
                                //Checking if the datatype of the field modified is Boolean :
                                else if(fieldType == 'boolean')
                                {
                                        Boolean valueInBoolean;
                                        If( wrapper_var.value == null)
                                        {
                                            valueInBoolean = false;
                                        }
                                        else{
                                            try{
                                                String ObjToString = (String) wrapper_var.value;
                                                valueInBoolean=Boolean.valueOf(ObjToString);
                                            }
                                            catch(Exception e){
                                                System.debug('Error occured while converting to Boolean datatype :' + e.getMessage());
                                            }
                                        }
                                        sobj_var.put(wrapper_var.Name,valueInBoolean); 
                                }
                                else {
                                        String valueInString;
                                        If( wrapper_var.value == null)
                                        {
                                            valueInString = '';
                                        }
                                        else{
                                            try{
                                                String ObjToString = (String) wrapper_var.value;
                                                valueInString=ObjToString;
                                            }
                                            catch(Exception e){
                                                System.debug('The exception is :' + e.getMessage());
                                            }
                                        }
                                        sobj_var.put(wrapper_var.Name,valueInString); 
                                }
                           }
                                
                        }
                    } 
               
            }
            update queryResult;
            recordInsertedOrModified='Record(s) updated';
      }
        return recordInsertedOrModified;
    }
    private List<LabelName> getFieldMetaData(Schema.DescribeSObjectResult dsor, sObject csRecord){
        List<LabelName> returnList = new List<LabelName>();
        // map of all fields in the object
        Map<String, Schema.SObjectField> objectFields = dsor.fields.getMap();
    
        // iterate over the requested fields and get the describe info for each one. 
        // add it to a map with field name as key
        for(String field : objectFields.keySet()){
            Schema.DescribeFieldResult dr = objectFields.get(field).getDescribe();
            // add the results to the map to be returned
            
            if(dr.isCustom()){
                if(csRecord == null){
                    // returnList.add(new LabelName(dr.getLabel(),dr.getName(),null,false,dr.getType()));
                    returnList.add(new LabelName(dr.getLabel(),dr.getName(),null,false));
                }else{
                    // returnList.add(new LabelName(dr.getLabel(),dr.getName(),csRecord.get(dr.getName()),false,dr.getType()));
                    returnList.add(new LabelName(dr.getLabel(),dr.getName(),csRecord.get(dr.getName()),false));
                }
            }
        }
       return returnList;
    }
    
    private String getAllFieldsSOQL(String objectName){
        String selects = '';
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    selectFields.add(fd.getName());
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        return 'SELECT ' + selects + ' FROM ' + objectName;
         
    }
    public class LabelName{
        public Id id;
        public String label;
        public String name;
        public Object value;
        public Boolean isChanged;
       public LabelName(String label,String name, Object value,Boolean isChanged){
            this.label = label;
            this.name = name;
            this.value = value;
            this.isChanged = isChanged;
            this.id=id;
        }
        
    }
}