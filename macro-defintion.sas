
/*--------------------------------------------------------------------
   LEVEL 2: Storing a Macro
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Define the Macro "TUT"
   - Creates a simple macro that writes "king tut"
--------------------------------------------------------------*/

options mcompilenote=all;

%macro tut;
   king tut
%mend tut;

/*--------------------------------------------------------------
   Step b: Compilation Check
   - The SAS log confirms: 
     "The macro TUT completed compilation without errors."
--------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step c: Verify the Temporary Macro
   - Display contents of the WORK.SASMACR catalog
   - This shows macros currently compiled in the WORK library
--------------------------------------------------------------*/
proc catalog cat=work.sasmacr;
  contents;
  title "Temporary Macros in WORK.SASMACR";
quit;

/*--------------------------------------------------------------
   Step d: Delete the Macro
   - Use %SYSMACDELETE to remove TUT
   - Re-check catalog contents after deletion
--------------------------------------------------------------*/
%sysmacdelete tut;

proc catalog cat=work.sasmacr;
  contents;
  title "Temporary Macros After Deletion";
quit;

/*--------------------------------------------------------------------
   LEVEL 1: Defining and Using Macro Parameters
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Boilerplate & Original Macro
   - Enable compile notes; clear TITLE/FOOTNOTE
   - Include the original macro (no parameters) per the exercise
--------------------------------------------------------------*/
options mcompilenote=all;
title;
footnote;

%macro customers;
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
      title "&type Customers";
   run;
%mend customers;

/*--------------------------------------------------------------
   Step b: Convert to a positional parameter
--------------------------------------------------------------*/
%macro customers(type);
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
      title "&type Customers";
   run;
%mend customers;

/*--------------------------------------------------------------
   Step c: Call with Gold
--------------------------------------------------------------*/
%customers(Gold);

/*--------------------------------------------------------------
   Step d: Call with Catalog
--------------------------------------------------------------*/
%customers(Catalog);

/*--------------------------------------------------------------
   Step e: Change to a keyword parameter with default Club
--------------------------------------------------------------*/
%macro customers(type=Club);
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
      title "&type Customers";
   run;
%mend customers;

/*--------------------------------------------------------------
   Step f: Call with Internet
--------------------------------------------------------------*/
%customers(type=Internet);

/*--------------------------------------------------------------
   Step g: Call using the default (Club)
--------------------------------------------------------------*/
%customers();

/*--------------------------------------------------------------------
   LEVEL 2: Using a Macro to Generate PROC MEANS Code
--------------------------------------------------------------------*/

/*--------------------------------------------------------------
   Step a: Boilerplate code
   - Start with the given PROC MEANS program
--------------------------------------------------------------*/
options nolabel;
title 'Order Stats';
proc means data=orion.order_fact maxdec=2 mean;
   var total_retail_price;
   class order_type;
run;
title;

/*--------------------------------------------------------------
   Step b: Create a macro with keyword parameters + defaults
   - stats=       -> statistics keywords
   - decimals=    -> number of decimal places
   - analysis=    -> analysis variables
   - class=       -> class variables
--------------------------------------------------------------*/
%macro order_means(
   stats=mean,
   decimals=2,
   analysis=total_retail_price,
   class=order_type
);
   options nolabel;
   title 'Order Stats';
   proc means data=orion.order_fact maxdec=&decimals. &stats.;
      var &analysis.;
      class &class.;
   run;
   title;
%mend order_means;

/*--------------------------------------------------------------
   Step c: Execute macro with defaults
--------------------------------------------------------------*/
%order_means();

/*--------------------------------------------------------------
   Step d: Override ALL parameters
--------------------------------------------------------------*/
%order_means(
   stats=N NMISS MIN MEAN MAX RANGE,
   decimals=3,
   analysis=total_retail_price costprice_per_unit,
   class=order_type quantity
);

/*--------------------------------------------------------------
   Step e: Override ONLY statistics and decimal places
--------------------------------------------------------------*/
%order_means(
   stats=MAX MIN RANGE,
   decimals=1
);


