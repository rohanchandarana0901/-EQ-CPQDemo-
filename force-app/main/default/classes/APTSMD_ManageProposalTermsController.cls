/*
@Name: APTSMD_ManageProposalTermsController
@Author: Tirth Mathuria
@CreateDate: 17-Aug-2015
@Description: New Apex Class for Manage Proposal Terms functionality
@UsedBy: Product Configuration
******************************************************************
*/ 
public class APTSMD_ManageProposalTermsController{

  
    public Apttus_Config2__ProductConfiguration__c configSO;
    public String configRequestId{get;set;}
    public Apttus_Config2__ProductConfiguration__c config {get; set;}
    public List<Apttus__Term_Exception__c> teListData {get;set;}
    public String teListJson {get;set;}
    public String nonTEListJson {get;set;}
    public String savedTeIDsJson {get;set;}
    public List<Apttus_Config2__LineItem__c> lineItems;
    public List<Apttus_DealMgr__DealTerm__c> dealTermList;
    public String previousURL {get; set;}
    public transient Component.Apex.StyleSheet customCSSStyle{get;set;}
    
     public APTSMD_ManageProposalTermsController(ApexPages.StandardController stdController){

        previousURL = '/apex/Apttus_Config2__Cart?flow=' + ApexPages.currentPage().getParameters().get('flow');
        previousURL += '&cartStatus=New';
        previousURL += '&id=' + ApexPages.currentPage().getParameters().get('id');
        previousURL += '&configRequestId=' + ApexPages.currentPage().getParameters().get('configRequestId');
        
        List<Apttus__Term_Exception__c> teList = [select id, Apttus__Exception__c,Apttus__Exception_Type__c,Apttus__Description__c,Apttus__Active__c,APTSMD_Pre_Approved_Language__c,Apttus__Approval_Required__c
                                            from Apttus__Term_Exception__c where Apttus__Active__c=true and APTSMD_Pre_Approved_Language__c=true order by Apttus__Exception_Type__c];
                                            
         lineItems = new List<Apttus_Config2__LineItem__c>();
         
        if(!teList.isEmpty()){
            teListJson = JSON.serialize(teList);
        }

        
        List<Apttus__Term_Exception__c> nonteList = [select id, Apttus__Exception__c,Apttus__Exception_Type__c,Apttus__Description__c,Apttus__Active__c,APTSMD_Pre_Approved_Language__c,Apttus__Approval_Required__c
                                            from Apttus__Term_Exception__c where Apttus__Active__c=true and APTSMD_Pre_Approved_Language__c=false order by Apttus__Exception_Type__c];
         if(!nonteList.isEmpty()){           
            nonTEListJson = JSON.serialize(nonteList);
         }
         

        configRequestId = ApexPages.CurrentPage().getParameters().get('configRequestId');  
        // get the configSO
        this.configSO = (Apttus_Config2__ProductConfiguration__c)stdController.getRecord();
         
        configSO = [SELECT id, Apttus_CMConfig__AgreementId__c, Apttus_QPConfig__Proposald__c
                    FROM Apttus_Config2__ProductConfiguration__c 
                    WHERE id =: configSO.id];
                      
          lineItems = [SELECT Apttus_Config2__PricingStatus__c , Apttus_Config2__LineType__c, Apttus_Config2__LineNumber__c, Apttus_Config2__ItemSequence__c, Apttus_Config2__ConfigurationId__c
                       FROM Apttus_Config2__LineItem__c 
                       WHERE Apttus_Config2__ConfigurationId__c =: configSO.Id];
         
         // Get the Configuration record 
        config =  [SELECT id, name, Apttus_Config2__PriceListId__c, Apttus_QPConfig__Proposald__c, Apttus_QPConfig__Proposald__r.Name, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Proposal_Name__c, Apttus_QPConfig__Proposald__r.Apttus_Proposal__Approval_Stage__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id = :configSO.id];

         //New Code for retrieving existing Deal Terms 21-08-2015,Author:Tirth Mathuria
         
         dealTermList = [select Apttus_DealMgr__TermId__c,APTSMD_Related_Proposal__c from Apttus_DealMgr__DealTerm__c 
                         where APTSMD_Related_Proposal__c =:configSO.Apttus_QPConfig__Proposald__c];
         

         List<String> teIDList =new List<String>();
         if(!dealTermList.isEmpty()) {
             for(Apttus_DealMgr__DealTerm__c dt : dealTermList) {
            
                    teIDList.add(dt.Apttus_DealMgr__TermId__c);
            }
         }
         

          
                savedTeIDsJson= JSON.serialize(teIDList);
          
      setCustomCSSPath();
    }
     public void setCustomCSSPath(){
             String path;
             Apttus_Config2__ConfigSystemProperties__c config = Apttus_Config2__ConfigSystemProperties__c.getValues('System Properties');
             if(config !=null && config.Apttus_Config2__CSSOverride__c !=null){
                 String resourceName = config.Apttus_Config2__CSSOverride__c;
                 List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];
                                    
                //Checking if the result is returned or not
                if(resourceList.size() == 1)
                {
                   //Getting namespace
                   String namespace = resourceList[0].NamespacePrefix;
                   //Resource URL
                   path= '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
                   customCSSStyle= new Component.Apex.StyleSheet();
                   customCSSStyle.value=path;
                }
             } 
         } 
    //Code for saving Deal Terms
    public PageReference saveDealTerms()
    {
        
        String idString=ApexPages.currentPage().getParameters().get('idString');

       List<String> teIDs=new List<String>();
       if(''!=idString && null!=idString){
           teIDs=idString.split('\\-');
           
       }
       if(!dealTermList.isEmpty()){
             delete dealTermList;
         }

       if(!teIDs.isEmpty()){
           List<Apttus__Term_Exception__c> teList = [select id, Apttus__Exception__c,Apttus__Exception_Type__c,Apttus__Description__c,Apttus__Active__c,APTSMD_Pre_Approved_Language__c,Apttus__Approval_Required__c
                                            from Apttus__Term_Exception__c where id in:teIDs];
                                            

            Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        proposal = [select Apttus_Proposal__Opportunity__c from Apttus_Proposal__Proposal__c where id=: configSO.Apttus_QPConfig__Proposald__c];
        List<Apttus_DealMgr__Deal__c> proposalDeal = new List<Apttus_DealMgr__Deal__c>();      
        proposalDeal = [select id from Apttus_DealMgr__Deal__c where Apttus_DealMgr__RelatedOpportunityId__c =: proposal.Apttus_Proposal__Opportunity__c ];
        List<Apttus_DealMgr__DealTerm__c> agmtClauseListToBeInserted = new List<Apttus_DealMgr__DealTerm__c>();  
        for(Apttus__Term_Exception__c selectedClause : teList) {
            Apttus_DealMgr__DealTerm__c agmtClause = new Apttus_DealMgr__DealTerm__c ();
            agmtClause.APTSMD_Related_Proposal__c = configSO.Apttus_QPConfig__Proposald__c; 
            agmtClause.Apttus_DealMgr__BusinessObjectType__c = 'Proposal';
            if(!proposalDeal.isEmpty()){
                agmtClause.Apttus_DealMgr__DealId__c = proposalDeal[0].id;
            }
            agmtClause.Apttus_DealMgr__TermId__c = selectedClause.id;
            agmtClause.Apttus_DealMgr__TermDetails__c=selectedClause.Apttus__Exception__c;
            agmtClause.Apttus_DealMgr__Description__c=selectedClause.Apttus__Description__c;
            
            agmtClauseListToBeInserted.add(agmtClause);     
        }
        
        if(!agmtClauseListToBeInserted.isEmpty()) {
            insert agmtClauseListToBeInserted;
        }
        
        List<Apttus_Config2__LineItem__c> lineItemsToBeUpdated = new List<Apttus_Config2__LineItem__c>();
        for(Apttus_Config2__LineItem__c lineItem : lineItems) {
            lineItem.Apttus_Config2__PricingStatus__c = 'pending';
            
            lineItemsToBeUpdated.add(lineItem);
        }
        
        if(lineItemsToBeUpdated.isEmpty()) {
            update lineItemsToBeUpdated;
        }                                
                                            
                                            
       }
       
        PageReference toCart = new PageReference(previousURL);
         return toCart;

    }
    
     public PageReference cancelAndBack() {
         
          PageReference toCart = new PageReference(previousURL);
         return toCart;
           
    }
    
    public class ClausesWrapper{        
        public Apttus__Term_Exception__c clause{get; public set;}
        public Boolean selected {get; set;}
        
        public ClausesWrapper(Apttus__Term_Exception__c clause){
            this.clause = clause;
            this.selected=false;
        }    
    }
}