
use strict;
use warnings;

package Games::Bowling::Scorecard::Frame::TenPinTenth;
use base qw(Games::Bowling::Scorecard::Frame);

=head1 NAME

Games::Bowling::Scorecard::Frame::TenPinTenth - ten pin's weird 10th frame

=head1 VERSION

version 0.001

  $Id$

=cut


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
