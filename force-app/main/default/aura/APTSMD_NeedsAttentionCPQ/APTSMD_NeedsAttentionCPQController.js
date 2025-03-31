({
    doInit : function(component, event, helper) {
        helper.getNeedsAttentionCount(component);        
        helper.getListViewDetail(component, 'Apttus_Proposal__Proposal__c','Needs_Approval','myProposalsList');
	},
	gotoList: function(component, event, helper) {
        var listId = component.get("v.myProposalsList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus_Proposal__Proposal__c/list?filterName='+listId}).fire();
    } 
})