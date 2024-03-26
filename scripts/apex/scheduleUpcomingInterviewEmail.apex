String cronExpression = '0 0 6 * * ?';  // run daily at 6 AM
System.schedule('Send daily email for upcoming interviews', cronExpression, new UpcomingInterviewEmail_Schedule());