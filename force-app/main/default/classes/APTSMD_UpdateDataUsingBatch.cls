/*

Developed By : Jeetu Agrawal
Date : 17/01/2019
Description : Update Proposal and Agreement Date and Date/Time field.

*/

public class APTSMD_UpdateDataUsingBatch{

    Public String ObjectType;
    public List<String> temp;
    Public Map<String,String> fieldWithDatatype;
    
    Public APTSMD_UpdateDataUsingBatch(){
        ObjectType = apexpages.currentpage().getparameters().get('Object');
        temp=new List<String>();
        fieldWithDatatype=new Map<String,String>();
    }


Public Void UpdateData(){
        
        String tempField=getField('apttus__apts_agreement__c');
        String soqlQuery='select id,'+tempField+',createddate from Apttus__APTS_Agreement__c where APTSMD_Include_In_Report__c=true';
        System.debug('tempField : '+tempField);
      List<Apttus__APTS_Agreement__c> agreementList = database.query(soqlQuery);
      
      Date todayDate = Date.today();
      Boolean flag=false;
      
      if(agreementList!=null){
      for(Apttus__APTS_Agreement__c tmp:agreementList){
            
            DateTime agrCreatedDateTime = tmp.createddate;
            Date agrCreatedDate = Date.newInstance(agrCreatedDateTime.year(), agrCreatedDateTime.month(), agrCreatedDateTime.day());
            Integer monthsBetween = agrCreatedDate.monthsBetween(todayDate);
            monthsBetween = monthsBetween-1;
            
            if(monthsBetween>0){
                 for(String fieldname : temp){
                     if(fieldWithDatatype.get(fieldname)=='DATE'){
                        Date d = (Date) tmp.get(fieldname);
                        if(d!=null){
                                d=d.addMonths(monthsBetween);
                                tmp.put(fieldname,d);
                                flag=true;
                         }     
                     }
                     else if(fieldWithDatatype.get(fieldname)=='DATETIME'){
                         DATETIME d1 = (DATETIME) tmp.get(fieldname);
                          if(d1!=null){
                                 d1=d1.addMonths(monthsBetween);
                                 tmp.put(fieldname,d1);
                                 flag=true;
                        }
                     }
                }
            }
      }
      
        if(flag==true){
        update agreementList;}}
     
      
        tempField=getField('apttus_proposal__proposal__c');
        soqlQuery='select id,'+tempField+',createddate from Apttus_Proposal__Proposal__c where APTSMD_Include_In_Report__c=true';
      List<Apttus_Proposal__Proposal__c> proposalList = database.query(soqlQuery);
      
     todayDate = Date.today();
      flag=false;
      if(proposalList!=null){
      for(Apttus_Proposal__Proposal__c tmp:proposalList){
      
            DateTime proposalCreatedDateTime = tmp.createddate;
            Date proposalCreatedDate = Date.newInstance(proposalCreatedDateTime.year(), proposalCreatedDateTime.month(), proposalCreatedDateTime.day());
            Integer monthsBetween = proposalCreatedDate.monthsBetween(todayDate);
            monthsBetween = monthsBetween-1;
            
            if(monthsBetween>0){
                 for(String fieldname : temp){
                     if(fieldWithDatatype.get(fieldname)=='DATE'){
                        Date d = (Date) tmp.get(fieldname);
                        if(d!=null){
                                d=d.addMonths(monthsBetween);
                                tmp.put(fieldname,d);
                                flag=true;
                         }     
                     }
                     else if(fieldWithDatatype.get(fieldname)=='DATETIME'){
                         DATETIME d1 = (DATETIME) tmp.get(fieldname);
                          if(d1!=null){
                                 d1=d1.addMonths(monthsBetween);
                                 tmp.put(fieldname,d1);
                                 flag=true;
                        }
                     }
                }
            }
      }
      
      if(flag==true){
     update proposalList;}}
     
     
   /*  PageReference pr = new PageReference('/');
     pr.setRedirect(true);
     return pr;*/
      
}

Public String getField(String type){
    fieldWithDatatype=new Map<String,String>();
    String tempField='';
    temp=new List<String>();
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
        { temp.add(fieldName);
            fieldWithDatatype.put(fieldName, 'DATE');
        }
        
        if(fielddataType == Schema.DisplayType.DATETIME){
          temp.add(fieldName);
          fieldWithDatatype.put(fieldName, 'DATETIME');
        }
            
        }
    }
    
   for(String tmp:temp){
        if(count+1==temp.size()){
            tempField += tmp;
            }
            else{
                tempField += tmp + ',';
            }
          
            count++;
    }
   // System.debug('tempField : '+tempField);
    return tempField;
}

}