/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-16-2024
 * @last modified by  : @Fritz
**/
public with sharing class JoobleIntegration {
    
    public static void makeHTTPCallout(String keywords, String location){
        Intergrations__mdt jooble = Intergrations__mdt.getInstance('JoobleAPI');
        if(jooble != null && jooble.APIKey__c != null && jooble.Endpoint__c != null){
            HttpRequest request = new HttpRequest();
            system.debug('Intergrations endpoint is: ' + jooble.Endpoint__c);
            request.setEndpoint(jooble.Endpoint__c + jooble.APIKey__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');

            String sevenDaysAgo = Date.today().addDays(-7).format('yyyy-MM-dd');

            Map<String,Object> requestBodyMap = new Map<String, Object>{
                'keywords' => keywords,
                'location' => location,
                'datecreatedfrom' => sevenDaysAgo
            };

            System.debug('RequestBodyMap: '+ JSON.serializePretty(requestBodyMap));
            String requestBodyJSON = JSON.serialize(requestBodyMap);
            request.setBody(requestBodyJSON);

            Http http = new Http();
            HttpResponse response = new HttpResponse();
            try{
                response = http.send(request);
                String responseBody = response.getBody();
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);

                if(response.getStatusCode() != 200){
                    System.debug('Response was not 200 it was :' + response.getStatusCode());
                }else{
                    System.debug('responseMap is: ' + responseMap);
                    //TODO parse response
                    //TODO Search for and Create Account?Update Account
                    //TODO Create and/or Update Job Posted
                    //TODO ExternalID fields
                                  
                }
            }catch(Exception e){
                System.debug('Exception is: ' + e.getMessage());
            }
        }
    }
    /*
    private static HttpResponse makeHTTPRequest(){

    }
    private static void processResponse(){

    }*/
}