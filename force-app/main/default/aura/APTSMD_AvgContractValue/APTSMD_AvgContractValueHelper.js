({
    
	getAvgContractValue: function(component) {
        var action = component.get("c.getAvgContractValue");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.totalAgreements", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    getAvgACVView: function(component) {
        var action = component.get("c.getAvgACVView");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.AvgACVView", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})