
use strict;
use warnings;

package Games::Bowling::Scorecard::Frame;

=head1 NAME

Games::Bowling::Scorecard::Frame - one frame on a scorecard

=head1 VERSION

version 0.001

  $Id$

=cut


use Carp ();

sub new {
  my ($class) = @_;

  bless {
    balls => [],
    score => 0,

    done    => 0,
    pending => 0,
  } => $class;
}

sub record {
  my ($self, $ball) = @_;

  if ($self->is_done) {
    if ($self->is_pending) {
      $self->{pending}--;
      $self->{score} += $ball;
      return;
    } else {
      Carp::croak "two balls already recorded for frame" if $self->is_done;
    }
  }

  push @{ $self->{balls} }, $ball;
  $self->{score} += $ball;

  $self->_check_done;
  $self->_check_pending;
}

sub _check_pending {
  my ($self) = @_;
  return unless $self->is_done;

  return $self->{pending} = 2
    if @{ $self->{balls} } == 1 and $self->{balls}[0] == 10;

  return $self->{pending} = 1
    if @{ $self->{balls} } == 2 and $self->{balls}[0] + $self->{balls}[1] == 10;
}

sub _check_done {
  my ($self) = @_;

  $self->{done} = 1
    if (@{ $self->{balls} } == 1 and $self->{balls}[0] == 10)
    or @{ $self->{balls} } == 2;
}

sub score {
  my ($self) = @_;
  return $self->{score};
}

sub is_pending {
  my ($self) = @_;
  return $self->{pending};
}

sub is_done {
  my ($self) = @_;
  return $self->{done};
}

sub balls {
}

1;
