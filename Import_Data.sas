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