global class APTSMD_CustomIterableAgreement implements Iterator<list<APTSMD_AgreementWrapper>>{
    list<APTSMD_AgreementWrapper> innerList{get; set;}
    list<APTSMD_AgreementWrapper> listRequested{get; set;}
    
    Integer i {get; set;} 
    public Integer setPageSize {get; set;} 
    
    public APTSMD_CustomIterableAgreement(List<APTSMD_AgreementWrapper> lstAccWr)
    {
        innerList = new list<APTSMD_AgreementWrapper>(); 
        listRequested = new list<APTSMD_AgreementWrapper >();     
        innerList = lstAccWr;
        setPageSize = 10;
        i = 0; 
    }   
    
    global boolean hasNext(){ 
        if(i >= innerList.size()) {
            return false; 
        } else {
            return true; 
        }
    } 
    
    global boolean hasPrevious(){ 
        system.debug('I am in hasPrevious' + i);
        if(i <= setPageSize) {
            return false; 
        } else {
            return true; 
        }
    }   
    
    global list<APTSMD_AgreementWrapper > next(){       
        system.debug('i value is ' + i);
        listRequested = new list<APTSMD_AgreementWrapper >(); 
        integer startNumber;
        integer size = innerList.size();
        if(hasNext())
        {  
            if(size <= (i + setPageSize))
            {
                startNumber = i;
                i = size;
            }
            else
            {
                i = (i + setPageSize);
                startNumber = (i - setPageSize);
            }
            
            system.debug('i value is =====' + i);
            system.debug('i value is 2==== ' + (i - setPageSize));
            
            for(integer start = startNumber; start < i; start++)
            {
                listRequested.add(innerList[start]);
            }
        } 
        return listRequested;
    } 
    
    global list<APTSMD_AgreementWrapper > previous(){      
        listRequested = new list<APTSMD_AgreementWrapper >(); 
        system.debug('i value is previous before =====' + i);
        integer size = innerList.size(); 
        if(i == size)
        {
            if(math.mod(size, setPageSize) > 0)
            {    
                i = size - math.mod(size, setPageSize);
            }
            else
            {
                i = (size - setPageSize);
            } 
        }
        else
        {
            i = (i - setPageSize);
        }
        
        system.debug('i value is previous =====' + i);
        system.debug('i value is 2previous ==== ' + (i - setPageSize));
        
        for(integer start = (i - setPageSize); start < i; ++start)
        {
            listRequested.add(innerList[start]);
        } 
        return listRequested;
    }   
}