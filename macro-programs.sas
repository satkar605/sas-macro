/* DSCI 519    : Advanced Business Analytics Modeling      */
/* Exercise    : 05_Macro Programs                         */
/* Author      : Satkar Karki                              */
/* Submitted To: Dr. Hanus                                 */
/*---------------------------------------------------------*/

/*--------------------------------------------------------------------
   LEVEL 1: Conditionally Processing Complete Statements
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Starter Macro (given)
--------------------------------------------------------------*/

options mprint mlogic;

%macro listing(custtype);
	proc print data=orion.customer noobs;
	run;
%mend listing;

%listing(2010)

/*--------------------------------------------------------------
   Step b: Add conditional logic on CUSTTYPE
   - If CUSTTYPE is blank: show ID, Name, and Type_ID (all rows).
   - If CUSTTYPE is provided: filter by Customer_Type_ID and show
     ID and Name with a type-specific title.
--------------------------------------------------------------*/

%macro listing(custtype);
	proc print data=orion.customer noobs;
	%if &custtype =  %then %do;
		var Customer_ID Customer_Name Customer_Type_ID;
		title 'All Customers';
	%end;
	%else %do;
		where Customer_Type_ID=&custtype;
		var Customer_ID Customer_Name;
		title "Customer Type: &custtype";
	%end;
	run;
%mend listing;

/*--------------------------------------------------------------
   Step c: Exercise the macro
   - Null call → all customers.
   - Support step → quick lookup of valid Customer_Type_ID values.
   - Valid calls → filtered listings for selected types.
--------------------------------------------------------------*/

%listing()

/* this procedure lists the lookup for customer-type-id */
proc freq data=orion.customer;
   tables Customer_Type_ID / nocum nopercent;
run;

/* Calling amacro using valid values of CUSTTYPE */
%listing(2010)
%listing(1030)

/*--------------------------------------------------------------------
   LEVEL 1: Validating a Macro Parameter
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Boilerplate macro (given)
   - Takes TYPE as parameter
   - Converts TYPE to uppercase
   - Prints customers whose Customer_Group matches TYPE
--------------------------------------------------------------*/

options mlogic;

%macro custtype(type);
   %let type=%upcase(&type);
   proc print data=orion.customer_dim;
      var Customer_Group Customer_Name Customer_Gender  
          Customer_Age;
      where upcase(Customer_Group) contains "&type";
      title "&type Customers";
   run;
%mend custtype;

/* Example call */
%custtype(internet)

/* Quick lookup of customer group values */
proc freq data=orion.customer_dim;
   tables Customer_Group / nocum nopercent;
run;

/*--------------------------------------------------------------
   Step b: Validate TYPE with IF–ELSE
   - Only GOLD or INTERNET are valid
   - Log ERROR message otherwise
--------------------------------------------------------------*/
%macro custtype(type) / minoperator;
   %let type=%upcase(&type);
   %if &type in GOLD INTERNET %then %do;
      proc print data=orion.customer_dim;
         var Customer_Group Customer_Name Customer_Gender  
             Customer_Age;
         where upcase(Customer_Group) contains "&type";
         title "&type Customers";
      run;
   %end;
   %else %do;
      %put ERROR: Invalid TYPE: &type.;
      %put ERROR: Valid TYPE values are INTERNET or GOLD.;
   %end;
%mend custtype;

/* Example calls */
%custtype(internet)
%custtype(GOLD)
%custtype(abc)   /* logs the two ERROR lines */

/*--------------------------------------------------------------
   Step d: Add null check before validation
   - If TYPE is missing → log ERROR, skip PROC PRINT
   - If TYPE is present → convert to uppercase and validate
--------------------------------------------------------------*/
%macro custtype(type) / minoperator;
   %if &type = %then %do;
      %put ERROR: Missing TYPE.;
      %put ERROR: Valid TYPE values are INTERNET or GOLD.;
      %return;
   %end;
   %let type=%upcase(&type);
   %if &type in GOLD INTERNET %then %do;
      proc print data=orion.customer_dim;
         var Customer_Group Customer_Name Customer_Gender  
             Customer_Age;
         where upcase(Customer_Group) contains "&type";
         title "&type Customers";
      run;
   %end;
   %else %do;
      %put ERROR: Invalid TYPE: &type.;
      %put ERROR: Valid TYPE values are INTERNET or GOLD.;
   %end;
%mend custtype;

/*--------------------------------------------------------------
   Step e: Test the macro
   - Null parameter
   - Valid values (upper, lower, mixed case)
   - Invalid value
--------------------------------------------------------------*/

%custtype()          /* null */
%custtype(GOLD)      /* uppercase */
%custtype(internet)  /* lowercase */
%custtype(GoLd)      /* mixed case */
%custtype(Silver)    /* invalid */


/*--------------------------------------------------------------------
   LEVEL 1: 6. Using Macro Loops and Indirect References
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Starter code
--------------------------------------------------------------*/
title; 
footnote; 

proc means data=orion.order_fact sum mean maxdec=2;
   where Order_Type=1;
   var Total_Retail_Price CostPrice_Per_Unit;  
   title "Summary Report for Order Type 1";
run;

/*--------------------------------------------------------------
   Step  b. Using Macro Loop for iteratively process 
   Order_Type from 1 to 3
--------------------------------------------------------------*/

%macro mean;
	%do t=1 %to 3;
		proc means data=orion.order_fact sum mean maxdec=2;
		   where Order_Type=&t;
		   var Total_Retail_Price CostPrice_Per_Unit;  
		   title "Summary Report for Order Type &t";
		run;
	%end;
%mend mean;

%mean

/*--------------------------------------------------------------
 Step  c. Create macro variables TYPE1-TYPEn from lookup table 
- TYPE&START = LABEL
- NUMTYPES = number of distinct order types 
--------------------------------------------------------------*/

%macro maketypes;
	data _null_;
		set orion.lookup_order_type end=last;
/* Create TYPE1, TYPE2, ... using START as the index */
		call symputx('type' || left(start), label);
/* Count total rows -> create macro variable numtypes  */
		if last then call symputx('numtypes', _n_);
	run;
%mend maketypes;

/* Create the macro variables */
%maketypes

/* Check for existence of the macro variables */
%put &=type1 &=type2 &=type3;
%put &=numtypes;


/*--------------------------------------------------------------
   Step d: Loop using ENDLOOP and indirect TYPE reference
--------------------------------------------------------------*/

/* Create TYPE1-TYPEn and ENDLOOP from the lookup table */
data _null_;
	set orion.lookup_order_type end=last;
	call symputx('type' || left(start), label);
	if last then call symputx('endloop', _n_); 
run;

/* Generate one PROC MEANS per order type using data-driven loop */
%macro mean;
 %do i = 1 %to &endloop;
 	proc means data=orion.order_fact sum mean maxdec=2;
 		where Order_Type = &i;
 		var Total_Retail_Price CostPrice_Per_Unit;
 		title "Summary Report for &&type&i";
 	run;
 %end;
%mend mean;

/* Run the data-driven set of reports */
%mean

/*--------------------------------------------------------------------
   LEVEL 2: 7. Generating Data-Dependent Steps
--------------------------------------------------------------------*/

options mprint mlogic;

/*--------------------------------------------------------------
   Step a: Starter code
--------------------------------------------------------------*/
title; 
footnote; 

%macro tops(obs=3);
    proc means data=orion.order_fact sum nway noprint; 
       var Total_Retail_Price;
       class Customer_ID;
       output out=customer_freq sum=sum;
    run;

    proc sort data=customer_freq;
       by descending sum;
    run;

    data _null_;
       set customer_freq(obs=&obs);
       call symputx('top'||left(_n_), Customer_ID);
    run;
%mend tops;

%tops()
%tops(obs=5)

/*--------------------------------------------------------------
   Step b: Print Listing of Top X Customers
   - After creating TOP1-TOPX, build hte IN list via a macro loop
   - Show Customer_ID, Customer_Name, Customer_Type from CUSTOMER_DIM
-------------------------------------------------------------------*/
%macro tops(obs=3);
	proc means data=orion.order_fact sum nway noprint; 
       var Total_Retail_Price;
       class Customer_ID;
       output out=customer_freq sum=sum;
    run;
    
    proc sort data=customer_freq;
       by descending sum;
    run;
    
   data _null_;
      set customer_freq(obs=&obs);
      call symputx(cats('top', _n_), Customer_ID);
   run;
   
/* Print Top X custmers using a dynamic IN list */
	proc print data=orion.customer_dim noobs;
		where Customer_ID in (
			%do i=1 %to &obs; 
				&&top&i %end;
			);
		var Customer_ID Customer_Name Customer_Type;
		title "Top &obs Customers";
	run;
%mend tops;

/* Perform SAS log checks to verify */
%tops()
%tops(obs=5)


/*--------------------------------------------------------------------
   Level 1 - 8. Understanding Symbol Tables
--------------------------------------------------------------------*/

options mprint mlogic;

/*------------------------------------------------------------------
Answer a: Macro variable DOG is stored in the Global Symbol Table 
-------------------------------------------------------------------*/
%let dog=Paisley;
%macro whereisit;
   %put My dog is &dog;
%mend whereisit;

%whereisit


/*--------------------------------------------------------------
Answer b: Macro variable DOG is stored in the Local Symbol Table
--------------------------------------------------------------*/
%macro whereisit;
   %let dog=Paisley;
   %put My dog is &dog;
%mend whereisit;

%whereisit

/*--------------------------------------------------------------
Answer c: Macro variable DOG is stored in the Global Symbol Table
--------------------------------------------------------------*/
%macro whereisit(dog);
   %put My dog is &dog;
%mend whereisit;

%whereisit(Paisley)


