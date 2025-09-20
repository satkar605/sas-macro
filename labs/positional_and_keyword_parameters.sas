/* MACRO PARAMETER  */
/* TYPES */
/* 1) POSITIONAL PARAMETER */
/* 2) KEYWORD PARAMETER */
/*  */
/* SYNTAX */

%MACRO MACRONAME(INPUT=,OUTPUT=,VAR=);
	SAS STATEMENT;
%MEND MACRONAME;

/* 1) POSITIONAL PARAMETER */
%macro final (d1,d2,d3);
	proc sort data=&d1. out=&d2.; 
	by &d3.;
	run;
%mend final;
%final (sashelp.class,report,age); --> /* This creates a new output file sorted by age. */
%final (sashelp.cars,new,origin); --> /* This creates a new output file sorted by origin of the car. */
%final (sashelp.cars,new2, Type);

/* - The sequence in which the paramaters are defined must be consistent to how they are called out. */
/* - The position matters.  */

/* 2) KEYWORD PARAMETER */
%macro final (d1=, d2=, d3=);
	proc sort data=&d1. out=&d2.;
	by &d3.;
	run;
%mend final;

%final (d2=report,d1=sashelp.class,d3=age);
%final (d3=origin, d1=sashelp.cars, d2=brandnew);

/* In keyword parameter, we can change the order of the parameters. */


%macro ty (r1);
	proc print data=$r1.;
	run;
%mend ty;
%ty(sashelp.class);