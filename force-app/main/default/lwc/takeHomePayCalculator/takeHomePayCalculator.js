/**
 * @description       : 
 * @author            : @Fritz
 * @group             : Cohort2
 * @last modified on  : 03-09-2024
 * @last modified by  : @Fritz
**/
import { LightningElement } from 'lwc';

export default class TakeHomePayCalculator extends LightningElement {

    salary = 25000;
    federalTax = 0.175;
    stateTax = 0.065;
    medicare = 0.0175;
    socialSecurity = 0.03;
    takeHome = '';


    get salary() {
        return this.salary;
    }

    // set householdIncome(value) {
    //     this.householdIncome = value;
    // }
    handleSalaryChange(event) {
        this.salary = event.target.value;
    }

    // handleFirstNameChange(event) {
    //     this.firstName = event.target.value;
    // }

    // handleLastNameChange(event) {
    //     this.lastName = event.target.value;
    // }

    // handleAgeChange(event) {
    //     this.age = event.target.value;
    // }

    // handleHouseholdIncomeChange(event) {
    //     this.householdIncome = event.target.value;
    // }
    
}