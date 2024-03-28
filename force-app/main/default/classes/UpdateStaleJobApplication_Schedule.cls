public with sharing class UpdateStaleJobApplication_Schedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        UpdateStaleJobApplication_Batch batch = new UpdateStaleJobApplication_Batch();
        Database.executeBatch(batch);
    }
}