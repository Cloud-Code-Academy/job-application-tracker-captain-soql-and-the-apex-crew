global class jobPostCallout {
    @AuraEnabled(cacheable=true)
    public static String getJsonData() {
        String jsonData = '';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'joobleResponseBody' WITH USER_MODE];

        if (sr != null) {
            jsonData = sr.Body.toString();
        }
        
        return jsonData;
    }

}