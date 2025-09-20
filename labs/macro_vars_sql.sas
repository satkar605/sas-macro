*m104d05a;

/*---------------------------------------------------------*/
/* Topic      : Creating Macro Variables in SQL             */
/* Goal       : Practice SELECT ... INTO, trimming, lists,  */
/*              and inspecting macro variables              */
/*---------------------------------------------------------*/


/*--------------------------------------------------------------------
   STEP 1 — Single macro variable via INTO:
   - Creates one macro variable (&total) on the fly from a query.
   - Here we sum TOTAL_RETAIL_PRICE for 2011, order_type=3.
   - Note: FORMAT in SELECT can introduce padding (fixed width).
--------------------------------------------------------------------*/
proc sql noprint;
   select sum(total_retail_price) format=dollar8. into :total
      from orion.order_fact
      where year(order_date)=2011 and order_type=3;
quit;

%put &=total;

/*--------------------------------------------------------------------
   Trimming trick:
   - A self-assignment with %LET removes leading/trailing blanks that
     may be introduced by the formatted SELECT ... INTO value.
--------------------------------------------------------------------*/
%let total=&total;
%put &=total;


/*--------------------------------------------------------------------
   STEP 2 — Multiple macro variables via INTO:
   - OUTOBS=3 keeps the top 3 rows after ORDER BY (largest first).
   - :price1-:price3 creates &price1, &price2, &price3.
   - :date1-:date3  creates &date1,  &date2,  &date3 (MM/DD/YYYY).
----------------------------------
