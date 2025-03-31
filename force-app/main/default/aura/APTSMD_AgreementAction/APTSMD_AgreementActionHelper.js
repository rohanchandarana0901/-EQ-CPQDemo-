({
    getGrandTotal: function(component, oppId) {
        console.log("QuoteStatusHelper-->oppId: " + oppId);        
        var action = component.get("c.getGrandTotal");
        action.setParams({
        	"oppId": oppId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log("getGrandTotal-->state: " + state);
        	if (state === "SUCCESS") {
        		component.set("v.grandTotal", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    
    getAgreement: function(component, qId) {
        console.log("AgreementStatusHelper-->oppId: " + qId);
        var action = component.get("c.getAgreement");
        action.setParams({
        	"agreementId": qId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log("getAgreement-->");
            console.log(response);
        	if (state === "SUCCESS") {
        		component.set("v.agreement", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    sendForReview: function(component, event, helper) {
        var agreementId = component.get("v.recordId");
        helper.showLoading(component, 'Sending document for review...');
        var action = component.get("c.sendDocumentForParallelReview");
        action.setParams({
        	"agreementId": agreementId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log("sendForReview --> state: " + state);
            helper.hideLoading(component);
        	if (state === "SUCCESS") {
        		var resp = response.getReturnValue();
                console.log(resp);
                if(resp.isSuccess){
                	helper.showToast('Success','success', resp.message);    
                }else{
                    helper.showToast('Error','error', resp.message);
                }
                helper.refreshView();
        	}
        });
        $A.enqueueAction(action);
    },
    sendForLegalReview: function(component, event, helper) {
        var agreementId = component.get("v.recordId");
        helper.showLoading(component, 'Assigning Agreement to Legal Reviewer...');
        var action = component.get("c.sendAgreementToLegalReviewer");
        action.setParams({
            "agreementId" : agreementId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log(response.getReturnValue());
            helper.hideLoading(component);
        	if (state === "SUCCESS") {
        		var resp = response.getReturnValue();
                console.log(resp);
                if(resp.isSuccess){
                	helper.showToast('Success','success', resp.message);    
                }else{
                    helper.showToast('Error','error', resp.message);
                }
                helper.refreshView();
        	}
        });
        $A.enqueueAction(action);
    },
    getPresalesSetting: function(component) {
        var action = component.get("c.getPresalesConfigSetting");
        action.setParams({});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log(response.getReturnValue());
        	if (state === "SUCCESS") {
        		component.set("v.preSalesConfigSettingRecord", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    showToast : function(title, type, message){
        // Display error message using a toast
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });        
        toastEvent.fire();
    },
    showLoading : function(component, loadingMessage){
        // Set Loader and message
        component.set("v.isLoading", true);
        component.set("v.loadingMessage", (loadingMessage || 'Loading! Please wait...'));
    },
    hideLoading : function(component){
        // Hide Loader
        component.set("v.isLoading", false);
    },
    refreshView : function(){
        // refersh the Record Page 
        $A.get('e.force:refreshView').fire();
    }
})