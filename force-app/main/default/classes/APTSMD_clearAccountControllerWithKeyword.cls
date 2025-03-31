/**
 * Company      : Apttus Inc.
 * Description  : Deletion of Account related object's data alongwith keyword logic class
 * History      :
 * [25.May.2018] Devangi Mehta    : Created Class 
 * [31.Dec.2018] Jeetu Agrawal : Migrate
 * [15.Apr.2022] Vivek Parmar : UI/UX Enhanced
 */ 
global with sharing class APTSMD_clearAccountControllerWithKeyword {
    
    public static String accName{get;set;}
    public static String keyword{get;set;}
    public static ID accountId{get;set;}
    public boolean accountDelete {get;set;}
    public List<Account> accountLookup {get;set;}
    public string jsonAccounts {get;set;}

    public APTSMD_clearAccountControllerWithKeyword(){
        accountLookup =  [SELECT Id,Name from Account where APTSMD_Is_Included_in_Report__c=false order by LastModifiedDate desc];
        jsonAccounts = JSON.serialize(accountLookup);
    }

    public static Pagereference submit()
    {
        if(accName == '') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Please Enter Any Account Name');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        //Deletes records that contains the specified keyword under the mentioned account
        else if(accName != '' && keyword != '') {
            List<Account> acc = [SELECT ID 
                                FROM Account 
                                WHERE Name=:accName.trim() 
                                LIMIT 1];
            if(acc.size() == 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'No Such Account Exists');
                ApexPages.addMessage(myMsg);
                return null;
            }
            accountId = acc[0].Id;
            List<Opportunity> oppList = [SELECT Id,
                                                Name
                                         FROM Opportunity
                                         WHERE AccountId =: accountId 
                                         AND Name LIKE :('%' + keyword + '%')];
            
            List<Apttus_Proposal__Proposal__c> propList = [SELECT id,
                                                                Apttus_Proposal__Proposal_Name__c 
                                                           FROM Apttus_Proposal__Proposal__c 
                                                           WHERE Apttus_Proposal__Account__c =:accountId 
                                                           AND Apttus_Proposal__Proposal_Name__c LIKE :('%' + keyword + '%')];
            List<Apttus__APTS_Agreement__c> agmtList = [SELECT id,
                                                                Name 
                                                        FROM Apttus__APTS_Agreement__c 
                                                        WHERE Apttus__Account__c = :accountId 
                                                        AND Name LIKE :('%' + keyword + '%')];
            List<Apttus_Config2__ProductConfiguration__c> productconfigsolist = [SELECT id,
                                                                                        Name 
                                                                                FROM Apttus_Config2__ProductConfiguration__c 
                                                                                WHERE Apttus_Config2__AccountId__c = :accountId 
                                                                                AND Name LIKE :('%' + keyword + '%')];
            delete oppList;
            delete propList;
            delete agmtList;
            delete productconfigsolist;
            
            
            ID acc_ID = [SELECT ID FROM Account WHERE Name=:accName.trim() LIMIT 1].id;
            PageReference pr = new PageReference('/' + acc_ID);
            return pr;
            
        }
        
        //Deletes all the records of the mentioned Account
        else if(accName != '' && keyword == '') {
            List<Account> acc = [SELECT ID 
                                FROM Account 
                                WHERE Name=:accName.trim() LIMIT 1];
            if(acc.size() == 0) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'No Such Account Exists');
                ApexPages.addMessage(myMsg);
                return null;
            }
            accountId = acc[0].Id;
            List <Apttus_Config2__AssetLineItem__c> assetList = [SELECT ID 
                                                                FROM Apttus_Config2__AssetLineItem__c 
                                                                WHERE Apttus_Config2__AccountId__c =:accountId];
            List<Apttus_Billing__WalletDrawdown__c> walletList = [SELECT ID
                                                                 FROM Apttus_Billing__WalletDrawdown__c
                                                                 WHERE Apttus_Billing__WalletId__c in :assetList];
            List<Apttus_Billing__BillingSchedule__c> billingSchedulelist = [SELECT id 
                                                                            FROM Apttus_Billing__BillingSchedule__c 
                                                                            WHERE Apttus_Billing__BillToAccountId__c=:accountId];
            List<Apttus_Billing__UsageSchedule__c> usageSchedulelist = [SELECT id 
                                                                        FROM Apttus_Billing__UsageSchedule__c 
                                                                        WHERE Apttus_Billing__BillingScheduleId__r.Apttus_Billing__BillToAccountId__c =:accountId];
            List<Apttus_Config2__AccountBillingSummary__c> billingSummarylist = [SELECT id 
                                                                                 FROM Apttus_Config2__AccountBillingSummary__c 
                                                                                 WHERE Apttus_Config2__AccountId__c=:accountId];
            List<Apttus_Billing__ForecastedBillingSummary__c> fcBillingSummarylist = [SELECT id 
                                                                         FROM Apttus_Billing__ForecastedBillingSummary__c 
                                                                         WHERE Apttus_Billing__BillToAccountId__c=:accountId];
            List<Apttus_Billing__ForecastedBillingSchedule__c> fcBillingScheduleList = [SELECT id 
                                                                         FROM Apttus_Billing__ForecastedBillingSchedule__c 
                                                                         WHERE Apttus_Billing__BillToAccountId__c=:accountId];
            List<Apttus_Config2__Order__c> orderList = [SELECT id 
                                                        FROM Apttus_Config2__Order__c 
                                                        WHERE Apttus_Config2__SoldToAccountId__c =:accountId];
            List<Apttus_Billing__Invoice__c> invList = [SELECT id 
                                                        FROM Apttus_Billing__Invoice__c 
                                                        WHERE Apttus_Billing__BillToAccountId__c =:accountId];
            List<Apttus_Proposal__Proposal__c> propList = [SELECT id 
                                                           FROM Apttus_Proposal__Proposal__c 
                                                           WHERE Apttus_Proposal__Account__c =:accountId];
            List<Apttus__APTS_Agreement__c> agmtList = [SELECT id 
                                                        FROM Apttus__APTS_Agreement__c 
                                                        WHERE Apttus__Account__c = :accountId];
            List<Apttus_Config2__ProductConfiguration__c> productconfigsolist = [SELECT id 
                                                                                FROM Apttus_Config2__ProductConfiguration__c 
                                                                                WHERE Apttus_Config2__AccountId__c = :accountId];
            List<Opportunity> oppList = [SELECT Id,
                                                Name
                                         FROM Opportunity
                                         WHERE AccountId =: accountId];
            List<Apttus_Billing__ForecastedBillingOptions__c> fcBillingOptionlist = [SELECT id 
                                                                         FROM Apttus_Billing__ForecastedBillingOptions__c 
                                                                         WHERE Apttus_Billing__ProposalId__r.Apttus_Proposal__Account__c =:accountId];
            List<Apttus_Billing__ForecastedLineItemOptions__c> fcBillingOptionLIlist = [SELECT id 
                                                                         FROM Apttus_Billing__ForecastedLineItemOptions__c 
                                                                         WHERE Apttus_Billing__ProposalId__r.Apttus_Proposal__Account__c =:accountId];
            List<Apttus_Billing__CreditMemo__c> creditMemoList = [SELECT ID
                                                                 FROM Apttus_Billing__CreditMemo__c
                                                                 WHERE Apttus_Billing__InvoiceID__c in :invList];
            List<Apttus_Billing__RelatedARTransaction2__c> arTrxList = [SELECT ID
                                                                 FROM Apttus_Billing__RelatedARTransaction2__c
                                                                 WHERE Apttus_Billing__DestinationCreditMemoId__c in :creditMemoList
                                                                       Or Apttus_Billing__SourceCreditMemoId__c in :creditMemoList
                                                                       Or Apttus_Billing__DestinationInvoiceId__c in :invList
                                                                       Or Apttus_Billing__SourceInvoiceId__c in :invList];
            List<Apttus_Billing__UsageInput__c> usageInputList = [Select Id From Apttus_Billing__UsageInput__c
                                                                Where Apttus_Billing__AssetLineItemId__r.Apttus_Config2__AccountId__c =:accountId];
            List<Apttus_Billing__Payment__c> paymentList = [Select Id From Apttus_Billing__Payment__c
                                                                Where Apttus_Billing__AccountId__c =:accountId];
            
            delete paymentList;
            delete usageInputList;
            delete fcBillingOptionLIlist;
            delete fcBillingOptionlist;
            delete arTrxList;
            delete creditMemoList;
            delete walletList;
            delete assetList;
            delete billingSchedulelist;
            delete fcBillingScheduleList;
            delete usageSchedulelist;
            update billingSummarylist;
            delete fcBillingSummaryList;
            delete orderList;
            delete invList;
            delete propList;
            delete agmtList;
            delete productconfigsolist;
            
            if(oppList.size() > 0){
                //Set of Opportunity Id to be used to query Opportunity Line items below                             
                Set<Id> oppIdSet = new Set<Id>();
                for(Opportunity eachOpp : oppList){
                    oppIdSet.add(eachOpp.Id);
                }
                List<OpportunityLineItem> oppLineItemList = [SELECT Id,
                                                                    OpportunityId
                                                             FROM OpportunityLineItem
                                                             WHERE OpportunityId IN: oppIdSet];
                delete oppLineItemList;   
            }
            
            ID acc_ID = [SELECT ID FROM Account WHERE Name=:accName.trim() LIMIT 1].id;
            PageReference pageRef = new PageReference('/' + acc_ID);
            return pageRef;
            
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Please Enter Any Account Name');
            ApexPages.addMessage(myMsg);
            return null;
        }
    }
    
    @RemoteAction
    global static Pagereference clearData(string selectedAccountId, string accountName, string kw){
        accName = accountName;
        accountId = Id.valueOf(selectedAccountId);
        keyword = kw;
        return submit();
        //PageReference pageRef = new PageReference('/' + selectedAccountId);
        //return pageRef;
    }
    
    
    public pagereference cancel() {
        PageReference pageRef = new PageReference('/');
        return pageRef;
    }

}