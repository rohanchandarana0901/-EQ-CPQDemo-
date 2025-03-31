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
    }
})