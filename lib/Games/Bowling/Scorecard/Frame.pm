
use strict;
use warnings;

package Games::Bowling::Scorecard::Frame;

=head1 NAME

Games::Bowling::Scorecard::Frame - one frame on a scorecard

=head1 VERSION

version 0.103

=cut

our $VERSION = '0.103';

=head1 DESCRIPTION

A frame is one attempt to knock down all ten pins -- unless it's the tenth
frame, in which case it's so goofy that you need to use a different class,
L<Games::Bowling::Scorecard::Frame::TenPinTenth>.  A frame is done when you've
bowled twice or knocked down all the pins, and it's pending until its score can
be definitively be stated.

=cut

use Carp ();

=head1 METHODS

=head2 new

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

=head2 record

  $frame->record($ball);

This method records a single ball against the frame.  This method is used for
both the current frame and for pending frames.  It updates the frame's score
and whether the frame is done or pending.

=cut

sub record { ## no critic Ambiguous
  my ($self, $ball) = @_;

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

=head2 roll_ok

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

=head2 score

This method returns the current score for the frame, even if the frame is not
done or is pending further balls.

=cut

sub score {
  my ($self) = @_;
  return $self->{score};
}

=head2 is_pending

This method returns true if the frame is pending more balls -- that is, it
returns true for strikes or spares which have not yet recorded the results of
subsequent balls.

=cut

sub is_pending {
  my ($self) = @_;
  return $self->{pending};
}

=head2 is_done

This method returns true if the frame is done.

=cut

sub is_done {
  my ($self) = @_;
  return $self->{done};
}

=head2 balls

This method returns the balls recorded against the frame, each ball returned as
the number of pins it knocked down.  In scalar context, it returns the number
of balls recoded against the frame.

=cut

sub balls {
  my ($self) = @_;
  return @{ $self->{balls} };
}

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Games-Bowling-Scorecard>.  I
will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Ricardo SIGNES, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

300;
