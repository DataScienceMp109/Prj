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
Joining tables needs a key as bridge but the key needs to be a unique value.
Matching condition: on. A match is found if idA in A equals to idB in B.
prohibit variables have the same name in one dataset. It is allowed in different dateset.*/

/*Left join: 
A left join B means that keep every record in A and want variable in B supplment A.*/


proc import datafile= "&folder_loc.SQL demonstration.xlsx" 
dbms=xlsx
out=dataA
replace;
sheet = 'a';
getnames=yes;
run;

proc import datafile= "&folder_loc.SQL demonstration.xlsx" 
dbms=xlsx
out=dataB
replace;
sheet = 'b';
getnames=yes;
run;

/*Left Join*/
proc sql;
select *
from dataA
left join dataB
on dataA.aID = dataB.bID
;quit;

proc sql;
select *
from dataB
left join dataA
on dataA.aID = dataB.bID
;quit;

proc sql;
select *
from purchase
left join customer
on dataA.aID = dataB.bID
;quit;


proc sql;
create table merged as 
select purchase.ItemID, purchase.item, customer.area
from purchase
left join customer
on purchase.customer_name = customer.customer_name
;quit;

proc export data= merged outfile= "&folder_loc.Tali.xlsx" dbms=xlsx;
run;

* import the datasets;
PROC IMPORT OUT=customer DATAFILE="&folder_loc.customers.xlsx" DBMS=xlsx replace;
GETNAMES=YES;
RUN;
PROC IMPORT OUT=product DATAFILE="&folder_loc.products.xlsx" DBMS=xlsx replace;
GETNAMES=YES;
RUN;
PROC IMPORT OUT=sale DATAFILE="&folder_loc.sales.xlsx" DBMS=xlsx replace;
GETNAMES=YES;
RUN;
PROC IMPORT OUT=return DATAFILE="&folder_loc.returns.xlsx" DBMS=xlsx replace;
GETNAMES=YES;
RUN;

* merge them into one table;
proc sql;
create table mg as
select a.*, b.*, c.*
from sale as a
left join customer as b
on a.customer_id=b.id
left join product as c
on a.product_id=c.id
;quit;

* how much sale for each customer.;
proc sql;
create table percus as
select customer_name, sum(profit) as profit
from mg
group by customer_name
order by profit descending
;quit;

* region distribution;
proc sql;
create table prosale as 
select province, sum(Sales) as sale
from mg
group by province
;quit;
 
* region proportion;
proc sql;
create table propct as
select province, sale, sale/sum(sale) as pct
from prosale
;quit;

*pie plot;
proc gchart data=mg;
pie province / discrete
sumvar== sales;
run;


*concentration;
proc sql;
create table herfin as
select customer_name, sum(profit) as profit
from mg
group by customer_name
;quit;
 
 proc sql;
create table herfin_pct as
select *, profit/sum(profit) as pct
from herfin
;quit;

/* The result shows the concentration level is very solid to customers change. */
proc sql;
select sum(pct*pct) as Herfindal, 1/count(*) as benchmark
from herfin_pct
;quit;

/*SAS library.*/

* highest return rate product;
proc sql;
create table mgreturn as
select a.*,b.product_name 
from return as a
left join mg as b
on a.order_id=b.order_id
;quit;

PROC PRINT DATA=mgreturn(OBS=10);RUN;
* group up by product;
proc sql;
create table groupreturn as
select product_name, count(*) as returns
from mgreturn
group by product_name
order by returns descending
;quit;
 
PROC PRINT DATA=groupreturn(OBS=10);RUN;


/* correlation */
proc corr data=commrent;
run;

proc corr data=commrent;
var age rental_rates;
run;

/*Descriptive stats.*/
proc means data=rent mean median std p5 p95 min max;
var rent year;
run;

/*preview a dataset*/
proc contents data=rent;
run;


/* Macros are programs that make programs. 
It patch a bunch of programs and saves a lot of time. */
/* %do %if */
/* %macro  */
/* %mend */
/* %put  */
/* %let */
/* %xxxxxx */

/* %pr(din=commrent,n=15) */
/* proc print data = commrent (0bs=10); */
/*  */
/* %summary(din=commrent) */
/*  */
/* %winsorize(din=commrent, dou=test,var=age) */


/*Scatter plot.*/

data crent;
 set commrent;
run;

/*procedure makes plot*/
proc gplot data=crent;
/*symbol: is used for each data point.
  interpol: thing between data points.
  value: symbol represents data points.
  h: height of symbol.*/
symbol interpol=none value=dot h=1;
/*plot y*x;*/
plot vacancy_rates*SQfootage;
run;

/*Series plot is just a scatter plot with connection between points*/
proc sort data= crent;
by SQfootage;
run;

proc gplot data=crent;
title '';
/*symbol: is used for each data point.
  interpol: thing between data points.
           join two consecutive points, order matters. 
  value: symbol represents data points.
  h: height of symbol.*/
symbol interpol=join value=dot h=1;
/*plot y*x;*/
plot vacancy_rates*SQfootage;
run;


/*bar plot and pie plot are one variable*/
/*x-xais value of variable.*/
/*y- frequency of the values.*/

proc gchart data=commrent;
/*vertical bar*/
vbar age;
run;
/*not all the age show up. Some age aggregated to the closet value.*/

/*not aggreted.*/
proc gchart data=commrent;
/*vertical bar*/
vbar age/discrete;
run;

/*horizontal bar.*/
proc gchart data=commrent;
/*vertical bar*/
hbar age/discrete;
run;

/*pie plot*/
proc gchart data=commrent;
/*vertical bar*/
pie age/discrete;
run;

/*Multiple plots and legends.*/
proc sort data=commrent; by age; run;

/*legend represents what line represents what reletionship.*/

legend1 label=("Plot legend")
;

proc gplot data=commrent;
symbol ininterpol=join value=dot height=1;
plot vacancy_rates*age operating_expenses*age / overlay legend=legend1;
run;

