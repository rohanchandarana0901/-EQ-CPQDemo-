({
    doInit : function(component, event, helper) {
		var opportunityId = component.get("v.recordId");
        helper.getOpportunityRecord(component, opportunityId);
        helper.getPresalesSetting(component);
	},
    createQuote : function (component, event, helper) {
        var oppId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_CreateQuote?id=' + oppId}).fire();
    },
    createAgreement : function(component, event, helper){
        var oppId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus__OpportunityAgreement?id=' + oppId}).fire(); 
    },
    createQuoteRLP : function (component, event, helper) {
        var oppId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_CreateQuote?action=RLP&id=' + oppId}).fire();
    }
})