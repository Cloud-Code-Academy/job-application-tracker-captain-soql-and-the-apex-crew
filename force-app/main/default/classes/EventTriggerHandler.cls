public with sharing class EventTriggerHandler {
    public static void preventOverlappingFutureEventsForAssignedUser(List<Event> triggerDotNew) {
        Map<Id, List<Event>> ownerAssignedIdToEvents = createAssignedIdToEventListMap(triggerDotNew);
        for(Event newEvent: triggerDotNew){
            if(isWeekend(newEvent.StartDateTime, newEvent.EndDateTime)){
                newEvent.addError('This is your off day, stop working. Unlike the people who made this.');
            }
            DatesToCompare dates = new DatesToCompare();
            dates.startDateTimeOne = newEvent.StartDateTime;
            dates.endDateTimeOne = newEvent.EndDateTime;
            for(Event existingEvent: ownerAssignedIdToEvents.get(newEvent.OwnerId)){
                dates.startDateTimeTwo = existingEvent.StartDateTime;
                dates.endDateTimeTwo = existingEvent.EndDateTime;
                if(isOverlapping(dates)){
                    newEvent.addError('You have another scheduled event at this time.');
                }
            }
        }
    }
    private static Boolean isOverlapping(DatesToCompare dates){
        return dates.startDateTimeOne <= dates.endDateTimeTwo && dates.startDateTimeTwo <= dates.endDateTimeOne;
    }
    private static Boolean isWeekend(Datetime startDateTime, Datetime endDatetime){
        return  startDateTime.format('E') == 'Sun' || 
                startDateTime.format('E') == 'Sat' || 
                endDatetime.format('E') == 'Sun' || 
                endDatetime.format('E') == 'Sat';
    }
    private static Map<Id, List<Event>> createAssignedIdToEventListMap(List<Event> eventsToMap){
        Map<Id, List<Event>> assignedIdToEvents = new Map<Id, List<Event>>();
        for(Event newEvent: eventsToMap){
            assignedIdToEvents.put(newEvent.OwnerId, new List<Event>());
        }
        Datetime now = datetime.now();
        List<Event> eventsOwnedByUsers = [
            SELECT OwnerId, StartDateTime, EndDateTime 
            FROM Event 
            WHERE OwnerId IN :assignedIdToEvents.keySet()
            AND StartDateTime >= :now
            WITH USER_MODE
        ];
        for(Event newEvent: eventsOwnedByUsers){
            List<Event> eventList = assignedIdToEvents.get(newEvent.OwnerId);
            eventList.add(newEvent);
            assignedIdToEvents.put(newEvent.OwnerId, eventList);
        }
        return assignedIdToEvents;
    }
    private class DatesToCompare{
        private Datetime startDateTimeOne;
        private Datetime endDateTimeOne;
        private Datetime startDateTimeTwo;
        private DateTime endDateTimeTwo;

        // private DatesToCompare(Datetime startDateOne, Datetime endDateOne, Datetime startDateTwo, Datetime endDateTwo){
        //     startDateTimeOne = startDateOne;
        //     endDateTimeOne = endDateOne;
        //     startDateTimeTwo = startDateTwo;
        //     endDateTimeTwo = endDateTwo;
        // }
    }
}