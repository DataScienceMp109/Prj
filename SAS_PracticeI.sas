/*missover truckover*/

data missover_truckover;
infile datalines truncover;
input id  name $;
datalines;
1 mike
22 
333 liu
4444 wu
;
run;

data missover_truckover;
infile datalines truncover;
input id name $;
datalines;
1 mike
22 
333 liu
4444 wu
;
run;

data text;
infile "C:\Users\Mo.Pei\Desktop\data2\SAS_Regression\Prj\missover\text.txt" truncover ;
input id 2. name $8.;
run;

/*@@*/
DATA Readin;
   Input Name $ Score @@;   
   cards;
Sam 25 David 30 Ram 35
Deeps 20 Daniel 47 Pars 84
   ;
RUN;


/*proc means*/
data loss_info;
set in.loss_info;
run;


proc means data=loss_info n mean max min std nmiss;
var LossAmount
run;

/*by group.*/
proc means data=loss_info n mean max min std nmiss;
class LossCode/descending;
var LossAmount;
run;

/*by each group frequency.*/
proc means data=loss_info n mean max min std nmiss;
class LossCode/order=freq;
var LossAmount;
run;

/*display by each group frequency.*/
proc sort data= loss_info;
by LossCode;
run;

proc means data=loss_info n mean max min std nmiss;
by LossCode;
var LossAmount;
run;

/*output data and give mean and median names.*/
proc means data=loss_info n mean max min std nmiss;
class LossCode;
var LossAmount;
output out=loss_avg mean=median=/autoname;
run;

proc means data=loss_info n mean max min std nmiss;
class LossCode;
var LossAmount;
output out=m1 mean=/autoname;
run;

proc means data=loss_info n mean max min std nmiss;
class LossCode;
var LossAmount;
output out=m1 mean(lossamount)=/autoname;
run;

/*Give different names.*/
proc means data=loss_info n mean max min std nmiss;
class LossCode;
var LossAmount;
output out=m1 mean=mean_loss median=median_loss;
run;

/*Drop and Keep option.*/
proc means data=loss_info n mean max min std nmiss;
class LossCode;
var LossAmount;
output out=m1 (drop = _type_)mean=mean_loss median=median_loss;
run;

/*Where statement.*/
proc means data=loss_info n mean max min std nmiss;
where LossAmount > 200;
class LossCode;
var LossAmount;
output out=m1 (drop = _type_)mean=mean_loss median=median_loss;
run;

proc means data=loss_info nway n mean max min std nmiss;
where LossAmount > 200;
class LossCode;
var LossAmount;
output out=m1 mean=mean_loss median=median_loss;
run;

/*Simple T test.*/
proc means data = loss_info t prt;
var LossAmount;
run;


/*Character function.*/
/*http://www.listendata.com/2014/12/sas-character-functions.html*/
/*COMPBL*/
Data char;
Input Name $ 1-50 ;
Cards;
Sandy    David
Annie Watson 
Hello ladies and gentlemen
Hi, I am good
;
Run;

Data char1;
Set char;
char1 = compbl(Name);
run;

/*STRIP*/
/*It removes leading and trailing spaces.*/

Data char1;
Set char;
char1 = strip(Name);
run;

/*3. COMPRESS Function*/
/*COMPRESS(String, characters to be removed, Modifier)
Default - It removes leading, between and trailing spaces
*/
Data char1;
Set char;
char1 = compress(Name);
run;


/*Remove specific characters*/
data _null_;
x='ABCDEF-!1.234';
string=compress(x,'!4');
put string=;
run;

data _null_;
x='ABCDEF-!1234';
string=compress(x,'','ak');put string=;
run;


/*4. LEFT Function*/
/**/
/*It removes leading spaces.*/
Data char1;
Set char;
char1 = left(Name);
run;



/*5. TRIM Function*/
/**/
/*It removes trailing spaces.*/
Data char1;
Set char;
char1 = trim(Name);
run;


/*7. CAT Function*/
/**/
/*It concatenates character strings. It is equivalent to || sign.*/
data _null_;
a = 'abc';
b = 'xyz';
c= a || b;
d= cat(a,b);
put c= d =;
run;

data _null_;
x = "Temp";
y = 22;
z = x||y;
z1 = cats(x,y);
z2 = catx(",",x,y);
put z = z1= z2 =;
run;

/*8.SCAN*/
data _null_;
string='Hi, How are you doing?';
first_word=scan(string, 1, ' ' );
put first_word =;
run;

/*the last word and in that case, the delimiter is blank.*/
data _null_;
string='Hi, How are you doing?';
last_word=scan(string, -1, ' ' );
put last_word =;
run;


data _null_;
string='Hello SAS community people';
beginning= scan( string, 1, 'S' ); ** returns "Hello ";
middle = scan( string, 2, 'S' ); ** returns "A";
end= scan( string, 3, 'S' ); **returns " community people";
put beginning= middle =  ;
run;




data _null_;
t="AFHood Analytics Group";
new_var=substr(t,8,9);
put new_var=;
run;

/*11. LOWCASE, UPCASE and PROPCASE*/
data _null_;
sentence= 'I do not now what are you talking about? What is that?';
lcase=lowcase(sentence);
ucase=upcase(sentence);
pcase=PROPCASE(sentence);
put lcase= ucase= pcase=;
run;





data _null_;
x='dfsfs'||'fdsf';
put x;
run;