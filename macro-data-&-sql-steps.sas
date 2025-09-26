
/* DSCI 519    : Advanced Business Analytics Modeling      */
/* Deliverable : Week 4 Homework                           */
/* Author      : Satkar Karki                              */
/* Submitted To: Dr. Hanus                                 */
/*---------------------------------------------------------*/

/*--------------------------------------------------------------------
   LEVEL 1: Creating Macro Variables with the SYMPUTX Routine
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Boilerplate report (hard-coded "Audit")
--------------------------------------------------------------*/

data staff;
   keep employee_ID job_title salary gender;
   set orion.staff;
   where job_title contains 'Audit';
run;

proc print data=staff;
	sum salary;
   title 'Audit Staff';
run;

title;

/*--------------------------------------------------------------
   Step b: Parameterize job title with %LET
--------------------------------------------------------------*/
%let job=Audit;

data staff;
   keep employee_ID job_title salary gender;
   set orion.staff;
   where job_title contains "&job";
run;

proc print data=staff;
	sum salary;
   title "&job Staff";
run;

title;

/*--------------------------------------------------------------
   Step c: Change parameter value to Analyst
--------------------------------------------------------------*/
%let job=Analyst;

data staff;
   keep employee_ID job_title salary gender;
   set orion.staff;
   where job_title contains "&job";
run;

proc print data=staff;
	sum salary;
   title "&job Staff";
run;

title;

/*--------------------------------------------------------------
   Step d: Add &avg via SYMPUTX (avg Analyst salary in footnote)
--------------------------------------------------------------*/
%let job=Analyst;

data staff;
	keep employee_ID job_title salary gender;
	set orion.staff end=final;
	where job_title contains "&job";
	cnt +1; *running count;
	sumsal + salary; *running total;
	if final then do;
		if cnt>0 then call symputx('avg', put(sumsal/cnt, dollar12.));
		else call symputx('avg', 'N/A');
	end;
run;

proc print data=staff;
	sum salary;
	title "&job Staff";
	footnote "Average Salary: &avg";
run;

title;
footnote;

/*--------------------------------------------------------------------
   LEVEL 2: Creating Macro Variables with the SYMPUTX Routine
           (Top Customer by Total Purchase)
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Summarize spend per customer and sort descending
--------------------------------------------------------------*/

proc means data=orion.order_fact sum nway noprint; 
   var Total_Retail_Price;
   class Customer_ID;
   output out=customer_sum sum=CustTotalPurchase;
run;

proc sort data=customer_sum ;
   by descending CustTotalPurchase;
run;

proc print data=customer_sum(drop=_type_);
run;

/*--------------------------------------------------------------
   Observation (from part a):
   The table lists 75 customers ranked by total spend, with
   Customer_ID = 16 at the top at $6,545.90 across 25 orders and
   Customer_ID = 1684 ranking last with $18.80 spent through a
   single order. Each row is one Customer_ID, aggregating all rows
   in the order_fact table for that customer.
--------------------------------------------------------------*/
 
/*--------------------------------------------------------------
   Step b: Capture top Customer_ID in &top and print their orders
--------------------------------------------------------------*/
/* create &top from the top row */
data _null_;
	set customer_sum(obs=1);
	call symputx('top', Customer_ID);
run;

/* print only the top customer's order */
proc print data=orion.order_fact noobs;
	where customer_ID=&top;
	var Order_ID Order_Type Order_Date Delivery_Date;
	title "Orders for Customer &top - Orion's Top Customer";
run;

title;

/*--------------------------------------------------------------------
   LEVEL 1: Creating a Series of Macro Variables with SYMPUTX
--------------------------------------------------------------------*/

options mcompilenote=all;
title; 
footnote;

/*--------------------------------------------------------------
   Step a: Boilerplate Macro (given)
   - Prints members for a given Customer_Type_ID (id)
--------------------------------------------------------------*/
%macro memberlist(id=1020);
   %put _user_;
   title "A List of &id";
   proc print data=orion.customer;
      var Customer_Name Customer_ID Gender;
      where Customer_Type_ID=&id;
   run;
%mend memberlist;

/* Example call (given) */
%memberlist()

/*--------------------------------------------------------------
   Step b: Build series of macros TYPExxxx from CUSTOMER_TYPE
   - Creates: type1010, type1020, … with the text of Customer_Type
   - Place BEFORE the (re)definition used in Step c
--------------------------------------------------------------*/
data _null_;
  set orion.customer_type(keep=Customer_Type_ID Customer_Type);
  /* Use || as taught: convert ID to char, strip blanks, then concatenate */
  call symputx('type' || strip(put(Customer_Type_ID, best.)),
               Customer_Type);
run;

/* quick check */
%put &=type1010 &=type1020 &=type2030;

/*--------------------------------------------------------------
   Step c: Modify TITLE to use an INDIRECT reference
   - &&type&id resolves to the correct type text for current &id
--------------------------------------------------------------*/
%macro memberlist(id=1020);
  title "A List of &&type&id";
  proc print data=orion.customer;
    var Customer_Name Customer_ID Gender;
    where Customer_Type_ID=&id;
  run;
%mend memberlist;

/* Example call with default (1020) */
%memberlist()

/*--------------------------------------------------------------
   Step d: Call the macro again with id=2030
--------------------------------------------------------------*/
%memberlist(id=2030)

/* Cleanup titles */
title; 
footnote;

/*---------------------------------------------------------*/
/* Level 1 : Creating Macro Variables using SQL            */ 
/*---------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Boilerplate (MEANS + DATA step -> &Quant, &Price)
--------------------------------------------------------------*/
%let start=01Jan2011;
%let stop=31Jan2011;

proc means data=orion.order_fact noprint;
   where order_date between "&start"d and "&stop"d;
   var Quantity Total_Retail_Price;
   output out=stats mean=Avg_Quant Avg_Price;
   run;

data _null_;
   set stats;
   call symputx('Quant',put(Avg_Quant,4.2));
   call symputx('Price',put(Avg_Price,dollar7.2));
run;

proc print data=orion.order_fact noobs n;
   where order_date between "&start"d and "&stop"d;
   var Order_ID Order_Date Quantity Total_Retail_Price;
   sum Quantity Total_Retail_Price;
   format Total_Retail_Price dollar6.;
   title1 "Report from &start to &stop";
   title3 "Average Quantity: &quant";
   title4 "Average Price: &price";
run;

/*--------------------------------------------------------------
   Observation (Step b):
   In January 2011, 13 orders totaled $2,261 with 28 units sold
   — Avg Quantity = 2.15, Avg Price = $173.89.
--------------------------------------------------------------*/


/*--------------------------------------------------------------
   Step c: Delete macro variables &Quant and &Price
--------------------------------------------------------------*/
%symdel quant price;

/*--------------------------------------------------------------
 Step d: Replace PROC MEANS + DATA _NULL_ with a single PROC SQL
--------------------------------------------------------------*/
proc sql noprint;
	select 
		mean(quantity) format=4.2,
		mean(total_retail_price) format=dollar7.2
	into :quant, :price
	from orion.order_fact
	where order_date between "&start"d and "&stop"d;
quit;

/* Trim any padding introduced by format */
%let quant=&quant;
%let price=&price;


/*--------------------------------
  Step e: Re-run the same PROC PRINT 
---------------------------------*/
proc print data=orion.order_fact noobs n;
   where order_date between "&start"d and "&stop"d;
   var Order_ID Order_Date Quantity Total_Retail_Price;
   sum Quantity Total_Retail_Price;
   format Total_Retail_Price dollar6.;
   title1 "Report from &start to &stop";
   title3 "Average Quantity: &quant";
   title4 "Average Price: &price";
run;

/*---------------------------------------------------------*/
/* Level 2 : Creating a List of Values in a Macro Variable */
/*---------------------------------------------------------*/

/* Step a: Create &top3 with OUTOBS=3 and SELECT ... INTO: */
proc sql noprint outobs=3;
	select customer_id
		into :top3 separated by ', '
	from (
		select customer_id, sum(Total_Retail_Price) as total
	    from orion.order_fact
	    group by Customer_ID) as s
	order by s.total desc;
quit;

/* Check the top3 customer ids */
%put &=top3;

/* Step b: Print the top 3 customers from CUSTOMER_DIM */
proc print data=orion.customer_dim noobs;
	where Customer_ID in (&top3);
	var Customer_ID Customer_Name Customer_Type;
	title 'Top 3 Customers';
run;
