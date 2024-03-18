import { LightningElement, wire } from 'lwc';
import getJsonData from '@salesforce/apex/jobPostCallout.getJsonData';

const columns = [
    { label: 'Jooble Id', fieldName: 'id' },
    { label: 'Company Name', fieldName: 'company' },
    { label: 'Last updated', fieldName: 'updated' },
];

export default class JobPostingLWC extends LightningElement {
    data = [];
    columns = columns;

    @wire(getJsonData) 
    wiredJsonData({ error, data }){
        if (data) {
            let jsonDataObj = JSON.parse(data);

            if (jsonDataObj && jsonDataObj.jobs) {
                this.data = jsonDataObj.jobs;
            }
        } else if (error) {
            alert('error: ' + error);
        }
    }
}

