import { LightningElement, wire } from 'lwc';
// import getJsonData from '@salesforce/apex/jobPostCallout.getJsonData';
import getJobPostings from '@salesforce/apex/jobPostCallout.getJobPostings';

const ACTIONS = [{label: 'Convert to application', name: 'convert'}];

const columns = [
    { label: 'Name', fieldName: 'link', type: 'url', typeAttributes: {label: {fieldName: 'jobPostName'}}},
    { label: 'Jooble Id', fieldName: 'joobleLink', type: 'url', typeAttributes: {label: {fieldName: 'joobleId'}} },
    { label: 'Company Name', fieldName: 'company' },
    { label: 'Last updated', fieldName: 'updated' },
    { fieldName: "actions", type: 'action', typeAttributes: {rowActions: ACTIONS}},
];

export default class JobPostingLWC extends LightningElement {
    // data = [];
    columns = columns;
    selectedPostings;
    // baseData;
    jobPostings;
    wiredJobPostings;

    get selectedJobPostingsLength() {
        if(this.selectedPostings == undefined) {
            return 0;
        }
        return this.selectedPostings.length;
    }

    @wire(getJobPostings)
    jobPostingsWire(result) {
        this.wiredJobPostings = result;
        if (result.data) {
            this.jobPostings = result.data.map((row) => {
                return this.mapJobPostings(row);
            });
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    mapJobPostings(row) {
        return {...row,
            jobPostName: row.Name,
            link: `/${row.Id}`,
            company: row.CompanyRef__c,
            joobleId: row.JooblePostingId__c,
            joobleLink: row.Source__c,
        };
    }
    handleRowSelection(event) {
        this.selectedPostings = event.detail.selectedRows;
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

