({
    showToast : function(title, type, message){
        // Display error message using a toast
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });        
        toastEvent.fire();
    },
    showLoading : function(component, loadingMessage){
        // Set Loader and message
        component.set("v.isLoading", true);
        component.set("v.loadingMessage", (loadingMessage || 'Loading! Please wait...'));
    },
    hideLoading : function(component){
        // Hide Loader
        component.set("v.isLoading", false);
    },
    refreshView : function(){
        // refersh the Record Page 
        $A.get('e.force:refreshView').fire();
    },
    generateConsentForm: function(component, event, helper){
        var isLoading = component.get("v.isLoading");
        var fullName = component.get("v.fullName");
        var companyName = component.get("v.companyName");
        var address = component.get("v.address");
        var phoneNumber = component.get("v.phoneNumber");
        var emailAddress = component.get("v.emailAddress");
        var serviceStartDate = component.get("v.serviceStartDate");
        var serviceEndDate = component.get("v.serviceEndDate");
        var consentStatement = component.get("v.consentStatement");
        console.log(fullName);
        if(!consentStatement){
            helper.showToast('Error','error', 'Please accept the terms and conditions first to proceed further!');
            return;
        }
        helper.showLoading(component, 'Generating Document...');
        var action = component.get("c.processConsentForm");
        action.setParams({
            fullName: fullName,
            companyName: companyName,
            address: address,
            phoneNumber: phoneNumber,
            emailAddress: emailAddress,
            serviceStartDate: serviceStartDate,
            serviceEndDate: serviceEndDate,
            consentStatement: consentStatement
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            var responseValue = response.getReturnValue();
            console.log('responseValue', responseValue);
            helper.showLoading(component);
            if (state === "SUCCESS") {                
                if(responseValue.isSuccess){
                    if(responseValue.data && responseValue.data.correlationId){
                        //$A.enqueueAction(component.get('c.checkDocGenStatus').setParams({component: component, event: event, helper: helper, correlationId: responseValue.data.correlationId}));
                        helper.checkDocGenStatus(component, event, helper, responseValue.data.correlationId);
                    }
                    helper.showToast('Success','success', responseValue.message);
                }else{
                    helper.showToast('Error','error', responseValue.message);
                }
            } else {
                helper.showToast('Error','error', 'Something went wrong! Please try again later.');
            }
        });

        $A.enqueueAction(action);
    },
    checkDocGenStatus: function(component, event, helper, correlationId){
        if(correlationId){
            helper.showLoading(component, 'Checking Document Status...');
            var action = component.get("c.checkDocGenProcessStatus");
            action.setParams({
                correlationId: correlationId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var responseValue = response.getReturnValue();
                console.log('responseValue', responseValue);
                helper.hideLoading(component);
                if (state === "SUCCESS") {
                    if(responseValue.isSuccess){
                        if(responseValue.data && responseValue.data.correlationId){
                            if(responseValue.data.message == 'Pending'){
                                helper.checkDocGenStatus(component, event, helper, responseValue.data.correlationId);
                            }else if(responseValue.data.message == 'Completed'){
                                helper.sendDocumentForSign(component, event, helper, correlationId);
                            }
                        }
                        //helper.showToast('Success','success', responseValue.message);
                    }else{
                        helper.showToast('Error','error', responseValue.message);
                    }
                } else {
                    helper.showToast('Error','error', 'Something went wrong! Please try again later.');
                }
            });

            $A.enqueueAction(action);
        }
    },
    sendDocumentForSign: function(component, event, helper, correlationId){
        if(correlationId){
            helper.showLoading(component, 'Sending Document For Signature...');
            var fullName = component.get("v.fullName");
            var companyName = component.get("v.companyName");
            var emailAddress = component.get("v.emailAddress");
            var action = component.get("c.sendDocumentForCongaSign");
            action.setParams({
                correlationId: correlationId,
                fullName: fullName,
                companyName: companyName,
                emailAddress: emailAddress
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var responseValue = response.getReturnValue();
                console.log('responseValue', responseValue);
                helper.hideLoading(component);
                if (state === "SUCCESS") {
                    if(responseValue.isSuccess){
                        helper.showToast('Success','success', responseValue.message);
                        if(responseValue.data.id){
                            helper.getSigningURL(component, event, helper, responseValue.data.id)
                        }
                    }else{
                        helper.showToast('Error','error', responseValue.message);
                    }
                } else {
                    helper.showToast('Error','error', 'Something went wrong! Please try again later.');
                }
            });

            $A.enqueueAction(action);
        }
    },
    getSigningURL: function(component, event, helper, packageId){
        if(packageId){
            helper.showLoading(component, 'Getting Signing URL...');
            var action = component.get("c.getSigningURL");
            action.setParams({
                packageId: packageId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var responseValue = response.getReturnValue();
                console.log('responseValue', responseValue);
                helper.hideLoading(component);
                if (state === "SUCCESS") {
                    if(responseValue.isSuccess){
                        helper.showToast('Success','success', responseValue.message);
                        if(responseValue.data){
                            window.open(responseValue.data.slice(1,-1),'_blank');
                            helper.refreshView();
                        }
                    }else{
                        helper.showToast('Error','error', responseValue.message);
                    }
                } else {
                    helper.showToast('Error','error', 'Something went wrong! Please try again later.');
                }
            });

            $A.enqueueAction(action);
        }
    }
})