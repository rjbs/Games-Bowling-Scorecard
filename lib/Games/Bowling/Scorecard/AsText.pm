
use strict;
use warnings;

package Games::Bowling::Scorecard::AsText;

=head1 NAME

Games::Bowling::Scorecard::AsText - format a bowling scorecard as text

=head1 VERSION

version 0.011

  $Id: /my/cs/projects/Games-Bowling-Scorecard/trunk/lib/Games/Bowling/Scorecard.pm 30255 2007-01-21T19:09:26.950988Z rjbs  $

=cut

our $VERSION = 0.011;

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

  +-----+-----+-----+-----+-----+-----+-----+-----+-----+-------+
  | 6 1 | 7 2 | X   | 9 / | X   | X   | X   | - - | 8 / | X 9 / |
  |   7 |  16 |  36 |  56 |  86 | 106 | 116 | 116 | 136 |   156 |

=head1 WARNING

This module's interface is almost certain to change, whenever the author gets
around to it.

=head1 DESCRIPTION

So, you've written a bowling record-keeper and now you want to print out
scorecards to your dynamic Gopher site.  Games::Bowling::Scorecard has taken
care of the scoring, but now you need to worry about all those slashes and
dashes and X's

=cut

use Carp ();

sub card_as_text {
  my ($self, $card) = @_;
  
  my $hdr = '+-----+-----+-----+-----+-----+-----+-----+-----+-----+-------+';
  my $balls  = '';
  my $scores = '';

  my @frames = $card->frames;
  INDEX: for my $i (0 .. 8) {
    my $frame = $frames[ $i ];
    unless ($frame) {
      $_  .= '|     ' for $balls, $scores;
      next INDEX;
    }

    my ($b1, $b2) = $frame->balls;

    $balls .= sprintf '| %s ', $self->two_balls($b1, $b2);

    my $score = $self->score_through($card, $i + 1);
    $scores .= defined $score
             ? sprintf '| %3u ', $score
             : '|     ';
  }

  TENTH: for (1) {
    my $frame = $frames[ 9 ];

    unless ($frame and $frame->balls) {
      $_ .= '|       |' for $balls, $scores;
      last TENTH;
    }

    $balls .= sprintf '| %s |', $self->three_balls($frame->balls);

    my $score = $self->score_through($card, 10);
    $scores .= defined $score
             ? sprintf '|   %3u |', $score
             : '|       |';
  }

  return "$hdr\n"
       . "$balls\n"
       . "$scores\n";
}

sub score_through {
  my ($self, $card, $which_frame) = @_;

  Carp::croak "frame out of range"
    unless $which_frame >= 1 and $which_frame <= 10;

  my @frames = $card->frames;
  my $score = 0;

  INDEX: for my $idx (0 .. $which_frame - 1) {
    my $frame = $frames[ $idx ];
    return undef if $frame->is_pending or not $frame->is_done;

    $score += $frame->score;
  }

  return $score;
}

sub two_balls {
  my ($self, $b1, $b2) = @_;

  sprintf '%s %s',
    $b1 == 10 ? 'X' : $b1 || '-',
    $b1 == 10 ? ' ' : defined $b2 ? $b1 + $b2 == 10 ? '/' : $b2 || '-' : ' ';
}

sub three_balls {
  my ($self, $b1, $b2, $b3) = @_;

  if ($b1 == 10) {
    return 'X    ' unless defined $b2;

    return sprintf 'X X %s', defined $b3 ? $b3 == 10 ? 'X' : $b3 || '-' : ' '
      if $b2 == 10;

    return sprintf 'X %s', $self->two_balls($b2, $b3);
  } elsif (not defined $b2) {
    return sprintf '%s    ', $b1 || '-';
  } elsif ($b1 + $b2 == 10) {
    return sprintf '%s %s',
      $self->two_balls($b1, $b2),
      defined $b3 ? $b3 || '-' : ' ';
  } else {
    return sprintf '%s  ', $self->two_balls($b1, $b3);
  }
}

300;
