({
    doInit : function(component, event, helper) {
        helper.getActionRequiredCount(component);
		helper.getListViewDetail(component,'Apttus_Proposal__Proposal__c','PresentedtoCustomerrecently','myProposalList');        
	},
	gotoList: function(component, event, helper) {
        var listId = component.get("v.myProposalList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus_Proposal__Proposal__c/list?filterName='+listId}).fire();
    } 
})