({
	doInit : function(component, event, helper) {
		helper.getConfigSettings(component);
	},
	toggle : function(component, event, helper) {
        
        if(component.find("firstButton").get("v.iconName") == 'utility:chevronright'){
            component.find("firstButton").set("v.iconName",'utility:chevrondown');
            document.getElementById('link-list').style.display = 'block';
        }
        else{
            component.find("firstButton").set("v.iconName",'utility:chevronright');
            document.getElementById('link-list').style.display = 'none';
        }
       
    },
    clearaccount : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_clearAccountWithKeyword',"target":'_BLANK'}).fire();
    },
    mdoreset : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_ResetMDOData',"target":'_BLANK'}).fire();
    },  
    setupadobesign : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_Echosigninstruction'}).fire();
        $A.get("e.force:navigateToURL").setParams({"url" : 'https://apttustest-my.sharepoint.com/:w:/g/personal/dbrahmbhatt_conga_com/EY314VhvxztChBBdERzQtZABTsxr7gpUndTycm4Vk1tRQg?e=kfud8A',"target":'_BLANK'}).fire();
    },
     massdeleteactivity : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_DeleteActivities',"target":'_BLANK'}).fire();
    },
    MDOReleaseNotes : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_MDOtier1script'}).fire();
        $A.get("e.force:navigateToURL").setParams({"url" : 'https://apttustest-my.sharepoint.com/:w:/g/personal/dbrahmbhatt_conga_com/EUg7-G_aIvFMmucFgqQss0oBHJ_q2Ay8cfDOjnFbQs7xwQ?e=wrjFt1',"target":'_BLANK'}).fire();
    },
     
    MDODemoScripts : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        $A.get("e.force:navigateToURL").setParams({"url" : 'https://apttustest-my.sharepoint.com/:f:/g/personal/dbrahmbhatt_conga_com/Er_2RwCNP7BAuVnuwPTFyqwBdq1PzrqgSIzTFgT6okBFjw?e=oIlKxM',"target":'_BLANK'}).fire();
    },
    
     MDOCustomVsOOBFeatures : function (component, event, helper) {
        console.log('###createQuote');
        var qId = component.get("v.recordId");
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_MDOCustomVsOOBFeatures'}).fire();
        //$A.get("e.force:navigateToURL").setParams({"url" : 'https://apttustest-my.sharepoint.com/:w:/g/personal/dbrahmbhatt_apttus_com/EajM8n6oOCNEkATASkpvBBEBE97KdlQBne8Z156MrQ0O_w?e=FvzDTx',"target":'_BLANK'}).fire();
         $A.get("e.force:navigateToURL").setParams({"url" : 'https://apttustest-my.sharepoint.com/:x:/g/personal/dbrahmbhatt_conga_com/EdEPJa4vOxpNgEg8dH0Zs94B-tcTdXOU1WieEJ2R9Jfw6g?e=j57NkV',"target":'_BLANK'}).fire();
    },
    intelligentImportSampleDoc : function(component, event, helper){
    	console.log('###intelliegentImportSampleDoc');
        //$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_DownloadAgreementDocVf'}).fire();
        $A.get("e.force:navigateToURL").setParams({"url": 'https://apttustest-my.sharepoint.com/:f:/g/personal/dbrahmbhatt_conga_com/EvMQEEBk0DdMqcFeePTfYWcBCKjsj6a1v4-hz9IjWIIrzg?e=zXmox6',"target":'_BLANK'}).fire();
	},
    updateDateField : function(component, event, helper){
    	console.log('###intelliegentImportSampleDoc');
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_UpdateDateField',"target":'_BLANK'}).fire();
	},
    manageAIIJobs : function(component, event, helper){
    	$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_ManageIDEJobScheduler',"target":'_BLANK'}).fire();
	},
    redirectEcommerce : function(component, event, helper){
    	$A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_RedirectEcommerce',"target":'_BLANK'}).fire();
	},
	deleteDuplicateClauses: function(component, event, helper){
	    $A.get("e.force:navigateToURL").setParams({"url" : '/apex/APTSMD_FixDuplicateClauses',"target":'_BLANK'}).fire();
	},
	releaseDocumentSearch: function(component, event, helper){
	    $A.get("e.force:navigateToURL").setParams({"url" : 'https://release-search.azurewebsites.net/Search.html',"target":'_BLANK'}).fire();
	},
	apttusLabPortal: function(component, event, helper){
	    $A.get("e.force:navigateToURL").setParams({"url" : 'https://apttustest.sharepoint.com/sites/TeamSiteVB-1/SitePages/Welcome-to-The-Age-of-the-Intelligent-Middle-Office.aspx',"target":'_BLANK'}).fire();
	},
	kiraProjectListView: function(component, event, helper){
	    $A.get("e.force:navigateToURL").setParams({"url" : '/apex/APTSMD_AgreementAIMLRedirectVF',"target":'_BLANK'}).fire();
	},
    openMFA: function(component, event, helper){
	    $A.get("e.force:navigateToURL").setParams({"url" : '/apex/APTSMD_UpdateDemoUserDetails',"target":'_BLANK'}).fire();
	},
    congalabapiapps: function(component, event, helper){
        var orgIDPrefix = "00D";
        var congaLabOrgID = orgIDPrefix+ "8Z000001t7Dx"; 
        // this is because trialforce org change hardcoded id in spin org so we concatenate 
        //https://help.salesforce.com/s/articleView?language=en_US&id=000314092&type=1
	    //$A.get("e.force:navigateToURL").setParams({"url" : 'https://congalabadmin.azurewebsites.net/#/Composer?org_id='+congaLabOrgID,"target":'_BLANK'}).fire();
	    $A.get("e.force:navigateToURL").setParams({"url" : 'https://coreapps-rlspreview.azurewebsites.net/#/Composer?org_id='+congaLabOrgID,"target":'_BLANK'}).fire();
	},
    congalabapiappslearn: function(component, event, helper){
        var orgIDPrefix = "00D";
        var congaLabOrgID = orgIDPrefix+ "8Z000001t7Dx"; 
        $A.get("e.force:navigateToURL").setParams({"url" : 'https://congalabadmin.azurewebsites.net/#/Learning?org_id='+congaLabOrgID,"target":'_BLANK'}).fire();
	},
    createProvision: function(component, event, helper){
	    $A.get("e.force:navigateToURL").setParams({"url" : '/apex/APTSMD_CCICreateProvisionMappingV2',"target":'_BLANK'}).fire();
	},
    toggleGoogleDocAction: function(component, event, helper){
        var action = component.get("c.toggleGoogleDoc");
        action.setParams({});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            console.log(response.getReturnValue());
            var response = response.getReturnValue();
        	if (state === "SUCCESS") {
                if(response.isSuccess){
                    helper.getConfigSettings(component);
                	helper.showToast('Success','success', response.message);
                }else{
                    helper.showToast('Error','error', response.message);
                }        		
        	}
        });
        $A.enqueueAction(action);
    }
})