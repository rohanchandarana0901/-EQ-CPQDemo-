trigger APTSMD_SendAttachmentForReviewSign on Attachment (After insert) {
    
    /*
    String agrPrefix = Apttus__APTS_Agreement__c.sobjecttype.getDescribe().getKeyPrefix();
    //Map of Agreement Id versus the attachment Id
    Map<Id,Id> mapOfAgmtIdVsAttachmentId = new Map<Id,Id>();
    Map<Id,Attachment> mapOfAgmtIdVsAtt = new Map<Id,Attachment>();
    private APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting;
    
    for(Attachment attachmentNew : Trigger.new) {
        System.debug('string.valueOf(attachmentNew.parentId).indexOf(agrPrefix) -> ' + string.valueOf(attachmentNew.parentId).indexOf(agrPrefix));
        if(string.valueOf(attachmentNew.parentId).indexOf(agrPrefix) == 0 && (!(attachmentNew.Name.toLowerCase()).contains('signed'))) {
            mapOfAgmtIdVsAttachmentId.put(attachmentNew.parentId,attachmentNew.Id);
            mapOfAgmtIdVsAtt.put(attachmentNew.parentId,attachmentNew);
        }
    }
    
    if(!mapOfAgmtIdVsAttachmentId.isEmpty()){
        //Query Agreements using the Map Values
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id,Name,Apttus__Primary_Contact__c,Apttus__Account__c,Apttus__Related_Opportunity__c,
                APTSMD_Sign_or_Review__c FROM Apttus__APTS_Agreement__c WHERE id IN:mapOfAgmtIdVsAttachmentId.keyset()];
        // Fetch Presales Properties Values
        presalesSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        for(Apttus__APTS_Agreement__c agmtRec : agreementList){
            //Send for esignature
            if(agmtRec.APTSMD_Sign_or_Review__c == 'Review'){
                APTSMD_EmailHelper.sendEmail(agmtRec.Id,mapOfAgmtIdVsAttachmentId.get(agmtRec.Id));  
            }else if(agmtRec.APTSMD_Sign_or_Review__c == 'Sign'){
                try{
                    if(presalesSetting.APTSMD_Esignature_Type__c=='Docusign'){
                        APTSMD_SendToDocuSignHandler.sendToDocuSign(agmtRec.Id,mapOfAgmtIdVsAttachmentId.get(agmtRec.Id));
                    }else{
                        APTSMD_SendToEchoSignHandler.sendForEchoSignHelper(agmtRec,mapOfAgmtIdVsAtt.get(agmtRec.Id));
                    }
                }catch(EmailException emailEx){
                    System.debug('Error while sending email : Limit exceeded');
                }
                catch(LimitException LimitEx){
                    System.debug('Error while sending email : Governer Limit exceeded');
                }
            }
        }
    } */
}