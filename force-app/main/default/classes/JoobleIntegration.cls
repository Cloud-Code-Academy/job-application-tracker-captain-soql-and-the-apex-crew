public with sharing class JoobleIntegration {
    
    @future(callout=true)public static void makeHTTPCallout(String keywords, String location){
        Intergrations__mdt jooble = Intergrations__mdt.getInstance('JoobleAPI');
        if(jooble != null && jooble.APIKey__c != null && jooble.Endpoint__c != null){
            HttpRequest request = new HttpRequest();
            request.setEndpoint(jooble.Endpoint__c + jooble.APIKey__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');          

            Map<String,Object> requestBodyMap = new Map<String, Object>{
                'keywords' => keywords,
                'location' => location
            };
            String requestBodyJSON = JSON.serialize(requestBodyMap);
            request.setBody(requestBodyJSON);

            Http http = new Http();
            HttpResponse response = new HttpResponse();
            try{
                response = http.send(request);
                String responseBody = response.getBody().replace('\r\n', '');
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                if(response.getStatusCode() != 200){
                }else{
                    List<Posting> postList = parseResponseBodyIntoPostingInnerClass(responseBody);
                    processResponse(postList);
                }
            }catch(Exception e){
                System.debug('Exception is: ' + e.getMessage());
            }
        }
    }
    private static void processResponse(List<Posting> postings){
        Map<String, Account> accountNameToAccount = new Map<String, Account>();
        List<String> acccountNames = new List<String>();
        List<JobPosting__c> postingsToUpsert = new List<JobPosting__c>();
        Map<String, Posting> externalIdToPosting = new Map<String, Posting>();
        Map<String, JobPosting__c> externalIdToJobPosting = new Map<String, JobPosting__c>();
        for(Posting post: postings){
            acccountNames.add(post.companyName);
            externalIdToPosting.put(post.postingId, post);
        }
        for(Account acc: [SELECT Id, Name FROM Account WHERE Name IN :acccountNames]){
            accountNameToAccount.put(acc.Name, acc);
        }
        for(JobPosting__c jobPost: [
            SELECT CompanyRef__c, JooblePostingId__c, Name, Link__c, Location__c, Salary__c, Snippet__c, Source__c, Type__c, Updated__c , Id
            FROM JobPosting__c 
            WHERE JooblePostingId__c IN:externalIdToPosting.keySet()]){
                externalIdToJobPosting.put(jobPost.JooblePostingId__c, jobPost);
            }
        for(Posting post: postings){
            JobPosting__c jobPost = externalIdToJobPosting.get(post.postingId);
            if(jobPost != null){
                jobPost.Name = post.title;
                jobPost.Link__c = post.link;
                jobPost.Location__c = post.location;
                jobPost.Salary__c = post.salary;
                jobPost.Snippet__c = post.snippet;
                jobPost.Type__c = post.type;
                jobPost.Updated__c = post.updated;
                postingsToUpsert.add(jobPost);
            }else{
                JobPosting__c newJobPost = new JobPosting__c(
                    Name = post.title,
                    Link__c = post.link,
                    Location__c = post.location,
                    Salary__c = post.salary,
                    Snippet__c = post.snippet,
                    Type__c = post.type,
                    Updated__c = post.updated,
                    JooblePostingId__c = post.postingId
                );
                Account acc = accountNameToAccount.get(post.companyName);
                if(acc != null){
                    newJobPost.CompanyRef__c = acc.Id;
                }else{
                    Account newAcc = new Account(
                        Name = post.companyName
                    );
                    accountNameToAccount.put(newAcc.Name , newAcc);
                }
                postingsToUpsert.add(newJobPost);
            }
        }
        try{
            Database.upsert(accountNameToAccount.values(), false, AccessLevel.SYSTEM_MODE);
            for(JobPosting__c jobPost: postingsToUpsert){
                if(jobPost.CompanyRef__c == null){
                    jobPost.CompanyRef__c = accountNameToAccount.get(externalIdToPosting.get(jobPost.JooblePostingId__c).companyName).Id;
                }
            }
            Database.upsert(postingsToUpsert, JobPosting__c.Fields.JooblePostingId__c, false, AccessLevel.SYSTEM_MODE);
        }catch(Exception e){
            System.debug('Exception is :' + e.getMessage());
            System.debug('Cause is: ' + e.getCause());
        }
        
    }
    @TestVisible
    private static List<JoobleIntegration.Posting> parseResponseBodyIntoPostingInnerClass(String responseBody) {
        Map<String, Object> jsonResponseBody = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> jobPostsList = (List<Object>) jsonResponseBody.get('jobs');

        List<Posting> postings = new List<Posting>();
        for (Object jobPost : jobPostsList) {
            Map<String, Object> jobPostRecord = (Map<String, Object>) jobPost;
            Posting newJobPost = new Posting();
            newJobPost.companyName = String.valueOf(jobPostRecord.get('company'));
            newJobPost.title = String.valueOf(jobPostRecord.get('title'));
            newJobPost.postingId = String.valueOf(jobPostRecord.get('id'));
            newJobPost.location = String.valueOf(jobPostRecord.get('location'));
            newJobPost.snippet = String.valueOf(jobPostRecord.get('snippet'));
            newJobPost.salary = String.valueOf(jobPostRecord.get('salary'));
            newJobPost.source = String.valueOf(jobPostRecord.get('source'));
            newJobPost.type = String.valueOf(jobPostRecord.get('type'));
            newJobPost.updated = convertJsonTimeToDate(String.valueOf(jobPostRecord.get('updated')));
            newJobPost.link = String.valueOf(jobPostRecord.get('link'));
            postings.add(newJobPost);
        }
        return postings;
    }

    @TestVisible
    class Posting{
        @TestVisible String companyName;
        @TestVisible String title;
        @TestVisible String postingId;
        @TestVisible String location;
        @TestVisible String snippet;
        @TestVisible String salary;
        @TestVisible String source;
        @TestVisible String type;
        @TestVisible Date updated;
        @TestVisible String link;
    }

    @TestVisible
    private static Date convertJsonTimeToDate(String jsonTimeString) {
        if (String.isBlank(jsonTimeString)) {
            return null;
        }

        List<String> dateComponents = jsonTimeString.split('-');

        Integer year = Integer.valueOf(dateComponents[0]);
        Integer month = Integer.valueOf(dateComponents[1]);
        Integer day = Integer.valueOf(dateComponents[2].left(2));

        Date dateValue = Date.newInstance(year, month, day);
        return dateValue;
    }
}