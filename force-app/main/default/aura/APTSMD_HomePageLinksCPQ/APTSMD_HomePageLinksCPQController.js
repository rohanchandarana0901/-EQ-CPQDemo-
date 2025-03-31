({
    doInit : function(component, event, helper) {
        helper.getListViewDetail(component, 'Opportunity','MyOpportunities','myOppList');               
        helper.getListViewDetail(component, 'Apttus_Proposal__Proposal__c','APTSMD_My_Proposals','proposalList');               
        helper.getListViewDetail(component, 'Apttus_Proposal__Proposal__c','APTSMD_Accepted_Proposals','acceptedProposalList');               
        helper.getListViewDetail(component, 'Apttus_Config2__CollaborationRequest__c','All','collabList');
        helper.getDashboardId(component, 'Apttus_Proposal_Analysis_Dashboard','dashboardId');
        helper.getPresaleConfig(component);
        helper.getECommerceURL(component);
        helper.getPartnerCommerceURL(component);
	},
	gotoAcceptedProposals: function (component, event, helper) {
        var listId = component.get("v.acceptedProposalList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus_Proposal__Proposal__c/list?filterName='+listId}).fire();
    },
    gotoMyProposals: function (component, event, helper) {
        var listId = component.get("v.proposalList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus_Proposal__Proposal__c/list?filterName='+listId}).fire();
    },
    gotoMyOpportunities: function(component, event, helper) {       
        var listId = component.get("v.myOppList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Opportunity/list?filterName='+listId}).fire();
    },
    goToCollaboration: function(component, event, helper) {       
        var listId = component.get("v.collabList");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/o/Apttus_Config2__CollaborationRequest__c/list?filterName='+listId}).fire();
    },
    goToWebstore: function(component, event, helper) {
        var eCommerceURL = component.get("v.eCommerceURL");
        $A.get("e.force:navigateToURL").setParams({"url": eCommerceURL,"target":'_blank'}).fire();
    },
    goToPartnerCommerce: function(component, event, helper) {
        var partnerCommerceURL = component.get("v.partnerCommerceURL");
        $A.get("e.force:navigateToURL").setParams({"url": partnerCommerceURL,"target":'_blank'}).fire();
    },
    goDashboard: function(component, event, helper) {
        var dashboardId = component.get("v.dashboardId");
        $A.get("e.force:navigateToURL").setParams({"url": '/lightning/r/Dashboard/'+dashboardId+'/view'}).fire();
    } 
})