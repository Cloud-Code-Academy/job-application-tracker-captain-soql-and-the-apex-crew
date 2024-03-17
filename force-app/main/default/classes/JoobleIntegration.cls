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

            Map<String,Object> requestBodyMap = new Map<String, Object>{
                'keywords' => keywords,
                'location' => location
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
    private static void processResponse(List<Posting> postings){
        // create look up account, job posting
    }*/
    private static List<JobPosting__c> parseResponseBodyIntoPostingInnerClass(String responseBody) {
        Map<String, Object> jsonResponseBody = (List<Object>) JSON.deserializeUntyped(responseBody);
        List<Object> jobPostsList = (List<Object>) jsonResponseBody.get('jobs');

        List<Posting> postings = new List<Posting>();
        for (Object jobPost : jobPostsList) {
            Posting newJobPost = new Posting();
            newJobPost.title = '';
            newJobPost.postingId = '';

        }
        return null;
    }

    class Posting{
        String title;
        String postingId;
        String location;
        String snippet;
        String salary;
        String source;
        String type;
        Datetime updated;
        String companyName;
        String url;

    }
        
}