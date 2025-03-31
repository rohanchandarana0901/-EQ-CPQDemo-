({
    getOpportunityRecord: function(component, opportunityId){
        var action = component.get("c.getOpportunityRecord");
        action.setParams({opptyId: opportunityId});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log(response.getReturnValue());
        	if (state === "SUCCESS") {
        		component.set("v.opportunity", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    getPresalesSetting: function(component) {
        var action = component.get("c.getPresalesConfigSetting");
        action.setParams({});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log(response.getReturnValue());
        	if (state === "SUCCESS") {
        		component.set("v.preSalesConfigSettingRecord", response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    }    
})