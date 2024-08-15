: begin here ; immediate
: again lit branch , here - , ; immediate
: until lit branch0 , here - , ; immediate
: while lit branch0 , here 0 , ; immediate
: repeat swap lit branch , here - , here over - swap ! ; immediate
: if lit branch0 , here 0 , ; immediate
: else lit branch , here 0 , swap here over - swap ! ; immediate
: then here over - swap ! ; immediate
: nip swap drop ;
: -rot rot rot ;
: ?dup dup if dup then ;
: 2dup over over ;
: tuck swap over ;
: 2drop drop drop ;
: % /mod drop ;
: / /mod nip ;
: > swap < ;
: = 2dup < invert -rot swap < invert and ;
: <> = invert ;
: >= < invert ;
: <= swap < invert ;
: ( begin key 41 = until ; immediate
: min 2dup < if drop else nip then ;
: max 2dup > if drop else nip then ;
: cr 10 emit ;

: variable
  word mkhdr
  48016 , 1024 , 58367 ,
  lit lit ,
  here 4 + ,
  lit exit , 0 , ;

: constant
  word mkhdr
  48016 , 1024 , 58367 ,
  lit lit , ,
  lit exit , ;

: . ( n -- )
    dup 0 < if 45 emit -1 * then
    10 /mod ?dup if . then
    48 + emit ;

: print ( a -- ) begin dup c@ 0 <> while dup c@ emit 1 + repeat drop ;

: "
  lit lit , here 6 + ,
  lit branch , here 0 ,
  key begin dup 34 <> while c, key repeat drop
  0 c,
  dup here swap - swap !
; immediate

save

