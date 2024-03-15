public with sharing class UpcomingInterviewEmail_Schedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        // query for interview events with a start date tomorrow
        List<Event> interviewsTomorrow = [
            SELECT 
                Id,
                Location,
                OwnerId, 
                StartDateTime 
            FROM Event 
            WHERE 
                RecordType.Name = 'Interview' 
                AND StartDateTime = NEXT_N_DAYS:1
        ];

        // if the query returns results, map the ownerId to a list of events, generate emails of all events for each ownerId and add to a list of emails to send out
        if (!interviewsTomorrow.isEmpty()) {
            Map<Id, List<Event>> ownerIdToListOfInterviewsTomorrowMap = generateMapOfOwnerIdsToInterviews(interviewsTomorrow);
            List<Messaging.SingleEmailMessage> emailsToSendOut = new List<Messaging.SingleEmailMessage>();
            for (Id ownerId : ownerIdToListOfInterviewsTomorrowMap.keySet()) {
                Messaging.SingleEmailMessage emailToSend = generateEmail(ownerId, ownerIdToListOfInterviewsTomorrowMap.get(ownerId));
                emailsToSendOut.add(emailToSend);
            }
            try {
                Messaging.sendEmail(emailsToSendOut);
            } catch (Exception ex) {
                System.debug('Error sending email: ' + ex.getMessage());
            } 
        }
    }

    @TestVisible
    private static Messaging.SingleEmailMessage generateEmail(Id ownerId, List<Event> ownerTasks) {
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
        String eventTableHTML = generateEventTable(ownerTasks);
        newEmail.setSubject('Interview Events Tomorrow: ' + Date.today().addDays(1));
        newEmail.setHtmlBody(eventTableHTML);
        newEmail.setToAddresses(new String[] {ownerId});
        return newEmail;
    }
    @TestVisible
    private static String generateEventTable(List<Event> events) {
        String tableHTML = '<table border="1"><tr><th>Location</th><th>Appointment</th><th>Start</th></tr>';
        for(Event evt : events) {
            tableHTML += '<tr>';
            tableHTML += '<td>' + evt.Location + '</td>';
            tableHTML += '<td>' + evt.Subject + '</td>';
            tableHTML += '<td>' + evt.StartDateTime.format('yyyy-MM-dd HH:mm:ss') + '</td>';
            tableHTML += '</tr>';
        }
        tableHTML += '</table>';
        
        return tableHTML;
    }
    @TestVisible
    private static Map<Id, List<Event>> generateMapOfOwnerIdsToInterviews(List<Event> events) {
        Map<Id, List<Event>> interviewsByOwnerId = new Map<Id, List<Event>>();
        for (Event event : events) {
            if (!interviewsByOwnerId.containsKey(event.OwnerId)) {
                interviewsByOwnerId.put(event.OwnerId, new List<Event>());
            }
            interviewsByOwnerId.get(event.OwnerId).add(event);
        }
        return interviewsByOwnerId;
    } 

}

/*
// Schedule the job to run daily at 6 AM
String cronExpression = '0 0 6 * * ?';
System.schedule('DailyScheduledJob', cronExpression, new DailyScheduledJob());
*/