********************************************************************
*  Assignment:    Final Project                                       
*                                                                    
*  Description:   Using NHANES data to look at prevalence of diabetes 
*                 amongst different group characteristics
*
*  Name:          Alice Yu
*
*  Date:          4/11/2022                                     
*------------------------------------------------------------------- 
*  Job name:      final2_alicewyu.sas   
*
*  Purpose:       Create graphs to show BMIs amongst different groups and 
*                 reports to show prevalence of diabetes 
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         NHANES 2017-March 2020 pre-pandemic data: 
*                 	P_DEMO, P_BMX, P_DIQ
*
*  Output:        PDF
*                   
*                                                                    
********************************************************************;
%LET job=final;
%LET onyen=alicewyu;
%LET outdir=C:\Users\alwwi\Documents\bios669\final_proj;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN;
ODS _ALL_ CLOSE;   
                  
FOOTNOTE "Job &job._&onyen run on &sysdate at &systime";

LIBNAME final "c:\Users\alwwi\Documents\bios669\final_proj\data";
ODS PDF FILE="&outdir\&job._&onyen..PDF" STYLE=JOURNAL;

proc format;
	value bmif 1="Underweight"
				2="Normal Weight"
				3="Overweight"
				4="Obese";
	value genderf 1="Male"
					2="Female";
	value racef 1="Mexican American"
				2="Other Hispanic"
				3="Non-Hispanic White"
				4="Non-Hispanic Black"
				6="Non-Hispanic Asian"
				7="Other Race - Including Multi-Racial";
	value diqf 1="Yes"
				2="No"
				3="Borderline"
				7="Refused"
				9="Don't Know";
	value agef 1="2 to 19 Years old"
				2="20 to 40 Years old"
				3="41 to 60 Years old"
				4="61 to 80 Years old"
				5="81+ Years";
run;	

*looking at datasets; 
data demo; set final.p_demo; run;
data bmx; set final.p_bmx; run;
data diq; set final.p_diq; run;

*checking bmi calculations;
*bmxwt - weight, bmxht - height; 
*wt/ht**2;
data bmx_check;
	set bmx;
	
	if missing(bmxwt) or missing(bmxht) then bmi_check=.;
	else bmi_check=bmxwt/(bmxht**2);
	
	keep bmxwt bmxht bmxbmi bmi_check;
run;

*merging datasets;
proc sql;
	create table merged_set as 
	select a.seqn, a.riagendr, a.RIDRETH3, a.RIDAGEYR, b.BMXBMI, b.BMDBMIC, c.DIQ010, a.WTMECPRP*a.WTINTPRP as samp_wt, a.SDMVPSU, a.SDMVSTRA
		from demo as a 
		left join 
		bmx as b
		on a.seqn=b.seqn
		left join diq as c
		on a.seqn=c.seqn;
quit;

*categorizing ages;
data diabetes;
	set merged_set;
	if ridageyr <= 19 then age_group=1;
	else if 19<ridageyr<=40 then age_group=2;
	else if 40<ridageyr<=60 then age_group=3;
	else if 60<ridageyr<=80 then age_group=4;
	else age_group=5;
run;

*creating graph of relationship between BMI and diabetes;
%macro graph1(groupvar= ,var= );
	%if %upcase(&groupvar)=RIDRETH3 %then %do;
		%let formatvar=racef.;
	%end;	
	%else %if %upcase(&groupvar)=RIAGENDR %then %do;
		%let formatvar=genderf.;
	%end;
	%else %if %upcase(&groupvar)=AGE_GROUP %then %do;
		%let formatvar=agef.;
	%end;
	%else %if %upcase(&groupvar)=BMDBMIC %then %do;
		%let formatvar=bmif.;
	%end;
	
	proc sgpanel data=diabetes;
		title "BMI of Study Participants by &var. and whether they have Diabetes";
		format diq010 diqf. &groupvar &formatvar;
		where not missing(bmxbmi);
		panelby diq010;
		vbox bmxbmi / category=&groupvar dataskin=crisp;
		colaxis display=(nolabel);
	run;
%mend;

ods graphics on / reset=all;
ods graphics on / width=8in;
*x=race, y=bmi, group=diabetes; 
%graph1(groupvar=ridreth3,var=Race);

*x=gender, y=bmi, group=diabetes;
%graph1(groupvar=riagendr,var=Gender);


*creating graphs just based on children/youth;
*bmi grouping only available for (2 to 19 years);
*x=bmi_grouping, y=bmi, group=gender;
title "BMI of Children/Youth Study Participants (2 to 19 years) by Gender and BMI Category";
proc sgpanel data=diabetes;
	format riagendr genderf. bmdbmic bmif.;
	panelby riagendr;
	vbox bmxbmi / category=bmdbmic;
	colaxis display=(nolabel);
	rowaxis values=(0 to 80 by 15);
run;

ods graphics /attrpriority=none;
title "Mean BMI of Children/Youth Study Participants (2 to 19 years) who have diabetes by BMI Category";
proc sgplot data=diabetes;
	format diq010 diqf. bmdbmic bmif.;
	where ridageyr <=19 and diq010=1;
	vline ridageyr / response=bmxbmi stat=mean weight=samp_wt markers group=bmdbmic;
	yaxis values=(10 to 45 by 5);
	styleattrs datasymbols=(TriangleFilled CircleFilled SquareFilled)
				datalinepatterns=(Solid ShortDash Dot)
				datacolors=(blue red green);
	footnote2 "BMI Category 'Underweight' has no observations who have diabetes";
run;

*creates dataset for a report for all values of a variable;
%macro compare_all(var= ,ds_name= );
	*adding total variable;
	data diabetes2;
		set diabetes;
		output;
		&var=0;
		output;
	run;
	
	ods pdf exclude where=(_name_? 'CrossTabs');
	proc surveyfreq data=diabetes2 missing nosummary;
		cluster SDMVPSU;
		strata SDMVSTRA;
		tables diq010*&var /col nototal;
		weight samp_wt;
		ods output CrossTabs=diabetes_var;
	run;
	
	ods pdf exclude where=(_name_? 'OneWay');
	proc surveyfreq data=diabetes2 missing nosummary;
		cluster SDMVPSU;
		strata SDMVSTRA;
		tables &var /nototal;
		weight samp_wt;
		ods output OneWay=varcnt;
	run;

	proc sql noprint;
		select (count(distinct &var)) into :uniVal
			from varcnt;
	quit;
	
	*creating macro variable that contains number of observations for each variable;
	%let i=0;
	data _null_;
		set varcnt;
		
		%do %until (&i>&uniVal);
			if &var=&i then call symputx(cats("n",&i),put(frequency,5.),'g');
			%let i= %eval(&i+1);
		%end;
	run;
	
	data diabetes_var2;
		set diabetes_var;
		length value $25; 
		value=put(frequency, 5.) || ' (' || put(colpercent,4.1)||')';
	run;
	
	proc sort data=diabetes_var2; by diq010; run;
	proc transpose data=diabetes_var2 out=&ds_name(drop=_name_) prefix=col;
		by diq010;
		var value;
		id &var;
	run;
	
%mend;

*proc report of comparing different races;
%compare_all(var=ridreth3, ds_name=final_race);

options missing='';
title "Prevalence of Diabetes among different Races";
proc report data=final_race nowd;
	columns diq010 col0 col1 col2 col3 col4 col6 col7;
	define diq010 / display "//N(%)/Diabetes Diagnosis" format=diqf.;
	define col0 / display "Total/n=&n0" right style=[backgroundcolor=lightsteelblue];
	define col1 / display "Mexican American/n=&n1" center;
	define col2 / display "Other Hispanic/n=&n2" center;
	define col3 / display "White/n=&n3" center;
	define col4 / display "Black/n=&n4" center;
	define col6 / display "Asian/n=&n6" center;
	define col7 / display "Other - including multi-race/n=&n7" center;	
run;

*formats macro variables;
%macro format(value,format);
	%if %datatyp(&value)=CHAR
		%then %sysfunc(putc(&value,&format));
		%else %left(%qsysfunc(putn(&value,&format)));
%mend format;

*create macro for specific to compare different 2 groups and different vars;
%macro compare_two(var= ,group1= ,group2= );
	%if %upcase(&var)=RIDRETH3 %then %do;
		%let formatvar=racef.;
	%end;	
	%else %if %upcase(&var)=RIAGENDR %then %do;
		%let formatvar=genderf.;
	%end;
	%else %if %upcase(&var)=RIDAGEYR %then %do;
		%let formatvar=agef.;
	%end;
	%else %if %upcase(&var)=BMDBMIC %then %do;
		%let formatvar=bmif.;
	%end;
	
	*getting labels are specific groups of interest;
	%let group1l = %format(&group1,&formatvar);
	%let group2l = %format(&group2,&formatvar);
	
	ods pdf exclude where=(_name_? 'CrossTabs');
	proc surveyfreq data=diabetes missing nosummary;
		cluster SDMVPSU;
		strata SDMVSTRA;
		tables diq010*&var /col nototal;
		weight samp_wt;
		ods output CrossTabs=diabetes_var;
	run;

	ods pdf exclude where=(_name_? 'OneWay');
	proc surveyfreq data=diabetes missing nosummary;
		cluster SDMVPSU;
		strata SDMVSTRA;
		tables &var /nototal;
		weight samp_wt;
		ods output OneWay=varcnt;
	run;
	
	data _null_;
		set varcnt;
		if &var=&group1 then call symput("n1",put(frequency,5.));
		else if &var=&group2 then call symput("n2",put(frequency,5.));
	run;
	
	data diabetes_var2;
		set diabetes_var;
		length value $25; 
		where &var in(&group1, &group2);
		value=put(frequency, 5.) || ' (' || put(colpercent,4.1)||')';
	run;
	
	proc sort data=diabetes_var2; by diq010; run;
	proc transpose data=diabetes_var2 out=diabetes3(drop=_name_) prefix=col;
		by diq010;
		var value;
		id &var;
	run;
	
	ods pdf exclude where=(_name_? 'ChiSq');
	ods pdf exclude where=(_name_? 'CrossTabs');
	proc surveyfreq data=diabetes missing nosummary;
		cluster SDMVPSU;
		strata SDMVSTRA;
		tables diq010*&var /chisq nototal;
		weight samp_wt;
		ods output ChiSq=pvalue;
	run;
	
	data pvalue2;
		set pvalue;
		where Label1="Pr > ChiSq";
	run;
	
	data final;
		set diabetes3 pvalue2(keep=nValue1);
	run;
	
	%if %upcase(&var)=BMDBMIC %then %do;
		title "Prevalence of Diabetes between Children/Youth Study Participants (2 to 19 years) of &group1l. and &group2l.";
	%end;
	%else %do;
		title "Prevalence of Diabetes between &group1l. and &group2l.";
	%end;
	proc report data=final nowd;
		columns diq010 col&group1 col&group2 nValue1;
		define diq010 / display "//N(%)/Diabetes Diagnosis" format=diqf.;
		define col&group1 / display "&group1l/n=&n1" center;
		define col&group2 / display "&group2l/n=&n2" center;
		define nValue1 / display "P-Value*" format=pvalue6.4 style(column)=[just=right cellwidth=2cm vjust=bottom]
			style(header)=[just=right cellwidth=2cm];
		compute nValue1;
			if nValue1<0.05 then do;
				call define(_col_,"style","style=[fontweight=bold]");
			end;
		endcomp;
		footnote2 h=10pt "*Rao-Scott Chi-Square test used to compare &group1l. and &group2l.";
	run;

%mend;

options missing='';
%compare_two(var=riagendr,group1=1,group2=2);

ods pdf close;
