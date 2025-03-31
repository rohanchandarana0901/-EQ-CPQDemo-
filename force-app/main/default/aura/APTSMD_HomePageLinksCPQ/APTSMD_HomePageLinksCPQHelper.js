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
    getDashboardId: function(component, dashboardName,compId) {        
        var action = component.get("c.getDashboardId");
        action.setParams({
        	"dashboardName": dashboardName            
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();            
        	if (state === "SUCCESS") {
        		component.set("v."+compId, response.getReturnValue());                
        	}
        });
        $A.enqueueAction(action);
    },
    getPresaleConfig : function(component) {
            var action  = component.get("c.getPresalesConfigSetting");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.preSaleConfigVal", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
    },
    getECommerceURL : function(component) {
            var action  = component.get("c.getECommerceURL");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.eCommerceURL", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
    },
    getPartnerCommerceURL : function(component) {
            var action  = component.get("c.getPartnerCommerceURL");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.partnerCommerceURL", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
    }
})