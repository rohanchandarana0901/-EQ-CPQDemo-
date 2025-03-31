/*****
**  Purpose : we are using this class to schedule / Abort jobs for Apttus Intelligent Import Feature
*   Date : 22 January 2019
*   Author : Chetan Meghnathi
*   Methods : scheduleJobs,abortAllJobs
***/
public class APTSMD_ManageIDEJobSchedulerController {
    public Integer numberOfMinutes{get;set;}
    public string allJobs{get;set;}
    
    /*
        This constructor will intialize the default value of interval
    */
    public APTSMD_ManageIDEJobSchedulerController(){
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesSettings = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        System.debug(presalesSettings);
        
        if(presalesSettings != Null && presalesSettings.APTSMD_Schedule_Time_for_AII_Minutes__c!=null && presalesSettings.APTSMD_Schedule_Time_for_AII_Minutes__c>0){
            numberOfMinutes = Integer.valueOf(presalesSettings.APTSMD_Schedule_Time_for_AII_Minutes__c);
        }
        else{
            numberOfMinutes = 2;
        }
        
        List<CronTrigger> cronList = getallJobs();
        allJobs = cronList.isEmpty() ? '[]' : JSON.serialize(cronList);
    }   
    
    public static List<CronTrigger> getallJobs(){
        return [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType,StartTime,EndTime,
                                    NextFireTime,PreviousFireTime,State,TimesTriggered,TimeZoneSidKey
                                    FROM CronTrigger 
                                    WHERE CronJobDetail.Name like 'IDEJobScheduler%'];
    }
    /*
        This will abort the old scheduled jobs and schedule new jobs as per time interval provided
    */
    @RemoteAction
    public static List<CronTrigger> scheduleJobs(String interval){
        abortAllJobs();
        Integer numberOfMinutes = Integer.valueOf(interval);
        for(Integer i=0;i<=59;i+=numberOfMinutes){
            Apttus.IDEJobScheduler scheduler = new Apttus.IDEJobScheduler();
        	String cronvalue = '0 '+i+' * * * ?';
        	System.schedule ('IDEJobScheduler '+i, cronvalue, scheduler);    
        }
        
        APTSMD_Apttus_PreSales_Config_Settings2__c presalesSettings = APTSMD_Apttus_PreSales_Config_Settings2__c.getOrgDefaults();
        presalesSettings.APTSMD_Schedule_Time_for_AII_Minutes__c = numberOfMinutes;
        update presalesSettings;
        
        return getallJobs();
    }
    /*
        This will abort the old scheduled jobs.
    */
    @RemoteAction
    public static List<CronTrigger> abortAllJobs(){
        for(CronTrigger ct : [SELECT Id 
                                FROM CronTrigger 
                                WHERE CronJobDetail.Name like 'IDEJobScheduler%']){
            try{
                system.abortJob(ct.id);
            }
            catch (exception e) {}
        }
        return getallJobs();
    }
}