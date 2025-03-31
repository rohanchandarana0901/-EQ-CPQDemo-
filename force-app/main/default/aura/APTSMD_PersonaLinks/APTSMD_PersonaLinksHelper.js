({
    getUserPicklistValues: function(component, event) {
        var action = component.get("c.getUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var userDetails = [];
                for(var key in result){
                    userDetails.push({key: key, value: result[key]});
                }
                component.set("v.userDetails", userDetails);
            }
        });
        $A.enqueueAction(action);
    }
})