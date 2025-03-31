/**
 * Company      : Apttus Inc.
 * Description  : Custom Setting Comparator class
 * History      :
 * [31.Jul.2018] Devangi Mehta    : Created Class 
 * 31.dec.2018 Jeetu Agrawal : Migrate
 */ 

public with sharing Class APTSMD_CustomSettingComparatorCtrl
{     
    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';
    
    public APTSMD_CustomSettingComparatorCtrl(){
    
    }
    
    
    /**
   * Calls the login method and sends back the SessionId and Server Url for both the Orgs
   * @param Org1UN and Org2UN are the Usernames of the Orgs
   * @param Org1pwd and Org2pwd are the passwords of the Orgs
   * @param selectedOrg1Type and selectedOrg2Type are the types of org i.e. production or sandbox
   * @return the list of sessionIds and Server Urls of both the Orgs
   */ 
    @Remoteaction
    public static List<String> performLogin(String Org1UN, String Org1pwd,String selectedOrg1Type,String Org2UN, String Org2pwd,String selectedOrg2Type) {
        String sessionIdOfOrg1 = '';
        String serverURLOfOrgOfOrg1 = '';
        String sessionIdOfOrg2 = '';
        String serverURLOfOrgOfOrg2 = '';
       
        //Org1 Login
        List<String> sessionParameterOfOrg1 = login(Org1UN,Org1pwd,selectedOrg1Type);
        sessionIdOfOrg1 = sessionParameterOfOrg1[0] ;
        if(!sessionParameterOfOrg1.isEmpty()){
            URL urlTypeOfOrg1 = new URL(sessionParameterOfOrg1[1]);
            serverURLOfOrgOfOrg1  = urlTypeOfOrg1.getProtocol() + '://' + urlTypeOfOrg1.getHost();
        }
        
        
        //Org2 Login
        List<String> sessionParameterOfOrg2 = login(Org2UN,Org2pwd,selectedOrg2Type);
        sessionIdOfOrg2 = sessionParameterOfOrg2[0] ;
        if(!sessionParameterOfOrg2.isEmpty()){
            URL urlTypeOfOrg2 = new URL(sessionParameterOfOrg2[1]);
            serverURLOfOrgOfOrg2  = urlTypeOfOrg2.getProtocol() + '://' + urlTypeOfOrg2.getHost();
        }
        return new List<String>{sessionIdOfOrg1,serverURLOfOrgOfOrg1,sessionIdOfOrg2,serverURLOfOrgOfOrg2};
        
    }
    
     
     /**
   * Performs login to for both the orgs
   * @param username is Org username
   * @param password is password of the Org
   * @param selectedOrgType is the type of org i.e. production or sandbox
   * @return the list of sessionIds and Server Urls of both the Orgs
   */ 
     public static List<String> login(String username, String password, String selectedOrgType)
    {
        string endpointdomain = '';
        if(selectedOrgType == 'Production') {
            endpointdomain = 'login';
        } else if(selectedOrgType == 'Sandbox') {
            endpointdomain = 'test';    
        }
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');   
        request.setTimeout(60000);
        request.setEndpoint('https://'+ endpointdomain +'.salesforce.com/services/Soap/u/29.0');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
        request.setHeader('SOAPAction', '""');
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +username+ '</username><password>' + password + '</password></login></Body></Envelope>');        
        HttpResponse response =  new Http().send(request);
        if(response.getStatusCode() != 200)
        {
            Dom.Document responseDocument = response.getBodyDocument();
            Dom.Xmlnode rootElement = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElement = rootElement.getChildElement('Body', NS_SOAP); // soapenv:Body 
            Dom.Xmlnode faultElement = bodyElement.getChildElement('Fault', NS_SOAP); // soapenv:Fault
            Dom.Xmlnode faultStringElement = faultElement.getChildElement('faultstring', null); // faultstring          
        }
        Dom.Document responseDocument = response.getBodyDocument();
        Dom.Xmlnode rootElement = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElement = rootElement.getChildElement('Body', NS_SOAP); // soapenv:Body 
        Dom.Xmlnode loginResponseElement = bodyElement.getChildElement('loginResponse', NS_SF); // loginResponse
        Dom.Xmlnode resultElement = loginResponseElement.getChildElement('result', NS_SF); // result
        Dom.Xmlnode sessionIdElement = resultElement.getChildElement('sessionId', NS_SF); // sessionId
        Dom.Xmlnode serverURLElement = resultElement.getChildElement('serverUrl', NS_SF); // sessionId
        return new List<String>{sessionIdElement.getText(), serverURLElement.getText()};
    }
    
    
    /**
   * Queries custom setting objects for the Orgs and also creates remote site endpoint in the Org if not present
   * @param OrgsessionParam is the list of sessionId and ServerURLs of both the Orgs
   * @return the combined list custom setting objects of both the Orgs
   */ 
    @Remoteaction 
    public static List<csSobjectWrapper> makecalloutsOrg(List<String> OrgsessionParam){
       List<csSobjectWrapper> Org1sobjectsList = new List<csSobjectWrapper>();
       List<csSobjectWrapper> Org2sobjectsList = new List<csSobjectWrapper>();
       List<csSobjectWrapper> ListOfSobjstoReturn = new List<csSobjectWrapper>();
       Boolean doesRemoteSite1Exists = false;
       Boolean doesRemoteSite2Exists = false;
       
       //Get remotesite endpoints to compare with the endpoints of orgs to be compared
       String currentOrgUrl = System.URL.getSalesforceBaseURL().toExternalForm();
       Set<String> listOfRemoteSiteEndpts = checkIfRemoteSiteExists();
       
       if(!listOfRemoteSiteEndpts.isEmpty() && !listOfRemoteSiteEndpts.contains(currentOrgUrl)){
           APTSMD_createRemoteSiteEndpoint newRemoteSite = new APTSMD_createRemoteSiteEndpoint();
           newRemoteSite.createRemoteSiteSetting(currentOrgUrl);
       }
       
       if(!listOfRemoteSiteEndpts.isEmpty() && listOfRemoteSiteEndpts.contains(OrgsessionParam[1])){
           doesRemoteSite1Exists = true;
       }
       if(!listOfRemoteSiteEndpts.isEmpty() && listOfRemoteSiteEndpts.contains(OrgsessionParam[3])){
           doesRemoteSite2Exists = true;
       }
       
       //Org1
       Org1sobjectsList = queryAllsobjectsofRemoteOrg(OrgsessionParam[0], OrgsessionParam[1],doesRemoteSite1Exists);
       
       //Org2
       Org2sobjectsList = queryAllsobjectsofRemoteOrg(OrgsessionParam[2], OrgsessionParam[3],doesRemoteSite2Exists);
    
        if(!Org1sobjectsList.isEmpty() && !Org2sobjectsList.isEmpty()){
            for(csSobjectWrapper cs1wrap : Org1sobjectsList){
                ListOfSobjstoReturn.add(cs1wrap);
            }
            for(csSobjectWrapper cs2wrap : Org2sobjectsList){
                ListOfSobjstoReturn.add(cs2wrap);
            }
        }
   
        return ListOfSobjstoReturn;
    }
    
    
     /**
   * Queries data for the particular custom setting object selected by the user
   * @param OrgsessionParams is the list of sessionId and ServerURLs of both the Orgs
   * @param selectedSobjcsOrg is the custom setting object selected by user
   * @return the combined list of custom setting records of both org
   */ 
    @Remoteaction
    public static List<List<csfieldsWrapper>> retrievesobjData(List<String> OrgsessionParams,String selectedSobjcsOrg){
        List<List<csfieldsWrapper>> listOfOrgDataToReturn = new List<List<csfieldsWrapper>>();
        csSobjectWrapper selSobjcsOrg = (csSobjectWrapper)JSON.deserialize(selectedSobjcsOrg, csSobjectWrapper.class); 
        
        //Org1
        Map<List<csfieldsWrapper>,String> Org1sObjlabelvsQueryMap = querycsMetadataofRemoteOrg(OrgsessionParams[0], OrgsessionParams[1],selSobjcsOrg.apiname);
        List<csfieldsWrapper> listOfOrg1Data = new List<csfieldsWrapper>();
        if(!Org1sObjlabelvsQueryMap.isEmpty()){
            listOfOrg1Data  = httpcall(Org1sObjlabelvsQueryMap, OrgsessionParams[0], OrgsessionParams[1]);
        }
        

        //Org2
        Map<List<csfieldsWrapper>,String> Org2sObjlabelvsQueryMap = querycsMetadataofRemoteOrg(OrgsessionParams[2], OrgsessionParams[3],selSobjcsOrg.apiname);
        List<csfieldsWrapper> listOfOrg2Data = new List<csfieldsWrapper>();
        if(!Org2sObjlabelvsQueryMap.isEmpty()){
            listOfOrg2Data  = httpcall(Org2sObjlabelvsQueryMap, OrgsessionParams[2], OrgsessionParams[3]);
        }

		if(!listOfOrg1Data.isEmpty() || !listOfOrg2Data.isEmpty()){
		    if(listOfOrg1Data.size() < listOfOrg2Data.size()){
		        for(Integer i=0 ;i< listOfOrg1Data.size();i++){
                      for(Integer j=0 ;j< listOfOrg2Data.size();j++){
                          //This checks for the same value of each field
                          if(listOfOrg1Data[i].fieldValue == listOfOrg2Data[j].fieldValue && listOfOrg1Data[i].fieldapiname == listOfOrg2Data[j].fieldapiname){
                              listOfOrg1Data[i].isValuesame = 'Yes';
                              listOfOrg2Data[j].isValuesame = 'Yes';
                          }
                      }
                }
		    }else{
		        for(Integer i=0 ;i< listOfOrg2Data.size();i++){
                      for(Integer j=0 ;j< listOfOrg1Data.size();j++){
                          //This checks for the same value of each field
                          if(listOfOrg2Data[i].fieldValue == listOfOrg1Data[j].fieldValue && listOfOrg2Data[i].fieldapiname == listOfOrg1Data[j].fieldapiname){
                              listOfOrg2Data[i].isValuesame = 'Yes';
                              listOfOrg1Data[j].isValuesame = 'Yes';
                          }
                      }
                }
		    }
    		
             listOfOrgDataToReturn.add(listOfOrg1Data);
             listOfOrgDataToReturn.add(listOfOrg2Data);
             
		}
        return listOfOrgDataToReturn;
    }
    
    
    /**
   * REST API call to fetch data for the particular custom setting object selected by the user
   * @param queryvsfieldsWrapMap is the Map of queryString vs custom setting fields wrapper object and others are sessionId and ServerURL
   * @param sessionId and ServerURL of the Org
   * @return the queried data in the List of custom setting fields wrapper
   */ 
    public static List<csfieldsWrapper> httpcall(Map<List<csfieldsWrapper>,String> queryvsfieldsWrapMap,String sessionId, String serverURLOfOrg) {
        List<String> queryList = queryvsfieldsWrapMap.values();
        List<csfieldsWrapper> csRecordValueList = new List<csfieldsWrapper>();
        List<csfieldsWrapper> receivedcsQueryVsfieldsWrapList = new List<csfieldsWrapper>();
        for(List<csfieldsWrapper> csfieldwrapValue : queryvsfieldsWrapMap.keySet()){
            receivedcsQueryVsfieldsWrapList = csfieldwrapValue;
        }
        String cusObjId;
        for(String query : queryList) {
            String updatedQuery = query.replaceall(' ','+');
            String endpoint = serverURLOfOrg + '/services/data/v39.0/query/?q='+updatedQuery;
            HttpRequest request = new HttpRequest(); 
            request.setHeader('Authorization', 'Bearer ' + sessionId); 
            request.setHeader('Content-Type', 'application/json'); 
            request.setEndpoint(endpoint); 
            request.setMethod('GET'); 
            Http httpCall = new Http(); 
            HttpResponse response = httpCall.send(request);            
            if(response.getStatusCode() == 200){
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> csRecordsList = (List<Object>)results.get('records');
                for(Object obj : csRecordsList){
                    if(obj != Null){
                        Map<String,Object> csRecObj = (Map<String,Object>)obj;
                        for(String csRecfieldValue : csRecObj.keyset()){
                            if(csRecfieldValue != 'attributes'){
                                csRecordValueList.add(new csfieldsWrapper(null,csRecfieldValue,null,csRecObj.get(csRecfieldValue),''));
                            }
                        }
                    }
                }
            }
            
      }
      if(!csRecordValueList.isEmpty() || !receivedcsQueryVsfieldsWrapList.isEmpty()){
          for(csfieldsWrapper csfield : csRecordValueList){
              for(csfieldsWrapper csqueryvsfieldsval : receivedcsQueryVsfieldsWrapList){
                  if(csfield.fieldapiname == csqueryvsfieldsval.fieldapiname){
                      csfield.sobjName = csqueryvsfieldsval.sobjName;
                      csfield.fieldlabel = csqueryvsfieldsval.fieldlabel;
                  }
              }
          }
      }
      return csRecordValueList;
    }
    
    
    /**
   * REST API call to fetch all custom setting objects for both the Orgs
   * @param doesRemoteSiteExists is the flag to check whether the remote site endpoint for that Org exists in the current org or not
   * @return the List of custom setting objects
   */ 
    public static List<csSobjectWrapper> queryAllsobjectsofRemoteOrg(String sessionId, String serverURLOfOrg,Boolean doesRemoteSiteExists) {
        List<csSobjectWrapper> cswrapperList = new List<csSobjectWrapper>();
        //Checks if remote site endpoint exists or not,if not then creates a new one
        if(!doesRemoteSiteExists){
            APTSMD_createRemoteSiteEndpoint newRemoteSite = new APTSMD_createRemoteSiteEndpoint();
            newRemoteSite.createRemoteSiteSetting(serverURLOfOrg);
        }  
        String endpoint = serverURLOfOrg + '/services/data/v43.0/sobjects';
        HttpRequest request = new HttpRequest(); 
        request.setHeader('Authorization', 'Bearer ' + sessionId); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setEndpoint(endpoint); 
        request.setMethod('GET'); 
        Http httpCall = new Http(); 
        HttpResponse response = httpCall.send(request);            
        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> sobjectList = (List<Object>)results.get('sobjects');
            cswrapperList = new List<csSobjectWrapper>();
            for(Object obj : sobjectList) {
                Map<String,Object> mp_StrObj = (Map<String,Object>)obj;
                if(Boolean.valueOf(mp_StrObj.get('customSetting'))) {
                    cswrapperList.add(new csSobjectWrapper(mp_StrObj.get('name').toString(),mp_StrObj.get('label').toString(),Boolean.valueOf(mp_StrObj.get('customSetting')),Boolean.valueOf(mp_StrObj.get('custom'))));
                }
            }
            return cswrapperList;
        } else {
            return cswrapperList;
        }
        
    }
    
    
    /**
   * REST API call to fetch metadata of selected custom setting
   * @param csObjName is the selected custom setting object
   * @return the Map of queryString vs the custom setting fields wrapper containing fieldname and label
   */ 
    public static Map<List<csfieldsWrapper>,String> querycsMetadataofRemoteOrg(String sessionId, String serverURLOfOrg,String csObjName) {
        List<csfieldsWrapper> csfieldsWrapperList = new List<csfieldsWrapper>();
        Map<List<csfieldsWrapper>,String> QueryVsfieldlabelMap = new Map<List<csfieldsWrapper>,String>();
        
        String selects = '';
        String endpoint = serverURLOfOrg + '/services/data/v43.0/sobjects/'+csObjName+'/describe' ;
        HttpRequest request = new HttpRequest(); 
        request.setHeader('Authorization', 'Bearer ' + sessionId); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setEndpoint(endpoint); 
        request.setMethod('GET'); 
        Http httpCall = new Http(); 
        HttpResponse response = httpCall.send(request);            
        if(response.getStatusCode() == 200){
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> fieldsList = (List<Object>)results.get('fields');
            List<string> selectFields = new List<string>();
            for(Object eachfield : fieldsList)
            {
                Map<String,Object> csfieldObj = (Map<String,Object>)eachfield;
                if(csfieldObj != Null && (Boolean.valueOf(csfieldObj.get('custom')) || csfieldObj.get('name').toString() == 'Name' || csfieldObj.get('name').toString() == 'Id')){
                    selectFields.add(csfieldObj.get('name').toString());
                    csfieldsWrapperList.add(new csfieldsWrapper(csObjName,csfieldObj.get('name').toString(),csfieldObj.get('label').toString(),null,''));
                }
            }
            
            if (!selectFields.isEmpty()){
                for (string s:selectFields){
                    selects += s + ',';
                }
                if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
                 
            }
            
            QueryVsfieldlabelMap.put(csfieldsWrapperList,'SELECT ' + selects + ' FROM ' + csObjName);
            
            return QueryVsfieldlabelMap;
        }else{
            return QueryVsfieldlabelMap;
        }
        
        
    }
    
    
    //custom settings sobjects wrapper
    public class csSobjectWrapper{
        public String apiname{get;set;}
        public String label{get;set;}
        public Boolean customSetting {get;set;}
        public Boolean custom {get;set;}
        
        public csSobjectWrapper(String apiname,String label, Boolean customSetting,Boolean custom){
            this.apiname = apiname;
            this.label = label;
            this.customSetting = customSetting;
            this.custom = custom;
        }
    }
    
    //custom settings fields wrapper
    public class csfieldsWrapper{
        public String sobjName{get;set;}
        public String fieldapiname{get;set;}
        public String fieldlabel{get;set;}
        public Object fieldValue{get;set;}
        public String isValuesame {get;set;}
        
        public csfieldsWrapper(String sobjName,String fieldapiname,String fieldlabel, Object fieldValue,String isValuesame){
            this.sobjName = sobjName;
            this.fieldapiname = fieldapiname;
            this.fieldlabel = fieldlabel;
            this.fieldValue = fieldValue;
            this.isValuesame = '';
        }
    }
    
    
    //This method queries the remote site settings of the org where this apex class exists using tooling API
    /**
   * REST API call to fetch remote site settings of the currentOrg where the ctrl exists
   * @return the List of RemoteSite Settings
   */ 
    public static Set<String> checkIfRemoteSiteExists()
    {
        
        //Logic to form the endpoint for querying the remote site
        // String urlInstance = String.valueof(System.URL.getSalesforceBaseURL()).replace('Url:[delegate=','').replace(']','');
        // String[] instance = urlInstance.split('\\.');
        // String domainName = instance[0].replace('--c','');
        
        String instance;
        String instanceUrl;
        List<String> parts = System.URL.getSalesforceBaseUrl().getHost().split('\\.');
        if (parts.size() == 3) instance = parts[0].replace('--c','')+ '.' + 'my';
        else if (parts.size() == 5)  {
            if(parts[0] == 'c') {
                instance = parts[1];
            } else {
                instance = parts[0].substringBefore('--c') + '.' + 'my';
            }
        }
        else if (parts.size() == 4) instance = parts[0]+ '.' +parts[1];
        else instance = null;
        instanceUrl= 'https://' + instance + '.salesforce.com';
        
        Set<String> endPointList = new Set<String>();
        String endpoint = instanceUrl +'/services/data/v43.0/tooling/query/?q=SELECT+SiteName,EndpointUrl+FROM+RemoteProxy';
        HttpRequest request = new HttpRequest(); 
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); 
        request.setHeader('Content-Type', 'application/json'); 
        request.setEndpoint(endpoint); 
        request.setMethod('GET'); 
        Http httpCall = new Http(); 
        HttpResponse response = httpCall.send(request);            
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> remoteSiteList = (List<Object>)results.get('records');
        for(Object obj : remoteSiteList)
        {
            Map<String,Object> remoteSiteobj = (Map<String,Object>)obj;
            for(String remoteEndpoint : remoteSiteobj.keyset()){
                if(remoteEndpoint == 'EndpointUrl'){
                    endPointList.add(remoteSiteobj.get(remoteEndpoint).toString());
                }
            }
        }
        return endPointList;
    }
}