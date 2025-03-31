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
    },
    getOrgExpirationDate: function(component) {
        var action = component.get("c.getOrgExpirationDate");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
               	component.set("v.orgExpirationDate", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
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