/**
 * Company      : Apttus Inc.
 * Description  : Clears all data created after MDO creation
 * History      :
 * [16.Jan.2019] Chetan Patel    : Created Class 
 */ 
public class APTSMD_ResetMDODataController {
    
    public datetime MDOCreatedDate {get;set;}
    public datetime UserEnteredDate {get;set;}
    public Apttus_Proposal__Proposal__c DummyProp {get;set;}
    public organization org {get; set;}
    public APTSMD_ResetMDODataController (){
        
        DummyProp = new Apttus_Proposal__Proposal__c();
        org = [select id,createddate, name from organization limit 1];
        MDOCreatedDate = org.createddate; 
        DummyProp.Apttus_QPConfig__PricingDate__c = org.createddate;
    
    }
    public Pagereference submit()
    {
     
        UserEnteredDate = DummyProp.Apttus_QPConfig__PricingDate__c;
        
        if(UserEnteredDate < MDOCreatedDate){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enterred date can not be before MDO Created date '+ MDOCreatedDate +' Please refresh page to default date to MDO Created Date.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(MDOCreatedDate != null)
        {       
            List <Apttus_Config2__AssetLineItem__c> assetList = [SELECT ID 
                                                                FROM Apttus_Config2__AssetLineItem__c 
                                                                WHERE createddate > :MDOCreatedDate];
            List<Apttus_Billing__BillingSchedule__c> billingSchedulelist = [SELECT id 
                                                                            FROM Apttus_Billing__BillingSchedule__c 
                                                                            WHERE createddate > :MDOCreatedDate];
            List<Apttus_Billing__UsageSchedule__c> usageSchedulelist = [SELECT id 
                                                                        FROM Apttus_Billing__UsageSchedule__c 
                                                                        WHERE createddate > :MDOCreatedDate];
            List<Apttus_Config2__AccountBillingSummary__c> billingSummarylist = [SELECT id 
                                                                                 FROM Apttus_Config2__AccountBillingSummary__c 
                                                                                 WHERE createddate > :MDOCreatedDate];
            List<Apttus_Config2__Order__c> orderList = [SELECT id 
                                                        FROM Apttus_Config2__Order__c 
                                                        WHERE createddate > :MDOCreatedDate];
            List<Apttus_Billing__Invoice__c> invList = [SELECT id 
                                                        FROM Apttus_Billing__Invoice__c 
                                                        WHERE createddate > :MDOCreatedDate];
            List<Apttus_Proposal__Proposal__c> propList = [SELECT id 
                                                           FROM Apttus_Proposal__Proposal__c 
                                                           WHERE createddate > :MDOCreatedDate];
            List<Apttus__APTS_Agreement__c> agmtList = [SELECT id 
                                                        FROM Apttus__APTS_Agreement__c 
                                                        WHERE createddate > :MDOCreatedDate];
            List<Apttus_Config2__ProductConfiguration__c> productconfigsolist = [SELECT id 
                                                                                FROM Apttus_Config2__ProductConfiguration__c 
                                                                                WHERE createddate > :MDOCreatedDate];
            List<Account> accList = [SELECT ID 
                                     FROM Account 
                                     WHERE createddate > :MDOCreatedDate];
            List<Contact> conList = [SELECT ID 
                                     FROM Contact 
                                     WHERE createddate > :MDOCreatedDate];
            
            List<Opportunity> oppList = [SELECT Id,Name
                                         FROM Opportunity
                                         WHERE createddate > :MDOCreatedDate];
            
            List<task> lstTask= [SELECT Id 
                                  FROM Task 
                                  WHERE createddate > :MDOCreatedDate];
                                  
            List<Apttus_Config2__AssetTransactionHistory__c> lstAssetTranHis= [SELECT Id 
                                                                               FROM Apttus_Config2__AssetTransactionHistory__c 
                                                                               WHERE createddate > :MDOCreatedDate];
                                                                    
            List<Apttus_DealMgr__Deal__c> lstDeals = [SELECT Id 
                                                              FROM Apttus_DealMgr__Deal__c 
                                                              WHERE createddate > :MDOCreatedDate];
            
            List<Apttus_Config2__TempRenewAssetLineItem__c> lstTempRenewAssetLine= [SELECT Id 
                                                                                      FROM Apttus_Config2__TempRenewAssetLineItem__c 
                                                                                      WHERE createddate > :MDOCreatedDate];
            List<Apttus_Config2__TempRenewAssetGroup__c> lstTempRenewAssetGroup= [SELECT Id 
                                                                                      FROM Apttus_Config2__TempRenewAssetGroup__c 
                                                                                      WHERE createddate > :MDOCreatedDate];
            List<Apttus_Revenue2__Agreement_Revenue_Schedule_Forecast__c> lstAgmtrevForecast = [SELECT Id
                                                                                                FROM Apttus_Revenue2__Agreement_Revenue_Schedule_Forecast__c	
                                                                                                WHERE createddate > :MDOCreatedDate];
            List<Apttus_Revenue2__Agreement_Revenue_Summary__c	> lstAgmrRevSummary= [SELECT Id 
                                                  FROM Apttus_Revenue2__Agreement_Revenue_Summary__c	 
                                                  WHERE createddate > :MDOCreatedDate];
            
            // if(lstTask !=null)
            //     delete lstTask;
            // if(lstAgmtrevForecast!=null)
            //     delete lstAgmtrevForecast;
            // if(lstAgmrRevSummary!=null)
            //     delete lstAgmrRevSummary;
            // if(assetList!=null)
            //     delete assetList;
            // if(billingSchedulelist!=null)
            //     delete billingSchedulelist;
            // if(usageSchedulelist!=null)
            //     delete usageSchedulelist;
            // if(billingSummarylist!=null)
            //     delete billingSummarylist;
            // if(orderList!=null)
            //     delete orderList;
            // if(orderList!=null)
            //     delete invList;
            // if(productconfigsolist!=null)
            //     delete productconfigsolist;
            // if(propList!=null)
            //     delete propList;
            // if(agmtList!=null)
            //     delete agmtList;
            // if(oppList!=null)
            //     delete oppList;
            // if(conList!=null)
            //     delete conList;
            // if(accList!=null)
            //     delete accList;
            // if(lstAssetTranHis !=null)
            //     delete lstAssetTranHis;
            // if(lstDeals !=null)
            //     delete lstDeals;
            // if(lstTempRenewAssetLine !=null)
            //     delete lstTempRenewAssetLine;
            // if(lstTempRenewAssetGroup !=null)
            //     delete lstTempRenewAssetGroup;
            
            
            PageReference pr;
            if(isSalesForce1orLE())
                pr = new PageReference('/lightning/page/home');
            else
                pr = new PageReference('/');
            return pr;
        }else{
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'MDO Created date in presales config setting is not set.');
            ApexPages.addMessage(myMsg);
            return null;
        }  
    }

    public pagereference cancel() {
        
        PageReference pageRef;
        if(isSalesForce1orLE())
            pageRef = new PageReference('/lightning/page/home');
        else
            pageRef = new PageReference('/');  
        return pageRef;
    }
    
     public static Boolean isSalesForce1orLE(){
         
        if(ApexPages.currentPage().getParameters().get('sfdcIFrameHost') != null ||
           ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin') != null ||
           ApexPages.currentPage().getParameters().get('isdtp') == 'p1') {      
            return true;
        }
        else {      
            return false;
        }           
    }


}