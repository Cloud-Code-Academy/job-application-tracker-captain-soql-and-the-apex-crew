public with sharing class EventTriggerHandler {
    public static void preventOverlappingEvents(List<Event> triggerDotNew) {
        Map<Long, Long> newStartEndTimesInEpoch = new Map<Long, Long>();
        //Epoc Time is in https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm#apex_System_Datetime_getTime
        //Get time from a DateTime.
        //Article on coverting DateTime to Epoch and back
        //https://salesforce.stackexchange.com/questions/27020/converting-from-datetime-to-epoch-and-back
        for(Event ev: triggerDotNew){
            Long epochStartTime = ev.StartDateTime.getTime();
            Long epochEndTime = ev.EndDateTime.getTime();
        }
    }
}