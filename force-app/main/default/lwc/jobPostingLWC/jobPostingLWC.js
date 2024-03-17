import { LightningElement, wire } from 'lwc';
import JOBPOSTINGLWC_PAGE_HEADER from '@salesforce/label/c.JOBPOSTINGLWC_PAGE_HEADER';
import JOB_POST_ID from '@salesforce/label/c.JOB_POST_ID';
import COMPANY_NAME from '@salesforce/label/c.COMPANY_NAME';
import UPDATED from '@salesforce/label/c.UPDATED';
import getCalloutData from '@salesforce/apex/jobPostCallout.getCalloutData';

export default class JobPostingLWC extends LightningElement {
    ready=false;
    label={
        JOBPOSTINGLWC_PAGE_HEADER,
        JOB_POST_ID,
        COMPANY_NAME,
        UPDATED
    };
    @wire (getCalloutData) callout;
}