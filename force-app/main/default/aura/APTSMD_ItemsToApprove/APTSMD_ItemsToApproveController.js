({
	doInit : function(component, event, helper) {
        var parts = window.location.toString().split('/');
        var lastSegment = parts.pop() || parts.pop();
        
        helper.showOrgExpirationDetail(component);
        helper.showpackageLicenseExpirationDetail(component);
        helper.handleShowEmailNotice(component);
        helper.getAllApprovalRequests(component,lastSegment);
        helper.updateMFADemoUsers(component);//added by vivek as on 29th Jan 2022 to auto assign licenses to MFA demo users        
	},
    openActionPage : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var action_str = ctarget.dataset.action;
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/Apttus_Approval__ApprovalSummaryLaunch?id='+id_str+'&pageMode='+action_str}).fire();
    },
    openRecord : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        $A.get("e.force:navigateToURL").setParams({"url": '/'+id_str}).fire();
    },
    hideShowSection : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var x = document.getElementsByTagName("section");
         
        for(var i =0 ; i<x.length;i++){            
            if(x[i].title == id_str){                
                $A.util.toggleClass(x[i], 'slds-is-open');
            }
        }     		
        
        var icons1 = component.find("ic11");
        for(var i =0 ; i<icons1.length;i++){            
            if(icons1[i].get("v.title") == id_str){                
                $A.util.toggleClass(icons1[i], 'displaynone');
            }
        }
        var icons2 = component.find("ic22");
        for(var i =0 ; i<icons2.length;i++){            
            if(icons2[i].get("v.title") == id_str){                
                $A.util.toggleClass(icons2[i], 'displaynone');
            }
        }
    }
})