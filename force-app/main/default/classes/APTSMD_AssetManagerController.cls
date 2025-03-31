/// APTSMD_AssetManageController - Handling of Asset Manager Page
public with sharing class APTSMD_AssetManagerController {
  
  // field names
  String recordId;
  private Account acct;
  private static APTSMD_Apttus_PreSales_Config_Settings2__c presaleConfigSetting;
  
  /**
   * Class Constructor specifying initial values
   * @param stdController the standard controller
   */
    public APTSMD_AssetManagerController(ApexPages.StandardController stdController) {
        recordId = stdController.getRecord().id;
        if(recordId == null){
            recordId = ApexPages.CurrentPage().getparameters().get('id');
        }
        if(PresaleConfigSetting == null){
            //presaleConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getValues('System Properties');
            presaleConfigSetting = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        }
    }
    
    public PageReference init() {            
        Opportunity opp = new Opportunity();
        string priceListId;
        acct = [SELECT name,APTSMD_PriceListId__c,id  FROM Account WHERE id =: recordId Limit 1];
        opp.name = acct.name +' Asset Opportunity';
        if(acct.APTSMD_PriceListId__c != null){
            priceListId = acct.APTSMD_PriceListId__c;
        }
        else{
            Apttus_Config2__PriceList__c priceList = [Select id from Apttus_Config2__PriceList__c  where name = :presaleConfigSetting.APTSMD_Default_Pricelist__c limit 1];
            priceListId = priceList.id;
        }
        
        opp.APTSMD_Price_List__c = priceListId;
        opp.accountId = recordId;
        opp.CloseDate = System.today()+365;
        opp.StageName = 'Prospecting';
        insert opp;

        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal.Apttus_Proposal__Proposal_Name__c =acct.name + ' Asset Quote';
        
        proposal.Apttus_QPConfig__PriceListId__c = priceListId;
        proposal.Apttus_Proposal__Account__c = recordId;
        proposal.Apttus_Proposal__Opportunity__c = opp.id;
        insert proposal;
        
        String flow = null;
        
        if(presaleConfigSetting.APTSMD_Flow__c == Null){
            flow= 'Default';
        }else{
            flow= presaleConfigSetting.APTSMD_Flow__c;
        }
        
        PageReference pageRef = new PageReference('/apex/Apttus_Config2__Cart');          
        pageRef.setRedirect(true);           
        pageRef.getParameters().put('businessObjectId', proposal.Id);
        pageRef.getParameters().put('flow', flow );        
        pageRef.getParameters().put('launchState', 'assetsgrid');
        pageRef.getParameters().put('useAdvancedApproval', 'true');
        pageRef.getParameters().put('useDealOptimizer', 'true');
        pageRef.getParameters().put('method', 'csrFlow');          
        return pageRef;
    }
}