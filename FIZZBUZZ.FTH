: div?    ( n n -- bool ) % 0 = ;
: fiz?    ( n -- bool ) 3 div? ;
: buz?    ( n -- bool ) 5 div? ;
: fizbuz? ( n -- bool ) dup fiz? swap buz? and ;

: fiz " fiz" print ;
: buz " buz" print ;
: space 32 emit ;

: match ( n -- )
  dup fizbuz? if fiz buz drop exit then
  dup fiz?    if fiz     drop exit then
  dup buz?    if buz     drop exit then
  . ;

: sequence ( n -- )
  1
  begin
    2dup >=
  while
    dup match space 1 +
  repeat
  2drop ;

15 sequence

bye
