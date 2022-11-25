use v5.20.0;
use warnings;
package Games::Bowling::Scorecard;
# ABSTRACT: score your bowling game easily

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

  printf "total score: %u\n", $card->score; # total score: 156, lousy!

=head1 DESCRIPTION

Scoring ten-pin bowling can be confusing for new players.  Frames can't always
be scored until several frames later, and then there's that weird tenth frame.
Modern bowling alleys incorporate computer scoring into the pin cleanup
mechanism, so it's easy to just concentrate on throwing a perfect game and not
on grease-pencilling the sheet for the overhead.

What's one to do, though, when bowling cantaloupes at beer bottles in one's
back yard?  Now, with Games::Bowling::Scorecard, it's easy to improvise a
scoring device -- maybe on a mobile phone running Symbian Perl.

=cut

use Games::Bowling::Scorecard::Frame;

=method new

This returns a new scorecard object.  It does not take any arguments.

=cut

sub new {
  my ($class) = @_;

  my $self = bless { frames => [ ] } => $class;

  return $self;
}

=method frames

  my @frames = $card->frames;

This method returns all of the frames for the game.  This will return all
frames in which scores have been recorded, and possibly one final frame with no
recorded balls.  It will never return any frames after that.

Frames are returned as Games::Bowling::Scorecard::Frame objects.

=cut

sub frames {
  my ($self) = @_;

  return @{ $self->{frames} };
}

=method current_frame

The current frame is the frame into which the next ball will be recorded.  If
the card is done, this method returns false.

=cut

sub current_frame {
  my ($self) = @_;

  return if $self->is_done;

  my @frames = $self->frames;

  my $frame = pop @frames;

  return $self->_next_frame if !$frame || $frame->is_done;

  return $frame;
}

sub _next_frame {
  my ($self) = @_;

  my $frame = $self->frames == 9
            ? do {
                require Games::Bowling::Scorecard::Frame::TenPinTenth;
                Games::Bowling::Scorecard::Frame::TenPinTenth->new;
              }
            : Games::Bowling::Scorecard::Frame->new;

  push @{ $self->{frames} }, $frame;

  return $frame;
}

=method pending_frames

This method returns any completed frames the score of which has not yet been
finalized.  This includes spares and strikes, before the next ball or balls
have been recorded.

=cut

sub pending_frames {
  my ($self) = @_;

  my @pending_frames = grep { $_->is_pending } $self->frames;
}

=method record

  $card->record(@balls);

This method makes a record of a ball or balls.  It is passed a list of bowling
results, each being a number of pins knocked down by the ball.

For example:

  $card->record(0, 0);  # two gutter balls

  $card->record(6, 4);  # a spare

  $card->record( (0, 0) x 10); # the worst game you could play

  $card->record( (10) x 12 ); # a perfect game

An exception will be raised if this method is called on a scorecard that's
done.

If you need to record a ball with more arguments, you can pass them together in
an array reference.  For example, to pick up an incredible 7-10 split, you
might call:

  $card->record([ 8, { split => 1 } ], 2);

The first ball records that it's a split, and the second ball just gets two
pins.

=cut

sub record { ## no critic Ambiguous
  my $self  = shift;
  my @balls = @_;

  for my $i (0 .. $#balls) {
    Carp::croak "can't record more balls on a completed scorecard"
      if $self->is_done;

    my ($ball, $arg) = ref $balls[$i]
                     ? ($balls[$i][0], $balls[$i][1])
                     : ($balls[$i]);

    for my $pending ($self->pending_frames) {
      $pending->record($ball);
    }

    $self->current_frame->record($ball, $arg);
  }
}

=method score

This method returns the current score.  It will include the tentative score for
all pending frames.

=cut

sub score {
  my ($self) = @_;

  my $score = 0;
  $score += $_->score for $self->frames;

  return $score;
}

=method score_through

  my $score = $card->score_through($n)

This method returns the score as of the end of the I<n>th frame.  If that
frame's cannot be definitively stated, because it is pending or not done, undef
is returned.

=cut

sub score_through {
  my ($card, $n) = @_;

  Carp::croak "frame out of range" unless $n >= 1 and $n <= 10;

  my @frames = $card->frames;
  my $score = 0;

  INDEX: for my $idx (0 .. $n - 1) {
    my $frame = $frames[ $idx ];
    return undef if $frame->is_pending or not $frame->is_done;

    $score += $frame->score;
  }

  return $score;
}

=method is_done

This returns true if the scorecard is done.  The scorecard is done if its
contents indicate that the player's game is over.

=cut

sub is_done {
  my ($self) = @_;

  my @frames = $self->frames;

  return (@frames == 10 and $frames[9]->is_done);
}

=head1 TODO

=for :list
* maybe a way to indicate a split

=head1 SECRET ORIGINS

In late 2006, I hadn't bowled in something like ten years.  I got a Wii, and
while I recognized the little triangle and X marks on the Wii Sports Bowling
scorecard, I couldn't remember how on earth scoring worked.  Once I thought I
had a handle on it, I thought writing this would be a good way to cement it in
my mind.

=cut

300;
