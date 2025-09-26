/* Method 1: Use OR operators for parameter validation */

%macro customers(place);
   %let place=%upcase(&place);
   %if &place=AU
   or  &place=CA
   or  &place=DE
   or  &place=IL
   or  &place=TR
   or  &place=US
   or  &place=ZA %then %do;
       proc print data=orion.customer;
          var customer_name customer_address country;
          where upcase(country)="&place";
          title "Customers from &place";
       run;
   %end;
   %else %put ERROR: No customers from &place..;
%mend customers;

options mlogic;

/* This returns customer data from DE because country exists */
%customers(de)

/* aa doesn't exist and isn't a possible parameter, throws an error */
%customers(aa)

/* Method 2: Use the IN operator for parameter validation */
/* IMP: need to pass the minoperator logic while defining the macro to use IN */
/* The macro IN operator does not require parantheses */
/* When using NOT with the IN operator, NOT must precede the IN expression */


%macro customers(place) / minoperator;
   %let place=%upcase(&place);
   %if &place in AU CA DE IL TR US ZA %then %do;       	
      proc print data=orion.customer;
         var customer_name customer_address country;
         where upcase(country)="&place";
         title "Customers from &place";
      run;
   %end;
   %else %put Sorry, no customers from &place..;
%mend customers;

/* This returns customer data from AU because country exists */
%customers(au)

/* zz doesn't exist and isn't a possible parameter, throws an error */
%customers(zz)

/* Method 3: Data-driven parameter evaluation */

%macro customers(place) / minoperator;
   %let place=%upcase(&place);
   proc sql noprint;
      select distinct country into :list separated by ' '
   		 from orion.customer;
   quit;
   %if &place in &list %then %do;             	
	proc print data=orion.customer;
	   var customer_name customer_address country;
         where upcase(country)="&place";
         title "Customers from &place";
      run;
   %end;
   %else %do;
	  %put ERROR: No customers from &place..;
	  %put ERROR- Valid countries are: &list..;
   %end;
%mend customers;

/* This returns customer data from AU because country exists */
%customers(au)

/* zz doesn't exist and isn't a possible parameter, throws an error */
%customers(zz)

