public class APTSMD_FlowHelper {

    
    /*
     * ExecuteFlowHelperMethod - This method will be generic for all flows. 
     * Description - In this method we will pass the apex class name, method name and its related params and we will call the class dynamically.
	*/
    @InvocableMethod
    public static void ExecuteFlowHelperMethod(List<FlowInputs> params) {
        
        final string ERORR = 'Error';  
        final string SUCCESS = 'Success';  
        //List<string> response = new List<string>();
        
        try{            
            FlowInputs input = new FlowInputs();            
            if(!params.isEmpty()){
                input = params[0];
                System.debug('input >> ' + input);
                
                Type typeInstance = Type.forName(input.APEX_CLASS_NAME);
                APTSMD_HandlerInterface handlerInterface = (APTSMD_HandlerInterface)typeInstance.newInstance();
    			handlerInterface.executeMethod(input.Param_1,input.Param_2,input.Param_3,input.Param_4,input.Param_5);
                //response.add(SUCCESS);
                //response.add('APEX Operation has been process successfully!');                
            } else {
                //response.add(ERORR);
                //response.add('Please pass the parameters properly to execute this actions!');
            }
        }catch(Exception ex){
            //response.add(ERORR);
            //response.add(ex.getMessage() + ' @ ' + ex.getLineNumber());
            System.debug(ex.getMessage() + ' @ ' + ex.getLineNumber());
        }
        
    	//return response;
   	}
    
    /* 
     * FlowInputs - This class is used to send the Flow Input Params to the ExecuteFlowHelperMethod
     * Description - In this class we are setting properties like Apex Clas Name, Apex Class Method, First to Fifth Parameters.	
	*/
    public class FlowInputs{
    
        @InvocableVariable(label='Apex Class Name' description='Name of the Apex class which you want to invoke' required=true)
        public string APEX_CLASS_NAME;
        
        @InvocableVariable(label='First Parameter' description='First Parameter of the fuction' required=false)
        public string PARAM_1;
        
        @InvocableVariable(label='Second Parameter' description='Second Parameter of the fuction' required=false)
        public string PARAM_2;
        
        @InvocableVariable(label='Third Parameter' description='Third Parameter of the fuction' required=false)
        public string PARAM_3;
        
        @InvocableVariable(label='Fourth Parameter' description='Third Parameter of the fuction' required=false)
        public string PARAM_4;
        
        @InvocableVariable(label='Fifth Parameter' description='Fifth Parameter of the fuction' required=false)
        public string PARAM_5;
        
    }    
    
}