public class APTSMD_AgreementStatusController {
    /**
     * returns total price of from Apttus Quotes
     * @param oppId opportunity id of the current record
     */  
    @AuraEnabled
    public static Double getGrandTotal(Id oppId) { 
        System.debug('opportunityId = ' + oppId);
      List<OpportunityLineItem> items = [SELECT Description, 
                                        Id, ListPrice, Name,
                                        OpportunityId, Product2Id, ProductCode, SortOrder, TotalPrice, UnitPrice 
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId =:oppId]; 
        
    Double grandTotal = 0.0;
        for (OpportunityLineItem item : items) {
            grandTotal += item.ListPrice;    
        }
        return grandTotal;
        
    }
    
    /**
     * returns the agreement associated with the opty
     */ 
    @AuraEnabled
    public static Apttus__APTS_Agreement__c getAgreement(Id agreementId) {
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting = [SELECT name,APTSMD_Esignature_Type__c
                                                                          FROM APTSMD_Apttus_PreSales_Config_Settings2__c 
                                                                          WHERE name='System Properties' LIMIT 1];
        List<Apttus__ClauseApproval__c> clauseApprovalsList = [select id 
                                                                from Apttus__ClauseApproval__c 
                                                                where Apttus__AgreementId__c = :agreementId
                                                                And Apttus__ApprovalStatus__c in ('Approval Required','Pending Approval')];
        
        List<Apttus__APTS_Agreement__c> agreements 
            = [SELECT Id, Name,Apttus__Agreement_Number__c/*temporary used as echosign/docusign value store*/,
                     Apttus__FF_Agreement_Number__c, Apttus_Approval__Approval_Status__c,
                      Apttus__Total_Contract_Value__c,                       
                      Apttus__Status_Category__c,
                     Apttus__Status__c,
                    Apttus_CMConfig__PriceListId__c
          FROM Apttus__APTS_Agreement__c 
        WHERE Id =: agreementId               
                LIMIT 1];
        //below snippet was written to overcome false 'in clause approval' status in winter'21 release Date:14 Dec 2021         
        if(agreements[0].Apttus__Status__c == 'In Clause Approval' && clauseApprovalsList.isEmpty()){
            agreements[0].Apttus__Status_Category__c = 'In Signatures';
            agreements[0].Apttus__Status__c = 'Ready for Signatures';
        }
        update agreements;
        
        if(!agreements.isEmpty()) {
            if(agreements[0].Name.contains('Amended')){
                agreements[0].Apttus__IsLocked__c=True;    
            }else{
                agreements[0].Apttus__IsLocked__c=False;
            }
            if(agreements[0].Apttus__Status__c==null){
                agreements[0].Apttus__Status__c='none';    
            }
            if(presalesConfigSetting!=null){
                // if(presalesConfigSetting.APTSMD_EchoSign__c){
                    agreements[0].Apttus__Agreement_Number__c=presalesConfigSetting.APTSMD_Esignature_Type__c;
                // }else if(presalesConfigSetting.APTSMD_DocuSign__c){
                //     agreements[0].Apttus__Company_Signed_Title__c='DocuSign';
                // }
            }
            return agreements[0];
        } else {
            return null;
            
        }
    }
    
    @AuraEnabled
    public static Response sendDocumentForParallelReview(string agreementId){
        try{
            if(agreementId == null || agreementId == ''){
               	return new Response(false, 'Please provide valid agreement record id', null);
            }
            
            // Get Agreement Record
            List<Apttus__APTS_Agreement__c> agreement = new List<Apttus__APTS_Agreement__c>();
            agreement = [SELECT Id, Name, Apttus__Primary_Contact__c, Apttus__Primary_Contact__r.FirstName, 
                         		Apttus__Primary_Contact__r.LastName, Apttus__Primary_Contact__r.Email
                         	FROM Apttus__APTS_Agreement__c
                        	WHERE Id = :agreementId LIMIT 1];
            if(agreement.isEmpty()){
                return new Response(false, 'No agreement record found. Please try again later!', null);
            }
            
            // Get Document Version
            List<Apttus__DocumentVersion__c> docVersion = new List<Apttus__DocumentVersion__c>();
            docVersion = [SELECT Id, Apttus__LatestVersionId__c, Apttus__LatestVersionId__r.Apttus__ContentId__c, Apttus__PendingReviews__c
                         	FROM Apttus__DocumentVersion__c WHERE Apttus__AgreementId__c = :agreementId ORDER BY CreatedDate DESC LIMIT 1];
            
            // Check for latest document version 
            if(docVersion.isEmpty()){
                return new Response(false, 'Document version is found for the given agreement. Please try again later!', null);
            }
            
            // Check for pending reviews
            if(docVersion[0].Apttus__PendingReviews__c > 0){
                return new Response(false, 'It seems like latest document has already been sent for review. Please try again later!', null);
            }
            
            // Send email
            String emailSubject = 'Please review following document for agreement ' + agreement[0].Name;
            String emailBody = 'Hi ' + agreement[0].Apttus__Primary_Contact__r.FirstName + '</br></br>' + 
                				'Please review following document for agreement ' + agreement[0].Name + '.'+
                				'<br/><br/>'+
                				'Thanks,'+
                				'</br>'+
                				'Team Conga';
            List<Apttus.ReviewerWrapper> reviewersList = new List<Apttus.ReviewerWrapper>();
            List<Apttus.ReviewerWrapper.ContentControls> contentControls = null;    
            Apttus.ReviewerWrapper reviewerWrapper = new Apttus.ReviewerWrapper(agreement[0].Apttus__Primary_Contact__c, agreement[0].Apttus__Primary_Contact__r.FirstName + ' ' + agreement[0].Apttus__Primary_Contact__r.LastName, agreement[0].Apttus__Primary_Contact__r.Email, contentControls);
            reviewersList.add(reviewerWrapper);
            Apttus.AuthorWebService.initiateParallelReview(docVersion[0].Apttus__LatestVersionId__r.Apttus__ContentId__c, 
                                                           agreement[0].Id, 
                                                           docVersion[0].Apttus__LatestVersionId__c, 
                                                           emailSubject, 
                                                           emailBody, 
                                                           reviewersList);
            
            return new Response(true, 'Agreement sent for review successfully!', null);
        }catch(Exception ex){
            return new Response(false, 'Exception: ' + ex.getMessage() + ' @ ' + ex.getLineNumber() , null);
        }
    }
    
    @AuraEnabled
    public static APTSMD_Apttus_PreSales_Config_Settings2__c getPresalesConfigSetting(){
        try{
            APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
            return presalesConfigSetting;
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }        
    }
    
    @AuraEnabled
    public static Response sendAgreementToLegalReviewer(string agreementId){
        try {
            if(agreementId == null || agreementId == ''){
                return new Response(false, 'Please pass valid agreement id.', null);
            }
            // Fetch Agreement
            List<Apttus__APTS_Agreement__c> agreements = [SELECT Id, Name,Apttus__Agreement_Number__c,OwnerId,Owner.type,
                                                                Apttus__Primary_Contact__c
                                                                FROM Apttus__APTS_Agreement__c 
                                                                WHERE Id =: agreementId               
                                                            LIMIT 1];
            if(agreements.isEmpty()){
                return new Response(false, 'No valid agreement found! Please try again later.', null);
            }
            // Get Legal Queue data
            Group legalQueue = new Group();
            legalQueue = [SELECT Id, Name FROM Group WHERE Name = 'Legal' AND Type = 'Queue'];
            System.debug('legalQueue >> '+ legalQueue);
            if(legalQueue == null){
                return new Response(false, 'No such queue found name Legal', null);
            }
            // Assign agreement to Legal queue
            Update new Apttus__APTS_Agreement__c(Id = agreementId, OwnerId = legalQueue.Id);
            // Get Queue Memeber Details
            List<String> queueMemberEmailIds = new List<String>();
            List<User> queueMembers = [SELECT Id, Name, Email FROM user
                                        WHERE Id IN 
                                            (SELECT UserOrGroupId FROM GroupMember
                                                WHERE GroupId  =: legalQueue.Id )];
            for(User member : queueMembers){
                queueMemberEmailIds.add(member.Email);
            }
            // Send email to the member
            List<EmailTemplate> listOfReviewEmailTemplate = [SELECT Id, Body FROM EmailTemplate WHERE DeveloperName ='APTSMD_Agreement_Owner_Change_Notification'];
            if(!listOfReviewEmailTemplate.isEmpty() && !queueMemberEmailIds.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(queueMemberEmailIds);
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(agreements[0].Apttus__Primary_Contact__c);
                mail.setTemplateId(listOfReviewEmailTemplate[0].id);
                mail.setWhatId(agreements[0].id);
                mail.setTreatTargetObjectAsRecipient(false);
                System.debug('##sendtoLegal:mail'+mail);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('##sendtoLegal:mail sent');
            }            
            return new Response(true, 'Agreement assigned to the legal queue for review',null);
        } catch (Exception ex) {
            return new Response(false, 'Exception: ' + ex.getMessage() + ' @ ' + ex.getLineNumber() , null);
        }
    }
        
        
    // Helper Classes
    public class Response{
        @AuraEnabled public boolean isSuccess {get;set;}
        @AuraEnabled public string message {get;set;}
        @AuraEnabled public object data {get;set;}
        
        public Response(boolean isSuccess, string message, object data){
            this.isSuccess = isSuccess;
            this.message = message;
            this.data = data;
        }
    }
}