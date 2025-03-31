({
	getListViewDetail: function(component, objectName , viewName,compId) {        
        var action = component.get("c.getListViewDetail");
        action.setParams({
        	"objectName": objectName,
            "viewName": viewName
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
        		component.set("v."+compId, response.getReturnValue());                
        	}
        });
        $A.enqueueAction(action);
    },
    getPresalesSetting : function(component, event, helper){
        var getPresalesSettingsAction = component.get("c.getPresalesConfigSetting");
        getPresalesSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.presalesSetting", response.getReturnValue());
                console.log("Company Setting loaded.");
            } else {
                console.log("Failed to load Company Setting.");
            }
        });
        $A.enqueueAction(getPresalesSettingsAction);
    }
})