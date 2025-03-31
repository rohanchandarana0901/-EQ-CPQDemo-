public class APTSMD_LoadObligationCtrl {
    Public static String recordTypeName;
    
    public static String getMasterObligations() {
        List<Id> existingMasterObligationIds = new List<Id>();
        existingMasterObligationIds = getExistingMasterObligationIds(Apexpages.currentPage().getParameters().get('Id'));
        
        List<APTSMD_Master_Obligation__c> masterObligations = new List<APTSMD_Master_Obligation__c>();
        masterObligations = [SELECT Id, 
                             		Name,
                                	APTSMD_Obligation_Extract__c,
                               		APTSMD_Obligation_Topic_Description__c,
                                	APTSMD_Obligation_Type__c,
                                	APTSMD_Agreement_RecordType__c,
                                	APTSMD_Template__c,
                             		APTSMD_Clause_Name__c 
                           	   FROM APTSMD_Master_Obligation__c
                              WHERE Id NOT IN :existingMasterObligationIds
                           ORDER BY APTSMD_Agreement_RecordType__c DESC NULLS LAST];
        
        return JSON.serialize(masterObligations);
   }
    
    public static List<Id> getExistingMasterObligationIds (Id agreementId){
        List<Id> idsToReturn = new List<Id>();
        List<Apttus__Obligation__c> obligations = new List<Apttus__Obligation__c>();
        obligations = [SELECT APTSMD_Master_Obligation__c FROM Apttus__Obligation__c WHERE APTSMD_Agreement__c = :agreementId];
        
        for(Apttus__Obligation__c temp : obligations){
            idsToReturn.add(temp.APTSMD_Master_Obligation__c);
        }
        
        return idsToReturn;
    }
    
    public static String getAgreement(){
        Id agreementId = Apexpages.currentPage().getParameters().get('Id');
        
        Apttus__APTS_Agreement__c thisAgreement = new Apttus__APTS_Agreement__c();
        thisAgreement = [SELECT Name, RecordType.Name FROM Apttus__APTS_Agreement__c WHERE Id= :agreementId];
        recordTypeName = thisAgreement.RecordType.Name;
        return JSON.serialize(thisAgreement);
    }
    
    public static PageReference addToAgreement(){
        String newObligationsString = ApexPages.currentPage().getParameters().get('myParam');
        
        
        List<APTSMD_Master_Obligation__c> deserializedObligations = (List<APTSMD_Master_Obligation__c>)JSON.deserialize(newObligationsString, List<APTSMD_Master_Obligation__c>.class);
      	List<Apttus__Obligation__c> obligationsToInsert = new List<Apttus__Obligation__c>();
        for(APTSMD_Master_Obligation__c obg : deserializedObligations){
        	obligationsToInsert.add(createObligationRecord(obg));
        }
        
        insert obligationsToInsert;
		createTasksForObligations(obligationsToInsert);
        
        return null;
    }
    
    public static PageReference addNewObligationToAgreement(){
        String newObligationsString = ApexPages.currentPage().getParameters().get('newObligations');
        
        
        List<Apttus__Obligation__c> obligationsToInsert = (List<Apttus__Obligation__c>)JSON.deserialize(newObligationsString, List<Apttus__Obligation__c>.class);
        for(Apttus__Obligation__c obg : obligationsToInsert){
        	modifyObligationRecord(obg);
        }
        
        insert obligationsToInsert;
		createTasksForObligations(obligationsToInsert);
        
        return null;
    }
    
    public static pageReference reRoute(){
        Id agreementId = Apexpages.currentPage().getParameters().get('Id');
        
        PageReference pageRef = new PageReference('/'+agreementId);
        return pageRef;
    }
    
    public static pageReference reRouteSamePage(){
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public static Apttus__Obligation__c createObligationRecord(APTSMD_Master_Obligation__c temp){
        Apttus__Obligation__c thisObligation = new Apttus__Obligation__c();
        
        thisObligation.APTSMD_Agreement__c = Apexpages.currentPage().getParameters().get('Id');
        thisObligation.APTSMD_Master_Obligation__c = temp.Id;
        thisObligation.APTSMD_Template__c = temp.APTSMD_Template__c;
        thisObligation.APTSMD_Obligation_Extract__c = temp.APTSMD_Obligation_Extract__c;
        thisObligation.APTSMD_Obligation_Topic_Description__c = temp.APTSMD_Obligation_Topic_Description__c;
        thisObligation.APTSMD_Obligation_Type__c = temp.APTSMD_Obligation_Type__c; 
        thisObligation.Apttus__Description__c = 'Standard Obligation';
        thisObligation.APTSMD_Guidance__c = 'Standard';
        thisObligation.APTSMD_Active__c = true;
        //thisObligation.APTSMD_Payment_Amount__c = 100;
        thisObligation.APTSMD_Recurrence__c = 'Once a Week';
        thisObligation.APTSMD_Status__c = 'Not Started';
        thisObligation.APTSMD_Due_Date__c = Date.today() + 7;
        thisObligation.Apttus__StartDate__c = Date.today();
        thisObligation.Apttus__EndDate__c = Date.today() + 7;
            
        return thisObligation;
    }
    
    public static Apttus__Obligation__c modifyObligationRecord(Apttus__Obligation__c temp){
        Id masterObligationId;
        
        temp.APTSMD_Agreement__c = Apexpages.currentPage().getParameters().get('Id');
        temp.APTSMD_Obligation_Type__c = 'Ad-Hoc';
        String abc = getAgreement();
        temp.APTSMD_Agreement_RecordType__c = recordTypeName;
        temp.APTSMD_Obligation_Extract__c=temp.name;
        temp.Apttus__Description__c = 'Standard Obligation';
        temp.APTSMD_Active__c = true;
        temp.APTSMD_Status__c = 'Not Started';
        temp.APTSMD_Guidance__c = 'Standard';
        temp.Apttus__StartDate__c = Date.today();
        temp.Apttus__EndDate__c = temp.APTSMD_Due_Date__c.date()+1;

        if(temp.APTSMD_Create_Master__c == true){
            masterObligationId = createMasterObligation(temp);
        	temp.APTSMD_Master_Obligation__c = masterObligationId;
        }
            
        return temp;
    }
    
    public static Id createMasterObligation(Apttus__Obligation__c temp){
        APTSMD_Master_Obligation__c masterObligation = new APTSMD_Master_Obligation__c();
        masterObligation.APTSMD_Obligation_Extract__c = temp.APTSMD_Obligation_Extract__c;
        masterObligation.APTSMD_Obligation_Topic_Description__c = temp.APTSMD_Obligation_Topic_Description__c;
        masterObligation.APTSMD_Obligation_Type__c = temp.APTSMD_Obligation_Type__c;
        masterObligation.APTSMD_Agreement_RecordType__c = temp.APTSMD_Agreement_RecordType__c;
        insert masterObligation;
        
        return masterObligation.Id;
    }
    
    public static void createTasksForObligations(List<Apttus__Obligation__c> allObligations){
        List<Task> tasksToInsert = new List<Task>();
        
        for(Apttus__Obligation__c temp : allObligations){
            System.debug('@@@temp.APTSMD_Recurrence__c   ' + temp.APTSMD_Recurrence__c);
        if(temp.APTSMD_Recurrence__c!=null && temp.APTSMD_Recurrence__c!='') 
        {
                Task thisTask = new Task();
                thisTask.WhatId = temp.Id;
                thisTask.priority = 'Normal';
                thisTask.status = 'Not Started';
                thisTask.description = 'New  Work';
                if(temp.APTSMD_Recurrence__c == 'Once a Week'){
                    thisTask.Subject = 'Weekly Checkpoint';
                    //thisTask.IsRecurrence = true;
                    //thisTask.RecurrenceInterval = 7;
                    //thisTask.RecurrenceStartDateOnly = System.today();
                    //thisTask.RecurrenceEndDateOnly = System.today()+7;
                    //thisTask.RecurrenceType = 'RecursDaily';
                }
                else if(temp.APTSMD_Recurrence__c == 'One-Time'){
                    thisTask.Subject = 'One-Time Checkpoint';
                    thisTask.IsRecurrence = false;
                    thisTask.ActivityDate = System.today()+7;
                    /*thisTask.RecurrenceInterval = 1;
                    thisTask.RecurrenceStartDateOnly = System.today()+7;
                    thisTask.RecurrenceEndDateOnly = System.today()+7;
                    thisTask.RecurrenceType = 'RecursOneTime';*/
                }
                else if(temp.APTSMD_Recurrence__c == 'Once a Month'){
                    thisTask.Subject = 'Monthly Checkpoint';
                    //thisTask.IsRecurrence = true;
                    //thisTask.RecurrenceInterval = Date.daysInMonth(System.today().year(), System.today().month());
                    //thisTask.RecurrenceStartDateOnly = System.today()+7;
                    //thisTask.RecurrenceEndDateOnly = System.today()+Date.daysInMonth(System.today().year(), System.today().month());
                    //thisTask.RecurrenceType = 'RecursMonthly';
                    //thisTask.RecurrenceDayOfMonth=System.today().day();
                    System.debug('@@@thisTask   ' + thisTask);
                }
                
                tasksToInsert.add(thisTask);    
            }
        }
            if(!tasksToInsert.isEmpty())
            insert tasksToInsert;
    }
    
    public static Id getClauseId(String clauseName){
        Id clauseId = [SELECT Name FROM Apttus__APTS_Template__c WHERE Name =: clauseName Limit 1].Id;
        
        return clauseId;
    }
    
}