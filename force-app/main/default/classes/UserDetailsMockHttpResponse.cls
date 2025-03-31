/*************************************************************
@Name: UserDetailsMockHttpResponse
@Author: Apttus Team
@CreateDate: April-16-2018
@purpose: Mock HTTP callout response.
******************************************************************/
@isTest
global class UserDetailsMockHttpResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('Received Request');
        res.setStatusCode(200);
        return res;
    }
}