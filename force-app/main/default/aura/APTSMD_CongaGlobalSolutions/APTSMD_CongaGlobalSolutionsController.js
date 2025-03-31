({
    doInit : function(component, event, helper) {
        helper.getPerformanceReportLink(component, 'performanceReportLink');               
        helper.getQbrLink(component, 'qbrLink');               
        helper.getCaseBreakdownLink(component, 'caseBreakdownLink');
	},
    openPerformanceReportLink : function (component, event, helper){
        var performanceReportLink = component.get("v.performanceReportLink");
        window.open(performanceReportLink);
    },
    openQbrLink : function (component, event, helper){
        var qbrLink = component.get("v.qbrLink");
        window.open(qbrLink);
    },
    openCaseBreakdownLink : function (component, event, helper){
        var caseBreakdownLink = component.get("v.caseBreakdownLink");
        window.open(caseBreakdownLink);
    }
})