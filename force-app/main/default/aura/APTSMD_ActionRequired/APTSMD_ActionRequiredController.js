({
    doInit : function(component, event, helper) {
        helper.getActionRequiredCount(component);
		helper.getListViewDetail(component,'Apttus__APTS_Agreement__c','APTSMD_Agreements_for_my_review','myAgreementsList');        
	},
	gotoList: function(component, event, helper) {
        var listId = component.get("v.myAgreementsList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus__APTS_Agreement__c/list?filterName='+listId}).fire();
    } 
})