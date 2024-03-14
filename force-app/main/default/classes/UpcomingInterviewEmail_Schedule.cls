public with sharing class UpcomingInterviewEmail_Schedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<Event> interviewsTomorrow = [
            SELECT 
                Id,
                Location,
                WhatId.Name, 
                StartDateTime 
            FROM Event 
            WHERE 
                RecordType.Name = 'Interview' 
                AND StartDateTime = NEXT_N_DAYS:1
        ];
        if (!interviewsTomorrow.isEmpty()) {
            String eventTableHTML = generateEventTable(interviewsTomorrow);
            Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
            newEmail.setSubject('Interview Events Tomorrow');
            newEmail.setHtmlBody(eventTableHTML);
            newEmail.setToAddresses(new String[] {'recipient@example.com'});    // need to account for OwnerId

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newEmail });
        }
    }

    private static String generateEventTable(List<Event> events) {
        String tableHTML = '<table border="1"><tr><th>Location</th><th>Appointment</th><th>Start</th></tr>';
        for(Event evt : events) {
            tableHTML += '<tr>';
            tableHTML += '<td>' + evt.Location + '</td>';
            tableHTML += '<td>' + evt.StartDateTime.format('yyyy-MM-dd HH:mm:ss') + '</td>';
            tableHTML += '<td>' + evt.WhatId.Name + '</td>';
            tableHTML += '</tr>';
        }
        tableHTML += '</table>';
        
        return tableHTML;
    }
}

/*
// Schedule the job to run daily at 6 AM
String cronExpression = '0 0 6 * * ?';
System.schedule('DailyScheduledJob', cronExpression, new DailyScheduledJob());
*/