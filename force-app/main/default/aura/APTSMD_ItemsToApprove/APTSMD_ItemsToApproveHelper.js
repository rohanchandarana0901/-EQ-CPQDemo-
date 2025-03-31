({
	getAllApprovalRequests: function(component,appName) {
        var action = component.get("c.getAllApprovalRequests");
        action.setParams({
        	"appName": appName            
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
        		component.set("v.approvals", response.getReturnValue());
                console.log(response.getReturnValue());
        	}
        });
        $A.enqueueAction(action);
    },
    //added by vivek as on 29th Jan 2022 to auto assign licenses to MFA demo users      
    updateMFADemoUsers : function(component) {
        var action  = component.get("c.updateMFADemoUsers");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var mfaMsg = response.getReturnValue();
            console.log('getMFAMsg',mfaMsg);
        	if(state === "SUCCESS") {
                var mfaMsgResponse = JSON.parse(mfaMsg);
                console.log('updateMFADemoUsers '+mfaMsgResponse);
        	}
        });
        $A.enqueueAction(action);
    },
    showOrgExpirationDetail : function(component) {
        var action  = component.get("c.orgExpiration");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var orgExpirationValue = response.getReturnValue();
            console.log('orgExpirationValue',orgExpirationValue);
        	if(state === "SUCCESS") {
                var orgExpirationResponse = JSON.parse(orgExpirationValue);
        	    for(var orgCount=0;orgCount<orgExpirationResponse.length;orgCount++){
                    if(orgExpirationResponse[orgCount].daysRemaining >0 && orgExpirationResponse[orgCount].daysRemaining<=orgExpirationResponse[orgCount].interval){
            		    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            title: "Warning!",
                            message: "This org will expire in "+orgExpirationResponse[orgCount].daysRemaining+" day(s).",
                            type: "warning"
                        });
                        toastEvent.fire();
                    }
                }
        	}
        });
        $A.enqueueAction(action);
    },
    showpackageLicenseExpirationDetail : function(component) {
        var action  = component.get("c.packageLicenseExpiration");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var packageLicenseValue = response.getReturnValue();
            console.log('packageLicenseValue',packageLicenseValue);
        	if(state === "SUCCESS") {
        	    //process the response
        	    var packageLicenseResponse = JSON.parse(packageLicenseValue);
        	    console.log('packageLicenseResponse',packageLicenseResponse);
                
                if(packageLicenseResponse.length > 0){
                    var lowestRemainingDay=packageLicenseResponse[0].daysRemaining;
                    for(var pkgCount=0;pkgCount<packageLicenseResponse.length;pkgCount++){
                        if(lowestRemainingDay>packageLicenseResponse[pkgCount].daysRemaining){
                            lowestRemainingDay=packageLicenseResponse[pkgCount].daysRemaining;
                        }   
                    }
                    if(lowestRemainingDay>0){
                        if(lowestRemainingDay<=packageLicenseResponse[0].interval){
                            var toastEvent = $A.get("e.force:showToast");
                            //updated by vivek as on 15 dec 2022 to add provisioning link
                            toastEvent.setParams({
                            mode: 'sticky',
                            title: "Warning!",
                            message: "One or more packages in this org will expire in {0} day(s). Click {1} to extend it.",
                            messageTemplate: "One or more packages in this org will expire in {0} day(s). Click {1} to submit 'Provisioning Support' request.",
                            messageTemplateData: [
                                {
                                    label:lowestRemainingDay
                                },
                                {
                                    label:"here",
                                    url: "https://apttustest.sharepoint.com/sites/Provisioning/SitePages/Submitting-a-SR.aspx"    
                            	}
                            ],  
                            type: "warning"
                        });
                        toastEvent.fire();
                        }
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        //updated by vivek as on 15 dec 2022 to add provisioning link
                        toastEvent.setParams({
                            mode: 'sticky',
                            title: "Error!",
                            message: "Some of the packages in this org are expired. Click {0} to submit 'Provisioning Support' request.",
                            messageTemplate: "Some of the packages in this org are expired. Click {0} to submit 'Provisioning Support' request.",
                            messageTemplateData: [
                                {
                                    label:"here",
                                    url: "https://apttustest.sharepoint.com/sites/Provisioning/SitePages/Submitting-a-SR.aspx"    
                            	}
                            ],
                            type: "error"
                        });
                        toastEvent.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleShowEmailNotice : function(component) {
        
        var action  = component.get("c.getEmailLimitStatus");
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var returnValue = response.getReturnValue();
        	if(state === "SUCCESS") {
        	    
        	    //process the response
        	    var processedResponse = JSON.parse(returnValue);
        	    
        	    var maxLimit = processedResponse.singleemail.Max;
        	    var remainingLimit = processedResponse.singleemail.Remaining;
        	    
        	    
        	    var remainingPercent = Math.round((remainingLimit/maxLimit)*100);
;
        	    var usedPercent = 100 - remainingPercent;
        	    
        	    //Show If Enabled From CustomSettings->Presales Config Setting
        	    if(processedResponse.isEnabledInSettings == true){
        	        //Show Toasts Accordingly
            	    if(remainingPercent >=0 && remainingPercent <= processedResponse.singleemail.Threshold){
            		    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            title: "Warning!",
                            message: "You have used "+usedPercent+"% of your daily email limit. Your remaining limit is "+remainingLimit+" mails.",
                            type: "warning"
                        });
                        toastEvent.fire();
            	    }else if(remainingPercent == 0){
            	        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            title: "Error!",
                            message: "You Have Exhausted Your Daily Email Limit!",
                            type: "error"
                        });
                        toastEvent.fire();
            	    }
        	    }
        	}
        });
        $A.enqueueAction(action);
    }
})