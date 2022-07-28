/*** QualityWatch analysis for annual statement 2021 ***/
/** A&E waits for children and young people using ECDS data **/

/* Input ECDS datasets */
libname ecds19 '~\DATA\ECDS';
libname ecds20 '~\DATA\ECDS\20210521 transfer\Formatted';
libname ecds21 '~\DATA\hes data Y2122 M7 - received 20211215\Formatted';
libname lookups '~\DATA\ECDS\lookups';

/*Filter data for 2021/22*/
data work.ecds_21;
	set ecds21.ec21m (keep = age_at_arrival arrival_date arrival_time departure_time department_type departure_date decided_to_admit_date decided_to_admit_time diagnosis_code_1--diagnosis_code_12);
		length age_band $10.; informat age_band $10.; format age_band $10.;
		if 0 <= age_at_arrival <= 18 then age_group = 'cyp';
		else if 19 <= age_at_arrival <= 100 then age_group = 'adults';
		else age_group = 'null';
		where 0 <= age_at_arrival <= 100
		and department_type in ('01','02','03') and (departure_date >= arrival_date) and (departure_date ~=.) and (departure_time ~=.) and (arrival_date ~=.) and (arrival_time ~=.) ;
		if decided_to_admit_date = . then admitted = 'null';
		else admitted = 1;
		quarter=qtr(arrival_date); month=month(arrival_date); year_new=year(arrival_date); /* nb. annual year quarter not financial year quarter */
		q_yr=yyq(year_new,quarter); format q_yr yyq.;
		arrival_dttm=input(put(arrival_date, date7.)||':'||put(arrival_time, time8.), datetime16.); format arrival_dttm datetime16.; 
		depart_dttm=input(put(departure_date, date7.)||':'||put(departure_time, time8.), datetime16.); format depart_dttm datetime16.; 
run;


/*Filter data for 2020/21*/
data work.ecds_20;
	set ecds20.ec20m (keep = age_at_arrival arrival_date arrival_time departure_time department_type departure_date decided_to_admit_date decided_to_admit_time diagnosis_code_1--diagnosis_code_12);
		length age_band $10.; informat age_band $10.; format age_band $10.;
		if 0 <= age_at_arrival <= 18 then age_group = 'cyp';
		else if 19 <= age_at_arrival <= 100 then age_group = 'adults';
		else age_group = 'null';
		where 0 <= age_at_arrival <= 100
		and department_type in ('01','02','03') and (departure_date >= arrival_date) and (departure_date ~=.) and (departure_time ~=.) and (arrival_date ~=.) and (arrival_time ~=.) ;
		if decided_to_admit_date = . then admitted = 'null';
		else admitted = 1;
		quarter=qtr(arrival_date); month=month(arrival_date); year_new=year(arrival_date); /* nb. annual year quarter not financial year quarter */
		q_yr=yyq(year_new,quarter); format q_yr yyq.;
		arrival_dttm=input(put(arrival_date, date7.)||':'||put(arrival_time, time8.), datetime16.); format arrival_dttm datetime16.; 
		depart_dttm=input(put(departure_date, date7.)||':'||put(departure_time, time8.), datetime16.); format depart_dttm datetime16.; 
run;


/*Filter data for CYP for 2019/20*/
data work.ecds_19;
	set ecds19.ec19 (keep = age_at_arrival arrival_date arrival_time departure_time department_type departure_date decided_to_admit_date decided_to_admit_time diagnosis_code_1--diagnosis_code_12);
		length age_band $10.; informat age_band $10.; format age_band $10.;
		if 0 <= age_at_arrival <= 18 then age_group = 'cyp';
		else if 19 <= age_at_arrival <= 100 then age_group = 'adults';
		else age_group = 'null';
		where 0 <= age_at_arrival <= 100
		and department_type in ('01','02','03') and (departure_date >= arrival_date) and (departure_date ~=.) and (departure_time ~=.) and (arrival_date ~=.) and (arrival_time ~=.) ;
		if decided_to_admit_date = . then admitted = 'null';
		else admitted = 1;
		quarter=qtr(arrival_date); month=month(arrival_date); year_new=year(arrival_date); /* nb. annual year quarter not financial year quarter */
		q_yr=yyq(year_new,quarter); format q_yr yyq.;
		arrival_dttm=input(put(arrival_date, date7.)||':'||put(arrival_time, time8.), datetime16.); format arrival_dttm datetime16.; 
		depart_dttm=input(put(departure_date, date7.)||':'||put(departure_time, time8.), datetime16.); format depart_dttm datetime16.; 
run;

data ecds_waits19;
	set work.ecds_19;
time_diff=intck('minute',arrival_dttm,depart_dttm);
if time_diff <=240 then under_4 = 1;
else if (time_diff > 240) and (time_diff < 1440) then under_4 = 0;
else under_4=-1;
/* if time_diff <=720 then under_12 = 1;
else if (time_diff > 720) and (time_diff < 1440) then under_12 = 0;
else under_12=-1; */
run;

data ecds_waits20;
	set work.ecds_20;
time_diff=intck('minute',arrival_dttm,depart_dttm);
if time_diff <=240 then under_4 = 1;
else if (time_diff > 240) and (time_diff < 1440) then under_4 = 0;
else under_4=-1;
/* if time_diff <=720 then under_12 = 1;
else if (time_diff > 720) and (time_diff < 1440) then under_12 = 0;
else under_12=-1; */
run;

data ecds_waits21;
	set work.ecds_21;
time_diff=intck('minute',arrival_dttm,depart_dttm);
if time_diff <=240 then under_4 = 1;
else if (time_diff > 240) and (time_diff < 1440) then under_4 = 0;
else under_4=-1;
/* if time_diff <=720 then under_12 = 1;
else if (time_diff > 720) and (time_diff < 1440) then under_12 = 0;
else under_12=-1; */
run;


/* Add on primary diagnosis lookup */
proc sql;
	create table ecds_diag21 as
	select A.*,
		   B.diagnosis_desc as primarydiagnosis
	from ecds_waits21 as A
	left join lookups.diagnosis as B
	on A.diagnosis_code_1=B.diagnosis
;
quit;


proc sql;
	create table ecds_diag20 as
	select A.*,
		   B.diagnosis_desc as primarydiagnosis
	from ecds_waits20 as A
	left join lookups.diagnosis as B
	on A.diagnosis_code_1=B.diagnosis
;
quit;

proc sql;
	create table ecds_diag19 as
	select A.*,
		   B.diagnosis_desc as primarydiagnosis
	from ecds_waits19 as A
	left join lookups.diagnosis as B
	on A.diagnosis_code_1=B.diagnosis
;
quit;

/* Data tables */
proc freq data = ecds_diag21;
tables month*age_group*under_4*primarydiagnosis / nocol norow nopercent out = ecds_2021;
run;

proc export data = ecds_2021
outfile = "~\QualityWatch\Annual statement 2021\ecds_2021.csv"
dbms = csv
replace;
run;

proc freq data = ecds_diag20;
tables month*age_group*under_4*primarydiagnosis / nocol norow nopercent out = ecds_2020;
run;

proc export data = ecds_2020
outfile = "~\QualityWatch\Annual statement 2021\ecds_2020.csv"
dbms = csv
replace;
run;

proc freq data = ecds_diag19;
tables month*age_group*under_4*primarydiagnosis / nocol norow nopercent out = ecds_2019;
run;

proc export data = ecds_2019
outfile = "~\QualityWatch\Annual statement 2021\ecds_2019.csv"
dbms = csv
replace;
run;
