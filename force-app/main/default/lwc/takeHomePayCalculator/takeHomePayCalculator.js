/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-09-2024
 * @last modified by  : @Fritz
**/
import { LightningElement } from 'lwc';

// Tax rates
const federalTaxRate = 0.25;
const medicareRate = 0.02;
const socialSecurityRate = 0.03;
let monthlyTakeHomePay = 0;
//let salary = 200000;
export default class TakeHomePayCalculator extends LightningElement {
    

    salary = 100000; // Default salary

    // Calculate the take home pay
    calculateTakeHomePay() {
        let federalTax = this.salary * federalTaxRate;
        let medicare = this.salary * medicareRate;
        let socialSecurity = this.salary * socialSecurityRate;
        console.log(federalTax);
        console.log(medicare);
        console.log(socialSecurity);
        let totalTax = federalTax + medicare + socialSecurity;
        console.log(totalTax);
        let takeHomePay = this.salary - totalTax;
        console.log(takeHomePay);

        // Convert annual take home pay to monthly
        this.monthlyTakeHomePay = takeHomePay / 12;
        console.log(this.monthlyTakeHomePay);

        return this.monthlyTakeHomePay;
    }

    // Change handler for salary input
    handleSalaryChange(event) {
        this.salary = Number(event.target.value);
        const inputName = event.target.name;
        if(inputName == 'salaryName') {
            this.calculateTakeHomePay();
        }
        console.log(this.salary);
    }
}