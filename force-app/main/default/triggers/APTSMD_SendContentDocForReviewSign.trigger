/**
 * Company      : Apttus Inc.
 * Description  : Trigger is used to send the Agreement record for Review or E-signature based on the selection made by the 
                  user in the Mass Amendment Screen if the Attachment type is FILE(Enable Files Checkbox is true in Comply system properties).
*/
trigger APTSMD_SendContentDocForReviewSign on ContentDocumentLink (After insert) {
    String DVDPrefix = Apttus__DocumentVersionDetail__c.sobjecttype.getDescribe().getKeyPrefix();
    String agrPrefix = Apttus__APTS_Agreement__c.sobjecttype.getDescribe().getKeyPrefix();
    //Map of Agreement Id versus the contentdocument Id
    Map<Id,Id> mapOfAgmtIdVsContentDocId = new Map<Id,Id>();
    Map<Id,ContentDocumentLink> mapOfAgmtIdVsCDL = new Map<Id,ContentDocumentLink>();
    Map<Id,Apttus__DocumentVersionDetail__c> mapOfDVDIdVsDVD = new Map<Id,Apttus__DocumentVersionDetail__c>();
    Set<Id> AllDVDLinkedEntityId = new Set<Id>();
   
    private APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting;
    
    for(ContentDocumentLink contentDocLink : Trigger.new){
        if(string.valueOf(contentDocLink.LinkedEntityId).indexOf(DVDPrefix) == 0){
            AllDVDLinkedEntityId.add(contentDocLink.LinkedEntityId);
        }
    }
    
    if(!AllDVDLinkedEntityId.isEmpty()){
        mapOfDVDIdVsDVD = new Map<Id,Apttus__DocumentVersionDetail__c>([SELECT Id, APTSMD_Agreement_Id__c FROM Apttus__DocumentVersionDetail__c WHERE Id = :AllDVDLinkedEntityId]);
    }
    
    for(ContentDocumentLink contentDocLink : Trigger.new) {
        if(string.valueOf(contentDocLink.LinkedEntityId).indexOf(agrPrefix) == 0) {
            mapOfAgmtIdVsContentDocId.put(contentDocLink.LinkedEntityId,contentDocLink.ContentDocumentId);
            mapOfAgmtIdVsCDL.put(contentDocLink.LinkedEntityId,contentDocLink);
        }else if(string.valueOf(contentDocLink.LinkedEntityId).indexOf(DVDPrefix) == 0){
            mapOfAgmtIdVsContentDocId.put(mapOfDVDIdVsDVD.get(contentDocLink.LinkedEntityId).APTSMD_Agreement_Id__c,contentDocLink.ContentDocumentId);
            mapOfAgmtIdVsCDL.put(mapOfDVDIdVsDVD.get(contentDocLink.LinkedEntityId).APTSMD_Agreement_Id__c,contentDocLink);
        }
    }
    
    if(!mapOfAgmtIdVsContentDocId.isEmpty()){
        
        // Fetch List of Content Doc List
        List<ContentDocument> contentDocList = [SELECT Id,LatestPublishedVersionId from ContentDocument where Id IN : mapOfAgmtIdVsContentDocId.values()];
        Map<Id,Id> MapOfCDVsCV = new Map<Id,Id>();
        for(ContentDocument cd: contentDocList){
            MapOfCDVsCV.put(cd.Id, cd.LatestPublishedVersionId);
        }
        
        // Fetch List of Content Version List
        List<ContentVersion> contentVerList = [SELECT Id, VersionData, ContentDocumentId, FileType, FileExtension, Title FROM ContentVersion WHERE Id IN : MapOfCDVsCV.values() 
            AND (NOT Title LIKE '%Signed%') AND (NOT Title LIKE '%signed%')];
        Map<Id, ContentVersion> MapOfCDIdvsCV = new Map<Id, ContentVersion>();
        for(ContentVersion cv : contentVerList){
            MapOfCDIdvsCV.put(cv.ContentDocumentId, cv);
        }
        
        // Query Agreements using the Map Values
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id,Name,Apttus__Primary_Contact__c, Apttus__Account__c,Apttus__Related_Opportunity__c,
                APTSMD_Sign_or_Review__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE id IN:mapOfAgmtIdVsContentDocId.keyset()];
        // Fetch Presales Properties Values
        presalesSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        for(Apttus__APTS_Agreement__c agmtRec : agreementList){
            //Send for esignature
            if(agmtRec.APTSMD_Sign_or_Review__c == 'Review'){
                APTSMD_EmailHelper.sendEmail(agmtRec.Id,mapOfAgmtIdVsContentDocId.get(agmtRec.Id));  
            }else if(agmtRec.APTSMD_Sign_or_Review__c == 'Sign' && agmtRec.Apttus__Status__c == 'Ready for Signatures'){
                try{
                    if(presalesSetting.APTSMD_Esignature_Type__c=='Docusign'){
                        APTSMD_SendToDocuSignHandler.sendToDocuSign(agmtRec.Id,mapOfAgmtIdVsContentDocId.get(agmtRec.Id));
                    }else{
                        // Create a new attachment
                        Attachment tempAtt = new Attachment(
                            Name = agmtRec.Name + '.' + MapOfCDIdvsCV.get(mapOfAgmtIdVsContentDocId.get(agmtRec.Id)).FileExtension,
                            Body = MapOfCDIdvsCV.get(mapOfAgmtIdVsContentDocId.get(agmtRec.Id)).VersionData,
                            ContentType = APTSMD_SendToEchoSignHandler.getMIMEType(MapOfCDIdvsCV.get(mapOfAgmtIdVsContentDocId.get(agmtRec.Id)).FileExtension)
                        );
                        APTSMD_SendToEchoSignHandler.sendForEchoSignHelper(agmtRec,tempAtt);
                    }
                }
                catch(EmailException emailEx){
                    System.debug('Error while sending email : Limit exceeded');
                }
                catch(LimitException LimitEx){
                    System.debug('Error while sending email : Governer Limit exceeded');
                }
            }
        }
     }
}