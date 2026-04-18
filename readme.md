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
- ecl ::= amb|blu|brn|gry|grn|hzl|oth
- pid ::= ddddddddd, where d ::= 0-9

## Day 5

Part One: Seats on a plane are represented by a binary partition sequences, like
`FBFBBFFRLR`, which is called the boarding pass. This boarding pass represents
seat 5 in row 44. There are 8 seats in each of the 128 rows. Given that the seat
ID is the result of the expression `row * 8 + column` (for this sequence it
would be 357), find the highest seat ID from a list of boarding passes.

Part Two: Not all of the possible seat IDs on the plane actually exist,
specifically the ones at the front and back of the hypothetical rows. The input
includes all possible seats *except* one, but what is the ID of this seat?

## Day 6

Part One: The input contains groups of people's positive responses to a set of
questions, each question being identified by a single lowercase letter of the
alphabet (meaning there is a maximum of 26 different questions). For each group
of people, count the unique number of questions with positive reponses; then
take the same of this count for all groups.

Part Two: Same as before but instead count for each group the number of
questions for which everyone in the group gave positive responses.

## Day 7

Part One: Given a set of rules about what colour bags bags of a colour are
allowed to carry, find the number of different coloured bags that could fit
(no matter how indirectly) a `shiny gold` bag inside.

Part Two: Using the same rules, count how many bags a `shiny gold bag` contains.

## Day 8

Part One: You are given a program consisting of a simple instruction set:

- `acc` increases or decreases an accumulator by its operand
- `jmp` jumps to an instruction relative to itself using the operand as an
  offset
- `nop` which does nothing and continues to the next instruction

This particular program contains an infinite loop, which can be identified when
the execution jumps to an instruction that has already been executed. What is
the value of the accumulator immediately before the program loops?

Part Two: Exactly one of the instructions in the program has been corrupted;
either a `jmp` has become a `nop` or vice-versa. When it is not corrupted, the
program terminates by reaching the end of the instructions. After finding and
fixing the corruption, what is the value in the accumulator when the program
terminates?

