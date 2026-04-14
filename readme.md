# Advent of Code 2020 IN HASKELL ?

Not bothering with the data parsing this time, since it really doesn't seem to
be the point to me. This means that the data will be included with the source
code.

## Day 1

Part One: Find the product of two integers in a list that sum to 2020.

Part Two: Find the product of three integers in a list that sum to 2020.

## Day 2

Part One: Determine whether the count of a character in a string is within a
minimum and maximum bound; if so this string is considered a *valid password*.
Find the number of valid passwords within a list of strings.

Part Two: Determine whether *only one* of the specified indices is equal to the
specified character; if so this string is considered a *valid password*. As
above, find the number of valid passwords with a list of strings.

## Day 3

Given a grid of *trees* that repeats infinitely to the right, find the number of
trees encountered on the line that follows the slope `(right 3, down 1)` from
the top-left corner of the grid.

Part Two: The same as abve, but for multiple slopes, `(right 1, down 1)`,
`(right 3, down 1)`, `(right 5, down 1)`, `(right 7, down 1)` and `(right 1,
down 2`. Take the product of the number of trees that each slope collides with
on the grid.

## Day 4

Part One: A valid passport has all of the following fields: `byr` birth year,
`iyr` issue year, `eyr` expiration year, `hgt` height, `hcl` hair colour, `ecl`
eye colour, `pid` passport ID, `cid` country ID. *However*, you have modified
this system to permit omissions of the `cid`. Using this modified system, for a
given batch of passports, count the number of valid passport.

Part Two: Same as above only valid passport must have valid values for each
specified field:

- 1920 <= `byr` <= 2002
- 2010 <= `iyr` <= 2020
- 2020 <= `eyr` <= 2030
- `hgt` ::= <number>(cm|in)
    - for cm, 150 <= number <= 193
    - for in, 59 <= number <= 76
- hcl ::= #hhhhhh, where h ::= 0-9a-f
- ecl ::= amb|blue|brn|gry|grn|hzl|oth
- pid ::= ddddddddd, where d ::= 0-9

