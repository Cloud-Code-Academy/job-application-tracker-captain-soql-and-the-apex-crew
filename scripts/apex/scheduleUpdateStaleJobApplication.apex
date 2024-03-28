UpdateStaleJobApplication_Schedule scheduleJob = new UpdateStaleJobApplication_Schedule();
String cron = '0 0 0 ? * 6';//Every Friday at midnight
System.schedule('Update Stale Job Applications', cron, scheduleJob);