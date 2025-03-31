({
    getOrder: function(component, qId) {
        var action = component.get("c.getOrder");
        action.setParams({
        	"orderId": qId
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
        	if (state === "SUCCESS") {
        		component.set("v.order", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})