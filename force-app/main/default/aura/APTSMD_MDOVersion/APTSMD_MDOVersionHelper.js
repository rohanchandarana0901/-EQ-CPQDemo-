({
	getMDOVersion: function(component) {
        var action = component.get("c.getMDOVersion");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
               	component.set("v.mdoVersion", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})