
use strict;
use warnings;

use Test::More tests => 21;

my $class = 'Games::Bowling::Scorecard';

use_ok($class);

{ # worst possible game
  my $card = $class->new;

  isa_ok($card, $class);

  for (1 .. 10) {
    $card->record(0, 0);
  }

  is($card->score, 0, "the worst game you can bowl has score 0");

  ok($card->is_done, "we're done after ten gutterballs");

  eval { $card->record(0); };
  ok($@, "trying to record a ball after we're done dies");
}

{ # worst possible game, always hitting a pin
  my $card = $class->new;

  isa_ok($card, $class);

  for (1 .. 10) {
    $card->record(1,1);
  }

  is($card->score, 20, "the worst game you can bowl, if you always hit a pin");

  ok($card->is_done, "we're done after ten 1-pin bowls");

  eval { $card->record(0); };
  ok($@, "trying to record a ball after we're done dies");
}


{ # a PERFECT GAME!!
  my $card = $class->new;

  isa_ok($card, $class);

  for (1 .. 10) {
    $card->record(10);
  }

  # Having thrown ten strikes, we are TOTALLY AWESOME and the card looks like:
  #  10  10  10  10  10  10  10  10  10  10
  #  30  30  30  30  30  30  30  30  20* 10*
  #  30  60  90 120 150 180 210 240 260 270
  #                                          10 10
  #                                  30  30   0  0
  #                                 270 300

  is($card->score, 270, "after ten strikes, we're standing at 270");

  {
    my ($last_frame) = $card->current_frame;

    my @frames  = $card->frames;
    my $frame_9 = $frames[8];

    ok($last_frame != $frame_9, "frame 9 isn't the current frame");

    is($frame_9->score, 20,  "the 9th frame is standing at 20 points");
    ok($frame_9->is_done,    "the 9th frame is done");
    ok($frame_9->is_pending, "the 9th frame is pending (one more pin)");

    is($last_frame->score, 10, "the 10th frame is standing at 10 points");
    ok(! $last_frame->is_done, "the 10th frame is not yet done");
  }

  ok(! $card->is_done, "but after ten strikes, we're not done!");

  $card->record(10); # strike in the 10th, bonus 1
  $card->record(10); # strike in the 10th, bonus 2

  ok($card->is_done, "we're done after twelve strikes bowls");
  is($card->score, 300, "...and it's a PERFECT GAME");

  eval { $card->record(0); };
  ok($@, "trying to record a ball after we're done dies");
}
