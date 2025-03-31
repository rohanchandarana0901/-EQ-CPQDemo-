/**
 * Company      : Apttus Inc.
 * Description  : Triggers checks whether the agreement record satisfies any approval process criteria through API call. If yes, then sets
                  Approval Required as value in the Status field of the record.
 * History      :
 * [24.Jan.2019]: Devangi Mehta Created Trigger 
 */ 
trigger APTSMD_checkForApprovals on Apttus__APTS_Agreement__c (after Insert,before Update,after update) {
    Set<Id> agmtIdSet = new Set<Id>();
    if((Trigger.isInsert && Trigger.isAfter) || (Trigger.isAfter && Trigger.isUpdate)){
        for(Apttus__APTS_Agreement__c agmtRec: Trigger.New){
            if(!agmtRec.APTSMD_Is_Included_in_Report__c){
                agmtIdSet.add(agmtRec.Id);
            }
        }
    }
    
    //Update Agreement record's status field in case of approval check condition fulfillment
    if(!agmtIdSet.isEmpty()){
        List<Apttus__APTS_Agreement__c> insertedAgmtList = [SELECT Id,
                                                           Apttus__Status__c,
                                                           Apttus_Approval__Approval_Status__c
                                                    FROM Apttus__APTS_Agreement__c
                                                    WHERE Id IN: agmtIdSet];
                                                            
        List<Apttus__APTS_Agreement__c> agmtListToUpdate = new List<Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agmtRecToUpdate : insertedAgmtList){
            if(agmtRecToUpdate.Apttus_Approval__Approval_Status__c == 'Not Submitted' && agmtRecToUpdate.Apttus__Status__c != 'Approval Required'){
                //API to check whether approval is required or not
                Boolean isApprovalReq = Apttus_Approval.ApprovalsWebService.isApprovalRequired('Apttus__APTS_Agreement__c',agmtRecToUpdate.Id);
                //Update status if API returns true value
                if(isApprovalReq){
                    agmtRecToUpdate.Apttus__Status__c = 'Approval Required';
                    agmtListToUpdate.add(agmtRecToUpdate);
                }
            }
        }
        
        if(!agmtListToUpdate.isEmpty()){
            Update agmtListToUpdate;
        }
    }
}