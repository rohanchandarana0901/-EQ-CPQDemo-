/*************************************************************
@Name: TaxCallBackMockHttpResponse
@Author: Apttus Team
@CreateDate: Jone-06-2019
@purpose: Mock HTTP callout response.
******************************************************************/
@isTest
global class TaxCallBackMockHttpResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        String JsonBody = '{"totalRate":0.090000,"rates":[{"rate":0.002500,"name":"CA COUNTY TAX","type":"County"}]}';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JsonBody);
        res.setStatusCode(200);
        return res;
    }
}