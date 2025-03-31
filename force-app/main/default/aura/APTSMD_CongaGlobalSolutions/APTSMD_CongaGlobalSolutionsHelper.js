({
	getPerformanceReportLink: function(component, parameterName) {        
        var action = component.get("c.getPerformanceReportLink");
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
        		component.set("v."+parameterName, response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    getQbrLink: function(component, parameterName) {        
        var action = component.get("c.getQbrLink");
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
        		component.set("v."+parameterName, response.getReturnValue());                
        	}
        });
        $A.enqueueAction(action);
    },
    getCaseBreakdownLink: function(component, parameterName) {        
        var action = component.get("c.getCaseBreakdownLink");
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
        		component.set("v."+parameterName, response.getReturnValue());                
        	}
        });
        $A.enqueueAction(action);
    }
})