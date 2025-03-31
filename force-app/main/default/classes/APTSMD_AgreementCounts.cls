public class APTSMD_AgreementCounts {
    @AuraEnabled
    public static Integer getActionRequiredCount(){
        List<Apttus__APTS_Agreement__c> agreementList =  [SELECT id
                       FROM Apttus__APTS_Agreement__c
                       WHERE ownerid =: userinfo.getUserId()
                       AND Apttus__Status__c='Other Party Review'];
        return agreementList.size();
    }
    @AuraEnabled
    public static Integer getNeedsAttentionCount(){
        List<Apttus__APTS_Agreement__c> agreementList =  [SELECT id
                       FROM Apttus__APTS_Agreement__c
                       WHERE APTSMD_Days_Until_Contract_Expiration__c <= 30
                       And APTSMD_Days_Until_Contract_Expiration__c > 0];
        
        if(!agreementList.isEmpty()){
            return agreementList.size();
        }
        
        if(UserInfo.getUserName() != 'master-htm@mdo.com'){
            Datetime orgCreationDate = [Select CreatedDate from Organization].CreatedDate;
            List<Apttus__APTS_Agreement__c> agreementListToUpdate =  [SELECT id
                           FROM Apttus__APTS_Agreement__c
                           WHERE APTSMD_Days_Until_Contract_Expiration__c <= 30
                           And CreatedDate = :orgCreationDate
                           And Name like '%MSA ABC Corporation%'
                           Order BY CreatedDate Desc Limit 10];
            for(Apttus__APTS_Agreement__c agreement : agreementListToUpdate){
                agreement.Apttus__Contract_End_Date__c = Date.today() + 25;
            }
            update agreementListToUpdate;
            
            return agreementListToUpdate.size();
		}

        return 0;
    }
    @AuraEnabled
    public static String getListViewDetail(String objectName,String viewName){
        return APTSMD_ListViewIdGeneric.getListViewDetail(objectName,viewName);
    }
    //added by vivek as on 28 sept 2022 to for contract request home page 
    @AuraEnabled
    public static String getAvgContractValue(){
    
        Decimal avgACV;
        String acv;
        AggregateResult[] acvAggr = [SELECT AVG(Apttus__Total_Contract_Value__c)ACV FROM Apttus__APTS_Agreement__c ];
        if(acvAggr !=null && acvAggr.size()>0)
        {
            avgACV = (Decimal) acvAggr[0].get('ACV');
            if (avgACV > 1000000) {
                acv='$' + (avgACV/1000000).round() + 'M';
            }
            else if (avgACV > 1000) {
                acv='$' + (avgACV/1000).round() + 'K';
            }
            else{
                acv = '$' + avgACV.round();
            }
        }                    
        return acv;      
    }
    @AuraEnabled
    public static string getAvgACVView(){
    
        List<ListView> filterView =  [SELECT Id, Name, DeveloperName,  SobjectType 
                                      FROM ListView 
                                      where SobjectType ='Apttus__APTS_Agreement__c' 
                                      and DeveloperName='APTSMD_High_Value_Agreements'];
        
        if(!filterView.isEmpty()){
            return filterView[0].id;
        }

        return 'Recent';
    }
    @AuraEnabled
    public static Integer getMyReports(){
    
        Integer myReportsCnt=0;
        AggregateResult[] myReports = [select Count(Id)MyReport from Report where createdById =: UserInfo.getUserId()];
        myReportsCnt = (Integer) myReports[0].get('MyReport');
        return myReportsCnt;
    }
    @AuraEnabled
    public static Integer getApprovalCount(){
        Integer count=0;
        Date currentDate = Date.today();
        List<Apttus__APTS_Agreement__c> agreementList =  [SELECT id
                       FROM Apttus__APTS_Agreement__c
                       WHERE Apttus_Approval__Approval_Status__c = 'Pending Approval'];
        
        if(agreementList !=null && agreementList.size()>0)
            count=agreementList.size();
        

        return count;
    }
    @AuraEnabled
    public static Integer getMyContracts(){
        Integer count=0;
        AggregateResult[] myContracts = [SELECT COUNT(id)MyContracts FROM Apttus__APTS_Agreement__c where OwnerId =: Userinfo.getUserId()];
        
        if(myContracts !=null && myContracts.size()>0){
            count = (Integer) myContracts[0].get('MyContracts');
        }
        return count;
    }
    @AuraEnabled
    public static string getMyContractsView(){
    
        List<ListView> filterView =  [SELECT Id, Name, DeveloperName,  SobjectType 
                                      FROM ListView 
                                      where SobjectType ='Apttus__APTS_Agreement__c' 
                                      and DeveloperName='APTSMD_My_Agreements'];
        
        if(!filterView.isEmpty()){
            return filterView[0].id;
        }

        return 'Recent';
    }
}