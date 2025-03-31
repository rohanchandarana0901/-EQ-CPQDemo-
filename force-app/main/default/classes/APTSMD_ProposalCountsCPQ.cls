public class APTSMD_ProposalCountsCPQ {
@AuraEnabled
    public static Integer getActionRequiredCount(){
        /*DATE d1 = date.today();
        Date d2 = d1.addMonths(-2);
        Integer d3 = d2.daysBetween(d1);*/
        List<Apttus_Proposal__Proposal__c> proposalList =  [SELECT id
                       FROM Apttus_Proposal__Proposal__c
                       WHERE ownerid =: userinfo.getUserId()
                       AND Apttus_Proposal__Approval_Stage__c = 'Presented'];
                       //AND Apttus_Proposal__Presented_Date__c >= :d2 AND   CreatedDate <=:d1];
    	return proposalList.size();
    }
    @AuraEnabled
    public static Integer getNeedsAttentionCount(){
        List<Apttus_Proposal__Proposal__c> proposalList =  [SELECT id
                       FROM Apttus_Proposal__Proposal__c
                       WHERE Apttus_QPApprov__Approval_Status__c ='Pending Approval'];
    	return proposalList.size();
    }
    @AuraEnabled
    public static String getListViewDetail(String objectName,String viewName){
        return APTSMD_ListViewIdGeneric.getListViewDetail(objectName,viewName);
    }
}