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


/* Macros are programs that make programs. */
/* %do %if */
/* %macro  */
/* %mend */
/* %put  */
/* %let */
/* %xxxxxx */

/*Macro variable.*/
%let a=1;
%let me = heng;
%let you= best friend;
%let ex=aswhole;

%put it is a sunny day;
%put &a.;
%put &you.;

/* macro variables.name of dataset, name of variables.  */


%let d=commrent;
proc print data =  &d.(obs=10);run;
proc means data=&d.;run;
proc corr data=&d.;run;

%let ind=age operating_expenses vacancy_rates SQfootage;

proc reg data=commrent;
model rental_rates=&ind.;
run; 

proc corr data=commrent;
var rental_rates &ind.;
run;

/* macro function. */
/* macro function saves you for typing the whole procedure. */


%macro foobar (params);
/* do something here; */
%mend foobar;

%macro myfunc(data=,n=10);
/* a equal sign after each of parameters. */
/* refer to the value, put & ahead. */

%mend myfunc;

%myfunc(data=proj,n=100);

%myfunc(data=proj);



/* Case study one */
proc import out = baseball datafile="&folder_loc.baseball.xlsx"
dbms=xlsx replace;
getnames=yes;
run;

/* view distribution of data */
proc means data=baseball;run;

/* the top 5 home run players in 1986; */
proc sort data=baseball; by descending nhome;run;
proc print data=baseball(obs=5);run;

/* the top 5 paid players in 1986 */
proc sort data=baseball; by descending salary;run;
proc print data=baseball(obs=5);run;

/* the impact of home runs on salary; */
proc reg data=baseball;
model salary = nhome;
run;

/* add more variables */
proc reg data=baseball;
MODEL salary = nHome nHits nRuns nAtBat nRBI nBB nOuts nError;
RUN;

* calculate performance score;
DATA score;
SET baseball;
ps= 3*nHome + 0.5*nHits + 1*nRuns +1* nAtBat 
    - 1*nRBI + 0.3*nBB + 2*nOuts - 1*nError;
RUN;

/* regression ps on salary */
proc reg data=score;
model salary = ps;
run;


/* case study 2 */
PROC IMPORT OUT=car DATAFILE="&folder_loc.cars.xlsx" DBMS=XLSX;
GETNAMES=YES;
RUN;
 
PROC CORR DATA=car;RUN;
 
* determinants of horse power;
/* multi-linearity heaveily damage parameter estimate.  */
PROC REG DATA=car;
MODEL horsepower=cylinders enginesize/ VIF;
RUN;

PROC REG DATA=car;
MODEL horsepower=cylinders/ VIF;
RUN;

* determinants of MPG;
PROC REG DATA=car;
MODEL MPG_city = cylinders weight wheelbase length / VIF;
RUN;
 
* determinants of price;
PROC REG DATA=car;
MODEL MSRP = horsepower MPG_city / VIF;
RUN;

* brand premium;
PROC GLM DATA=car;
CLASS make;
MODEL MSRP = horsepower MPG_city make / noint solution;
RUN;
