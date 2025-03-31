// In a separate class so that it can be used elsewhere
global class APTSMD_EmailHelper{
    public static void sendEmail(ID agreementId,ID attachmentID) {
        //Initialized here to avoid null pointer exception
        List<Attachment> noOfAttachment = new List<Attachment>();
        List<contentVersion> contentVerionList = new List<contentVersion>();
        
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT id,
                                                         ownerId,
                                                         Apttus__Primary_Contact__c,
                                                         Apttus__Primary_Contact__r.email,
                                                         Apttus__Primary_Contact__r.name,
                                                         Apttus__Status_Category__c,
                                                         Apttus__Status__c
                                                         FROM Apttus__APTS_Agreement__c 
                                                         WHERE id=:agreementId];
        
        //Query Comply system properties for checking the Enable Files flag
        Apttus__ComplySystemProperties__c ComplySystemProperty = Apttus__ComplySystemProperties__c.getValues('System Properties');
        //If true then use contentVersion object to get the generated document(Type will be file)
        if(ComplySystemProperty.Apttus__EnableFile__c){
            contentVerionList = [SELECT Id,VersionData,Title,IsLatest,ContentDocumentId
                                 FROM contentVersion
                                 WHERE ContentDocumentId =: attachmentID];
        }else{
            noOfAttachment=[select id,name,body from Attachment where Id=:attachmentID];
        }
        
        //New instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Who you are sending the email to
        if(!agreementList.isEmpty()){
            mail.setTargetObjectId(agreementList[0].Apttus__Primary_Contact__c);
        }
        
        // The email template ID used for the email
        Apttus__APTS_Admin__c adminEntry = [SELECT Apttus__Value__c,Apttus__Code__c FROM Apttus__APTS_Admin__c WHERE Name = 'APTS_EmailTemplateForReview'];
        EmailTemplate emailtemplate;
        if(adminEntry != Null){
            emailtemplate = [select id, name from EmailTemplate where name =: adminEntry.Apttus__Value__c];
        }else{
            emailtemplate = [select id, name from EmailTemplate where developername = 'Agreement_Review_Notification'];
        }
        mail.setTemplateId(emailtemplate.Id);
        
        mail.setWhatId(agreementList[0].Id);    
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setReplyTo('apttusdemo@apttus.com');
        mail.setSenderDisplayName(userinfo.getName());
        mail.setSaveAsActivity(false);  
        
        if(!contentVerionList.isEmpty()){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(contentVerionList[0].VersionData);
            attachment.setFileName(contentVerionList[0].Title);
            attachment.setinline(false);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        }else if(!noOfAttachment.isEmpty()){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(noOfAttachment[0].body);
            attachment.setFileName(noOfAttachment[0].name);
            attachment.setinline(false);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        }
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        List<Task> taskToInsert = new List<Task>();
        
        Task emailTask =new Task();
        emailTask.subject = agreementList[0].Apttus__Primary_Contact__r.name +' Please Review the Following Contract';
        emailTask.WhoId = agreementList[0].Apttus__Primary_Contact__c;
        emailTask.ActivityDate = Date.today();
        emailTask.Status = 'Completed';
        emailTask.Priority = 'Normal';
        emailTask.WhatId = agreementList[0].id;
        taskToInsert.add(emailTask);
        
        Task sentReview=new Task();
        sentReview.subject = 'Sent For Review';
        sentReview.ActivityDate = Date.today();
        sentReview.Status = 'Completed';
        sentReview.Priority = 'Normal';
        sentReview.WhatId = agreementList[0].id;
        taskToInsert.add(sentReview);
        
        insert taskToInsert;
        
        agreementList[0].Apttus__Status_Category__c = 'In Authoring';
        agreementList[0].Apttus__Status__c = 'Other Party Review';
        update agreementList; 
        
    }  
    
    public static void sendExceptionEmail(Exception e) {
        try{
            List<ApexEmailNotification> apexEmailNotificationRecord = new List<ApexEmailNotification>();
            apexEmailNotificationRecord = [SELECT Email, UserId FROM ApexEmailNotification LIMIT 1];
            
            if(!apexEmailNotificationRecord.isEmpty()){
                // Get the current user's email address
                String emailAddress = UserInfo.getUserId();
                
                // Create a new email message
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setSubject('Exception Occurred');
                message.setTargetObjectId(emailAddress);
                message.setPlainTextBody(e.getMessage());
                message.setSaveAsActivity(false);
                
                // Add the exception stack trace to the email body
                String stackTrace = e.getStackTraceString();
                message.setPlainTextBody(message.getPlainTextBody() + '\n\n' + stackTrace);
                
                // Send the email
                Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[] { message };
                Messaging.sendEmail(emails);
            }
        }catch(Exception ex){
            throw e;
        }
        
    }
}