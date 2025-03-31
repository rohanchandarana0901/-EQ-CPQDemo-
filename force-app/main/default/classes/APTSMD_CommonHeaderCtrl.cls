// Added by Japan Bhavsar on 11/6/2018
public class APTSMD_CommonHeaderCtrl {
    
    // Initialize Variables
    public boolean isShowLogoOnHeaderBar {get;set;}
    //public boolean isEnableGA {get; set;}
    private APTSMD_Apttus_PreSales_Config_Settings2__c presalesSetting;
    
    public APTSMD_CommonHeaderCtrl() {
        
        presalesSetting = [select id, name,APTSMD_Show_Logo_In_Custom_Pages__c, APTSMD_Enable_Google_Analytics__c
                    from APTSMD_Apttus_PreSales_Config_Settings2__c where Name = 'System Properties' limit 1];
        
        // if(presalesSetting != null){  
        //     this.isEnableGA = presalesSetting.APTSMD_Enable_Google_Analytics__c;
        // }else{
        //     this.isEnableGA = false;
        // }
    }
    
    public string getmyimageurl() {  
    
        string imageid = '';
        //Fetch Org Id
        string orgId = UserInfo.getOrganizationId();
        // Fecth document logo
        document doc = new document();
        
        if(presalesSetting != null){
            this.isShowLogoOnHeaderBar = presalesSetting.APTSMD_Show_Logo_In_Custom_Pages__c;
        }else{
            this.isShowLogoOnHeaderBar = false;
        }
        
        if(this.isShowLogoOnHeaderBar){
            // Fecth document logo
            doc = [select id, Name from document where name = 'New Apttus logo' limit 1];
            imageid = doc.id; 
            //imageid = imageid.substring(0,15);
        }else{
            doc = null;
        }
        //return '/servlet/servlet.FileDownload?file=' + imageid;
        //Modified by in order to show logo in partner community
        return '/servlet/servlet.ImageServer?id=' + imageid + '&oid=' + orgId;
    
    }
    
}