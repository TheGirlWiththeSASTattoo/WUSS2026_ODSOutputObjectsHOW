options ps=55 ls=175 validvarname=v7 dlcreatedir nodate nonumber;
options fmtsearch=(work in1);

*******************************************************************;
*** WUSS2026_ODSOutput_Exercises          			***;
*** Program Author: Louise Hadden                               ***;
*** Purpose: Demonstrate ODS Output Objects                     ***;
*** Input(s): SASHELP.HEART                                     ***;
*** Output(s): HEART, ODS OUTPUT		        	***;
*** Modifications: (date/initials/reason)                       ***;
*** Set up for DM                                               ***;
*******************************************************************;

*******************************************************************;
***	Parameters:						***;
*******************************************************************;

ods noproctitle;

***>>STEP1: replace indir with the directory you are working in;
%let indir=work;

libname in1 "&indir.";
filename odsout "&indir.";
run;

title1 "WUSS 2026: ODS Output";
footnote1 "Last Run &sysdate. &systime - By &sysuserid";
run;

*******************************************************************;
***	Create formats for revised HEART data set 		***;
*******************************************************************;
***>>STEP2: run PROC FORMAT and review FMTLIB output;
proc format library=work fmtlib;
	value bmi_catf	1 = 'Underweight (<18.5)'
			2 = 'Healthy Weight (<18.5-<25)'
			3 = 'Overweight (<25-<30)'
			4 = 'Obesity (30+)';

	value obesityf	1 = 'Not Obese'
			2 = 'Class 1 Obesity'
			3 = 'Class 2 Obesity'
			4 = 'Class 3 Obesity (Severe)';
run;
quit;

*******************************************************************;
***	Create revised HEART data set           		***;
*******************************************************************;
***>>STEP3: Create revised HEART data set;

*** subroutine - enhance the SASHELP.HEART data set;

data heart (label="Enhanced version of SASHELP.HEART");
    set sashelp.heart;

*** create missing variable labels;
    label 	status="Status"
	      	sex="Sex"
		height="Height"
		weight="Weight"
		Diastolic="Diastolic Blood Pressure"
		Systolic="Systolic Blood Pressure"
		Smoking="Smoking Status"
		Cholesterol="Cholesterol Status";

*** create a faux group variable;
	HeartID=modz(_n_,4);

*** create a faux id;
	SeqNum=_n_;

*** create a faux weight;
	SampleWeight = 1 + (mod(_n_,10)*.1);

*** create BMI variables;
    bmi= weight / height**2 * 703;
	select;
		when (1 le bmi lt 18.5) bmi_cat = 1;
		when (18.5 le bmi lt 25) bmi_cat = 2;
		when (25 le bmi lt 30) bmi_cat = 3;
		when (30 le bmi) bmi_cat = 4;
		otherwise  bmi_cat = .;
	end;
	select;
		when (1 le bmi lt 30) obesity_cat = 1;
		when (30 le bmi lt 35) obesity_cat = 2;
		when (35 le bmi lt 40) obesity_cat = 3;
		when (40 le bmi) obesity_cat = 4;
		otherwise  obesity_cat = .;
	end;
	select;
	    when (sex='Female') female = 1;
		otherwise  female = 0;
	end;
	select;
	    when (sex='Male') male = 1;
		otherwise male = 0;
	end;


	label 	HeartID="Heart Group Variable"
	      	SeqNum="Sequence Number"
	      	bmi="BMI"
		bmi_cat="BMI Category"
		obesity_cat="Obesity Category"
		SampleWeight="Sample Weight"
		male="Binary: Male"
		female="Binary: Female";

run;

*******************************************************************;
***	PROC Contents Collate (Default)		                ***;
*******************************************************************;
***>>STEP4: Run Default PROC CONTENTS on revised HEART data set and examine results;
***>>NOTE: Default PROC CONTENTS presents variables sorted by alphabetic order;
***>>NOTE: This is also known as COLLATE;
***>>NOTE: Notice how many pieces the output is in; 

*** Default PROC CONTENTS;

proc contents data=heart;
title2 "Contents of Heart - Collate";
run;

title2;
run;

*******************************************************************;
***	PROC Contents VARNUM					***;
*******************************************************************;
***>>STEP5: Run PROC CONTENTS VARNUM on revised HEART data set and examine results;
***>>NOTE: Default PROC CONTENTS presents variables sorted by position;
***>>NOTE: Position is the order the variables appear in the PDV (Program Data Vector);
***>>NOTE: Notice how the output differs from the COLLATE PROC CONTENTS; 

*** PROC CONTENTS VARNUM;

proc contents data=heart varnum;
title2 "Contents of Heart - Varnum";
run;

title2;
run;

*******************************************************************;
***	PROC Contents Out=					***;
*******************************************************************;
***>>STEP6: Run PROC CONTENTS VARNUM on revised HEART data set and output out= data set;
***>>NOTE: What variables appear in the rectangular data base, and at what levels;
***>>NOTE: Do any / all of these variables appear in the listing contents;
***>>NOTE: Notice how the output differs from the COLLATE PROC CONTENTS; 
***>>STEP6A: Run a test print and a contents on the out= data set and examine;

*** PROC CONTENTS with OUTPUT data set;

proc contents data=heart out=contents_out1_heart noprint;
title2 "Contents with OUT= data set";
run;

proc print data=contents_out1_heart (obs=5) noobs;
title2 "Test Print of OUT= data set";
run;

proc contents data=contents_out1_heart;
title2 "Contents of OUT= data set";
run;

title2;
run;

*******************************************************************;
***	Using ODS Trace						***;
*******************************************************************;
***>>STEP7: Run PROC CONTENTS ORDER=COLLATE on revised HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 

*** PROC CONTENTS COLLATE with ODS TRACE data set;

ods trace on / listing;

proc contents data=heart order=collate;
title2 "Contents of Heart - Order=Collate - ODS TRACE";
run;

ods trace off;

*******************************************************************;
***	Using ODS Trace			                        ***;
*******************************************************************;
***>>STEP7: Run PROC CONTENTS ORDER=COLLATE on revised HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS COLLATE with ODS TRACE data set;

ods trace on / listing;

proc contents data=heart order=collate;
title2 "Contents of Heart - Order=Collate - ODS TRACE";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects				***;
*******************************************************************;
***>>STEP8: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP8: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP8: PROC CONTENTS and test prints on each ODS output file; 


ods output attributes=attributes1 enginehost=enginehost1 variables=variables1;

proc contents data=heart order=collate;
title2 "Collate contents with ODS OUTPUT objects";
run;

ods output close;

proc contents data=attributes1;
title2 "Contents of Attributes ODS Output (Collate)";
run;

proc print data=attributes1 (obs=5) noobs;
title2 "Test Print Attributes ODS Output (Collate)";
run;

proc contents data=enginehost1;
title2 "Contents of Engine Host ODS Output (Collate)";
run;

proc print data=enginehost1 (obs=5) noobs;
title2 "Test Print Engine Host ODS Output (Collate)";
run;

proc contents data=Variables1;
title2 "Contents of Variables ODS Output (Collate)";
run;

proc print data=Variables1 (obs=5) noobs;
title2 "Test Print Variables ODS Output (Collate)";
run;

*******************************************************************;
***	Using ODS Trace						***;
*******************************************************************;
***>>STEP9: Run PROC CONTENTS ORDER=VARNUM on revised HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with ODS TRACE data set;

ods trace on / listing;

proc contents data=heart order=varnum;
title2 "Contents of Heart - Order=VARNUM - ODS TRACE";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects				***;
*******************************************************************;
***>>STEP10: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP10: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP10: PROC CONTENTS and test prints on each ODS output file; 

ods output attributes=attributes2 enginehost=enginehost2 position=position2;

proc contents data=sashelp.heart order=varnum;
title2 "Varnum contents with ODS OUTPUT objects";
run;

ods output close;

proc contents data=attributes2;
title2 "Contents of Attributes ODS Output (Varnum)";
run;

proc print data=attributes2 (obs=5) noobs;
title2 "Test Print Attributes ODS Output (Varnum)";
run;

proc contents data=enginehost2;
title2 "Contents of Engine Host ODS Output (Varnum)";
run;

proc print data=enginehost2 (obs=5) noobs;
title2 "Test Print Engine Host ODS Output (Varnum)";
run;

proc contents data=Position2;
title2 "Contents of Variables ODS Output (Varnum)";
run;

proc print data=Position2 (obs=5) noobs;
title2 "Test Print Variables ODS Output (Varnum)";
run;

*******************************************************************;
***	Create a sorted version of heart			***;
*******************************************************************;
***>>STEP11: Create a sorted version of the heart data set;

proc sort data=heart out=heart_sorted;
    by seqnum;
run;

*******************************************************************;
***	Using ODS Trace						***;
*******************************************************************;
***>>STEP12: Run PROC CONTENTS ORDER=VARNUM on sorted version of HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with on sorted version of data set;

ods trace on;

proc contents data=heart_sorted varnum;
title2 "Contents on Corrected Data Set - Sorted";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects		                ***;
*******************************************************************;
***>>STEP13: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP13: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP13: PROC CONTENTS and test prints on each ODS output file; ;

ods output sortedby=sortedby;

proc contents data=heart_sorted varnum;
title2 "Contents on Corrected Data Set - ODS Output Sorted By";
run;

ods output close;

ods trace off;

proc contents data=SortedBy;
title2 "Contents of SortedBY ODS Output Object";
run;

proc print data=SortedBY noobs;
title2 'Test Print of SortedBy ODS Output Object';
run;

title2;
run;

*******************************************************************;
***	Create an indexed version of heart			***;
*******************************************************************;
***>>STEP14: Create a sorted version of the heart data set;

ods trace on;

proc contents data=heart_sorted varnum;
title2 "Contents on Corrected Data Set - Sorted";
run;

ods trace off;


*******************************************************************;
***	Using ODS Trace						***;
*******************************************************************;
***>>STEP15: Run PROC CONTENTS ORDER=VARNUM on indexed version of HEART data set and use ODS TRACE;
***>>NOTE: Review the log carefully for output data sets;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with on indexed version of data set;

data heart_index;
    set heart;
run;

proc datasets library=work nolist;
   modify heart_index;
      index create id=(seqnum heartid) / nomiss unique;
quit;

ods trace on;

proc contents data=heart_index varnum;
title2 "Contents on Modified Heart Data Set - Add Index";
run;

ods trace off;

*******************************************************************;
***	Harvesting ODS Output Objects		        	***;
*******************************************************************;
***>>STEP16: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP16: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP16: PROC CONTENTS and test prints on each ODS output file; ;

ods output indexes=indexes;

proc contents data=heart_index varnum;
title2 "Contents on Corrected Data Set - ODS Output Indexes";
run;

ods output close;

proc contents data=indexes varnum;
title2 'Contents of Indexes ODS Output Object';
run;

proc print data=indexes noobs;
title2 'Test Print Indexes ODS Output Object';
run;

***********************************************************************************;
*** End of PROC CONTENTS Exercises						***;
***********************************************************************************;

***********************************************************************************;
*** Start of Statistical Procedure Exercises					***;
***********************************************************************************;

*******************************************************************;
***	Using Univariate Outtable		        	***;
*******************************************************************;
***>>STEP17: Run PROC UNIVARIATE on BMI in the HEART data set and use ODS TRACE;
***>>STEP17: RUN PROC UNIVARIATE OUTTABLE in the HEART data set and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
*** PROC CONTENTS VARNUM with on indexed version of data set;

ods trace on;

proc univariate data=heart;
    var bmi;
title2 "Univariate on BMI";
run;

proc univariate data=heart outtable=heart_outtable noprint;
    var _numeric_;
run;

proc print data=heart_outtable noobs;
title2 "PROC UNIVARIATE OUTTABLE - Heart Numeric Variables";
run;

ods trace off;

ods output moments=moments1 basicmeasures=basicmeasures1 testsforlocation=testsforlocation1
				quantiles=quantiles1 extremeobs=extremeobs1 missingvalues=missingvalues1;

proc univariate data=heart;
    var bmi;
title2 "Univariate on BMI";
run;

ods output close;

*******************************************************************;
***	Harvesting ODS Output Objects				***;
*******************************************************************;
***>>STEP18: Check the Trace Results in the Log and record the temporary data set names;
***>>STEP18: Write an ODS OUTPUT code sandwich to output to work files and close ODS Output;
***>>STEP18: PROC CONTENTS and test prints on each ODS output file; ;

proc contents data=moments1 varnum;
title2 "PROC CONTENTS on UNIVARIATE MOMENTS1 ODS OUTPUT object";
run;

proc print data=moments1 (obs=5) noobs;
title2 "Test print on UNIVARIATE MOMENTS1 ODS OUTPUT object";
run;

proc contents data=basicmeasures1 varnum;
title2 "PROC CONTENTS on UNIVARIATE BASIC MEASURES 1 ODS OUTPUT object";
run;

proc print data=basicmeasures1 (obs=5) noobs;
title2 "Test print on UNIVARIATE BASIC MEASURES 1 ODS OUTPUT object";
run;

proc contents data=testsforlocation1 varnum;
title2 "PROC CONTENTS on UNIVARIATE TESTSFORLOCATION1 ODS OUTPUT object";
run;

proc print data=testsforlocation1 (obs=5) noobs;
title2 "Test print on UNIVARIATE TESTSFORLOCATION1 ODS OUTPUT object";
run;

proc contents data=quantiles1 varnum;
title2 "PROC CONTENTS on UNIVARIATE QUANTILES1 ODS OUTPUT object";
run;

proc print data=quantiles1 (obs=5) noobs;
title2 "Test print on UNIVARIATE QUANTILES1 ODS OUTPUT object";
run;

proc contents data=extremeobs1 varnum;
title2 "PROC CONTENTS on UNIVARIATE EXTREME OBS 1 ODS OUTPUT object";
run;

proc print data=extremeobs1 (obs=5) noobs;
title2 "Test print on UNIVARIATE EXTREME OBS 1 ODS OUTPUT object";
run;

proc contents data=missingvalues1 varnum;
title2 "PROC CONTENTS on UNIVARIATE MISSINGVALUES1 ODS OUTPUT object";
run;

proc print data=missingvalues1 (obs=5) noobs;
title2 "Test print on UNIVARIATE MISSINGVALUES1 ODS OUTPUT object";
run;

*******************************************************************;
***	PROC UNIVARIATE PLOT OUTPUT				***;
*******************************************************************;
***>>STEP19: Sort the HEART data set by sex and create a heartplots data set;
***>>STEP19: Turn on ODS LISTING SGE (SAS Graphics Editor) and ODS GRAPHICS;
***>>STEP19: RUN PROC UNIVARIATE on the HEARTPLOTS data set with the plot option and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
***>>NOTE: Review the files in the log;

proc sort data=heart out=heartplots;
    by sex;
run;


ods listing sge=on;
ods graphics on;
ods trace on;

proc univariate data=heartplots plot;
   by sex;
   var bmi;
title2 "PROC UNIVARIATE PLOTS";
run;
ods graphics off;

ods graphics on;
ods select Plots SSPlots;
proc univariate data=heartplots plot;
   by sex;
   var bmi;
title2 "PROC UNIVARIATE PLOTS";
run;
ods graphics off;
ods select all;
ods trace off;
proc scaproc;
    write;
run;

ods trace on;

proc freq data=heart;
    tables bmi_cat*obesity_cat / missing list;
title2 "Obesity coding test";
run;

ods trace off;

*******************************************************************;
***	PROC LOGISTIC OUTPUT										***;
*******************************************************************;
***>>STEP20: RUN PROC LOGISTIC on the HEART data set and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
***>>NOTE: Review the files in the log;
***>>NOTE: Output Parameter Estimates and Odds Ratios ods output objects;
***>>NOTE: Compare work data sets to see how to match;
***>>NOTE: Massage data sets;
***>>NOTE: Merge data sets;
***>>NOTE: Output Final Spreadsheet as Excel Spreadsheet;

title2 "Logistics";
run;

ods trace on;
ods output parameterestimates=parameterestimates oddsratios=oddsratios;

proc logistic data=heart;
    class sex;
    model status = AgeAtStart 
	               sex
                   mrw 
                   smoking 
				   bmi_cat
                   ;
run;

ods output close;
ods trace off;

proc print data=parameterestimates (obs=20) noobs;
title2 "Logistics Parameter Estimates";
run;

proc contents data=parameterestimates varnum;
run;

proc print data=oddsratios (obs=20) noobs;
title2 "Logistics Odds Ratios";
run;

proc contents data=oddsratios varnum;
run;

title2;
run;

proc format;
	value num2lab 1 = "Age at Start"
	              2 = "Female versus Male"
				  3 = "MRW"
				  4 = "Smoking Status"
				  5 = "BMI Category";
run;

data param;
    length rowlabel $ 40;
    set parameterestimates (where=(variable ne "Intercept"));
    order=_n_;
	rowlabel=put(order,num2lab.);
run;

data odds;
    length rowlabel $ 40;
    set oddsratios;
	if effect="Sex Female vs Male" then effect="Sex";
	order=_n_;
	rowlabel=put(order,num2lab.);
run;

proc print data=param (obs=10) noobs;
run;

proc print data=odds (obs=10) noobs;
run;

proc sort data=param out=param_sort;
    by order;
run;

proc sort data=odds out=odds_sort;
    by order;
run;

data test_design;
    merge param_sort odds_sort;
	by order;
run;

proc print data=test_design (obs=10) noobs;
title2 "Test Designer Data Set";
run;

*******************************************************************;
***	PROC REG OUTPUT	- USE ODS SHOW, SELECT, EXCLUDE 	***;
*******************************************************************;
***>>STEP21: RUN PROC SURVEYFREQ on the HEART data set and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
***>>NOTE: Review the files in the log;
***>>NOTE: Demonstrate ODS SHOW;
***>>NOTE: Demonstrate ODS EXCLUDE;
***>>NOTE: Demonstrate ODS SELECT;
***>>NOTE: Output Fit Statistics and Anova ods output objects;
***>>NOTE: Compare work data sets to see how to match;
***>>NOTE: Massage data sets;
***>>NOTE: No real opportunity for combining file;
***>>NOTE: Graphic outputs are created - ods listing, png, and SGE file;;

ods graphics on;
run;

ods trace on;

ods select all;
run;

ods show;
proc reg data=heart PLOTS(MAXPOINTS=NONE);
  model bmi = weight ageatstart height;
title2 "PROC REG: no selections or exclusions";
run;
quit;

ods select none;
run;

ods select FitStatistics Anova;
ods show;
ods output anova=anova1 fitstatistics=fitstatistics;
proc reg data=heart PLOTS(MAXPOINTS=NONE);
  model bmi = weight ageatstart height;
title2 "PROC REG: SELECT Fit and Anova";
run;
ods output close;
quit;

ods select all;
run;

ods exclude ParameterEstimates;
ods show;

proc reg data=heart PLOTS(MAXPOINTS=NONE);
  model bmi = weight ageatstart height;
  title2 "PROC REG: EXCLUDE parameters";
run;
quit;

ods trace off;
title2;
run;

*******************************************************************;
***	PROC SURVEYFREQ OUTPUT					***;
*******************************************************************;
***>>STEP22: RUN PROC SURVEYFREQ on the HEART data set and use ODS TRACE;
***>>NOTE: Review the files in the results window; 
***>>NOTE: Review the files in the log;
***>>NOTE: Output Summary, Crossstabs, and ChiSq ods output objects;
***>>NOTE: Compare work data sets to see how to match;
***>>NOTE: Transform data sets;
***>>NOTE: Merge or set data sets;
***>>NOTE: Note %SYSFUNC(EXIST) routine to address missing ChiSq;
***>>NOTE: Note Row / No Row Option variants - Choose Row;
***>>NOTE: Output Final Spreadsheet as Excel Spreadsheet;
***>>NOTE: ODS Excel Options;


Proc format;
    value agecatf 1="28 to 37 years"
	              2="38 to 43 years"
				  3="44 to 51 years"
				  4="52+ years";
	value heightcatf 1="51.5 to 62.25 inches"
	                 2="62.26 to 64.25 inches"
					 3="64.26 to 67.5 inches"
					 4="68+ inches";
    value weightcatf 1="67 to 132 lbs"
	                 2="133 to 150 lbs"
					 3="151 to 172 lbs"
					 4="173+ lbs";
    value cholecatf  1="96 to 196 cholesterol"
	                 2="197 to 223 cholesterol"
					 3="224 to 255 cholesterol"
					 4="256+";
	value mapcatf 1="63-92 MAP"
	              2="93-100 MAP"
				  3="101-110 MAP"
				  4="111-200 MAP";
	value nstatusf 1='Alive'
	               2='Dead';

run;

data heart_og;
retain counter 0;
    set heart;

	counter=counter+1;


	*make some categorical (4 values) variables from continuous variables;
	if ageatstart ne . then do;
	    if 28 le ageatstart le 37 then age_cat=1;
		else if 37 lt ageatstart le 43 then age_cat=2;
		else if 43 lt ageatstart le 51 then age_cat=3;
		else if 51 lt ageatstart then age_cat=4;
	end;
	label age_cat="Age Quartile: 1=28-37, 2=38-43, 3=44-51, 4=52-62";
    
	if height ne . then do;
	    if 51.5 le height le 62.25 then height_cat=1;
		else if 62.25 lt height le 64.25 then height_cat=2;
		else if 64.25 lt height le 67.5 then height_cat=3;
		else if 67.5 lt height then height_cat=4;
	end;
	label height_cat="Height Quartile: 1=51.5-62.25, 2=62.26-64.25, 3=64.26-67.5, 4=67.6-76";

	if weight ne . then do;
	    if 67 le weight le 132 then weight_cat=1;
		else if 132 lt weight le 150 then weight_cat=2;
		else if 150 lt weight le 172 then weight_cat=3;
		else if 172 lt weight then weight_cat=4;
	end;
	label weight_cat="Weight Quartile: 1=28-37, 2=38-43, 3=44-51, 4=52-62";

	if cholesterol ne . then do;
	    if 96 le cholesterol le 196 then chole_cat=1;
		else if 196 lt cholesterol le 223 then chole_cat=2;
		else if 223 lt cholesterol le 255 then chole_cat=3;
		else if 255 lt cholesterol then chole_cat=4;
	end;
	label chole_cat="Cholesterol Quartile: 1=96-196, 2=197-223, 3=224-255, 4=256-568";

	format age_cat agecatf. height_cat heightcatf. weight_cat weightcatf. chole_cat cholecatf.;

	*calculate mean arterial pressure (MAP) (systolic+(2xdiastolic))/3 ;

	if systolic ne . and diastolic ne . then sumsd=sum(systolic,2*diastolic);
	map=sumsd/3;
	drop sumsd;
	label map="Mean Arterial Pressure (MAP)";

    if map ne . then do;
	    if 63 le map le 92 then map_cat=1;
		else if 92 lt map le 100 then map_cat=2;
		else if 100 lt map le 110 then map_cat=3;
		else if 110 lt map le 200 then map_cat=4;
	end;
	label map_cat="Mean Arterial Pressure Quartile: 1=63-92 MAP, 2=93-100 MAP, 3=101-110 MAP, 4=111-200";
    format map_cat mapcatf.;

	label counter="Sequence Counter";

	if status="Alive" then nstatus=1;
	else if status="Dead" then nstatus=2;
	label nstatus='Numeric Status Variable';
	format nstatus nstatusf.;
run;

proc freq data=heart_og  ;
    tables smoking_status*bmi_cat / plots=freqplot (groupby=column orient=vertical twoway=stacked scale=grouppercent );
	title2 "Smoking Status by BMI Category";
run;

ods trace on;

title2 "PROC SURVEYFREQ No Row Option";

ods output crosstabs=crosstabs_norow;
proc surveyfreq data=heart_og;
    tables sex*bmi_cat / cv deff chisq;
    weight sampleweight;
	format bmi_cat bmi_catf.;
run;
ods output close;

ods trace off;

ods trace on;

proc contents data=crosstabs_norow;
run;

title2 "PROC SURVEYFREQ Row Option";

ods output crosstabs=crosstabs_row;
proc surveyfreq data=heart_og;
    tables sex*bmi_cat / row cv deff chisq;
    weight sampleweight;
	format bmi_cat bmi_catf.;
run;
ods output close;

ods trace off;

proc contents data=crosstabs_row;
run;

title2 "PROC SURVEYFREQ ODS OUTPUT CREATION";

%macro odssf(rowcat=1,dv=sex);

ods output summary=summary&rowcat. crosstabs=crosstabs&rowcat. chisq=chisq&rowcat.;
proc surveyfreq data=heart_og;
    tables &dv.*bmi_cat / row cv deff chisq;
    weight sampleweight;
	format bmi_cat bmi_catf.;
run;

ods output close;

data crosstabs&rowcat.a;
    length f_tablevar tablevar $ 32;
    set crosstabs&rowcat. (rename=(f_&dv=f_tablevar &dv=tablevar));
	rowcat=&rowcat.;
	rownum=_n_;
run;

data nobs&rowcat (keep=rowcat nobs);
    length nobs $ 10;
    set summary&rowcat (where=(label1="Number of Observations"));
	nobs =put(nvalue1,comma9.);
	rowcat=&rowcat.;
run;

%IF %SYSFUNC(EXIST(chisq&rowcat.)) %then %do; /* if it exists, go ahead and make our day */ 
data rchisq&rowcat (keep=rowcat chisqp);
    length chisqp $ 8.;
    set chisq&rowcat. (where=(name1 = "P_RSCHI"));
	chisqp = cvalue1;
	rowcat=&rowcat.;
run; 
%END; 
%ELSE %DO; /* so it doesn't exist, we make it */ 
DATA rchisq&rowcat (keep=rowcat chisqp);
    length chisqp $ 8.; 
	chisqp = "N/A";
	rowcat=&rowcat.;
run;
%END;

data rchisq&rowcat (keep=rowcat chisqp);
    length chisqp $ 8.;
    set chisq&rowcat. (where=(name1 = "P_RSCHI"));
	chisqp = cvalue1;
	rowcat=&rowcat.;
run;

data anal&rowcat.;
    set crosstabs&rowcat.a;
	if _n_=1 then set nobs&rowcat.;
	if _n_=1 then set rchisq&rowcat.;
run;

proc print data=anal&rowcat. noobs;
run;

%mend;

%odssf(rowcat=1,dv=sex);
%odssf(rowcat=2,dv=DeathCause);
%odssf(rowcat=3,dv=Chol_status);
%odssf(rowcat=4,dv=bp_status);
%odssf(rowcat=5,dv=Smoking_status);

proc format;
    value cat2tit 1='Sex'
	              2='Cause of Death'
				  3='Cholesterol Status'
				  4='Blood Pressure Status'
				  5='Smoking Status';
run;

data biganno;
    length description $ 200;
    rowcat=1; rownum=0; shadeit=1; description='Sex'; output;
	rowcat=2; rownum=0; shadeit=1; description='Cause of Death'; output;
	rowcat=3; rownum=0; shadeit=1; description='Cholesterol Status'; output;
	rowcat=4; rownum=0; shadeit=1; description='Blood Pressure Status'; output;
	rowcat=5; rownum=0; shadeit=1; description='Smoking Status'; output;
run;

proc print data=biganno noobs;
run;

proc sort data=biganno;
    by rowcat rownum;
run;



data biganal analcol1 analcol2 analcol3 analcol4 analcol5;
    length description $ 200;
    set anal1 anal2 anal3 anal4 anal5;

	colno=mod(rownum,5);
	if colno=0 then colno=5;
	if rownum ne 0 then description=f_tablevar;
	f_freq=put(frequency,comma11.);
	f_wgtfreq=put(wgtfreq,comma11.1);
	f_stddev=put(stddev,11.5);
	f_stderr=put(stderr,11.4);
    f_percent=percent;
	keep description f_freq f_wgtfreq f_percent f_stddev f_stderr chisqp nobs rowcat rownum colno;
	output biganal;
	
	if colno=1 then output analcol1;
	if colno=2 then output analcol2;
	if colno=3 then output analcol3;
	if colno=4 then output analcol4;
	if colno=5 then output analcol5;
run;

proc print data=biganal (obs=50) noobs;
run;

options missing=' ';

%macro splitem(col=1);

proc sort data=analcol&col.;
    by rowcat rownum;
run;

data analcol&col.r (rename=(f_freq=f_freq&col
    f_wgtfreq=f_wgtfreq&col f_percent=f_percent&col
    f_stddev=f_stddev&col f_stderr=f_stderr&col chisqp=chisqp&col));
    set biganno analcol&col;
	by rowcat rownum;
	*reset rownum;
    if 1 le rownum le 5 then newrow=1;
	else if 6 le rownum le 10 then newrow=2;
	else if 11 le rownum le 15 then newrow=3;
	else if 16 le rownum le 20 then newrow=4;
	else if 21 le rownum le 25 then newrow=5;
	else if 26 le rownum le 30 then newrow=6;
	else if 31 le rownum le 35 then newrow=7;
	else if 35 le rownum le 40 then newrow=8;
	else if 41 le rownum le 45 then newrow=9;
	else if 45 le rownum le 50 then newrow=10;
	else if 51 le rownum le 55 then newrow=11;

run;

proc sort data=analcol&col.r;
    by rowcat rownum;
run;


title2 "Test Print Column Set &col";
proc print data=analcol&col.r (obs=50) noobs;
run;

%mend;

%splitem(col=1);
%splitem(col=2);
%splitem(col=3);
%splitem(col=4);
%splitem(col=5);

%let orderlist= description f_freq1 f_wgtfreq1 f_stddev1 f_stderr1 f_percent1
	f_freq2 f_wgtfreq2 f_stddev2 f_stderr2 f_percent2
	f_freq3 f_wgtfreq3 f_stddev3 f_stderr3 f_percent3
	f_freq4 f_wgtfreq4 f_stddev4 f_stderr4 f_percent4
	f_freq5 f_wgtfreq5 f_stddev5 f_stderr5 f_percent5
	nobs chisqp1 rowcat rownum newrow shadeit; 


data report_sf (keep=&orderlist.);
    retain &orderlist;
    merge analcol1r analcol2r analcol3r analcol4r analcol5r;
	by rowcat newrow;
    *label variables;
	label 
		f_freq1 	= "N"
		f_wgtfreq1	= "Wgted N"
		f_percent1	= "Pct"
		f_stddev1	= "Std Dev"
		f_stderr1	= "Std Err"
		chisqp1 	= "ChiSqP"
		f_freq2 	= "N"
		f_wgtfreq2	= "Wgted N"
		f_percent2	= "Pct"
		f_stddev2	= "Std Dev"
		f_stderr2	= "Std Err"
		chisqp2 	= "ChiSqP"
		f_freq3 	= "N"
		f_wgtfreq3	= "Wgted N"
		f_percent3	= "Pct"
		f_stddev3	= "Std Dev"
		f_stderr3	= "Std Err"
		chisqp3 	= "ChiSqP"
		f_freq4 	= "N"
		f_wgtfreq4	= "Wgted N"
		f_percent4	= "Pct"
		f_stddev4	= "Std Dev"
		f_stderr4	= "Std Err"
		chisqp4 	= "ChiSqP"
		f_freq5 	= "N"
		f_wgtfreq5	= "Wgted N"
		f_percent5	= "Pct"
		f_stddev5	= "Std Dev"
		f_stderr5	= "Std Err"
		chisqp5 	= "ChiSqP"
		description = "Health Characteristics"
		nobs		= "File N"
		;

run;

options missing=" ";


title2 "SURVEYFREQ Output Objects" ;

proc print data=report_sf (obs=10) noobs label uniform;
run;



ods listing close;

ods excel file="reportsf.xlsx" 
options(embedded_titles="yes" tab_color="purple"
frozen_rowheaders="1"
sheet_name="reportsf") style=styles.excel;
title1 j=l "WUSS 2026: ODS Output";
title2 j=l "SURVEYFREQ Output Objects" ;

proc report nowd data=report_sf /* spacing=8 */
    style(report)=[cellpadding=3pt vjust=b]
    style(header)=[just=center font_face="Helvetica" font_weight=bold font_size=8pt]
    style(lines)=[just=left font_face="Helvetica"] split='|';
  columns description 
    ("Underweight" f_freq1 f_wgtfreq1 f_stddev1 f_stderr1 f_percent1)
	("Healthy Weight" f_freq2 f_wgtfreq2 f_stddev2 f_stderr2 f_percent2)
	("Overweight" f_freq3 f_wgtfreq3 f_stddev3 f_stderr3 f_percent3)
	("Obesity" f_freq4 f_wgtfreq4 f_stddev4 f_stderr4 f_percent4)
	("Total" f_freq5 f_wgtfreq5 f_stddev5 f_stderr5 f_percent5)
	chisqp1 shadeit;

  define shadeit / display ' ' noprint;


  define description / style(COLUMN)={just=l font_face="Helvetica"  
           font_size=8pt cellwidth=200 }
                      style(HEADER)={just=l font_face="Helvetica" font_weight=bold 
           font_size=8pt  };

  define f_freq1 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_wgtfreq1 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stddev1 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stderr1 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_percent1 / style(COLUMN)={just=c font_face="Helvetica" foreground=purple 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=purple
           font_size=8pt  };

  define f_freq2 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_wgtfreq2 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stddev2 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stderr2 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_percent2 / style(COLUMN)={just=c font_face="Helvetica" foreground=purple 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=purple
           font_size=8pt  };

  define f_freq3 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_wgtfreq3 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stddev3 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stderr3 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_percent3 / style(COLUMN)={just=c font_face="Helvetica" foreground=purple 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=purple
           font_size=8pt  };
  define f_freq4 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_wgtfreq4 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stddev4 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stderr4 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_percent4 / style(COLUMN)={just=c font_face="Helvetica" foreground=purple 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=purple
           font_size=8pt  };
  define f_freq5 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_wgtfreq5 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stddev5 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_stderr5 / style(COLUMN)={just=c font_face="Helvetica" foreground=navy 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=navy
           font_size=8pt  };
  define f_percent5 / style(COLUMN)={just=c font_face="Helvetica" foreground=purple 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=purple
           font_size=8pt  };
  define chisqp1 / style(COLUMN)={just=c font_face="Helvetica" foreground=purple 
           font_size=8pt cellwidth=100 }
                      style(HEADER)={just=c font_face="Helvetica" font_weight=bold foreground=purple
           font_size=8pt  };
compute shadeit;
  if (shadeit eq 1) then call define(_row_,"STYLE","STYLE=[BACKGROUND=VPAB FONT_WEIGHT=BOLD
	FONT_SIZE=8pt FONTSTYLE=ITALIC]");
  endcomp;
run;


ods excel close;
quit;

ods listing;

