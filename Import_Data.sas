%let folder_loc = /folders/myfolders/;

/*Import text: plain text*/
data rent;
infile "C:\Users\Mo.Pei\Desktop\data2\SAS_Regression\data\RENT.txt";
/*Without input statement, it just has a bouch of numbers.*/
input year rent; /*tell SAS the columns being input*/
run;

/*Import Excel File:*/
proc import datafile="C:\Users\Mo.Pei\Desktop\data2\SAS_Regression\data\rent.xlsx"
dbms=XLSX
out=rent;
sheet='rentdata';
getnames=YES;
run;

/*Import CSV File:
1.Specify variable import format.
2.Change variable change variable name.
3.Easily convert Excel file to a CSV file.*/
data proj;
infile "C:\Users\Mo.Pei\Desktop\data2\SAS_Regression\data\company data.csv" DSD missover firstobs=2;
/*DSD: it recognizes two consecutive delimiters as a missing value; it allows you to include
delimiters within quoted strings.
MISSOVER: This option prevents SAS from going to a new input line if it does not find values
for all of the variables in the current line of data, so you do not get messy results. */
/*Declare a string variable uses $.*/
input CUSIP $ fyer name$;
run;
proc print;
run;

/*Print*/

data rent;
infile "&folder_loc.RENT.txt";
/*Without input statement, it just has a bouch of numbers.*/
input year rent; /*tell SAS the columns being input*/
run;

proc print data=rent;
run;

data new;
n=1;
run;

/*Calculation*create a new variable.*/
data standard;
  set rent;
 rent_standard=25000;
 run;

data performance;
  set standard;
 performance=rent-rent_standard;
 run;


data c;
a=3*3;
a=sqrt(9);
a=3**3;
run;

data d;
x=8*3;
y=x+8;
run;

/*Keep drop rename variables.*/

data kep;
 set rent;
keep year;
run;

data dropped;
 set rent;
drop year rent;
run;

data ren_rent;
 set rent;
 rename rent=new_rent year = new_year;
/*Rename in datastep, after given a new name SAS still refers to the orginal name to keep the column.*/
keep rent;
run;

data ren_rent;
 set rent(rename = (rent=new_rent year = new_year));;
 /*Rename in set statemetn, after given a new name SAS still refers to the orginal name to keep the column.*/
keep new_rent;
run;


/*Filter data.*/
data filter;
set rent;
if year > 2000;
/*It stores the observations with year > 2000.*/
run;

data filter_2;
set rent;
if 2004 > year > 2000;
run;

data filter_2;
set rent;
if 2004 >= year and 2000 =< year;
run;

data filter_2;
set rent;
if 2004 >= year;
if 2000 =< year;
run;


/*Sort data.*/
proc sort data = rent out=sorted;
by rent;
run;

proc print data=sorted;
run;

proc sort data = rent out=sorted;
by descending rent;
run;
proc print data=sorted;
run;

proc sort data = rent out=sorted;
by descending rent year;
run;
proc print data=sorted;
run;

/*Combining tables\data*/
%macro import_sheet(sheet_name);
proc import datafile="&folder_loc.\sales.xlsx"
dbms=XLSX
out=&sheet_name.;
sheet="&sheet_name.";
getnames=YES;
run;
%mend();

%import_sheet(spring);
%import_sheet(summer);
%import_sheet(autumn);
%import_sheet(winter);


data annual;
 /*Combining tables with same variables.*/
 set spring summer autumn winter;
run;

data test;
/*Combining tables with different variables.*/
set spring rent;
run;

/*Exporting data.*/
proc export data=rent outfile="&folder_loc.export.csv"
dbms=CSV;
run;

proc export data=rent outfile="&folder_loc.export.txt"
dbms=tab;
run;


/*Recap.*/
proc import datafile="&folder_loc.commercial rent.xlsx"
dbms=XLSX
out=commrent;
sheet='data';
getnames=YES;
run;

data select;
 set commrent;
if age >= 10;
keep rental_rates	Age;
run;

proc export data=select outfile="&folder_loc.select.csv"
dbms=csv;
run;

/********************************************************************/
/*Linear regression*/
/********************************************************************/
proc import datafile="&folder_loc.commercial rent.xlsx"
dbms=XLSX out= commrent;
getnames=yes;
run;

proc reg data = commrent;
model rental_rates=age;
run;

/*Notes: Linear regression
Y dependent variable and x explanatory variable
Y=b0+b1*X1+e

two explanatory variables need a curve surface to demonstrate the
relationship.
y=1.2+0.8x1+2.5x2
Explanation: given all other variables fixed, on average \ the expected change in 
in Y for a one unit change in X1 is 0.8 units and on x2 is 2.5 units.     */

/*Results interpretaion:
regression coefficients estimate.
estimated regression function: rental rates=15.6 - 0.06* age*/

/*ANOVA: p-value
r square: the proportion of data variation that is explained by the model.*/

/*Evaluate fitness of the model 
residul of predicted values*/

proc reg data = commrent;
model rental_rates=age;
output out=res residual=resid p=pred;
run;

proc print data=res;
run;

/*Multiple Linear Regression.
Adjusted R squre takes consideration of the number 
of variables. 
Adjusted R square punishes more explanatory variables.
*/
proc reg data = commrent;
model rental_rates=age operating_expenses vacancy_rates
SQfootage;
run;

/*Make Prediction.*/

data new;
input rental_rates age operating_expenses vacancy_rates
SQfootage;
datalines;
. 4 10 0.1 80000
. 6 11.5 0 12000
. 12.0 12.5 0.32 340000
;
run;

data combined;
set commrent new;
run;

proc reg data=combined;
model rental_rates=age operating_expenses vacancy_rates
SQfootage / cli;
run;

/*Report: commerial rental rate.*/
proc import datafile="&folder_loc.commercial rent.xlsx"
dbms=XLSX out= commrent;
getnames=yes;
run;

/*Finding a model. First guess, include all varialbes.*/
proc reg data=commrent;
model rental_rates=age operating_expenses vacancy_rates
SQfootage;
run;
/*vacancy_rates not significant.Test vacany_rates*/
proc reg data=commrent;
model rental_rates=age operating_expenses vacancy_rates
SQfootage;
Cacancy: Test vacancy_rates=0;
run;

/*Adjusted model;*/
proc reg data=commrent;
model rental_rates=age operating_expenses 
SQfootage /cli;
run;

/*
 rental rate = 12.37 -0.14 * age +0.26* Expenses + 0.000008*square footage
 our model is significant at a 1% level. It explains 56.6% of the data.
 
 According to the model, given other variables fixed, for each year a house ages, the rental
 rate will decrease by 0.14 percent on average.
 
 For each unit expenses grows, the rental rate will increase by 0.24 percent 
 on average.
 
 for each square a house has, the rental rate will increase by 
 0.000008 percent on average. 
 */

/*SQL*/
/*select a variable, multiple variables, all variables.*/
proc import datafile="&folder_loc.SQL - purchases.csv"
dbms=csv out= purchase;
getnames=yes;
run;

proc import datafile="&folder_loc.SQL - items.csv"
dbms=csv out= item;
getnames=yes;
run;

proc import datafile="&folder_loc.SQL - customers.csv"
dbms=csv out= customer;
getnames=yes;
run;

proc print data=purchase (obs=10);
run;

proc sql;
select item
from purchase
;quit;

proc sql;
select item,itemID
from purchase
;quit;

proc sql;
select *
from purchase
;quit;

/*Distinct.*/
proc sql;
select distinct(customer_name)
from customer
;quit;

/*Count.*/
proc sql;
select count(*) as N
from customer
;quit;

proc sql;
select count(*) as tatol_purchase
from purchase
;quit;

/*Group by.by distinct value are there in the area variable.*/
proc sql;
select area,count(*) as N
from customer
group by area
;quit;






/*9/25/2107 */


%let folder_loc = C:\Users\Mo.Pei\Desktop\data2\SAS_Regression\Prj\;

/*SQL create tables.*/
proc import datafile= "&folder_loc.SQL - customers.csv" 
dbms=csv
out=customer;
getnames=yes;
run;

proc import datafile= "&folder_loc.SQL - purchases.csv" 
dbms=csv
out=purchase;
getnames=yes;
run;

proc import datafile= "&folder_loc.SQL - items.csv" 
dbms=csv
out=item;
getnames=yes;
run;

proc sql;
select area,count(*) as N
from customer
group by area
;quit;

proc sql;
create table area_distribution as 
select area,count(*) as N
from customer
group by area
;quit;

proc print data=area_distribution;
run;

proc sql;
create table name as
select customer_name as name
from purchase
;quit;

proc sql;
create table name as
select distinct customer_name as name
from purchase
;quit;


/*SQL - Merge Data sets.
Joining tables needs a key as bridge but the key needs to be a unique value.*/
