public class APTSMD_DeleteActivitiesController {
    
   
    public String getCountTask2(){
        List<Task> tasks = [Select Subject 
                        from Task 
                        where IsRecurrence=false AND (Subject like '%Get Internal Signatures%' 
                        OR Subject like '%Get External Signatures%' 
                        OR Subject like '%Scan & Attach Agreement%' 
                        OR Subject like '%Weekly Checkpoint%')];
        return String.valueOf(tasks.size());
        
    }
    
    public String getCountEvent2(){
         List<Event> events = [Select Subject 
                        from Event 
                        where Subject 
                        like '%Get Internal Signatures%' 
                        OR Subject like '%Get External Signatures%' 
                        OR Subject like '%Scan & Attach Agreement%' 
                        OR Subject like '%Weekly Checkpoint%'];
        return String.valueOf(events.size());
    }
    
   
    @remoteAction
    public static Integer massDeleteActivities(){
        Boolean runAgain = false;
        //IsRecurrence=false added by vivek to resolve apex trigger error on bulk deletion of reccuring task - dt. 7 april 2022
        List<Task> tasks = [Select Subject 
                        from Task 
                        where IsRecurrence=false AND (Subject like '%Get Internal Signatures%' 
                        OR Subject like '%Get External Signatures%' 
                        OR Subject like '%Scan & Attach Agreement%' 
                        OR Subject like '%Weekly Checkpoint%' )
                        LIMIT 5000];
        if(!tasks.isEmpty()){
            if(tasks.size() == 5000)
                runAgain=true;
                
            delete tasks;
        }
        List<Event> events = [Select Subject 
                        from Event 
                        where Subject 
                        like '%Get Internal Signatures%' 
                        OR Subject like '%Get External Signatures%' 
                        OR Subject like '%Scan & Attach Agreement%' 
                        OR Subject like '%Weekly Checkpoint%'
                        LIMIT 5000];
        if(!events.isEmpty()){
            if(events.size() == 5000)
                runAgain=true;
            delete events;
        }
        
       
        
        return ( runAgain ? 1 : 0);
        
    }
    
    public static Boolean isSalesForce1orLE(){
         
        if(ApexPages.currentPage().getParameters().get('sfdcIFrameHost') != null ||
           ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin') != null ||
           ApexPages.currentPage().getParameters().get('isdtp') == 'p1') {      
            return true;
        }
        else {      
            return false;
        }           
    }
    
    public pagereference cancel() {
        
        PageReference pageRef;
        if(isSalesForce1orLE())
            pageRef = new PageReference('/lightning/page/home');
        else
            pageRef = new PageReference('/');  
            
            
        return pageRef;
    }
    
}