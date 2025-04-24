proc format;
value numffmt
1='0'
2='1-2'
3='3-5'
4='6-9'
5='10+';
value morfmt
  1='More'
  2='Fewer'
  3='Same';
 value ynft  0='No'
	     1='Yes';
 value raceft  0='White'
	       1='Black'
	       2='Latina'
	       3='Asian'
               4='Others';
 value edft    1='le HS'
	       0='gt HS';

  value marft   1='married/partner'
	       0='single';


 value estroft 1='positive'
	       2='negative'
	       3='unknown';
 value mk1fmt 1="positive"
              2="negative"
			  0,3,8,9="unknown";
 value srfmt 3="Mast & radn"
             2="Mast no radn"
			 1="Lump & radn"
			 0="Lump no radn";
run;
