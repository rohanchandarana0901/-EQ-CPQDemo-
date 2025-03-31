({
    getProposal: function(component, quoteId) {
        var action = component.get("c.getProposal");
        action.setParams({
        	"proposalId": quoteId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (state === "SUCCESS") {
        		component.set("v.proposal", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    getCloudServerId: function(component) {
        var action = component.get("c.getCloudServerId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cloudServerId", response.getReturnValue());
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
    myApprovalsRLPHelper : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var sObjectName = "Apttus_Proposal__Proposal__c";
        // the below URL needs to be changed according to the environment of testing. eg: rlsstg, rlsqa..
        var redirectUrl = "https://preview-rls09.congacloud.com/approvals/my-approvals";
        var getSessionIdAction = component.get("c.getCurrentUserSessionId");
        getSessionIdAction.setCallback(this, function(response) {
            var state = response.getState();      
            if (state === "SUCCESS") {
                var params = {};
                var sessionId = response.getReturnValue();
                params.sessionId = sessionId;
                params.recordId = recordId;
                params.sObjectName = sObjectName;
				params.url = redirectUrl;
                this.navigateToURL(params);
            }
        });
        $A.enqueueAction(getSessionIdAction);
    },
    navigateToURL : function(params) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": params.url+'?recordId='+params.recordId+'&sObjectName='+params.sObjectName+'&sessionId='+params.sessionId
        });
        urlEvent.fire();
    }
})