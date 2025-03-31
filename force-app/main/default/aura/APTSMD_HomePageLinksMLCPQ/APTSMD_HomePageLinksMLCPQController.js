({
	myAction : function(component, event, helper) {
		
	},
    backToContexualPricing : function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_CostProfitAnalysis',"target":'_blank'}).fire();
    },
    gotoRecommender: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_MachineLearningForRecommender',"target":'_blank'}).fire();
        // Go back to previous window
        setTimeout(function(){    
        	window.history.go(-1);
        },5000);        
    },
    gotoPricingIntelligence: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_MachineLearningForPricingIntl',"target":'_blank'}).fire();       
        // Go back to previous window
        setTimeout(function(){    
        	window.history.go(-1);
        },5000);        
    },
    gotoWhiteSpace: function (component, event, helper) {
        $A.get("e.force:navigateToURL").setParams({"url": '/apex/APTSMD_MachineLearningForWhiteSpace',"target":'_blank'}).fire();        
        // Go back to previous window
        setTimeout(function(){    
        	window.history.go(-1);
        },5000);
    },
})