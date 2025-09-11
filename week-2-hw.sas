/*---------------------------------------------------------*/
/* DSCI 519    : Advanced Business Analytics Modeling      */
/* Deliverable : Week 1 Homework                           */
/* Author      : Satkar Karki                              */
/* Submitted To: Dr. Hanus                                 */
/*---------------------------------------------------------*/

/*=================================*/
/*             LEVEL 2             */
/* USING AUTOMATIC MACRO VARIABLES */
/*=================================*/

/*---------------------------------------------------------*/
/* 2a. Sorting orion.continent dataset by Continent_Name   */
/*---------------------------------------------------------*/
proc sort data=orion.continent
          out=work.continent_sorted;
    by Continent_Name;
run;

/*---------------------------------------------------------*/
/* 2b. Print most recently created data set with SYSLAST   */
/*---------------------------------------------------------*/
title "Most recently created data set: &SYSLAST";
proc print data=&SYSLAST noobs;
run;
title;

/*---------------------------------------------------------*/
/* 2c. Answer                                              */
/*---------------------------------------------------------*/
/* The output printed the most recently created data set as*/
/* "WORK.CONTINENT_SORTED".                                */

/*---------------------------------------------------------*/
/* 3a. Updating SYSLAST after a new DATA step              */
/*---------------------------------------------------------*/
data new;
    set orion.continent;
run;

/* After running this DATA step, the value for SYSLAST is  */
/* updated to 'WORK.NEW'.                                  */

/*---------------------------------------------------------*/
/* 3b.  SYSLAST remains 'WORK.NEW' after PROC PRINT        */
/*---------------------------------------------------------*/
proc print data=orion.continent;
run;

/* Answer: SYSLAST remains 'WORK.NEW' because PROC PRINT   */
/* does not create a new SAS data set. It only generates   */
/* a report. Automatic macro variable SYSLAST changes only */
/* when a new data set is created.                         */
/*---------------------------------------------------------*/

/*=================================*/
/*             LEVEL 2             */
/* NUMERIC MACRO VARIABLE USE (Q5) */
/*=================================*/

/*---------------------------------------------------------*/
/* 5a–b. Gold customers between age range using macros     */
/*     - shows only Gold-level customers                   */
/*     - age bounds parameterized via &age1/&age2          */
/*---------------------------------------------------------*/
options symbolgen;     /* 5c: show resolved macro values in LOG */

%let type=Gold;
%let age1=32;          /* 5d: change and resubmit as needed */
%let age2=40;          /* 5d: change and resubmit as needed */

title "&type Customers between &age1 and &age2";

proc print data=orion.customer_dim;
    var Customer_Name Customer_Gender Customer_Age;
    where Customer_Group contains "&type"
          and Customer_Age between &age1 and &age2;   /* 5b */
run;

title;
options nosymbolgen;   /* 5e: turn off LOG resolution */

/*=================================*/
/*             LEVEL 2             */
/*   USER-DEFINED MACROS (Q6)      */
/*=================================*/

/*---------------------------------------------------------*/
/* 6a. Create user-defined macro variables                 */
/*---------------------------------------------------------*/
title; 
footnote; 

%let pet1=Paisley;
%let pet2=Sitka;

/* (Verify created) */
%put _USER_;

/*---------------------------------------------------------*/
/* 6b. Delete user-defined macro variables                 */
/*---------------------------------------------------------*/
%symdel pet1 pet2;

/*---------------------------------------------------------*/
/* 6c. Verify deletion                                     */
/*---------------------------------------------------------*/

%put _USER_;

/*=================================*/
/*             LEVEL 2             */
/*=================================*/

/*=========================================================*/
/* MACRO VARIABLE REFERENCES WITH DELIMITERS               */
/*=========================================================*/

/*---------------------------------------------------------*/
/* 8a. Original Code                                       */
/*---------------------------------------------------------*/
title; 
footnote; 

proc print data=orion.organization_dim;
   id Employee_ID;
   var Employee_Name Employee_Country Employee_Gender;
   title 'Listing of All Employees From Orion.Organization_Dim';
run;

title; 

/*---------------------------------------------------------*/
/* 8b. Replace literals with macro variables dsn and var   */
/*---------------------------------------------------------*/
%let dsn=Organization;
%let var=Employee;

proc print data=orion.&dsn._dim;
   id &var._ID;
   var &var._Name &var._Country &var._Gender;
   title "Listing of All &var.s From Orion.&dsn._Dim";
run;

title; 

/*---------------------------------------------------------*/
/* 8c. Change values to Customer and resubmit              */
/*---------------------------------------------------------*/
%let dsn=Customer;
%let var=Customer;

proc print data=orion.&dsn._dim;
   id &var._ID;
   var &var._Name &var._Country &var._Gender;
   title "Listing of All &var.s From Orion.&dsn._Dim";
run;

title; 


/*=================================*/
/*            LEVEL 2              */
/*=================================*/

/*---------------------------------------------------------*/
/* 11. Using Macro Functions                               */
/*---------------------------------------------------------*/

/* 11a. The title is verified and it contains as it should be */
%let d=&sysdate9; 
%let t=&systime;

proc print data=orion.product_dim;
   where Product_Name contains "Jacket";
   var Product_Name Product_ID Supplier_Name;
   title1 "Product Names Containing 'Jacket'";
   title2 "Report produced &t &d";
run;

/*---------------------------------------------------------*/
/* 11b. Using a macro variable with special characters      */
/*---------------------------------------------------------*/
%let d=&sysdate9;
%let t=&systime;
%let product=%nrstr(R&D);
/* %put &=product; */

/* Inside PROC PRINT */
proc print data=orion.product_dim;
   where Product_Name contains "&product";
   var Product_Name Product_ID Supplier_Name;
   title1 "Product Names Containing '&product'";
   title2 "Report produced &t &d";
run;

