({
	getActionRequiredCount: function(component) {
        var action = component.get("c.getApprovalCount");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.totalAgreements", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})