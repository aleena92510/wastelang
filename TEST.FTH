: ok 79 emit 75 emit ;
: fail 70 emit 65 emit 73 emit 76 emit 1 (bye) ;
: assert ( bool -- ) if ok else fail then ;

: =assert ( n1 n2 -- )
  2dup <> if
    swap . 60 emit 62 emit .
    32 emit fail
  else
    drop drop ok
  then ;

depth 0 =assert

 0 invert         assert
-1 invert invert  assert
-1 invert   0    =assert
 0 invert  -1    =assert

depth 0 =assert

1 0 or   1 =assert 
0 1 or   1 =assert
1 1 or   1 =assert 
0 0 or   0 =assert
1 0 and  0 =assert 
0 1 and  0 =assert
1 1 and  1 =assert 
0 0 and  0 =assert
1 0 xor  1 =assert 
0 1 xor  1 =assert
1 1 xor  0 =assert
0 0 xor  0 =assert

123 456 or  507 =assert
123 456 and 72  =assert
123 456 xor 435 =assert

depth 0 =assert

1 2 3 depth 3 =assert
swap depth  3 =assert
drop depth  2 =assert
dup depth   3 =assert
rot depth   3 =assert
-rot depth  3 =assert
nip depth   2 =assert
drop depth  1 =assert
drop depth  0 =assert

4 dup
            4 =assert
            4 =assert
1 2 3 rot
            1 =assert
            3 =assert
            2 =assert
1 2 3 -rot
            2 =assert
            1 =assert
            3 =assert
1 2 swap
            1 =assert
            2 =assert
1 2 3 nip
            3 =assert
            1 =assert            
1 2 over
            1 =assert
            2 =assert
            1 =assert

depth 0 =assert

4 dup +     8 =assert
3 dup *     9 =assert
10 dup -    0 =assert
5 dup /     1 =assert
6 dup %     0 =assert

depth 0 =assert

6 4 +      10 =assert
-5 -9 +   -14 =assert
5 4 -       1 =assert
10 15 -    -5 =assert
-5 -4 -    -1 =assert
-5 4  -    -9 =assert
5 3 *      15 =assert
6 -4 *    -24 =assert
-6 -3 *    18 =assert
12 3 /      4 =assert
13 3 /      4 =assert
8 -2 /     -4 =assert
13 3 %      1 =assert

depth 0 =assert

1 2 <>         assert
-9 9 <>        assert
5 5 =          assert
-5 -5 =        assert
1 4 <          assert
-3 0 <         assert
5 4 >          assert
-3 -4 >        assert
4 4 >=         assert
4 4 <=         assert
5 4 >=         assert
5 6 <=         assert

10    0 lshift    10 =assert
10    0 rshift    10 =assert
0     0 lshift     0 =assert
0     0 rshift     0 =assert
1234  5 lshift 39488 =assert
39488 5 rshift  1234 =assert
-456  2 lshift -1824 =assert

depth 0 =assert

variable v
42 v !

v @       42 =assert
5 v ! v @  5 =assert

314 constant c
depth 0 =assert
314 c =assert

depth 0 =assert

3 4 min    3 =assert
3 4 max    4 =assert
4 3 min    3 =assert
4 3 max    4 =assert
-4 -1 min -4 =assert
-4 -1 max -1 =assert

depth 0 =assert

here 123 allot here swap - 123 =assert

depth 0 =assert

: fact ( n -- n! )
    1 2 rot
    begin
        2dup <=
    while
        -rot tuck
        * swap
        1 + rot
    repeat
    drop drop ;

8 fact 40320 =assert

depth 0 =assert

: test-until ( -- 2048 ) 2 10 begin 1 - swap 2 * swap dup 0 = until drop ;

test-until 2048  =assert

depth 0 =assert

: exit-test begin 15 exit 0 until ;
exit-test 15 =assert

variable c
0 c !
: nested
  0
  begin
    1 + 9
    begin
      dup 0 >=
    while
      1 -
      c @ 1 + c !
    repeat
    drop dup 10 >=
  until
  drop ;

nested
c @ 100 =assert

: xt: word find if nip else nip nip 0 then ;
: exec-test 230 4 + ;
xt: exec-test exec 234 =assert

: compile35 lit lit , 35 , ; immediate
: test-lit compile35 ;

test-lit 35 =assert

depth 0 =assert

( *** All Tests Passed *** )

bye

