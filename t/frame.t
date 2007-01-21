
use strict;
use warnings;

use Test::More tests => 37;

my $class = 'Games::Bowling::Scorecard::Frame';

use_ok($class);

{ # let's bowl an open frame
  my $frame = $class->new;

  isa_ok($frame, $class);

  is($frame->score, 0,     "frames start with a zero score");
  ok(! $frame->is_done,    "frames do not start done");
  ok(! $frame->is_pending, "frames do not start pending");

  $frame->record(5);
  is($frame->score, 5,     "one ball for five pins: tentative score 5");
  ok(! $frame->is_done,    "one ball for five pins: not done yet");
  ok(! $frame->is_pending, "one ball for five pins: not pending");

  $frame->record(3);
  is($frame->score, 8,     "bowled 5/3: score 8");
  ok($frame->is_done,      "after two balls, we're done");
  ok(! $frame->is_pending, "an open frame doesn't end up pending");
}

{ # let's bowl a spare
  my $frame = $class->new;

  isa_ok($frame, $class);

  is($frame->score, 0,     "frames start with a zero score");
  ok(! $frame->is_done,    "frames do not start done");
  ok(! $frame->is_pending, "frames do not start pending");

  $frame->record(5);
  is($frame->score, 5,     "one ball for five pins: tentative score 5");
  ok(! $frame->is_done,    "one ball for five pins: not done yet");
  ok(! $frame->is_pending, "one ball for five pins: not pending");

  $frame->record(5);
  is($frame->score, 10,  "bowled 5/5: score 10");
  ok($frame->is_done,    "after two balls, we're done");
  ok($frame->is_pending, "we bowled a spare, so we're pending");
  
  # and then let's record the extra ball
  $frame->record(6);
  is($frame->score, 16,    "recording 6 after a spare, we're at 16");
  ok($frame->is_done,      "a spare remains done after its bonus score");
  ok(! $frame->is_pending, "our spare is now done");
}

{ # let's bowl a strike!
  my $frame = $class->new;

  isa_ok($frame, $class);

  is($frame->score, 0,     "frames start with a zero score");
  ok(! $frame->is_done,    "frames do not start done");
  ok(! $frame->is_pending, "frames do not start pending");

  $frame->record(10);
  is($frame->score, 10,  "a strike!  tentative score: 10");
  ok($frame->is_done,    "a strike is done after one bowl");
  ok($frame->is_pending, "we bowled a strike, so we're pending");

  # first extra ball score
  $frame->record(5);
  is($frame->score, 15,  "a 5 after a strike; tentative score: 15");
  ok($frame->is_done,    "...and it stays done");
  ok($frame->is_pending, "...and it stays pending");
  
  # second extra ball score
  $frame->record(4);
  is($frame->score, 19,    "a 4 after a 5 after a strike: score 19");
  ok($frame->is_done,      "...and it stays done");
  ok(! $frame->is_pending, "...and it's not pending anymore");
}
