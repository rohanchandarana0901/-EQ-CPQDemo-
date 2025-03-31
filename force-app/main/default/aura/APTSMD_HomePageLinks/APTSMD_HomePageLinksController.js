({
    doInit : function(component, event, helper) {
        helper.getListViewDetail(component, 'Apttus__APTS_Agreement__c','APTSMD_My_Agreements','myAgreementsList');               
        helper.getListViewDetail(component, 'Apttus__APTS_Template__c','Clauses','clausesList'); 
        helper.getListViewDetail(component, 'Apttus__APTS_Template__c','Agreements','agreementTemplateList');
        helper.getPresalesSetting(component, event, helper);
	},
	createNDA: function (component, event, helper) {
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=NDA Wizard'}).fire();
        var presalesSettings = component.get("v.presalesSetting");
        console.log(presalesSettings);
        if(presalesSettings.APTSMD_Enable_Salesforce_Flow__c){
            $A.get("e.force:navigateToURL").setParams({"url": '/flow/APTSMD_NDA_Flow'}).fire();
        }else{
            $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=NDA Wizard'}).fire();
        }
    },
    createMSA: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=MSA Wizard'}).fire();
    },
    createACW: function (component, event, helper) {
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=Agreement Creation Wizard'}).fire();
        var presalesSettings = component.get("v.presalesSetting");
        console.log(presalesSettings);
        if(presalesSettings.APTSMD_Enable_Salesforce_Flow__c){
            $A.get("e.force:navigateToURL").setParams({"url": '/flow/APTSMD_Agreement_Creation_Flow'}).fire();
        }else{
            $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=Agreement Creation Wizard'}).fire();
        }
    },
    openPortal: function (component, event, helper) {
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_RedirectToContractPortal'}).fire(); updated by vivek as on 8-12-2021 
        var listId = component.get("v.agreementTemplateList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Template__c/list?filterName='+listId}).fire();
    },
    goToOfflineImport: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus__OfflineAgreement'}).fire();
    }, 
    gotoMyAgreements: function(component, event, helper) {       
        var listId = component.get("v.myAgreementsList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+listId}).fire();
    } ,
    gotoClauses: function(component, event, helper) {
        var listId = component.get("v.clausesList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Template__c/list?filterName='+listId}).fire();
    } 
})