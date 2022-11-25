use v5.20.0;
use warnings;
package Games::Bowling::Scorecard::AsText;
# ABSTRACT: format a bowling scorecard as text

use utf8;

=encoding utf8

=head1 SYNOPSIS

  use Games::Bowling::Scorecard;

  my $card = Games::Bowling::Scorecard->new;

  $card->record(6,1);  # slow start
  $card->record(7,2);  # getting better
  $card->record(10);   # strike!
  $card->record(9,1);  # picked up a spare
  $card->record(10) for 1 .. 3; # turkey!
  $card->record(0,0);  # clearly distracted by something
  $card->record(8,2);  # amazingly picked up 7-10 split
  $card->record(10, 9, 1); # pick up a bonus spare

  print Games::Bowling::Scorecard::AsText->card_as_text($card);

The above outputs:

  ┏━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━━━┓
  ┃ 6 1 ┃ 7 2 ┃ ╳   ┃ 9 ◢ ┃ ╳   ┃ ╳   ┃ ╳   ┃ - - ┃ 8 ◢ ┃ ╳ 9 ◢ ┃
  ┃   7 ┃  16 ┃  36 ┃  56 ┃  86 ┃ 106 ┃ 116 ┃ 116 ┃ 136 ┃   156 ┃
  ┗━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━━━┛

=head1 WARNING

This module's interface is almost certain to change, whenever the author gets
around to it.

=head1 DESCRIPTION

So, you've written a bowling record-keeper and now you want to print out
scorecards to your dynamic Gopher site.  Games::Bowling::Scorecard has taken
care of the scoring, but now you need to worry about all those slashes and
dashes and X's

=method card_as_text

  my $text = Games::Bowling::Scorecard::AsText->card_as_text($card);

Given a scorecard, this method returns a three-line text version of the card,
using standard notation.  A total is kept only through the last non-pending
frame.

=cut

use Carp ();

sub card_as_text {
  my ($self, $card) = @_;

  my $hdr = '┏━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━┳━━━━━━━┓';
  my $ftr = '┗━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━┻━━━━━━━┛';
  my $balls  = '';
  my $scores = '';

  my @frames = $card->frames;
  INDEX: for my $i (0 .. 8) {
    my $frame = $frames[ $i ];
    unless ($frame) {
      $_  .= '┃     ' for $balls, $scores;
      next INDEX;
    }

    $balls .= sprintf '┃ %s ',
      $self->_two_balls($frame->was_split, $frame->balls);

    my $score = $card->score_through($i + 1);
    $scores .= defined $score
             ? sprintf '┃ %3u ', $score
             : '┃     ';
  }

  TENTH: for (1) {
    my $frame = $frames[ 9 ];

    unless ($frame) {
      $_ .= '┃       ┃' for $balls, $scores;
      last TENTH;
    }

    $balls .= sprintf '┃ %s ┃',
      $self->_three_balls($frame->was_split, $frame->balls);

    my $score = $card->score_through(10);

    $scores .= defined $score
             ? sprintf '┃   %3u ┃', $score
             : '┃       ┃';
  }

  return "$hdr\n"
       . "$balls\n"
       . "$scores\n"
       . "$ftr\n";
}

my @NUM = qw(
  - 1 2 3 4 5 6 7 8 9
    ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ 
);

sub _two_balls {
  my ($self, $split, $b1, $b2) = @_;

  return '   ' unless defined $b1;

  my $c = $NUM[ (9 * $split) + $b1 ];

  sprintf '%s %s',
    $b1 == 10 ? '╳' : $c,
    $b1 == 10 ? ' ' : defined $b2 ? $b1 + $b2 == 10 ? '◢' : $b2 || '-' : ' ';
}

sub _three_balls {
  my ($self, $split, $b1, $b2, $b3) = @_;

  return '     ' unless defined $b1;

  if ($b1 == 10) {
    return '╳    ' unless defined $b2;

    return sprintf '╳ ╳ %s', defined $b3 ? $b3 == 10 ? '╳' : $b3 || '-' : ' '
      if $b2 == 10;

    return sprintf '╳ %s', $self->_two_balls($split, $b2, $b3);
  } elsif (not defined $b2) {
    return sprintf '%s    ', $b1 || '-';
  } elsif ($b1 + $b2 == 10) {
    return sprintf '%s %s',
      $self->_two_balls($split, $b1, $b2),
      defined $b3 ? $b3 == 10 ? '╳' : $b3 || '-' : ' ';
  } else {
    return sprintf '%s  ', $self->_two_balls($split, $b1, $b2);
  }
}

300;
