({
	doInit : function(component, event, helper) {
		var qId = component.get("v.recordId");
        helper.getProposal(component, qId);
    },
    update : function (component, event, helper) {
        var qId = component.get("v.recordId");
        helper.getProposal(component, qId);
    },
    generateProposal : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_Proposal__DocGen%3Fid%3D' + qId}).fire();
    },
    presentProposal : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_Proposal__ProposalPresent%3Fid%3D' + qId}).fire();
    },
    acceptProposal : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_QPConfig__ProposalAccept%3Fid%3D' + qId}).fire();
    },
    configureProducts : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FAPTSMD_CommunityConfigureQuote%3Fid%3D' + qId}).fire();
    },
    syncWithOppty : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_QPConfig__ProposalSyncWithOpportunity%3Fid%3D' + qId}).fire();
    },
    approvals : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_CQApprov__MyCartApprovalsLaunch%3Fid%3D' + qId}).fire();
    },
    myApprovals : function (component, event, helper) {
        var qId = component.get("v.recordId");
        //$A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FAPTSMD_MyApprovalsLight%3Fid%3D' + qId}).fire();
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_CQApprov__MyCartApprovalsLaunch%3Fid%3D' + qId}).fire();
    },
    sendForEchoSign : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_Echosign__SelectAttachment%3FtargetPageURL%3D%2Fapex%2FApttus_Echosign__EchoSignInfoEdit%26id%3D' + qId}).fire();
    },
    sendForDocuSign : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_QPDSign__QPDocuSignCreateEnvelope%3Fid%3D' + qId}).fire();
    },
    sendForCongaSign : function (component, event, helper) {
        var quoteId = component.get("v.recordId");
        var contactId = component.get("v.proposal.Apttus_Proposal__Primary_Contact__c");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FAPXT_CongaSign__apxt_sendForSignature%3Fid%3D' + quoteId + '%26recipient1%3D' + contactId}).fire();
    },
    createAgreement: function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FAPTSMD_NewAgreementFromQuoteVf%3Fid%3D' + qId}).fire();
        //$A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_QPComply__ProposalAgreementCreate%3Fid%3D' + qId}).fire();
    },
    
    checkESignature : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_DocuApi__DocuSignEnvStatusByEnvId%3Fenvelopeparentid%3D' + qId}).fire();
    },
})