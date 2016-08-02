
sub _PGauxiliaryFunctions_init {

}

=head1 DESCRIPTION

#
#  Get the functions that are in common with Parser.pm
#

=cut

# ^uses loadMacros
loadMacros("PGcommonFunctions.pl");

=head3

#
#  Do the additional functions such as:
#
#  step($number)
#  ceil($number)
#  floor($number)
#  max(@listNumbers)
#  min(@listNumbers)
#  round($number)
#  lcm($number1,$number2)
#  gfc($number1,$number2)
#  gcd($number1,$number2)  
#  isPrime($number)
#  reduce($numerator,$denominator)
#  preformat($scalar, "QuotedString")
#

=cut

# ^function step
sub step {     # heavyside function (1 or x>0)
	my $x = shift;
	($x > 0 ) ? 1 : 0;
}
# ^function ceil
sub ceil {
	my $x = shift;
	- floor(-$x);
}
# ^function floor
sub floor {
	my $input = shift;
	my $out = int $input;
	$out -- if ( $out <= 0 and ($out-$input) > 0 );  # does the right thing for negative numbers
	$out;
}

# ^function max
sub max {

        my $maxVal = shift;
        my @input = @_;

        foreach my $num (@input) {
                $maxVal = $num if ($maxVal < $num);
        }

        $maxVal;

}

# ^function min
sub min {

        my $minVal = shift;
        my @input = @_;

        foreach my $num (@input) {
                $minVal = $num if ($minVal > $num);
        }

        $minVal;

}

#round added 6/12/2000 by David Etlinger. Edited by AKP 3-6-03

# ^function round
# ^uses Round
sub round {
	my $input = shift;
	my $out = Round($input);
#	if( $input >= 0 ) {
#		$out = int ($input + .5);
#	}
#	else {
#		$out = ceil($input - .5);
#	}
	$out;
}

# Round contributed bt Mark Schmitt 3-6-03
# ^function Round
# ^uses Round
sub Round {
	if (@_ == 1) { $_[0] > 0 ? int $_[0] + 0.5 : int $_[0] - 0.5}
	elsif (@_ == 2) { $_[0] > 0 ? Round($_[0]*10**$_[1])/10**$_[1] :Round($_[0]*10**$_[1])/10**$_[1]}
}

#least common multiple
#VS 6/29/2000
# ^function lcm
sub lcm {
	my $a = shift;
	my $b = shift;

	#reorder such that $a is the smaller number
	if ($a > $b) {
		my $temp = $a;
		$a = $b;
		$b = $temp;
	}

	my $lcm = 0;
	my $curr = $b;;

	while($lcm == 0) {
		$lcm = $curr if ($curr % $a == 0);
		$curr += $b;
	}

	$lcm;

}


# greatest common factor
# takes in two scalar values and uses the Euclidean Algorithm to return the gcf
#VS 6/29/2000
# ^function gcf
sub gcf {
        my $a = abs(shift);	# absolute values because this will yield the same gcd,
        my $b = abs(shift);	# but allows use of the mod operation

	# reorder such that b is the smaller number
	if ($a < $b) {
		my $temp = $a;
		$a = $b;
		$b = $temp;
	}

	return $a if $b == 0;

	my $q = int($a/$b);	# quotient
	my $r = $a % $b;	# remainder

	return $b if $r == 0;

	my $tempR = $r;

	while ($r != 0) {

		#keep track of what $r was in the last loop, as this is the value
		#we will want when $r is set to 0
		$tempR = $r;

		$a = $b;
		$b = $r;
		$q = $a/$b;
		$r = $a % $b;

	}

	$tempR;
}


#greatest common factor.
#same as gcf, but both names are sufficiently common names
# ^function gcd
# ^uses gcf
sub gcd {
        return gcf($_[0], $_[1]);
}

#returns 1 for a prime number, else 0
#VS 6/30/2000
# ^function isPrime
sub isPrime {
        my $num = shift;
        return 1 if ($num == 2 or $num == 3);
        return 0 if ($num == 1 or $num == 0);
        for (my $i = 2; $i <= sqrt($num); $i++) { return 0 if ($num % $i == 0); }
        return 1;
}

#reduces a fraction, returning an array containing ($numerator, $denominator)
#VS 7/10/2000
# ^function reduce
# ^uses gcd
sub reduce {

	my $num = shift;
	my $denom = shift;
	my $gcd = gcd($num, $denom);

	$num = $num/$gcd;
	$denom = $denom/$gcd;

	# formats such that only the numerator will be negative
	if ($num/$denom < 0) {$num = -abs($num); $denom = abs($denom);}
	else {$num = abs($num); $denom = abs($denom);}

	my @frac = ($num, $denom);
	@frac;
}


# takes a number and fixed object, as in "$a x" and formats
# to account for when $a = 0, 1, -1
# Usage: preformat($scalar, "quoted string");
# Example: preformat(-1, "\pi") returns "-\pi"
# VS 8/1/2000  -  slight adaption of code from T. Shemanske of Dartmouth College
# ^function preformat
sub preformat {
	my $num = shift;
	my $obj = shift;
	my $out;


	if ($num == 0) { return 0; }
	elsif ($num == 1) { return $obj; }
	elsif ($num == -1) { return "-".$obj; }

	return $num.$obj;
}

#factorial
# ^function fact
# ^uses P
sub fact {
	P($_[0], $_[0]);
}

## sum list of numbers
sub sum{
    my $res = 0;
    while ( @_ ){
	$res += shift; }
    return $res; }

## product of list of numbers
sub product{
    my $res = 1;
    while ( @_ ){
	$res *= shift; }
    return $res; }

##flatten an array, given as ref
sub flatten {
    my $obj = shift;
    my @res;
    if ( ref( $obj ) ){
	@res =  map { @{&flatten( $_ )} } @$obj; }
    else {
	@res = ( $obj ); }
    return \@res; }

##flatten an array, given as ref
sub flattenN {
    my ( $obj, $depth ) = @_;
    my @res;
    if ( $depth == 0 || !ref( $obj ) ){
        @res =  ( $obj ); }
    else {
	@res =  map { @{&flattenN( $_, $depth - 1 )} } @$obj; }
    return \@res; }

## display object as string, array object given as ref
## object obj, tab depth
# sub dumper {
#     my $obj = shift;
#     my $tab = shift;    
#     if ( !$tab ){ $tab = 0; }
#     my @res;
#     if ( ref( $obj ) ){
# 	@res =  map { &dumper( $_, $tab + 1 )  } @$obj; 
# 	@res = ( @res, "$BR" );  }
#     else {
# 	my $space = "$SPACE"x$tab;
# 	@res = ("$space$obj, "); }
#     return "@res"; }

sub map2 {
    my $funref = shift;
    my $mat = shift;
    my $fun2 = sub {
	my $list = shift;
	my @res = map { $funref->( $_ ) } @$list; 
	return \@res; };
    my @res = map { $fun2 -> ( $_ ) } @$mat;
    return \@res; }

sub mapN {
    my $funref = shift;
    my $n = shift;
    my $mat = shift;
    my @list, $val;
    if ( $n == 0 ){
	$val = $funref->( $mat );
        return $val; }
    else {
        @list = map { mapN( $funref, $n - 1, $_) } @$mat;
        return \@list; } }

sub forEachN {
    my $funref = shift;
    my $n = shift;
    my $mat = shift;
    my @list, $val;
    if ( $n == 0 ){
	$val = $funref->( $mat ); }
    else {
        @list = map { mapN( $funref, $n - 1, $_) } @$mat; } }

sub outer {
    my ( $rows, $cols ) = @_;
    my @res = ();
    my $i, $j;
    for $i ( 0..$#$rows ){
        for $j ( 0.. $#$cols ){
            $res[$i][$j] = [ $rows->[$i], $cols->[$j] ]; } }
    return \@res; }

sub cartesianProduct {
    my ( $setA, $setB ) = @_;
    my $outer = &outer( $setA, $setB );
    return &flattenN( $outer, 2 ); }

sub removeElement{
    my ( $togo, @list ) = @_;
    return grep { $_ != $togo } @list; }

sub removeString{
    my ( $togo, @list ) = @_;
    return grep { !($_ eq $togo) } @list; }

sub removeNth{
    my ( $n, @list ) = @_;
    return @list[ 0..($n - 1), ($n + 1)..$#list ]; }

sub shallowEquals{
    my ( $la, $lb ) = @_;
    if ( $#$la != $#$lb ) {
        return (); }
    if ( $#$la == -1 ) {
        return 1; }
    my @l1 = @$la;
    my @l2 = @$lb;
    return pop(@l1) eq pop(@l2) && &shallowEquals( \@l1, \@l2 ); }

sub listHasString{
    my ( $l, $s ) = @_;
    my @test = grep { $_ eq $s } @$l;
    return scalar( @test ) > 0; }
    
sub listHas{
    my ( $l, $s ) = @_;
    return grep { $_ eq $s } @$l; }

sub roundTo {
    my ($val,$acc) = @_;
    my $pow = - round(log($acc)/log(10));
    my $mult = 10**$pow;
    return round($val*$mult)/$mult; }

sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s; }
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s; }
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s; }

sub getFactors {
    my $n = shift;
    my @factors = ();
    for my $f(2..$n) {
        if (not $n % $f) {
            push @factors, $f; } }
    return @factors; }

sub makeEq {
    my ($m,$b) = @_;
    my ($var,$con);
    my @mf = $m->value;
    my ($sgnm1,$sgnb1,$sgnm2,$sgnb2) = ("","","+","+");
    if ( $m < 0 ) {
        $mf[0] *= -1;
        $sgnm1 = $sgnm2 = "-"; }
    $var = $mf[1]==1 ? ( $mf[0]==1 ? "x" : "$mf[0] x" ) : ( $mf[0]==1 ? "\\frac{x}{$mf[1]}" : "\\frac{$mf[0]}{$mf[1]} x" );
    if ( $b eq 0 ) {
        return "y = $var"; }
    my @bf = $b->value;
    if ( $b < 0 ) {
        $bf[0] *= -1;
        $sgnb1 = $sgnb2 = "-";  }
    $con = $bf[1]==1 ? "$bf[0]" : "\\frac{$bf[0]}{$bf[1]}";
    if ( random(0,1) ) {
        return "y = $sgnm1 $var $sgnb2 $con"; }
    else {
        return "y = $sgnb1 $con $sgnm2 $var"; } }
    
   

# return 1 so that this file can be included with require
1

