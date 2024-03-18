import { LightningElement, wire } from 'lwc';
import JOBPOSTINGLWC_PAGE_HEADER from '@salesforce/label/c.JOBPOSTINGLWC_PAGE_HEADER';
import JOB_POST_ID from '@salesforce/label/c.JOB_POST_ID';
import COMPANY_NAME from '@salesforce/label/c.COMPANY_NAME';
import UPDATED from '@salesforce/label/c.UPDATED';
import getCalloutData from '@salesforce/apex/jobPostCallout.getCalloutData';

// export default class JobPostingLWC extends LightningElement {
//     ready=false;
//     label={
//         JOBPOSTINGLWC_PAGE_HEADER,
//         JOB_POST_ID,
//         COMPANY_NAME,
//         UPDATED
//     };
//     @wire (getCalloutData) callout;
// }

const columns = [
    { label: 'Jooble Id', fieldName: 'id' },
    { label: 'Company Name', fieldName: 'company' },
    { label: 'Last updated', fieldName: 'updated' },
];

export default class JobPostingLWC extends LightningElement {
    data = [];
    columns = columns;

    connectedCallback() {
        const data = [{
            company: 'Prospect Infosystem Inc',
            updated: '2024-02-28T00:00:00.0000000',
            id: '8542290820435711574'
            },
            {
            company: "Apex Informatics",
            updated: "2024-03-01T00:00:00.0000000",
            id: 7826091234674837853
            },
            {
            company: "Procare Solutions",
            updated: "2024-02-28T00:00:00.0000000",
            id: -8481210526286724053
        }];
        this.data = data;
    }
}

