trigger APTSMD_AddObligationsOnAgreement on Apttus__APTS_Agreement__c (after insert) {
    List<APTSMD_Master_Obligation__c> masterObligationsList = new List<APTSMD_Master_Obligation__c>();
    set<string> recordtypeNameSet = new set<string>();
    List<Apttus__Obligation__c> obligationListToInsert = new List<Apttus__Obligation__c>(); 
    List<Task> taskListToInsert = new List<Task>();
    
    for(Apttus__APTS_Agreement__c thisAgreement: trigger.new){
        recordtypeNameSet.add(thisAgreement.APTSMD_Record_Type_Name__c);
    }
    
    if(recordtypeNameSet.size()>0){
        masterObligationsList = [SELECT Id, 
                                APTSMD_Obligation_Extract__c,
                                APTSMD_Obligation_Topic_Description__c,
                                APTSMD_Obligation_Type__c,
                                APTSMD_Agreement_RecordType__c,
                                APTSMD_template__c,
                                APTSMD_Active__c
                           FROM APTSMD_Master_Obligation__c where APTSMD_Agreement_RecordType__c IN: recordtypeNameSet AND APTSMD_Active__c =: True];
    
        for(Apttus__APTS_Agreement__c thisAgreement: trigger.new){
            integer i = 0;
            for(APTSMD_Master_Obligation__c eachMo : masterObligationsList){
                if(eachMo.APTSMD_Agreement_RecordType__c != null){
                    if(thisAgreement.APTSMD_Record_Type_Name__c == eachMo.APTSMD_Agreement_RecordType__c && eachMo.APTSMD_template__c == null){
                        Apttus__Obligation__c thisObligation = new Apttus__Obligation__c();
                        
                        thisObligation.APTSMD_Agreement__c = thisAgreement.Id;
                        thisObligation.APTSMD_Master_Obligation__c = eachMo.Id;
                        thisObligation.APTSMD_template__c= eachMo.APTSMD_template__c;
                        thisObligation.APTSMD_Obligation_Extract__c = eachMo.APTSMD_Obligation_Extract__c;
                        thisObligation.APTSMD_Obligation_Topic_Description__c = eachMo.APTSMD_Obligation_Topic_Description__c;
                        thisObligation.APTSMD_Obligation_Type__c = eachMo.APTSMD_Obligation_Type__c; 
                        thisObligation.APTSMD_Active__c = true;
                        thisObligation.APTSMD_Recurrence__c = 'Once a Week';
                        
                        if(thisAgreement.Apttus__Contract_Start_Date__c != NULL && thisAgreement.Apttus__Contract_End_Date__c != NULL){
                            thisObligation.Apttus__StartDate__c = thisAgreement.Apttus__Contract_Start_Date__c;
                            thisObligation.Apttus__EndDate__c = thisAgreement.Apttus__Contract_End_Date__c;
                        
                        }
                        else{
                            thisObligation.Apttus__StartDate__c = Date.today();
                            thisObligation.Apttus__EndDate__c = Date.today() + 364;
                        }
                        if(i==0){
                            thisObligation.APTSMD_Status__c = 'Completed';
                            thisObligation.APTSMD_Date_Completed__c = Date.today() - 1;
                            thisObligation.APTSMD_Due_Date__c = Date.today() + 7;
                        }
                        else if(i==2){
                            thisObligation.APTSMD_Status__c = 'In Progress';
                            thisObligation.APTSMD_Due_Date__c = Date.today() + 3;
                        }
                        else{
                            thisObligation.APTSMD_Status__c = 'Not Started';
                            thisObligation.APTSMD_Due_Date__c = Date.today() + 7;
                        }
                            
                        obligationListToInsert.add(thisObligation);
                        i++;
                    }
                }
            }
        }
        
        if(obligationListToInsert.size()>0){
            insert obligationListToInsert;
        
            for(Apttus__Obligation__c eachObligation : obligationListToInsert){
                Task thisTask = new Task();
                thisTask.WhatId = eachObligation.Id;
                thisTask.Subject = 'Weekly Checkpoint';
                thisTask.priority = 'Normal';
                thisTask.status = 'Not Started';
                thisTask.description = 'New  Work';
                thisTask.IsRecurrence = false;
                //thisTask.RecurrenceInterval = 7;
                //thisTask.RecurrenceStartDateOnly = System.today()+7;
                //thisTask.RecurrenceEndDateOnly = System.today()+17;
                //thisTask.RecurrenceType = 'RecursDaily';
                taskListToInsert.add(thisTask);    
            }
            if(taskListToInsert.size()>0){
                insert taskListToInsert;
            }
        }
        
    }
    
}