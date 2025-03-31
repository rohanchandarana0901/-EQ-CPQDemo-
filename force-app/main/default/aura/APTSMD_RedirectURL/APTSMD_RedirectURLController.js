({
	doRedirect : function(component, event, helper) {
		var url = component.get("v.urlToRedirect");
		window.location.href = url;
	}
})