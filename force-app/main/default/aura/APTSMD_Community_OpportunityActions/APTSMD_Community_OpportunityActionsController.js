({
    createQuote : function (component, event, helper) {
        var oppId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FAPTSMD_CommunityCreateQuote%3Fid%3D' + oppId}).fire();
    },
    createAgreement : function(component, event, helper){
        var oppId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__OpportunityAgreement%3Fid%3D' + oppId}).fire(); 
    }
})