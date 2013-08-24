use strict;
use warnings;

package Games::Bowling::Scorecard::Frame::TenPinTenth;
use parent qw(Games::Bowling::Scorecard::Frame);
# ABSTRACT: ten pin's weird 10th frame

=head1 DESCRIPTION

The tenth frame of ten pin bowling is weird.  If you bowl a strike or spare,
you're allowed to throw balls to complete the frame's scoring.  The extra balls
are only counted for bonus points.  In other words, if the first two balls in
the tenth frame are strikes, the second ball is not counted as a "pending"
strike.  If this is confusing, don't worry!  That's why you're using this
module.

=method is_done

The tenth frame is done if: (a) three balls have been bowled or (b) two balls
have been bowled, totalling less than ten.

=cut

sub is_done {
  my ($self) = @_;

  my @balls = $self->balls;

  return 1 if @balls == 3 or @balls == 2 and $balls[0] + $balls[1] < 10;
  return;
}

=method is_pending

The tenth frame is never pending.  Once it's done, its score is final.

=cut

sub is_pending {
  return 0;
}

=method roll_ok

The tenth frame's C<roll_ok> is identical to the standard C<roll_ok>, but
replaces the "can't total more than 10" rule with a more complex rule.

=cut

sub roll_ok {
  my ($self, $ball) = @_;

  eval { $self->SUPER::roll_ok($ball) };

  if (my $error = $@) {
    return if $error =~ /would bring the frame above 10/;
    die $error;
  }
}

300;
