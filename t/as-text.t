#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

use Games::Bowling::Scorecard;
use Games::Bowling::Scorecard::AsText;

my $card = Games::Bowling::Scorecard->new;

$card->record(6,1);  # slow start
$card->record(7,2);  # getting better
$card->record(10);   # strike!
$card->record(9,1);  # picked up a spare
$card->record(10) for 1 .. 3; # turkey!
$card->record(0,0);  # clearly distracted by something
$card->record(8,2);  # amazingly picked up 7-10 split
$card->record(10, 9, 1); # pick up a bonus spare

my $expected = <<'END_TEXT';
+-----+-----+-----+-----+-----+-----+-----+-----+-----+-------+
| 6 1 | 7 2 | X   | 9 / | X   | X   | X   | - - | 8 / | X 9 / |
|   7 |  16 |  36 |  56 |  86 | 106 | 116 | 116 | 136 |   156 |
END_TEXT

is(
  Games::Bowling::Scorecard::AsText->card_as_text($card),
  $expected,
  "our scorecard stringifies as we expected",
);
