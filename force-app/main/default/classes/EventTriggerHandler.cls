public with sharing class EventTriggerHandler {
    public static void preventOverlappingFutureEventsForAssignedUser(List<Event> triggerDotNew) {
        Map<Id, List<Event>> ownerAssignedIdToEvents = createAssignedIdToEventListMap(triggerDotNew);
        for(Event ev: triggerDotNew){
            if(isWeekend(ev.StartDateTime, ev.EndDateTime)){
                ev.addError('This is your off day, stop working. Unlike the people who made this.');
            }
            DatesToCompare dates = new DatesToCompare();
            dates.startDateTimeOne = ev.StartDateTime;
            dates.endDateTimeOne = ev.EndDateTime;
            for(Event eve: ownerAssignedIdToEvents.get(ev.OwnerId)){
                dates.startDateTimeTwo = eve.StartDateTime;
                dates.endDateTimeTwo = eve.EndDateTime;
                if(isOverlapping(dates)){
                    ev.addError('You have another scheduled event at this time.');
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
        for(Event ev: eventsToMap){
            assignedIdToEvents.put(ev.OwnerId, new List<Event>());
        }
        Datetime now = datetime.now();
        List<Event> eventsOwnedByUsers = [
            SELECT OwnerId, StartDateTime, EndDateTime 
            FROM Event 
            WHERE OwnerId IN :assignedIdToEvents.keySet()
            AND StartDateTime >= :now
            WITH USER_MODE
        ];
        for(Event ev: eventsOwnedByUsers){
            List<Event> eventList = assignedIdToEvents.get(ev.OwnerId);
            eventList.add(ev);
            assignedIdToEvents.put(ev.OwnerId, eventList);
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