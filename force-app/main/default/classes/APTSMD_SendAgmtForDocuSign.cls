/**
     * Company      : Apttus Inc.
     * Description  : Webservice class for sending Agreement for Docusign/Echosign FROM MAX bot
     * History      :
     * [29.Aug.2018] Devangi Mehta    : Created Class 
     * [16.April.2019] Kaushik Kyada    : Modified Class for Enabling file
     */ 
    
    // @RestResource(urlMapping='/autoSendAgmtForEsignature')
    @RestResource(urlMapping='/agreement/docusign')
    
    global class APTSMD_SendAgmtForDocuSign {
        
        /**
       * Calls the Docusign/Echosign apis based on User input
       * @param agmtId is the agreement ID
       * @param provider is the User's choice for Docusign/Echosign
       * @param contactId ,userId and email are the recipient types
       * @return Boolean value of success/failure
       */ 
        @HttpPost
        webservice static Boolean executeTriggerLogic(String agmtId){
            if(agmtId != Null){
                 agmtId = String.escapeSingleQuotes(agmtId);
                 Map<Id,Id> mapOfAgmtIdVsContentDocId = new Map<Id,Id>();
                 Map<Id,ContentDocumentLink> mapOfAgmtIdVsCDL = new Map<Id,ContentDocumentLink>();
                 Attachment tempAtt;

                 //Getting agreement                    
                 Apttus__APTS_Agreement__c newAgreement = [SELECT Id, Name, Apttus__Primary_Contact__c FROM Apttus__APTS_Agreement__c WHERE Id =: agmtId];
               
                    //Checking Enable file setting   
                    Apttus__ComplySystemProperties__c a = [SELECT Name,Apttus__EnableFile__c FROM Apttus__ComplySystemProperties__c WHERE Name='System Properties'];
                    String AttachemntorFileId = '';             
                    if(a.Apttus__EnableFile__c){
                        List<ContentDocumentLink> generatedFiles = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: newAgreement.Id  and LinkedEntity.Type='Apttus__APTS_Agreement__c' and (not ContentDocument.Title Like '%signed%')];
                        if(!generatedFiles.isEmpty()){
                            AttachemntorFileId = String.valueOf(generatedFiles[0].ContentDocumentId).substring(0, 15);
                        }else{
                            return false;
                        }
                    }else{
                        List<Attachment> generatedAttachments = [SELECT id, name, ParentId, Parent.name, body, ContentType FROM Attachment WHERE ParentId =: newAgreement.Id ORDER BY CreatedDate Desc ];   
                        if(!generatedAttachments.isEmpty()){
                            AttachemntorFileId = String.valueOf(generatedAttachments[0].id).substring(0, 15);
                        }else{
                            return false;
                        }
                    }
                    
                    if(AttachemntorFileId==''){
                          return false;
                    }else{
                         try {   
                           String agreementId = String.valueOf(newAgreement.Id).substring(0, 15);
                           String result = Apttus_CMDSign.CMDocuSignSendForESignatureAPI.submitDocuSignBatchCreateEnvelopeJob(agreementId,new List<Id>{AttachemntorFileId});    
                           System.debug('Docusign result:'+result);  
                           Apttus__APTS_Agreement__c existingAgreement = new Apttus__APTS_Agreement__c (id=agreementId);
                           String status = 'Other Party Signatures';
                           Map<String,Schema.SObjectField> m = Schema.SObjectType.Apttus__APTS_Agreement__c.fields.getMap();
                           if (m.get('Apttus__Status__c').getDescribe().isUpdateable()) {
                               existingAgreement.Apttus__Status__c = status; 
                           }           
                           if(Apttus__APTS_Agreement__c.SObjectType.getDescribe().isUpdateable()) {
                               update existingAgreement;
                           } 
                           else {
                               throw new IllegalArgumentException('Cannot update echo sign object. Insufficient privileges');
                           }
                           return true;
                        } catch (Exception e) {
                           System.debug('Exception - ' + e );
                        }
                    }    
            }
            return false;
        }
    }