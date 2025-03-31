trigger APTSMD_CreateFileFromAttachment on Attachment (after insert) {
    
    schema.sObjectType sObjType = Schema.getGlobalDescribe().get('Apttus_Proposal__Proposal__c');
    String keyPrefix = sObjType.getDescribe().getKeyPrefix();
        
    for(Attachment attach : Trigger.new){
        String parentIdStr = String.ValueOf(attach.ParentId);
        if(parentIdStr.startsWith(keyPrefix)){
        
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
            Insert cVersion;
            
            FeedItem elm = new FeedItem(Body = 'Proposal Generated', ParentId = attach.ParentId, RelatedRecordId = cVersion.Id, Type = 'ContentPost', Visibility = 'AllUsers');
            insert elm;
        }
    }
}