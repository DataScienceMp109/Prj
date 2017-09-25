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
/*DSD: it recognize two consecutive delimiters as a missing value; it allows you to include
delimiters within quoted strings.
MISSOVER: This option prevents SAS from going to a new input line if it does not find values
for all of the variables in the current line of data, so you do not get messy results. */
/*Declare a string variable uses $.*/
input CUSIP $ fyer name$;
run;
proc print;
run;






9/25/2107


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
