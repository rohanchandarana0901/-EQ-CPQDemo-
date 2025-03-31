public class APTSMD_NewAgreementFromQuoteCls {
    public string agreementJSON {get;set;}
    public string contactJSON {get;set;}
    public string quoteJSON{get;set;}
    public string oppJSON {get;set;}
    public string accJSON {get;set;}
    public string agrRecordTypeJSON {get;set;}
    public string payTermJSON {get;set;}
    public string previousUrl {get;set;}
    public string accId {get;set;}
    public string supportExhibitJSON{get;set;}
    public string quoteId{get;set;}
    public string allQuoteJSON{get;set;}
    //public APTSCU_NewAgreementCls(ApexPages.StandardController controller){}
    public APTSMD_NewAgreementFromQuoteCls(){
        //ApexPages.StandardController controller
        agreementJSON='[]';
        contactJSON='[]';
        oppJSON='[]';
        accJSON='[]';
        agrRecordTypeJSON='[]';
        quoteJSON='[]';
        payTermJSON='[]';
        supportExhibitJSON='[]';
        quoteId='[]';
        allQuoteJSON='[]';
        //accId='yes';
        //accId=(String)controller.getRecord().id;
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            quoteId = ApexPages.currentPage().getParameters().get('id');
        }
        Apttus_Proposal__Proposal__c proposal = [SELECT Id,
                                                        Name,
                                                        Apttus_Proposal__Opportunity__c,
                                                        APTSMD_Discounted_Price_Display__c,
                                                        Apttus_Proposal__Account__c, 
                                                        Apttus_Proposal__ExpectedStartDate__c, 
                                                        Apttus_Proposal__ExpectedEndDate__c 
                                                FROM Apttus_Proposal__Proposal__c 
                                                WHERE id=:quoteId];
        quoteJSON = JSON.serialize(proposal);
        list<Apttus_Proposal__Proposal__c> allQuotes=[SELECT id,name FROM Apttus_Proposal__Proposal__c];
        allQuoteJSON=JSON.serialize(allQuotes);
        previousUrl = ApexPages.currentPage().getHeaders().get('Referer');
        list<account> accountList= new list<account>();
        accountList=[SELECT id,name FROM account];
        list<opportunity> oppList= new list<opportunity>();
        oppList=[SELECT id,Name FROM opportunity];
        list<contact> contactList = new list<contact>();
        contactList = [SELECT id,Name From contact];
        list<RecordType> recordTypeList = new list<RecordType>();
        recordTypeList = [SELECT id,Name From RecordType WHERE sobjecttype='Apttus__APTS_Agreement__c'];
        list<Apttus_Config2__PaymentTerm__c> payTermList = new list<Apttus_Config2__PaymentTerm__c>();
        payTermList=[SELECT Id,Name FROM Apttus_Config2__PaymentTerm__c];
        
        list<string> supportExhibitList = new list<string>();
        sObject obj = new Apttus__APTS_Agreement__c();
        supportExhibitList = getPickValues(obj,'APTSMD_Support_Exhibits__c',null);
        supportExhibitJSON = JSON.serialize(supportExhibitList);
        
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.name='';
        agreement.Apttus__Account__c=null;
        agreement.Apttus__Related_Opportunity__c=null;
        agreement.Apttus__Status_Category__c='Request';
        agreement.Apttus__Term_Months__c=12;
        agreement.Apttus__Total_Contract_Value__c=proposal.APTSMD_Discounted_Price_Display__c;
        agreement.Apttus__Contract_Start_Date__c=null;//proposal.Apttus_Proposal__ExpectedStartDate__c;
        agreement.Apttus__Contract_End_Date__c=null;//proposal.Apttus_Proposal__ExpectedEndDate__c;
        agreement.Apttus__Primary_Contact__c=null;
        agreement.Apttus_CMConfig__PaymentTermId__c=payTermList[0].Id;
        agreement.Apttus_QPComply__RelatedProposalId__c=proposal.Id;
        agreement.APTSMD_SLA__c=false;
        agreement.RecordTypeId=null;
        agreement.APTSMD_Support_Exhibits__c=supportExhibitList[1];
        agreementJSON = JSON.serialize(agreement);
        contactJSON = JSON.serialize(contactList);
        oppJSON = JSON.serialize(oppList);
        accJSON = JSON.serialize(accountList);
        payTermJSON = JSON.serialize(payTermList);
        agrRecordTypeJSON = JSON.serialize(recordTypeList);
    }
    @RemoteAction
    public static string insertAgreement(string agreement,string quoteId){
        system.debug('insertAgreement REMOTING method is called...!!!');
        Apttus__APTS_Agreement__c newAgreement = new Apttus__APTS_Agreement__c();
        newAgreement = (Apttus__APTS_Agreement__c) JSON.deserialize(agreement, Apttus__APTS_Agreement__c.class);
        system.debug('New Agreement :'+newAgreement);
        insert newAgreement;
        
        system.debug('----- Remote Action > New Agreement Created...!!!!');
        String soqlQuery = getCreatableFieldsSOQL('Apttus_Proposal__Proposal_Line_Item__c','Apttus_Proposal__Proposal__c=\''+ quoteId + '\'');
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = (List<Apttus_Proposal__Proposal_Line_Item__c>)Database.query(soqlQuery);
        List<Apttus__AgreementLineItem__c> agreementLineItemList = new List<Apttus__AgreementLineItem__c>();
        
        Set<String> aliFields = Schema.getGlobalDescribe().get('Apttus__AgreementLineItem__c').getDescribe().fields.getMap().keySet();
        Set<String> pliFields = Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal_Line_Item__c').getDescribe().fields.getMap().keySet();
        system.debug('pliFields:' + pliFields);
        
        Map<String, String> fieldMap = new Map<String, String>();
        system.debug('###Starting the loop...');
        for(String pField : pliFields){
            for(String aField : aliFields){
                if(pField.lastIndexOfIgnoreCase('Apttus') > -1 && aField.lastIndexOfIgnoreCase('Apttus') > -1 && pField.indexOf('__') > -1 && aField.indexOf('__') > -1 && pField.subString(pField.indexOf('__') + 2).equals(aField.subString(aField.indexOf('__') + 2))){
                    fieldMap.put(aField,pField);
                    break;
                }
            }
        }
        
        fieldMap.put('Apttus__ProductId__c','Apttus_Proposal__Product__c');
        fieldMap.put('Apttus__Quantity__c','Apttus_QPConfig__Quantity2__c');
        //system.debug('###fieldMap:' + fieldMap);
        
        for(Apttus_Proposal__Proposal_Line_Item__c pli : proposalLineItemList){
            Apttus__AgreementLineItem__c ali = new Apttus__AgreementLineItem__c(Apttus__AgreementId__c = newAgreement.Id);
            for(String field : fieldMap.keySet()){
                //system.debug('PropLi Field Name:' + field);
                if(field.contains('attribute')){
                    continue;
                }
                // system.debug('###field:' + field + ':value:' + pli.get(fieldMap.get(field)));
                if(field.equalsIgnoreCase('Apttus_CMConfig__SummaryGroupId__c')){
                    continue;
                }
                ali.put(field, pli.get(fieldMap.get(field)));
            }
            
            agreementLineItemList.add(ali);
        }
        system.debug('------Agrmt Line List Size :'+agreementLineItemList.size());
        if(!agreementLineItemList.isEmpty()){
            insert agreementLineItemList;
        }
        //pageReference pg = new pageReference('/'+ );
        return newAgreement.id;
    }
    
    private static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    public List<string> getPickValues(Sobject object_name, String field_name, String first_val) {

      List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
      list <string> optionValues = new list<string>();

      if (first_val != null) { //if there is a first value being provided
            options.add(new selectOption(first_val, first_val)); //add the first option
      }

      Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed

      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject

      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject

      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
      optionValues.add(a.getLabel());

         if(a.getValue() != 'unknown' && a.getValue() != 'Other' )        

            options.add(new selectOption(a.getValue(), a.getLabel())); //add the value and label to our final list

      }

      return optionValues; //return the List

    }
}