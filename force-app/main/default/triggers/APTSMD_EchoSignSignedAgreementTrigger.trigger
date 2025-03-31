/*
    Apttus EchoSign Integration for Quote/Proposal
    EchoSignSignedAgreementTrigger
     
    @2012 Apttus Inc. All rights reserved.
*/ 
trigger APTSMD_EchoSignSignedAgreementTrigger on echosign_dev1__SIGN_Agreement__c (after update) {
    //Jigar Naik-9/19/2019-Refactored the code and removed the redundant code
    // EchoSign inserts multiple records for their use...
    // we just need to process one of them
    Boolean inserted = false;
    for (Integer i=0;i<Trigger.new.size();i++){   
        if(!inserted 
                && Trigger.new[i].echosign_dev1__Status__c == 'Signed'
                && Trigger.new[i].Apttus_Proposal__c != null) {
            String name = Trigger.new[i].Name;
            system.debug('###esAgmtId:' + Trigger.new[i].Id);
            
            // fetch newly created signed doc
            List<Attachment> esAttachment = [SELECT id, Name
                                                , OwnerId
                                                , ContentType
                                                , Body
                                            FROM Attachment
                                            WHERE ParentId = :Trigger.new[i].Id
                                            And Name like '%signed%'
                                            ORDER BY CreatedDate DESC LIMIT 1];
            
            List<Attachment> proposalAttachments = [SELECT id, Name
                                                , OwnerId
                                                , ContentType
                                                , Body
                                            FROM Attachment
                                            WHERE ParentId = :Trigger.new[i].Apttus_Proposal__c
                                            And Name like '%signed%'
                                            ORDER BY CreatedDate DESC LIMIT 1];
            
            if(proposalAttachments.isEmpty() && !esAttachment.isEmpty()){
            system.debug('###esAttachment:' + esAttachment[0]);
            
                //Add signed docs to apttus proposal
                String parentId = Trigger.new[i].Apttus_Proposal__c;
                Attachment aptsAttachment = new Attachment(
                ParentId =parentId 
                , Name = esAttachment[0].Name
                , Body = esAttachment[0].Body
                , OwnerId = esAttachment[0].OwnerId
                , ContentType = esAttachment[0].ContentType);
                insert aptsAttachment;
            }
            
            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Id = Trigger.new[i].Apttus_Proposal__c, Apttus_Proposal__Approval_Stage__c = 'Presented');
            update proposal;
        }
    }
}