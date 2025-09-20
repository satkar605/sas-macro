*m104d03a;
/* Step 1: Harcode Customer_ID and Customer_Name */
proc print data=orion.order_fact;
   where customer_ID=9; 
   var order_date order_type quantity total_retail_price;
   title1 "Customer Number: 9";
   title2 "Customer Name: Cornelia Krahl";
run;

title;

/* Step 2: Use macrovar for Customer ID and hardcode Customer Name still */
%let custID=9;

proc print data=orion.order_fact;
   where customer_ID=&custID; *same WHERE statement;
   var order_date order_type quantity total_retail_price;
   title1 "Customer Number: &custID";
   title2 "Customer Name: Cornelia Krahl";
run;

title;

/* Step 3: Add a DATA step to create a macro variable with the customer's name. */
%let custID=9;

data _null_;
	set orion.customer;
	where customer_ID=&custID; *same WHERE statement;
	call symputx('name', Customer_Name);
run;

proc print data=orion.order_fact;
   where customer_ID=&custID; *same WHERE statement;
   var order_date order_type quantity total_retail_price;
   title1 "Customer Number: &custID";
   title2 "Customer Name: &name";
run;

title;

/* If we drop the WHERE statement, it will overwrite and give the last customer */
/* To improve over this situation, it is recommended to create a series of macro variables */

/* Step 4: Create a series of macro variables to store customer names */
data _null_;
	set orion.customer;
	call symputx('name'||left(Customer_ID),
		Customer_Name);
run;

%put _user_; * check log for the series of macro variables created;

/* referencing the name without returning the DATA step */
%let custID=9;
proc print data=orion.order_fact;
	where customer_ID=&custID;
	var order_date order_type quantity total_retail_price;
	title1 "Customer Number: &custID";
	title2 "Customer Name: &name9";
run;

/* if we were to change the customer id, we would need to change the values twice */
/* once in the %let call and other while calling the customer name in title2 */
/* this is where indirect references to macro variables come in handy */

/* Step 5: Use an indirect reference (&&) */
%let custID=4;
proc print data=orion.order_fact;
	where customer_ID=&custID;
	var order_date order_type quantity total_retail_price;
	title1 "Customer Number: &custID";
	title2 "Customer Name: &&name&custID";
run;
