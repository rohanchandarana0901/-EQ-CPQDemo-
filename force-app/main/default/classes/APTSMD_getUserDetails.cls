/*************************************************************
@Name: APTS_getUserDetails
@Authors: Apttus
@CreateDate:14/03/2018
@ModifiedDate: 8 Oct 2018
@purpose: This class is use to pass required User details to MAX.
******************************************************************/

Public class APTSMD_getUserDetails{
    public boolean flag{get;set;}
    
    Private String sJSONRequest {get; set;}
    Public APTSMD_UserDetails oUserDetail {get;set;}

    Public APTSMD_getUserDetails() {
        flag=false;
        this.preparRequest(); 
        this.invoke();
    }
    
    public PageReference APTS_Poller() {
        this.preparRequest(); 
        this.invoke();
        return null;
    }
    
    /***************************************************************
    Name: preparRequest
    purpose: This method is use to prepare JSON request body
    ****************************************************************/
    
    Public void preparRequest() {
        String baseURL = '';
        oUserDetail = new APTSMD_UserDetails();
        oUserDetail.Email = UserInfo.getUserEmail();
        oUserDetail.UserFullName = UserInfo.getName();
        oUserDetail.UserLanguage = UserInfo.getLanguage();
        oUserDetail.UserLocale = UserInfo.getLocale();
        oUserDetail.UserName = UserInfo.getUserName();
        oUserDetail.OrgID = UserInfo.getOrganizationId();
        oUserDetail.OrgName = UserInfo.getOrganizationName();
        oUserDetail.SessionId = UserInfo.getSessionId();
        
        /********************************************************************************************************************
        
            Getting instace url or base url
        
            We need to get the instance url here or the base url.
            To make it dynamic, there is a new method available from salesforce which returns the base url. Details below:
            
            URL.getOrgDomainUrl().toExternalForm()
            
            Now, the above method is part of Winter'19 release and it will release on Oct 13 2018 in production instances.
            So for now, we need to make it static in the code here. Thus setting the sandbox url as hardcoded for now but when moving this
            into production, we need to change this class to add the production instance url.
            
            NOTE: 
            
            URL.getSalesforceBaseUrl().toExternalForm()
            
            Above method won't work because it would return instance url with visualforce.com as the class is being called from a VF page.
            For eg: it may return https://na35.visual.force.com or https://ibmsf--gaiaint--c.visualforce.com
            Then we may have to prase it as a string and replace with instance, but it would add complications as the above urls are different
            and to write a logic that returns the excat instace url won't work for all SF orgs. We also tried below method, but visual.froce was change to visuaforce and it broke.
         
            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            system.debug('baseURL :'+baseURL);
            if(baseURL.toLowerCase().indexOf('visual.force') >-1){
                baseURL = baseURL.replace('visualforce', 'my.salesforce');
            }
            if(baseURL.toLowerCase().indexOf('--c')>-1){
                baseURL = baseURL.replace('--c', '');
            }
        
            So, it would be feasible to use the given method at top instead of hardcoding from Oct 13th 2018
            
        *******************************************************************************************************************/
        
        //change this to org's instance url, for IBM Sandbox, it's set as below. As mentioned in the above comment, it can be made dynamic by adding below statement after Winter'19 release:
        baseURL = URL.getOrgDomainUrl().toExternalForm();
        
        for (Apttus__ComplySystemProperties__c  setting : Apttus__ComplySystemProperties__c.getAll().values()){
            baseURL = setting.Apttus__InstanceUrl__c;
        } 
        
        //baseURL = 'https://botdev.my.salesforce.com';
        system.debug('#####baseURL After:'+baseURL);
        
        oUserDetail.BaseURL = baseURL;
        TimeZone userTimeZone = UserInfo.getTimeZone();
        oUserDetail.UserTimeZone = String.valueOf(userTimeZone);
        oUserDetail.UserId = UserInfo.getuserId();
        
        ConnectApi.Photo userPhotos = ConnectApi.UserProfiles.getPhoto(null, oUserDetail.UserId);
        oUserDetail.ProfilePhoto = userPhotos.smallPhotoUrl;
        
        oUserDetail.PlaceHolder  = Label.APTSMD_Domain;
        this.sJSONRequest = JSON.serialize(oUserDetail , true);
        system.debug('############# this.sJSONRequest'+this.sJSONRequest);
    }
    
    /***************************************************************
    Name: invoke
    purpose: This method is use to set required parameters to send 
             request to MAX end point.
    ****************************************************************/
    
    Public void invoke() {
        HttpRequest oHTTPRequest =  new HttpRequest();
        HttpResponse oHTTPResponse =  new HttpResponse();
        Http oHTTPHandler =  new Http();
        try {
            oHTTPRequest.setEndpoint(Label.APTSMD_MAX_End_Point + '/sendSfdcData');//oHTTPRequest.setEndpoint(Label.APTSMD_MAX_End_Point);
            oHTTPRequest.setBody(this.sJSONRequest);
            oHTTPRequest.setTimeout(Integer.valueOf(Label.APTSMD_Max_Time));
            oHTTPRequest.setMethod(Label.APTSMD_HTTP_Method);
            oHTTPRequest.setHeader(Label.APTSMD_HTTP_Header_Key,Label.APTSMD_HTTP_Header_Value);
System.debug(oHTTPRequest);
            oHTTPResponse = oHTTPHandler.send(oHTTPRequest);
            String JSONResponse = (oHTTPResponse.getBody());
            system.debug('########### JSONResponse'+JSONResponse);
            if(oHTTPResponse.getStatusCode() == 200){
                flag = true;  
            }else{
                flag = false;
            }
            //system.debug('########### JSONResponse'+);
        } catch (CalloutException e) {
            system.debug('############# CallOutException '+e.getMessage());
            system.debug('############# getStackTraceString '+e.getStackTraceString());
            
        } catch (JSONException e) { 
            system.debug('############# JSONException '+e.getMessage());
            system.debug('############# getStackTraceString '+e.getStackTraceString());
        } catch(Exception e) {
            system.debug('############# Exception '+e.getMessage());
            system.debug('############# getStackTraceString '+e.getStackTraceString());
        }
        
    }

}