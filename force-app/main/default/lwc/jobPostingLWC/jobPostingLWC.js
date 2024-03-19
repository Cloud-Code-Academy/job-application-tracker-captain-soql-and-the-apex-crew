import { LightningElement, wire } from 'lwc';
import getJsonData from '@salesforce/apex/jobPostCallout.getJsonData';

const ACTIONS = [{label: 'Convert to application'}];
const columns = [
    { label: 'Jooble Id', fieldName: 'id' },
    { label: 'Company Name', fieldName: 'company' },
    { label: 'Last updated', fieldName: 'updated' },
    { fieldName: "actions", type: 'action', typeAttributes: {rowActions: ACTIONS}}
];

export default class JobPostingLWC extends LightningElement {
    data = [];
    columns = columns;
    selectedContacts;
    baseData;

    get selectedJobPostingsLength() {
        if(this.selectedContacts == undefined) {
            return 0;
        }
        return this.selectedContacts.length;
    }

    @wire(getJsonData) 
    wiredJsonData({ error, data }){
        if (data) {
            let jsonDataObj = JSON.parse(data);

            if (jsonDataObj && jsonDataObj.jobs) {
                this.data = jsonDataObj.jobs;
            }
            this.baseData = this.data;
        } else if (error) {
            alert('error: ' + error);
        }
    }

    handleRowSelection(event) {
        this.selectedContacts = event.detail.selectedRows;
    }

    async handleSearch(event) {
        if(event.target.value == "") {
            this.contacts = this.baseData;
        } else if(event.target.value.length > 1) {
            const searchJobPostings = await searchJobPostings({})
        }
    }

    convertPostingToApplication(event) {
        alert('This is where you could create applications from selected postings some day!');
    }
}

