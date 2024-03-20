

@istest
global  class JoobleIntegration_Mock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(
                '{"totalCount": 8451,"jobs": [{"title": "Salesforce Developer","location": "Denver, CO","snippet": " Job Description: <b>Salesforce Developer </b> Location: 100% Remote  Rate: $80/hr on C2C.  Duration: Only 39 Days contract.  Responsibilities: \r\n~ Assist CDE in reviewing UIP and related cust...\r\n\r\n","salary": "","source": "aim.monster.com","type": "","link": "https://jooble.org/desc/8542290820435711574?ckey=Salesforce+developer&rgn=321&pos=1&groupId=40906&elckey=-2133063373152840484&p=1&aq=5283160083790945395&cid=3344&jobAge=428&relb=149&brelb=115&bscr=8467.861&scr=10971.402513043478","company": "Prospect Infosystem Inc","updated": "2024-02-28T00:00:00.0000000","id": 8542290820435711574},{"title": "Salesforce Developer","location": "Denver, CO","snippet": "&nbsp;...Assist CDE in reviewing UIP and related custom objects within the <b>Salesforce </b>instance in order to determine opportunities for modification,...&nbsp;&nbsp;...user) can interpret in order to support the work at the end of the contract once a <b>developer </b>is no longer available to CDE....&nbsp;","salary": "","source": "ziprecruiter.com","type": "","link": "https://jooble.org/desc/7826091234674837853?ckey=Salesforce+developer&rgn=321&pos=2&groupId=40906&elckey=-2133063373152840484&p=1&aq=5283160083790945395&cid=3344&jobAge=380&relb=115&brelb=115&bscr=8541.213&scr=8541.213","company": "Apex Informatics","updated": "2024-03-01T00:00:00.0000000","id": 7826091234674837853},{"title": "Salesforce Developer","location": "Denver, CO","snippet": "&nbsp;...customers can spend more time focusing on the kiddos, not back office administrative duties. \r\n A little about the role…\r\n As the <b>Salesforce Developer </b>you will be responsible for developing and maintaining the internal systems critical to running our business. These systems...&nbsp;","salary": "","source": "ziprecruiter.com","type": "","link": "https://jooble.org/desc/-8481210526286724053?ckey=Salesforce+developer&rgn=321&pos=3&groupId=40906&elckey=-2133063373152840484&p=1&aq=5283160083790945395&cid=3344&jobAge=428&relb=115&brelb=115&bscr=8407.9375&scr=8407.9375","company": "Procare Solutions","updated": "2024-02-28T00:00:00.0000000","id": -8481210526286724053}');
		res.setStatusCode(200);
		return res;
	}
}
