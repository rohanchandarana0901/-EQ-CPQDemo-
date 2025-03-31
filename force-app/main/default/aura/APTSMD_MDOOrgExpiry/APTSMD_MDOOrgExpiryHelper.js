({
	getOrgExpirationDate: function(component) {
        var action = component.get("c.getOrgExpirationDate");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
               	component.set("v.orgExpirationDate", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})