
use strict;
use warnings;

package Games::Bowling::Scorecard::Frame::TenPinTenth;
use base qw(Games::Bowling::Scorecard::Frame);

sub is_done {
  my ($self) = @_;

  return 1 if @{ $self->{balls} } == 3
           or @{ $self->{balls} } == 2
              and $self->{balls}[0] + $self->{balls}[1] < 10;

  return;
}

sub is_pending {
  return 0;
}

1;
