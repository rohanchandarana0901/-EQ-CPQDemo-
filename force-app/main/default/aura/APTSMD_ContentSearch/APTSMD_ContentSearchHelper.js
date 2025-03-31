({
	getRecordTypes: function(component) {
        var action = component.get("c.getRecordTypes");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.lstRecordTypes", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    getAccounts : function(component) {
        var action = component.get("c.getAccounts");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.lstAccounts", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})