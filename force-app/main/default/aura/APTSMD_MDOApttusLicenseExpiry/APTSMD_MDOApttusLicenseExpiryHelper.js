({
	
    getApttusLicenseExpirationDate: function(component) {
        var action = component.get("c.getApttusLicenseExpirationDate");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
               	component.set("v.apttusLicenseExpirationDate", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }
})