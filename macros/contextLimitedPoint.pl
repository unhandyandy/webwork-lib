loadMacros("Parser.pl");

sub _contextLimitedPoint_init {}; # don't load it again

##########################################################
#
#  Implements a context in which points can be entered,
#  but no operations are permitted between points.  So
#  students will be able to perform operations within the
#  coordinates of the points, but not between points.
#
#

#
#  Handle common checking for BOPs
#
package LimitedPoint::BOP;

#
#  Do original check and then if the operands are numbers, its OK.
#  Otherwise report an error.
#
sub _check {
  my $self = shift;
  my $super = ref($self); $super =~ s/LimitedPoint/Parser/;
  &{$super."::_check"}($self);
  return if $self->checkNumbers;
  my $bop = $self->{def}{string} || $self->{bop};
  $self->Error("In this context, '$bop' can only be used with Numbers");
}

##############################################
#
#  Now we get the individual replacements for the operators
#  that we don't want to allow.  We inherit everything from
#  the original Parser::BOP class, except the _check
#  routine, which comes from LimitedPoint::BOP above.
#

package LimitedPoint::BOP::add;
our @ISA = qw(LimitedPoint::BOP Parser::BOP::add);

##############################################

package LimitedPoint::BOP::subtract;
our @ISA = qw(LimitedPoint::BOP Parser::BOP::subtract);

##############################################

package LimitedPoint::BOP::multiply;
our @ISA = qw(LimitedPoint::BOP Parser::BOP::multiply);

##############################################

package LimitedPoint::BOP::divide;
our @ISA = qw(LimitedPoint::BOP Parser::BOP::divide);

##############################################
##############################################
#
#  Now we do the same for the unary operators
#

package LimitedPoint::UOP;

sub _check {
  my $self = shift;
  my $super = ref($self); $super =~ s/LimitedPoint/Parser/;
  &{$super."::_check"}($self);
  return if $self->checkNumber;
  my $uop = $self->{def}{string} || $self->{uop};
  $self->Error("In this context, '$uop' can only be used with Numbers");
}

##############################################

package LimitedPoint::UOP::plus;
our @ISA = qw(LimitedPoint::UOP Parser::UOP::plus);

##############################################

package LimitedPoint::UOP::minus;
our @ISA = qw(LimitedPoint::UOP Parser::UOP::minus);

##############################################
##############################################
#
#  Absolute value does vector norm, so we
#  trap that as well.
#

package LimitedPoint::List::AbsoluteValue;
our @ISA = qw(Parser::List::AbsoluteValue);

sub _check {
  my $self = shift;
  $self->SUPER::_check;
  return if $self->{coords}[0]->type eq 'Number';
  $self->Error("Vector norm is not allowed in this context");
}

##############################################
##############################################

package main;

#
#  Now build the new context that calls the
#  above classes rather than the usual ones
#

$context{LimitedPoint} = Context("Vector");
$context{LimitedPoint}->operators->set(
   '+' => {class => 'LimitedPoint::BOP::add'},
   '-' => {class => 'LimitedPoint::BOP::subtract'},
   '*' => {class => 'LimitedPoint::BOP::multiply'},
  '* ' => {class => 'LimitedPoint::BOP::multiply'},
  ' *' => {class => 'LimitedPoint::BOP::multiply'},
   ' ' => {class => 'LimitedPoint::BOP::multiply'},
   '/' => {class => 'LimitedPoint::BOP::divide'},
  ' /' => {class => 'LimitedPoint::BOP::divide'},
  '/ ' => {class => 'LimitedPoint::BOP::divide'},
  'u+' => {class => 'LimitedPoint::UOP::plus'},
  'u-' => {class => 'LimitedPoint::UOP::minus'},
);
#
#  Remove these operators and functions
#
$context{LimitedPoint}->operators->undefine('_','U','><','.');
$context{LimitedPoint}->functions->undefine('norm','unit');
$context{LimitedPoint}->lists->set(
  AbsoluteValue => {class => 'LimitedPoint::List::AbsoluteValue'},
);
$context{LimitedPoint}->parens->set(
  '(' => {formMatrix => 0},
  '[' => {formMatrix => 0},
);
$context{LimitedPoint}->parens->remove('<');
$context{LimitedPoint}->variables->are(x=>'Real');
$context{LimitedPoint}->constants->remove('i','j','k');

Context("LimitedPoint");