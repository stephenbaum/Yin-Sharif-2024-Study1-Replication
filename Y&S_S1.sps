* Encoding: UTF-8.

*/ load the data in.
GET DATA
  /TYPE=XLSX
  /FILE='/Users/stephenbaum/Desktop/Y&S_S1.xlsx'
  /SHEET=name 'Clean'
  /CELLRANGE=FULL
  /READNAMES=ON
  /DATATYPEMIN PERCENTAGE=95.0
  /HIDDEN IGNORE=YES.
EXECUTE.
DATASET NAME DataSet1 WINDOW=FRONT.

*/ change conditions from strings, add variable labels.

*/ the attention check.
IF (AC = 1 and drink = 1) passac = 1.
IF (AC = 2 and drink = 0) passac = 1.
IF (AC > 2) passac = 0.
IF (AC = 1 and drink ~= 1) passac = 0.
IF (AC = 2 and drink ~= 0) passac = 0.
EXECUTE.

*/ compute the main DV.
IF (drink = 1 and used = 1) likelihood_dv = dv_used_drink_1.
IF (drink = 1 and used = 0) likelihood_dv = dv_un_no_rp_drink_1.
IF (drink = 1 and used = -1) likelihood_dv = dv_unused_rp_drink_1.
IF (drink = 0 and used = 1) likelihood_dv  = dv_used_socks_1.
IF (drink = 0 and used = 0) likelihood_dv = dv_used_no_rp_socks_1.
IF (drink = 0 and used = -1) likelihood_dv = dv_unused_rp_socks_1.
EXECUTE.

*/ exclude people who failed the attention check.
USE ALL.
COMPUTE filter_$=(passac = 1).
VARIABLE LABELS filter_$ 'passac = 1 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

*/ now, look at the main pattern.
*/ this is technically an exploratory test. It is the 2x3.
UNIANOVA likelihood_dv BY drink used
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(drink) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(used) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(drink*used) COMPARE(drink) ADJ(LSD)
  /EMMEANS=TABLES(drink*used) COMPARE(used) ADJ(LSD)
  /PRINT ETASQ DESCRIPTIVE
  /CRITERIA=ALPHA(.05)
  /DESIGN=drink used drink*used.

*/ just the four cells.
IF (used = 1) used_unused = 1.
IF (used = 0) used_unused = 0.
EXECUTE.

*/ the comfirmatory ANOVA.
UNIANOVA likelihood_dv BY drink used_unused
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(OVERALL) 
  /EMMEANS=TABLES(drink) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(used_unused) COMPARE ADJ(LSD)
  /EMMEANS=TABLES(drink*used_unused) COMPARE(drink) ADJ(LSD)
  /EMMEANS=TABLES(drink*used_unused) COMPARE(used_unused) ADJ(LSD)
  /PRINT ETASQ DESCRIPTIVE
  /CRITERIA=ALPHA(.05)
  /DESIGN=drink used_unused drink*used_unused.

*/ look at the simple effects in just the OG conditions.
*/ split the file based on drink/socks.
SORT CASES  BY drink.
SPLIT FILE SEPARATE BY drink.

*/ the one-way ANOVA.
ONEWAY likelihood_dv BY used
  /ES=OVERALL
  /STATISTICS DESCRIPTIVES 
  /PLOT MEANS
  /MISSING ANALYSIS
  /CRITERIA=CILEVEL(0.95)
  /POSTHOC=LSD ALPHA(0.05).

*/ look at the people who gave 1s and 0s for the content coding.

*/ first, manually coded some responses.
*/ 62a3be0d93b8dd1e69b4317d manually coded as 0.
*/ 6526e6db8f0e2069023a4ba4 manually coded as 1.
*/ 631c8e97db06f601f81bd82f manually coded as 0.
*/ 5aa44687dbdb470001ef463f manually coded as 0.
*/ 65e3d52e5393504e7132920b manually coded as 1.
*/ 5fb2c8b4b04a8594fc0a3825 manually coded as 0.
*/ 65e85ad0d2ec2a33602e60ea manually coded as 0.
*/ 5c560b6fccb08c0001e134a8 manually coded as 0.
*/ 5b1487d330d562000155f1c7 manually coded as 0.
*/ 5c4fa169ee5ae100010a2057 manually removed coding.
*/ 646f77d9a7d75c8264dba865 manually removed coding.
*/ 546e3778fdf99b2bc7ebcff6 manually removed coding.
*/ 63b6cee06aaa9fc9669b8cc2 manually removed coding.
*/ 5dcea7314d51e4107516c80d manually removed coding.
*/ 6140e1974c9dae116f8dbcc4 manually removed coding.

*/ now, look to see how these differ by condition.

SORT CASES  BY clothes_code used.
SPLIT FILE SEPARATE BY clothes_code used.

DESCRIPTIVES VARIABLES=likelihood_dv
  /STATISTICS=MEAN STDDEV MIN MAX.

*/ turn the split file off.
SPLIT FILE OFF.



