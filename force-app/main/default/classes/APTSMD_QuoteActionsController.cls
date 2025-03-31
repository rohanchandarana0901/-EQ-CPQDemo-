/**
 * Class: APTSMD_QuoteActionsController
 *    Defines aura enabled methods for Apttus Quotes  
 */     
public class APTSMD_QuoteActionsController {
    /**
     * returns total price of from Apttus Quotes
     * @param oppId opportunity id of the current record
     */  

    /**
     * returns the Proposal
     */ 
    @AuraEnabled
    public static Apttus_Proposal__Proposal__c getProposal(Id proposalId) {
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting = [SELECT name,APTSMD_Esignature_Type__c from APTSMD_Apttus_PreSales_Config_Settings2__c where name='System Properties' LIMIT 1];
        List<Apttus_Proposal__Proposal__c> proposals 
            = [SELECT Id, Name, 
                     Apttus_QPConfig__PriceListId__c, 
                      Apttus_Proposal__ReadyToGenerate__c, 
                      Apttus_Proposal__ReadyToPresent__c, 
                      Apttus_Proposal__Approval_Stage__c,
                      Apttus_Proposal__Opportunity__c,
                      Apttus_Proposal__Primary_Contact__c,
                      APTSMD_Flow__c,Apttus_Proposal__Description__c/*temporary used as echosign/docusign value store*/
          FROM Apttus_Proposal__Proposal__c 
        WHERE Id =: proposalId
                LIMIT 1];
        
        if(!proposals.isEmpty()) {
            if(presalesConfigSetting!=null){
                //if(presalesConfigSetting.APTSMD_Esignature_Type__c!='Docusign'){
                    proposals[0].Apttus_Proposal__Description__c=presalesConfigSetting.APTSMD_Esignature_Type__c;
                //}
                // else{
                //     proposals[0].Apttus_Proposal__Description__c='Docusign';
                // }
                // if(presalesConfigSetting.APTSMD_DocuSign__c){
                //     proposals[0].Apttus_Proposal__Special_Terms__c='DocuSign';
                // }
            }
            SYSTEM.DEBUG('proposal :'+proposals[0]);
            return proposals[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static APTSMD_Apttus_PreSales_Config_Settings2__c getPresalesConfigSetting(){
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        return presalesConfigSetting;
    }
    
    @AuraEnabled
    public static String getCurrentUserSessionId(){
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled
    public static Id getCloudServerId() {
        Product2 productSO= [ Select Id from Product2 where Name='Cloud Server Solution'];
        return productSO.Id;
    }
    
    @AuraEnabled
    public static Opportunity getOpportunityRecord(string opptyId){
        if(opptyId != null){
            List<Opportunity> opptyRecord = new List<Opportunity>();
            opptyRecord = [SELECT Id, APTSMD_Price_List__c FROM Opportunity WHERE ID = :opptyId];
            if(!opptyRecord.isEmpty()){
                return opptyRecord[0];
            }
            return null;
        }else{
            return null;
        }
    }
}