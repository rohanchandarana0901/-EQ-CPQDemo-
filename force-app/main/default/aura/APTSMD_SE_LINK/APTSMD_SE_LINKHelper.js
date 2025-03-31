({
	getConfigSettings : function(component) {
		var action = component.get("c.getConfigSettingsData");
        action.setParams({});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log(response.getReturnValue());
        	if (state === "SUCCESS") {
        		component.set("v.customProperties", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
	},
    showToast : function(title, type, message){
        // Display error message using a toast
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });        
        toastEvent.fire();
    },
})