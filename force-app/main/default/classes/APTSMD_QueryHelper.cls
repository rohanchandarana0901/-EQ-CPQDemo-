/*
    Apttus EchoSign Integration for Quote/Proposal
    QueryHelper - Provide various database query methods
     
    @2012 Apttus Inc. All rights reserved.
*/
public without sharing class APTSMD_QueryHelper {    
    
    /**
    * Gets all child attachments associated with the given parent identifier
    * @param parentId parent identifier
    * @return list of attachments
    */
    public static List<Attachment> getChildAttachments(ID parentId) { 
        return [SELECT Id, Name
                , ContentType
                , BodyLength
                , CreatedById
                , LastModifiedById
                , CreatedDate            
                , LastModifiedDate
                , OwnerId
                , ParentId
                FROM Attachment WHERE parentId = :parentId
                    ORDER by CreatedDate DESC];
    }

    /**
    * Clone given list of attachment and associate with provided parent
    * @param attachments list of existing attachments
    * @param parentId new parent identifier
    */
    public static List<Attachment> cloneAttachments(List<Attachment> attachments, ID parentId) {
        List<Attachment> insertList = new List<Attachment>();
        for (Attachment attachment : attachments) {
            Attachment aptsAttachBody = [SELECT Id, Body FROM Attachment WHERE Id = :attachment.Id];
            Attachment esAttachment = new Attachment(Name = attachment.Name
                , ContentType = attachment.ContentType
                , Body = aptsAttachBody.Body
                , ParentId = parentId);
            insertList.add(esAttachment);
        }   
        insert insertList;
        return insertList;
    }
    
    /**
    * Get attachments with the given comma seperated attachment ids (DESC) ordered by created date
    * @param ids list of existing attachment identifiers
    * @return list of attachments ordered by created date descending
    */  
    public static List<Attachment> getAttachments(String ids) { 
        return [SELECT Id, Name
                , ContentType
                , BodyLength
                , CreatedById
                , LastModifiedById
                , CreatedDate              
                , LastModifiedDate
                , OwnerId
                , ParentId
                FROM Attachment WHERE Id IN :ids.split(',') ORDER BY CreatedDate DESC];
    }
}