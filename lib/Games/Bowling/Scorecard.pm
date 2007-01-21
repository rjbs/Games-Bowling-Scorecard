use strict;
use warnings;

package Games::Bowling::Scorecard;

=head1 NAME

Games::Bowling::Scorecard - score your bowling game easily

=cut

use Games::Bowling::Scorecard::Frame;

sub new {
  my ($class) = @_;

  my $self = bless {
    frames => [ ],
    score  => 0,
  } => $class;

  return $self;
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

sub frames {
  my ($self) = @_;

  return @{ $self->{frames} };
}

sub current_frame {
  my ($self) = @_;

  # return if $self->is_done;

  my @frames = $self->frames;

  my $frame = pop @frames;

  return $self->_next_frame if !$frame or $frame->is_done;

  return $frame;
}

sub pending_frames {
  my ($self) = @_;

  my @pending_frames = grep { $_->is_pending } $self->frames;
}

sub record {
  my ($self, @balls) = @_;
  
  Carp::croak "can't record more balls on a completed scorecard"
    if $self->is_done;

  for my $ball (@balls) {
    for my $pending ($self->pending_frames) {
      $pending->record($ball);
    }

    $self->current_frame->record($ball);
  }
}

sub score {
  my ($self) = @_;

  my $score = 0;
  $score += $_->score for $self->frames;

  return $score;
}

sub is_done {
  my ($self) = @_;

  my @frames = $self->frames;

  return (@frames == 10 and $frames[9]->is_done);
}

1;
