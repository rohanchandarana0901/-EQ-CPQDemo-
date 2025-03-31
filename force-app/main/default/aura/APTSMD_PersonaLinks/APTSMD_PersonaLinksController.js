({	
    doInit: function(component, event, helper) {        
        helper.getUserPicklistValues(component, event);
    },
	personaLogin : function(component, event, helper) {
        var userRedirectionURL = component.get("v.userRedirectionURL");
        window.open(userRedirectionURL, '_blank');
    }
})