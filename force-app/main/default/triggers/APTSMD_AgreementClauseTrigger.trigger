trigger APTSMD_AgreementClauseTrigger on Apttus__Agreement_Clause__c (before update, before insert, after insert) {
    try{
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                // MDO Note: Below Logic is used to create Obligation record from Master Obligation Record.
                List<APTSMD_Master_Obligation__c> masterObligationList = new List<APTSMD_Master_Obligation__c>();
                list<APTSMD_Apttus_PreSales_Config_Settings2__c> presaleConfigList = [SELECT id,APTSMD_Agreement_Clause_Actions__c FROM APTSMD_Apttus_PreSales_Config_Settings2__c WHERE Name='System Properties'];
                //Map<id,id> clauseIdTpTemplateIdMap = new Map<id,id>();
                List<String> clauseName = new List<String>();
                List<Apttus__Obligation__c> obligationListToInsert = new List<Apttus__Obligation__c>(); 
                List<Task> taskListToInsert = new List<Task>();
                
                for(Apttus__Agreement_Clause__c eachAgreementClause : trigger.new){
                    //clauseIdTpTemplateIdMap.put(eachAgreementClause.Id,eachAgreementClause.Apttus__Template__c);
                    clauseName.add(eachAgreementClause.Apttus__Clause__c);
                }
                
                if(clauseName.size()>0){
                    masterObligationList = [SELECT Id,
                                            APTSMD_Obligation_Extract__c,
                                            APTSMD_Obligation_Topic_Description__c,
                                            APTSMD_Obligation_Type__c,
                                            APTSMD_Agreement_RecordType__c,
                                            APTSMD_Active__c,
                                            APTSMD_Template__c
                                            FROM APTSMD_Master_Obligation__c
                                            WHERE APTSMD_Active__c =: True AND APTSMD_Clause_Name__c in :clauseName];
                }
                
                if(masterObligationList.size()>0){
                    for(Apttus__Agreement_Clause__c eachAgreementClause : trigger.new){
                        if(presaleConfigList[0].APTSMD_Agreement_Clause_Actions__c.contains(eachAgreementClause.Apttus__Action__c)){
                            
                            integer i = 0;
                            for(APTSMD_Master_Obligation__c eachMo : masterObligationList){
                                if(eachAgreementClause.APTSMD_Agreement_Record_Type_Name__c==eachMo.APTSMD_Agreement_RecordType__c && eachMo.APTSMD_Template__c == eachAgreementClause.Apttus__Template__c){ //thisAgreement.RecordType.Name
                                    Apttus__Obligation__c thisObligation = new Apttus__Obligation__c();
                                    thisObligation.APTSMD_Agreement__c = eachAgreementClause.Apttus__Agreement__c;
                                    thisObligation.APTSMD_Agreement_Clause__c = eachAgreementClause.Id;
                                    thisObligation.APTSMD_Master_Obligation__c = eachMo.Id;
                                    thisObligation.APTSMD_Template__c = eachAgreementClause.Apttus__Template__c;
                                    thisObligation.APTSMD_Obligation_Extract__c = eachMo.APTSMD_Obligation_Extract__c;
                                    thisObligation.APTSMD_Obligation_Topic_Description__c = eachMo.APTSMD_Obligation_Topic_Description__c;
                                    thisObligation.APTSMD_Obligation_Type__c = eachMo.APTSMD_Obligation_Type__c; 
                                    thisObligation.Apttus__StartDate__c = Date.today();
                                    thisObligation.Apttus__EndDate__c = Date.today() + 364;
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
                                    thisObligation.APTSMD_Active__c = true;
                                    thisObligation.APTSMD_Recurrence__c = 'One-Time';
                                    
                                    obligationListToInsert.add(thisObligation);
                                    i++;
                                }
                            }
                        }
                    }
                    if(obligationListToInsert.size()>0){
                        insert obligationListToInsert;
                        if(obligationListToInsert.size()>0){
                            for(Apttus__Obligation__c eachObligation : obligationListToInsert){
                                Task thisTask = new Task();
                                thisTask.WhatId = eachObligation.Id;
                                thisTask.Subject = 'Weekly Checkpoint';
                                thisTask.priority = 'Normal';
                                thisTask.status = 'Not Started';
                                thisTask.description = 'New  Work';
                                thisTask.IsRecurrence = false;
                                //thisTask.RecurrenceInterval = 7;
                                //thisTask.RecurrenceStartDateOnly = System.today();
                                //thisTask.RecurrenceEndDateOnly = System.today()+30;
                                //thisTask.RecurrenceType = 'RecursDaily';
                                taskListToInsert.add(thisTask);
                            }
                        }
                        if(taskListToInsert.size()>0){
                            insert taskListToInsert;
                        }
                    }
                }
            }        
        }else if(Trigger.isBefore){
            if(Trigger.isUpdate || Trigger.isInsert){
                // MDO Note: This logic is used to update agreement clause fields like Clause from library, Original text, etc. to use it in Compare Clause feature from the conga grid.
                if(Trigger.isInsert){
                    List<String> lstAgrClausesName = new List<String>();
                    for(Apttus__Agreement_Clause__c cls: Trigger.new){
                        // MDO Note: Added by Japan Bhavsar on 9/12/2023. This logic is used to copy Previous Text of clause to Orginal Text field of Agreement Clause.
                        cls.APTSMD_Original_Text__c = cls.Apttus__PrevText__c;
                        //If(String.isBlank(cls.Apttus__Template__c)){
                            lstAgrClausesName.add(cls.Apttus__Clause__c);
                        //}
                    }
                    if(lstAgrClausesName.size()>0){
                        Map<String,Apttus__APTS_Template__c> templateClause= new Map<String,Apttus__APTS_Template__c>();
                        for(Apttus__APTS_Template__c temp: [SELECT Name,Id,Apttus__TextContent__c FROM Apttus__APTS_Template__c  WHERE Apttus__IsActive__c=: true AND Name In: lstAgrClausesName]){
                            templateClause.put(temp.Name.toUpperCase(), temp);
                        }
                        if(templateClause.size()>0){
                            for(Apttus__Agreement_Clause__c cls: Trigger.new){
                                //If(String.isBlank(cls.Apttus__Template__c) && templateClause.get(cls.Apttus__Clause__c.toUpperCase())!=NULL){
                                If(templateClause.get(cls.Apttus__Clause__c.toUpperCase())!=NULL){
                                    try{
                                        cls.Apttus__Template__c= templateClause.get(cls.Apttus__Clause__c.toUpperCase()).Id;
                                        cls.APTSMD_Original_Text__c = templateClause.get(cls.Apttus__Clause__c.toUpperCase()).Apttus__TextContent__c;
                                    }catch(Exception e){
                                        System.debug('###Error:'+e.getMessage());
                                    }
                                }
                                /*if(cls.APTSMD_Agreement_Record_Type_Name__c == '3rd Party Agreements' && !cls.APTSMD_Third_Party_Clause__c){
                                    cls.APTSMD_Third_Party_Clause__c = true;
                                }*/
                            }
                        }
                    }
                    
                }else if(Trigger.isUpdate){
                    Map<Id,Id> mapClsTemp = new Map<Id,Id>();
                    Map<Id,Apttus__Agreement_Clause__c> mapAgrCls = new Map<Id,Apttus__Agreement_Clause__c>();
                    for(Apttus__Agreement_Clause__c cls: Trigger.new){
                        Apttus__Agreement_Clause__c oldCls = Trigger.oldMap.get(cls.id);
                        if(String.valueOf(cls.Apttus__Template__c) != '' && String.valueOf(cls.Apttus__Template__c)!=String.valueOf(oldCls.Apttus__Template__c) && String.valueOf(cls.Apttus__Template__c) != NULL){
                            mapClsTemp.put(cls.Apttus__Template__c, cls.id);
                            mapAgrCls.put(cls.id, cls);
                        }
                    }
                    if(mapClsTemp.size()>0 && mapAgrCls.size()>0)
                    {
                        Map<id,Apttus__APTS_Template__c> templateClause= new Map<id,Apttus__APTS_Template__c>([SELECT Id,Apttus__TextContent__c from Apttus__APTS_Template__c where id In: mapClsTemp.keyset()]);
                        for(ID tempId : mapClsTemp.keyset()){
                            Apttus__Agreement_Clause__c cls = mapAgrCls.get(mapClsTemp.get(tempId));
                            Apttus__APTS_Template__c temp =  templateClause.get(tempId);
                            if(temp.Apttus__TextContent__c!=''){
                                cls.APTSMD_Original_Text__c = temp.Apttus__TextContent__c;
                            }
                        }
                    }
                }
            }
        }
    }catch(Exception ex){
        APTSMD_EmailHelper.sendExceptionEmail(ex);
    }
}