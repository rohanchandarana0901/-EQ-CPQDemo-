({
    
	getMyContracts: function(component) {
        var action = component.get("c.getMyContracts");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.totalAgreements", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    getMyContractsView: function(component) {
        var action = component.get("c.getMyContractsView");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.ContractsView", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})