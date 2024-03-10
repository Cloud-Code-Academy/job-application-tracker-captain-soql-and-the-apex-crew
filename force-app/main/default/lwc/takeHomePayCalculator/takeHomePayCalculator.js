/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-09-2024
 * @last modified by  : @Fritz
**/
import { LightningElement } from 'lwc';

// Tax rates
const medicareRate = 0.0145;
const socialSecurityRate = 0.062;
export default class TakeHomePayCalculator extends LightningElement {
    
    salary = 0; // Default salary
    currentFederalTaxRate = 0; //default tax rate

    // Tax rates
    medicareRate = medicareRate;
    socialSecurityRate = socialSecurityRate;

        // Calculate the take home pay
    calculateTakeHomePay() {
            // Determine the federal tax rate based on the salary
            if (this.salary > 243725) {
                this.currentFederalTaxRate = 0.35;
            } else if (this.salary > 191950) {
                this.currentFederalTaxRate = 0.32;
            } else if (this.salary > 100525) {
                this.currentFederalTaxRate = 0.24;
            } else if (this.salary > 47150) {
                this.currentFederalTaxRate = 0.22;
            } else if (this.salary > 11600) {
                this.currentFederalTaxRate = 0.12;
            } else {
                this.currentFederalTaxRate = 0; // No tax for incomes under $11,600
            }
            
        let federalTax = this.salary * this.currentFederalTaxRate;
        let medicare = this.salary * medicareRate;
        let socialSecurity = this.salary * socialSecurityRate;
        let totalTax = federalTax + medicare + socialSecurity;
        let takeHomePay = this.salary - totalTax;

        this.yearlyTakeHomePay = takeHomePay.toLocaleString('en-US', {style: 'currency', currency: 'USD'});
            // convert to 6 month
        this.sixMonthlyTakeHomePay = (takeHomePay / 2).toLocaleString('en-US', {style: 'currency', currency: 'USD'});
            // Convert annual take home pay to monthly
        this.monthlyTakeHomePay = (takeHomePay / 12).toLocaleString('en-US', {style: 'currency', currency: 'USD'});
            // Convert Annual to Biweekly pay
        this.biweeklyTakeHomePay = (takeHomePay / 26).toLocaleString('en-US', {style: 'currency', currency: 'USD'});
    }

        // Change handler for salary input
    handleSalaryChange(event) {
        this.salary = Number(event.target.value);
        const inputName = event.target.name;
        if(inputName == 'salaryName') {
            this.calculateTakeHomePay();
        }
    }
}