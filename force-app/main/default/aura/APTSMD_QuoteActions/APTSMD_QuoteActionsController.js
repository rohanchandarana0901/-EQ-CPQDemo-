({
	doInit : function(component, event, helper) {
		var quoteId = component.get("v.recordId");
        helper.getProposal(component, quoteId);
        helper.getCloudServerId(component);
        helper.getPresalesSetting(component);
	},
    update : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        helper.getProposal(component, quoteId);
    },
    generateProposal : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Proposal__DocGen?id=' + quoteId+'&context=proposal'}).fire();
    },
    acceptProposal : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_QPConfig__ProposalAccept?id=' + quoteId}).fire();
    },
    configureProducts : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        var flow = component.get("v.proposal.APTSMD_Flow__c");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__Cart?businessObjectId=' + quoteId + '&useAdvancedApproval=true&useDealOptimizer=true&method=csrFlow&useAdvancedCurrency=true&flow='+flow}).fire();
    },
    syncWithOppty : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_QPConfig__ProposalSyncWithOpportunity?id=' + quoteId}).fire();
    },
    myApprovals : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_CQApprov__MyCartApprovalsLaunch?id=' + quoteId}).fire();
    },
    sendForEchoSign : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        
        //modified by vivek parmar to support Files in adobe sign
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_QPESign__SelectAttachment?id=' + quoteId}).fire();
        
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_SelectAttachmentLightning?targetPageURL=/apex/Apttus_Echosign__EchoSignInfoEdit&id=' + quoteId}).fire();
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/SelectAttachment?targetPageURL=/apex/Apttus_Echosign__EchoSignInfoEdit&id=' + quoteId}).fire();
    },
    sendForDocuSign : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_QPDSign__QPDocuSignCreateEnvelope?id=' + quoteId}).fire();
    },
    sendForCongaSign : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        var contactId = component.get("v.proposal.Apttus_Proposal__Primary_Contact__c");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APXT_CongaSign__apxt_sendForSignature?id=' + quoteId + '&recipient1=' + contactId}).fire();
    },
    createAgreement: function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_SelectTypeToCreateAgreement?id=' + quoteId + '&copyLineItems=true'}).fire();
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_QPComply__ProposalAgreementCreate?id=' + quoteId}).fire();
    },
    checkESignature : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_DocuApi__DocuSignEnvStatusByEnvId?envelopeparentid=' + quoteId}).fire();
    },
    configureProductsLA : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        var flow = component.get("v.proposal.APTSMD_Flow__c");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__Cart?businessObjectId=' + quoteId + '&useAdvancedApproval=false&useDealOptimizer=false&isCartTotalingDisabled=true&asyncFinalize=true&method=csrFlow&useAdvancedCurrency=true&flow='+flow}).fire();
    },
    configureCloudServer : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        var flow = component.get("v.proposal.APTSMD_Flow__c");
        var cloudServerId = component.get("v.cloudServerId");
        
       	$A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Config2__Cart?useAdvancedApproval=true&useAdvancedCurrency=true&useDealOptimizer=true#!/flows/'+flow+'/businessObjects/'+quoteId +'/products/'+cloudServerId+'/configure'}).fire();
    },
    configureProductsRLP : function(component, event, helper){
        var quoteId = component.get("v.recordId");
        var flow = component.get("v.proposal.APTSMD_Flow__c");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Conga_CCPQ__RLPCart?boid=' + quoteId + '&flow=system&idp=Salesforce&skipDealGuidance=false&skipApprovalCheck=false'}).fire();
    },
    myApprovalsRLP : function(component, event, helper) {
        helper.myApprovalsRLPHelper(component,event,helper);        
    }
})