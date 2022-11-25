use v5.24.0;
use warnings;

package Games::Bowling::Scorecard::Frame;
# ABSTRACT: one frame on a scorecard

=head1 DESCRIPTION

A frame is one attempt to knock down all ten pins -- unless it's the tenth
frame, in which case it's so goofy that you need to use a different class,
L<Games::Bowling::Scorecard::Frame::TenPinTenth>.  A frame is done when you've
bowled twice or knocked down all the pins, and it's pending until its score can
be definitively be stated.

=cut

use Carp ();

=method new

This method returns a new frame object.

=cut

sub new {
  my ($class) = @_;

  bless {
    balls => [],
    score => 0,

    done    => 0,
    pending => 0,
  } => $class;
}

=method record

  $frame->record($ball, \%arg);

This method records a single ball against the frame.  This method is used for
both the current frame and for pending frames.  It updates the frame's score
and whether the frame is done or pending.

The only valid argument in C<%arg> is C<split>. If true, it indicates the pins
are split.  This can only be passed on the first ball of a frame.

=cut

sub _assert_split_ok {
  my ($self, $ball) = @_;

  if ($self->{balls}->@*) {
    Carp::croak "can't record a split on second ball in a frame";
  }

  if ($ball >= 9) {
    Carp::croak "you can't split if you knocked down $ball pins!";
  }

  return;
}

sub record { ## no critic Ambiguous
  my ($self, $ball, $arg) = @_;

  if ($arg->{split}) {
    $self->_assert_split_ok($ball);

    $self->{split} = 1;
  }

  if ($self->is_done) {
    if ($self->is_pending) {
      $self->{pending}--;
      $self->{score} += $ball;
      return;
    } else {
      Carp::croak "two balls already recorded for frame";
    }
  }

  $self->roll_ok($ball);

  push @{ $self->{balls} }, $ball;
  $self->{score} += $ball;

  $self->_check_done;
  $self->_check_pending;
}

sub was_split {
  return $_[0]->{split} ? 1 : 0;
}

sub _check_pending {
  my ($self) = @_;
  return unless $self->is_done;

  my @balls = $self->balls;

  return $self->{pending} = 2 if @balls == 1 and $balls[0] == 10;
  return $self->{pending} = 1 if @balls == 2 and $balls[0] + $balls[1] == 10;
}

sub _check_done {
  my ($self) = @_;

  my @balls = $self->balls;

  $self->{done} = 1 if (@balls == 1 and $balls[0] == 10) or @balls == 2;
}

=method roll_ok

  $frame->roll_ok($ball);

This method asserts that given value is an acceptable number to score next in
this frame.  It checks that:

  * the frame is not already done
  * $ball is defined, an integer, and between 0 and 10
  * $ball would not bring the total number of pins downed above 10

=cut

sub roll_ok {
  my ($self, $ball) = @_;

  Carp::croak "the frame is done" if $self->is_done;
  Carp::croak "you can't bowl an undefined number of pins!" if !defined $ball;
  Carp::croak "you can't bowl more than 10 on a single ball" if $ball > 10;
  Carp::croak "you can't bowl less than 0 on a single ball" if $ball < 0;
  Carp::croak "you can't knock down a partial pin" if $ball != int($ball);

  my $i = 0;
  $i += $_ for $self->balls, $ball;

  Carp::croak "bowling a $ball would bring the frame above 10" if $i > 10;
}

=method score

This method returns the current score for the frame, even if the frame is not
done or is pending further balls.

=cut

sub score {
  my ($self) = @_;
  return $self->{score};
}

=method is_pending

This method returns true if the frame is pending more balls -- that is, it
returns true for strikes or spares which have not yet recorded the results of
subsequent balls.

=cut

sub is_pending {
  my ($self) = @_;
  return $self->{pending};
}

=method is_done

This method returns true if the frame is done.

=cut

sub is_done {
  my ($self) = @_;
  return $self->{done};
}

=method balls

This method returns the balls recorded against the frame, each ball returned as
the number of pins it knocked down.  In scalar context, it returns the number
of balls recoded against the frame.

=cut

sub balls {
  my ($self) = @_;
  return @{ $self->{balls} };
}

300;
