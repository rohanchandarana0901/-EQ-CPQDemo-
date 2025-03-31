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
    }
})