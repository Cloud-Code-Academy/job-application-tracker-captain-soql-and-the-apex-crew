public with sharing class jobPostCallout {
    @AuraEnabled(cacheable=true)
    public static String getJsonData() {
        String jsonData = '';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'joobleResponseBody' WITH USER_MODE];

        if (sr != null) {
            jsonData = sr.Body.toString();
        }
        
        return jsonData;
    }
    @AuraEnabled(cacheable=true)
    public static List<JobPosting__c> getJobPostings() {
        return [
            SELECT Id, Name, LastModifiedDate, CompanyRef__c, GoToPosting__c, JooblePostingId__c, Link__c, Location__c, Salary__c, Source__c, Type__c
            FROM JobPosting__c
            WITH SECURITY_ENFORCED 
            LIMIT 1000
        ];
    }

    @AuraEnabled
    public static string searchJobPostings(){

        return null;
    }

    @AuraEnabled
    public static string convertPostingToApplication(){
        try {
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}