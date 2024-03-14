public with sharing class EventTriggerHandler {
    public static void preventOverlappingEvents(List<Event> triggerDotNew) {
        Map<Datetime, Integer> newStartEndTimes = new Map<Datetime, Integer>();
        //Epoc Time is in https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm#apex_System_Datetime_getTime
        //Get time from a DateTime.
        for(Event ev: triggerDotNew){
            ev.StartDateTime.getTime();
        }
    }
}