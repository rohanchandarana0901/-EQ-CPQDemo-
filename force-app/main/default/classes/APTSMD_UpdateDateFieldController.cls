/*
Developed By : Jeetu Agrawal
Date : 17/01/2019
Description : Update Agreement,Agreement Line Item,Proposal,Proposal Line Item,Asset,Asset Line Item,Order,Order Line Item,Cycle Time Group Data, Agreement Term Exception,
Obligation and Agreement Clause Date and Date/Time field.
*/

public class APTSMD_UpdateDateFieldController{
   
    private List<String> dateTimeFieldList;
    private Map<String,String> fieldWithDatatype;
    private List<String> ObjectNameList;
    private Integer monthsBetween;
    private APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting;
    
    public APTSMD_UpdateDateFieldController(){
        dateTimeFieldList = new List<String>();
        fieldWithDatatype=new Map<String,String>();
        ObjectNameList=new List<String>();
        
        //add new object api name make sure api name is small character.
        ObjectNameList.add('apttus__apts_agreement__c');
        ObjectNameList.add('apttus__agreementlineitem__c');
        ObjectNameList.add('apttus_proposal__proposal__c');
        ObjectNameList.add('apttus_proposal__proposal_line_item__c');
        ObjectNameList.add('asset');
        ObjectNameList.add('apttus_config2__assetlineitem__c');
        ObjectNameList.add('apttus_config2__order__c');
        ObjectNameList.add('apttus_config2__orderlineitem__c');
        ObjectNameList.add('apttus__cycletimegroupdata__c');
        ObjectNameList.add('apttus__agreement_term_exception__c');
        ObjectNameList.add('apttus__obligation__c');
        ObjectNameList.add('apttus__agreement_clause__c');
        ObjectNameList.add('opportunity');
    }
    
    public PageReference updateDates(){
        if(UserInfo.getUserName().toLowerCase().contains('mdo') || UserInfo.getUserName().toLowerCase().contains('master')){
            return new PageReference('/one/one.app');
        }
        
        monthsBetween = getDateDifferencePostOrgSpin();
        
        if(monthsBetween <= 0){
            return new PageReference('/one/one.app');
        }
        
        for(Integer index = 0; index < ObjectNameList.size(); index++){
            updateDatesForSingleObject(index);
        }
        
        updateCustomSetting();
        
        return new PageReference('/one/one.app');
    }
    
    private Integer getDateDifferencePostOrgSpin(){
        //fetch presalesConfigSetting and organization date.
        presalesConfigSetting = [select APTSMD_Last_Updated_Date__c from APTSMD_Apttus_PreSales_Config_Settings2__c limit 1];
        organization OrgnizationRecord = [select id,createddate from organization limit 1];
        Date todayDate = Date.today();
          
        //if presalesConfigSetting last UpdateDate is null than use organization cretaed date other wise use presalesConfigSetting
        //(presalesConfigSetting last UpdateDate or organization createddate diff current date) - 1 
        if(presalesConfigSetting.APTSMD_Last_Updated_Date__c==null){    
            DateTime agrCreatedDateTime = OrgnizationRecord.createddate;
            Date agrCreatedDate = Date.newInstance(agrCreatedDateTime.year(), agrCreatedDateTime.month(), agrCreatedDateTime.day());
            return agrCreatedDate.monthsBetween(todayDate);
        }
        else{
            Date agrCreatedDate = presalesConfigSetting.APTSMD_Last_Updated_Date__c;
            return agrCreatedDate.monthsBetween(todayDate);
        }
    }

    private void updateDatesForSingleObject(Integer index){
        String dateTimeFieldListObjectName = ObjectNameList[index];
        system.debug(dateTimeFieldListObjectName  + ' is being processed.');
        
        //fetch all date field
        String dateTimeFieldListField = getFields(dateTimeFieldListObjectName);        
        String soqlQuery='select id,'+dateTimeFieldListField+',createddate from '+dateTimeFieldListObjectName+' where APTSMD_Is_Included_in_Report__c=true';
        
        if(dateTimeFieldListObjectName == 'opportunity'){
            soqlQuery='select id,closedate,createddate from opportunity';
        }
        
        if(soqlQuery.indexOf(',,')>0){
            soqlQuery = soqlQuery.replace(',,', ',');
        }
        
        //fetch object record 
        List<SObject> ObjectRecordList = database.query(soqlQuery);
        
        Boolean flag=false;
        
        if(ObjectRecordList!=null && ObjectRecordList.size()>0){
            //get one by one object record 
            for(SObject tmpRecord:ObjectRecordList){
                //get one by one object field
                for(String fieldname : dateTimeFieldList){
                    if(fieldWithDatatype.get(fieldname)=='DATE'){
                        Date d = (Date) tmpRecord.get(fieldname);
                        if(d!=null){
                                d=d.addMonths(monthsBetween);
                                tmpRecord.put(fieldname,d);
                                flag=true;
                        }     
                    }
                    else if(fieldWithDatatype.get(fieldname)=='DATETIME'){
                        DATETIME d1 = (DATETIME) tmpRecord.get(fieldname);
                        if(d1!=null){
                            d1=d1.addMonths(monthsBetween);
                            tmpRecord.put(fieldname,d1);
                            flag=true;
                        }
                    }
                }
            }
            
            if(flag == true){
                system.debug('Records being updated:' + ObjectRecordList);
                update ObjectRecordList;
            }
        }
    }
    
    private void updateCustomSetting(){
        presalesConfigSetting.APTSMD_Last_Updated_Date__c = Date.today();
        update presalesConfigSetting;
    }

    private String getFields(String type){
        fieldWithDatatype=new Map<String,String>();
        String dateTimeFieldListField='';
        dateTimeFieldList = new List<String>();
        double count=0;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            
        for (String fieldName: fieldMap.keySet()) {
            //It provides to get the object fields label.
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();

           //It provides to get the object fields data type.
           Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
           
            
            if(fieldMap.get(fieldName).getDescribe().isUpdateable()==true && fieldMap.get(fieldName).getDescribe().isCalculated()==false && (fielddataType == Schema.DisplayType.DATE || fielddataType == Schema.DisplayType.DATETIME)){
                if(fielddataType == Schema.DisplayType.DATE)
                { 
                    dateTimeFieldList.add(fieldName);
                    fieldWithDatatype.put(fieldName, 'DATE');
                }
                
                if(fielddataType == Schema.DisplayType.DATETIME){
                    dateTimeFieldList.add(fieldName);
                    fieldWithDatatype.put(fieldName, 'DATETIME');
                }
            }
        }
        
        for(String tmp:dateTimeFieldList){
            if(count+1==dateTimeFieldList.size()){
                dateTimeFieldListField += tmp;
            }
            else{
                dateTimeFieldListField += tmp + ',';
            }
              
            count++;
        }
        return dateTimeFieldListField;
    }

}