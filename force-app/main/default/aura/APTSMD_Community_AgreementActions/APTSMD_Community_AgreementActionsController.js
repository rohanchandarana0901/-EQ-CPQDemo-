({
	doInit : function(component, event, helper) {
		var qId = component.get("v.recordId");
        helper.getGrandTotal(component, qId);
        helper.getAgreement(component, qId);
	},
    
    agreementPreview : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningselecttemplate%3Faction%3DPreview_Agreement%26templateType%3DAgreement%26id%3D' + aId}).fire();
    },
    
    sendForApprovals : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_Approval__ApprovalContextPreview%3FsObjectType%3DApttus__APTS_Agreement__c%26sObjectId%3D' + aId}).fire();
    },
    myApprovals : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_Approval__MyApprovals%3Fid%3D' + aId}).fire();
    },
    
    generateAgreement : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningselecttemplate%3Faction%3DGenerate_Agreement%26templateType%3DAgreement%26id%3D' + aId}).fire();
    },
    activateAgreement : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningagreementactivate%3Fid%3D' + aId}).fire();
    },
	agreementRenew : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningagreementrenew%3FpageMode%3DRenew%26id%3D' + aId}).fire();
    },
    agreementTerminate : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningagreementterminate%3FpageMode%3DTerminate%26id%3D' + aId}).fire();
    },
    agreementExpire : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningagreementexpire%3FpageMode%3DExpire%26id%3D' + aId}).fire();
    },
    agreementAmend : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningagreementamend%3FpageMode%3DAmend%26id%3D' + aId}).fire();
    },
	
    checkESignature : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_DocuApi__DocuSignEnvStatusByEnvId%3Fenvelopeparentid%3D' + qId}).fire();
    },
    
    mergeDoc : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FAPTSMD_MergeDocumentstoPDF%3Faction%3DGenerate_Agreement%26templateType%3DAgreement%26id%3D' + aId}).fire();
    },
    generatesupportAgreement : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningselecttemplate%3Faction%3DGenerate_Supporting_Document%26templateType%3DSupporting_Document%26id%3D' + aId}).fire();
    },
    cancelAgreement : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningagreementcancel%3Fid%3D' + aId}).fire();
    },
    submitAgreementReq : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__agreementsubmitrequest%3Fid%3D' + aId}).fire();
    },
    importOfflineDoc : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningofflinedocumentimport%3Fid%3D' + aId}).fire();
    },
    sendForEchoSignature : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_Echosign__SelectAttachment%3FtargetPageURL%3D%2Fapex%2FApttus_Echosign__EchoSignInfoEdit%26id%3D' + aId}).fire();
    },
    agreementReview : function (component, event, helper) {
        var aId = component.get("v.recordId");
    	$A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__SendEmail%3Faction%3DSend_To_Other_Party_For_Review%26id%3D' + aId}).fire();
    },
    regenerateDoc : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus__lightningselecttemplate%3Faction%3DRegenerate_Agreement%26templateType%3DAgreement%26id%3D' + aId}).fire();
    },
    sendForDocuSignature : function (component, event, helper) {
        var aId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_CMDSign__CMDocuSignCreateEnvelope%3Fid%3D' + aId}).fire();
    },
    checkESignature : function (component, event, helper) {
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/sfdcpage/%2Fapex%2FApttus_DocuApi__DocuSignEnvStatusByEnvId%3Fenvelopeparentid%3D' + qId}).fire();
    }
})