({
    doInit : function(component, event, helper) {
        helper.getPresaleConfig(component);
        helper.showOrgExpirationDetail(component);
        helper.showpackageLicenseExpirationDetail(component);
        helper.handleShowEmailNotice(component);
        helper.getECommerceURL(component);
	},
    createNDA: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=NDA Wizard'}).fire();
    },
    createMSA: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=MSA Wizard'}).fire();
    },
    createACW: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_startWizard?type=Agreement Creation Wizard'}).fire();
    },
    redirectToPortal: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_RedirectToContractPortal'}).fire();
    },
    backToContexualPricing: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_CostProfitAnalysis'}).fire();
    },
    goToWebstore: function(component, event, helper) {
        var eCommerceURL = component.get("v.eCommerceURL");
        $A.get("e.force:navigateToURL").setParams({"url": eCommerceURL,"target":'_blank'}).fire();
    } ,
    goToOfflineImport: function(component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus__OfflineAgreement'}).fire();
    }
})