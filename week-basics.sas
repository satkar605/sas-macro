

/*==============================*/
/*           LEVEL 1             */
/*==============================*/

/*---------------------------------------------------------*/
/* 2. Writing Text to the SAS Log with the %PUT Statement  */
/*---------------------------------------------------------*/
%put Satkar Karki;

/*---------------------------------------------------------*/
/* 3a. Writing NOTE, WARNING, and ERROR Messages           */
/*     to the SAS Log with the %PUT Statement              */
/*---------------------------------------------------------*/
%put NOTE: Is this a SAS note?;
%put WARNING: Is this a SAS warning?;
%put ERROR: Is this a SAS error?;

/* 3b. Answer */
/* Using the colon (:) after NOTE, WARNING, and ERROR makes*/
/* SAS treat them as log message identifiers.              */
/* The output appears in the SAS log with special          */
/* formatting and colors (blue NOTE, green WARNING,        */
/* red ERROR).                                             */

/*---------------------------------------------------------*/
/* 3c. Answer                                              */
/*---------------------------------------------------------*/
%put NOTE- Is this a SAS note?;
%put WARNING- Is this a SAS warning?;
%put ERROR- Is this a SAS error?;

/* Replacing the colon with a hyphen (-) prevents SAS from */
/* recognizing NOTE, WARNING, and ERROR as log identifiers.*/
/* The text still prints, but without the special log      */
/* formatting. The indentation remains intact.             */

/*---------------------------------------------------------*/
/* 3d. Answer                                              */
/*---------------------------------------------------------*/
%put note: Is this a SAS note?;
%put warning: Is this a SAS warning?;
%put error: Is this a SAS error?;

/* Writing NOTE, WARNING, and ERROR in lowercase removes   */
/* the special log formatting completely.                  */
/* The log displays them as plain text strings without     */
/* color or message style.                                 */
/*---------------------------------------------------------*/


/*---------------------------------------------------------*/
/*  Level 2: Writing Special Characters with %PUT          */
/*---------------------------------------------------------*/

%put Can you display a semicolon ; in your %PUT statement?;

/*---------------------------------------------------------*/
/* b. Does the %PUT statement generate any text?           */
/*---------------------------------------------------------*/
/* Yes. The log displays: "Can you display a semicolon".   */
/* The word scanner stops processing at the first semicolon*/
/* it encounters, so the remainder is not included.        */

/*---------------------------------------------------------*/
/* c. Does the %PUT statement generate any error messages? */
/*---------------------------------------------------------*/
/* Yes. SAS issues ERROR 180-322. The semicolon ends the   */
/* %PUT statement early, so the following text is treated  */
/* as invalid SAS code, causing the error.                 */

/*---------------------------------------------------------*/
/* d. Is the second %PUT interpreted as text or keyword?   */
/*---------------------------------------------------------*/
/* It is interpreted as plain text, not as a macro keyword.*/
/* Because the first semicolon ended the statement, the    */
/* second %PUT simply appears in the log as raw text.      */
/*---------------------------------------------------------*/


