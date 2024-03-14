public with sharing class UpdateStaleJobApplication_Schedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateStaleJobApplication_Batch batch = new UpdateStaleJobApplication_Batch();
        Database.executeBatch(batch);
        //Call class in batchable only so the instructors don't be like "WhAt iF YoU HaVe A BiLlIoN ApPlIcATiOnS"
        //For one person could be easily handled in this single context with a SOQL LIMIT 200 query.
        //Aint no way someone is doing more than 200 apps a day.
        //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_scheduler.htm
        //How to schedule for every Friday System.schedule('Update Job Application Scheduled Job', '0 0 * * 5', new UpdateStaleJobApplication_Schedule())
    }
}