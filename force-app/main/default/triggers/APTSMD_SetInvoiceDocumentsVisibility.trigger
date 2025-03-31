trigger APTSMD_SetInvoiceDocumentsVisibility on ContentDocumentLink (before insert,before update) {
    String invoicePrefix = Apttus_Billing__Invoice__c.sobjecttype.getDescribe().getKeyPrefix();
   
    for(ContentDocumentLink cdl : Trigger.new){
        if(((String)(cdl.LinkedEntityId)).substring(0,3) == invoicePrefix){
            cdl.Visibility = 'AllUsers';
        }   
    }
}