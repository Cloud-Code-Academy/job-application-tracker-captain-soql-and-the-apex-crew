global class jobPostCallout {
    @AuraEnabled(cacheable=true)
    global static List<jobPostWrapper> getCalloutData() {
        staticResource sr = [SELECT Id,Body FROM StaticResource WHERE Name = 'joobleResponseBody'];
        string jsonString = sr.Body.toString();

        Map<String, Object> jsonResponseBody = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        List<Object> jobPostsList = (List<Object>) jsonResponseBody.get('jobs');

        List<jobPostWrapper> jobPostWrapperList = new List<jobPostWrapper>();
        for (Object jobPost : jobPostsList) {
            Map<String, Object> jobPostRecord = (Map<String, Object>) jobPost;
            jobPostWrapper newJobPostWrapper = new jobPostWrapper();
            newJobPostWrapper.JobPostId = String.valueOf(jobPostRecord.get('id'));
            newJobPostWrapper.CompanyName = String.valueOf(jobPostRecord.get('company'));
            newJobPostWrapper.Updated = String.valueOf(jobPostRecord.get('updated'));
            jobPostWrapperList.add(newJobPostWrapper);
        }
        return jobPostWrapperList;
    }
}