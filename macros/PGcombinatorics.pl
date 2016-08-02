sub _PGcombinatorics_init {
}

#use POSIX;
#use Math::Trig;
#use Math::CDF;

our $pi=3.14159265358979323846;

sub number { return(  (!(defined($_[0])) or ref($_[0]) or ($_[0] == 0 && $_[0] ne "0") ) ? 0 : 1 ) ;}

#sub integer { return( (number($_[0]) && $_[0] == POSIX::floor($_[0]) ) ? 1 : 0 ); }
sub integer { return( (number($_[0]) && $_[0] == int($_[0]) ) ? 1 : 0 ); }

#sub non_negative_integer { return ( (number($_[0]) && ($_[0] >= 0) && ($_[0] == POSIX::floor($_[0]) ) ) ? 1 : 0 ) ;}
sub non_negative_integer { return ( (number($_[0]) && ($_[0] >= 0) && ($_[0] == int($_[0]) ) ) ? 1 : 0 ) ;}

#sub positive_integer { return ( (number($_[0]) && ($_[0] > 0) && ($_[0] == POSIX::floor($_[0]) ) ) ? 1 : 0 ) ;}
sub positive_integer { return ( (number($_[0]) && ($_[0] > 0) && ($_[0] == int($_[0]) ) ) ? 1 : 0 ) ;}

sub roundSig { 
my ($x, $n) = @_;
if (not(positive_integer($n))) {return(undef);}
if ($x==0) {return($x);}
my $sign = sgn($x);
my $order = int(log(abs($x)));
my $adj = $order - $n;
return( $sign * 10**$adj * round(abs($x)/10**$adj) );
}

sub roundDecDig {
my ($x, $n)= @_;
if (not(non_negative_integer($n))) {return(undef);} if ($x == 0) {return($x);}
return( sgn($x) * (round(abs($x) * 10**$n))/(10**$n));
}


sub cbrandom {
  my ($low, $high, $incr) = @_;
  if (!defined($incr)) { return ( random(0,0.99999999,-1)*($high-$low) + $low ); }
  my $value = POSIX::floor( random(0,0.99999999,-1) * ( (($high-$low)/$incr) +1 ) ) * $incr + $low;
#  my $value = int( random(0,0.99999999,-1) * ( (($high-$low)/$incr) +1 ) ) * $incr + $low;
  $value = ($value > $high) ? $high : $value;
  return($value);
}

#sub random {
#	my ($low, $high, $incr) = @_;
#   my $value = POSIX::floor( rand() * ( (($high-$low)/$incr) +1 ) ) * $incr + $low;
#	return($value);
#}

# sub random_excluding { # call with random_excluding($low_end, $high_end, $increment, @excluded_values)
# 	my ($low_end, $high_end, $increment, @excluded_values) = @_;
# 	my $value;
# 	if ($#excluded_values <0) {
# 		return(random($low_end, $high_end, $increment));}
# 	my @sorted_exclusions = PGsort sub{$_[0] <=> $_[1]}, @excluded_values;
# 	my @vetted_exclusions = ();
# 	my $i= 0;
# 	my $test;
# 	while ($i <= $#sorted_exclusions and 
# 			(($test = $sorted_exclusions[$i]) < $low_end or 
# 				$test != int(($test - $low_end)/$increment) *$increment + $low_end)) {
# 		 $i++;}
# 	if ($i > $#sorted_exclusions or $sorted_exclusions[$i] > $high_end) {
# 		$value = random($low_end, $high_end, $increment);}
# 	else {
# 		push @vetted_exclusions, $sorted_exclusions[$i];
# 		$i++;
# 		while ($i <= $#sorted_exclusions and ($test = $sorted_exclusions[$i]) <= $high_end){
# 			if ($vetted_exclusions[$#vetted_exclusions] < $test
# 				and $ test == int(($test - $low_end)/$increment) *$increment + $low_end ) {
# 					push @vetted_exclusions, $test;
# 			}
# 			$i++;
# 		}
# 		my $number_of_excluded_values = $#vetted_exclusions+1;
# 		my $index = random(0, int(($high_end - $low_end)/$increment) -$number_of_excluded_values, 1);
# 		my $vetted=0;
# 		$value=$low_end;
# 		foreach $i (0..$index) {
# 			if ($i) {$value += $increment; }
# 			while ($value == $vetted_exclusions[$vetted]) {
# 				$value += $increment;
# 				$vetted +=1;
# 			}
# 		}
# 		if ($value > $high_end) {
# 			$value = $high_end;
# 		}
# 	}
# 	return($value);
# }

sub random_excluding { # call with random_excluding($low_end, $high_end, $increment, @excluded_values)
	my ($low_end, $high_end, $increment, @excluded_values) = @_;
	my $value;
	if ($#excluded_values <0) {
		return(random($low_end, $high_end, $increment));}
	my @sorted_exclusions = PGsort( sub{$_[0] <= $_[1]}, @excluded_values);
#warn("Sorted_exclusions = @sorted_exclusions");
	my $N_excluded = $#sorted_exclusions;
	my @vetted_values = ();
	my $i= 0;
	$value = $low_end;
	while ($value <= $high_end) {
		while ($i <= $N_excluded and $sorted_exclusions[$i] < $value) {$i++}
#warn("Testing with i=$i, N_excluded = $N_excluded, value=$value, exclusion=$sorted_exclusions[$i]");
		if ($i > $N_excluded or $value < $sorted_exclusions[$i])
			{push @vetted_values, $value; 
#warn("pushing $value");
		}
		$value += $increment;
	}
	$N_vetted_values = $#vetted_values;
#warn("Vetted_values = @vetted_values");
	$value = @vetted_values[random(0,$N_vetted_values,1)];
	return($value);
}

			
sub randomperm {
  my ($n, $r) = @_;
  if (not (positive_integer($n))) {return(undef);}
  if (defined($r) and (not(non_negative_integer($r)) or ($r > $n) ) ) {return(undef);}
  if (!defined($r)) {$r=$n;}
  @PermSource = (1..$n); @RandomPerm=(1..$r);
  foreach my $i (1..$r) {
      my $j = cbrandom(0,$n-$i,1);
      $RandomPerm[$i-1] = $PermSource[$j];
      foreach my $k ($j..$n-$i-1) {$PermSource[$k] = $PermSource[$k+1];}
  }
  return(@RandomPerm);
}

# -------------------------------------------------------------------------
#    Function: partition(n,t,gran, decDigits)
# 
# Description: Returns an array of n randomly chosen elements which form a
#              partition of t (i.e. sum to t) with a granularity of gran.

sub partition {
  my($n,$t,$gran,$decDigits)= @_;
  if (!defined($decDigits)) {$decDigits=4;}	
  if( not(non_negative_integer($n)) )       { return undef; } # partition must make sense
  if ( not(non_negative_integer(roundDecDig($t/$gran,$decDigits)) )) { return undef; } # granularity must go evenly into total
  if( $n == 1 ) { return ($t); }                              # if only one, return t
  my @parts = ();                                             # start with empty array
  for my $i (0..$n-1) {                                       # create n buckets
    $parts[$i] = $gran;                                       # each with one gran in it
    $t -= $gran;                                              # which is used up from the total
  }
  while($t > 0) {                                             # while we have a total left
    my $index = int(random(0,$n-1,1));                        # buggy random sometimes returns decimals
    $parts[$index] += $gran;                                  # toss a gran in a bucket
#    $t = round( ($t-$gran)/$gran ) * $gran;                   # subtract gran from t (buggy subtraction)
	$t = roundDecDig($t - $gran, $decDigits);
  }     
  return @parts;      
}; # end sub partition
  

sub pow {
  my ($p, $r) = @_;
  return ($p ** $r);
}

sub factorial {
	my ($n) = @_;
    if ($n== 0) {return(1);}
    elsif ( positive_integer($n) ) {my $prod = 1; foreach my $i (1..$n) {$prod *= $i;} return($prod);}
	else {return(undef);}
}

sub binomial {&combination(@_);}

sub comb {&combination(@_);}

sub combination { # number of combinations of $n things taken $r at a time
  my ($n, $r)=@_ ;
  if (not (non_negative_integer($n) and non_negative_integer($r) ) ) {return(0);}
  if ($n < $r) {return(0);}
  if ($n/2 < $r) { $r = $n-$r;}
  if ($r == 0) {return(1);}
  my $c = 1;
  my $d = 0;
  for (my $i=1; $i <= $r; $i++, $n--) {$d = $c * $n; $c = $d/ $i; }
  return($c);
}

sub multinomial {
  my $k = scalar @_;
  my $n=$_[0];
  my @r=@_[1..$k-1];
  if ($k<2) {return(undef);}
  my $value=1; my $m=$n;
  for (my $i=0; $i <= $k-2; $m -= $r[$i++]) {
    if (defined(my $temp = &combination($m, $r[$i])) ) {
       $value *= $temp;
       }
    else { return(undef);}
  }
  return($value);
}

sub perm {&permutation(@_);}

sub permutation { # number of permutations of $n things taken $r at a time
  my ($n, $r)=@_ ;
  if (not (non_negative_integer($n) and non_negative_integer($r) ) ) {return(undef);}
  if ($n < $r) {return(0);}
  if ($r == 0) {return(1);}
  my $c=1;
  foreach my $i ($n-$r+1 .. $n) {$c *= $i;}
  return($c);
}


sub hnqdf { # variables in order are $r=number of objects of type A selected,
            # $p = number of objects of type A, 
            # $q = number of objects of type B, 
            # $n = number of objects selected overall (i.e., the sample size);
  my ($r, $p, $q, $n) = @_;
#  if (not( non_negative_integer($r) and non_negative_integer($p) 
#          and non_negative_integer($q) and non_negative_integer($n)
#          and ($r <= $p) and ($r <= $n) and ($n-$r <= $q) ) ) {return(undef);}
  return( &combination($p, $r) * &combination($q, $n-$r) );
}

sub hnqcdf { # variables in order are $l, $h, $p, $q, $n;
  my ($l, $h, $p, $q, $n) = @_;
#  if (not ( non_negative_integer($l) and non_negative_integer($h)
#          and non_negative_integer($p) and non_negative_integer($q) 
#          and non_negative_integer($n) and ($l <= $h) and ($h <= $n)
#          and ($h <= $p) and ($n-$l <= $q) ) ) {return(undef);}
  my $sum = 0;
  foreach my $j ($l..$h) { $sum += &hnqdf($j, $p, $q, $n); }
  return($sum);
}

sub bnqdf { # variables in order are $r, $p, $q, $n;
  my ($r, $p, $q, $n) = @_;
  if ( not( non_negative_integer($r) and non_negative_integer($p) 
          and non_negative_integer($q) and non_negative_integer($n)
          and ($r <= $n) ) ) {return(undef);}
  return( &combination($n, $r) * pow($p, $r) * pow($q, $n-$r) );
}

sub bnqcdf { # variables in order are $l, $h, $p, $q, $n;
  my ($l, $h, $p, $q, $n) = @_;
  if (not( non_negative_integer($l) and non_negative_integer($h)
          and non_negative_integer($p) and non_negative_integer($q) 
          and non_negative_integer($n) and ($l <= $h) and ($h <= $n)) )
        {return(undef);}
  my $sum = 0;
  foreach my $j ($l..$h) { $sum += &bnqdf($j, $p, $q, $n); }
  return($sum);
}


sub pnqdf { # variables in order are $r, $p, $q, $n;
  my ($r, $p, $q, $n) = @_;
  if (not( non_negative_integer($r) and non_negative_integer($p) 
          and non_negative_integer($q) and non_negative_integer($n)
          and ($r <= $p) and ($r <= $n) and ($n-$r <= $q) ) ) {return(undef);}
  return( &combination($n, $r) * &permutation($p, $r) * &permutation($q, $n-$r) );
}

sub pnqcdf { # variables in order are $l, $h, $p, $q, $n;
  my ($l, $h, $p, $q, $n) = @_;
  if (not( non_negative_integer($l) and non_negative_integer($h)
          and non_negative_integer($p) and non_negative_integer($q) 
          and non_negative_integer($n) and ($l <= $h) and ($h <= $n)
          and ($h <= $p) and ($n-$l <= $q) ) ) {return(undef);}
  my $sum = 0;
  foreach my $j ($l..$h) { $sum += &pnqdf($j, $p, $q, $n); }
  return($sum);
}

sub hpdf {
  my ($r, $p, $q, $n) = @_;
  if (not( non_negative_integer($r) and non_negative_integer($p) 
          and non_negative_integer($q) and non_negative_integer($n)
          and positive_integer($p+$q)
          and ($r <= $p) and ($r <= $n) and ($n-$r <= $q) ) ) {return(undef);}
  return ( (1.0 * hnqdf($r, $p, $q, $n)) / &combination( $p+$q, $n) );
}

sub hcdf {
  my ($l, $h, $p, $q, $n) = @_;
  if (not( non_negative_integer($l) and non_negative_integer($h)
          and non_negative_integer($p) and non_negative_integer($q) 
          and positive_integer($p+$q)
          and non_negative_integer($n) and ($l <= $h) and ($h <= $n)
          and ($h <= $p) and ($n-$l <= $q) ) ) {return(undef);}
  return ( (1.0 * hnqcdf($l, $h, $p, $q, $n) )/&combination( $p+$q, $n) );
}

# -------------------------------------------------------------------------
#    Function: bernoulli(num,suc,p)
# 
# Description: Returns probability of suc successes in num trials with
#              the probability of a success of p

sub bernoulli {
  my($num,$suc,$p) = @_;
  return bpdf($suc,$p,1-$p,$num);
} # end sub bernoulli


# -------------------------------------------------------------------------
#    Function: bernoulli_range(num,min_s,max_s,p)
# 
# Description: Returns probability of between min_s and max_s successes
#              inclusively in num trials with the probability of a 
#              success of p

sub bernoulli_range {
  my($num,$min_s,$max_s,$p) = @_;
  my($prob) = 0;
  foreach my $i ($min_s..$max_s) { $prob += &bernoulli($num,$i,$p); }
  return  $prob;
} # end sub bernoulli


sub bpdf {
  my ($r, $p, $q, $n) = @_;
#  if (not( non_negative_integer($r) and non_negative_integer($p) 
#          and positive_integer($p+$q)
#          and non_negative_integer($q) and non_negative_integer($n)
#          and ($r <= $n) ) ) {return(undef);}
  if (not( non_negative_integer($r) and positive_integer($p+$q)
          and non_negative_integer($n)
          and ($r <= $n) ) ) {return(undef);}
  return( &combination($n, $r) * pow(($p/($p+$q)), $r) * pow(($q/($p+$q)), $n-$r) );
#  return (  bnqdf($r, ($p/($p+$q)), ($q/($p+$q)), $n) );
}

sub bcdf {
  my ($l, $h, $p, $q, $n) = @_;
  if (not( non_negative_integer($l) and non_negative_integer($h)
          and non_negative_integer($p) and non_negative_integer($q) 
          and positive_integer($p+$q)
          and non_negative_integer($n) and ($l <= $h) and ($h <= $n)) )
        {return(undef);}
  my $sum = 0;
  foreach my $j ($l..$h) { $sum += &bpdf($j, $p, $q, $n); }
  return($sum);
#  return (  bnqcdf($l, $h, ($p/($p+$q)), ($q/($p+$q)), $n) );
}

sub hev {  # Computes the expected value for hypergeometric bipartite sampling
  my ($p, $q, $n) = @_;
  if (not ( non_negative_integer($p) and non_negative_integer($q)
           and non_negative_integer($n) and positive_integer($p+$q)
           and ($n <= $p+$q) ) ) { return(undef); }
  return( ($n*$p)/($p+$q) );
}

sub hvar {
  my ($p, $q, $n) = @_;
  if (not ( non_negative_integer($p) and non_negative_integer($q)
           and non_negative_integer($n) and positive_integer($p+$q)
           and ($n <= $p+$q) ) ) { return(undef); }
  my $t=$p+$q;
  return( $n * ($p/$t) * ($q/$t) * ($t-$n)/($t-1) );
}

sub hstddev {
  my ($p, $q, $n) = @_;
  if (not ( non_negative_integer($p) and non_negative_integer($q)
           and non_negative_integer($n) and positive_integer($p+$q)
           and ($n <= $p+$q) ) ) { return(undef); }
  my $t=$p+$q;
  return( sqrt($n * ($p/$t) * ($q/$t) * ($t-$n)/($t-1) ) );
}

sub bev {  # Computes the expected value for hypergeometric bipartite sampling
  my ($p, $q, $n) = @_;
  if (not ( non_negative_integer($p) and non_negative_integer($q)
           and non_negative_integer($n) and positive_integer($p+$q) ) )
         { return(undef); }
  return( ($n*$p)/($p+$q) );
}

sub bvar {
  my ($p, $q, $n) = @_;
  if (not ( non_negative_integer($p) and non_negative_integer($q)
           and non_negative_integer($n) and positive_integer($p+$q) ) )
        { return(undef); }
  my $t=$p+$q;
  return( $n * ($p/$t) * ($q/$t) );
}

sub bstddev {
  my ($p, $q, $n) = @_;
  if (not ( non_negative_integer($p) and non_negative_integer($q)
           and non_negative_integer($n) and positive_integer($p+$q) ) )
        { return(undef); }
  my $t=$p+$q;
  return( sqrt($n * ($p/$t) * ($q/$t) ) );
}

sub pdf { # the input must be a reference to a hash that is a probability density function
	my ($function) = @_;
    if (not (ref($function) eq "HASH" )) {return(undef); }
    my $sum=0;
    foreach my $key (keys %{$function}) { 
        my $value=$function->{$key};
        if (! number($value) ) { return(undef);}
        if ( ($value < 0 ) or ($value > 1 ) ) { return(undef);}
        $sum += $value;
    }
    if (abs($sum - 1) > 10**(-14)) { return(undef);}
	return(1);
}    

sub ev_pdf {
    my ($function) = @_;
    if (not (pdf($function)) ) {return(undef);}
    my $sum=0;
    foreach my $key (keys %{$function}) {
        if (! number($key) ) {return(undef);}
        $sum += $key * ($function->{$key}) ;
    }
    return($sum);
}

sub var_pdf {
    my ($function) = @_;
	my $ev = ev_pdf($function);
    if (!defined($ev ) ) {return(undef);}
    my $sum=0;
    foreach my $key (keys %{$function}) {
       $sum += $key * $key* ($function->{$key});
    }
    return ($sum - ($ev *$ev));
}

sub stddev_pdf {
    my ($function) = @_;
	my $var = var_pdf($function);
    if (!defined($var)) {return(undef);}
    return (sqrt($var));
}

sub npdf {
    my ($x, $mu, $sigma) = @_;
    if (not (number($x) and number($mu) and number($sigma) and ($sigma > 0) ) ) {return(undef);}
    return ( exp( -($x-$mu)**2 / (2* $sigma*$sigma)) / ($sigma * sqrt(2 * $pi)) ) ;
}

sub ncdf {
    my ($low, $high, $mu, $sigma) = @_;
    if (not (number($low) and number($high) and ($low <= $high) and number($mu) and number($sigma) and ($sigma > 0) ) ) {return(undef);}
    my $low_left_tail_pvalue=&Math::CDF::pnorm( ( ($low - $mu)/$sigma) );
    my $high_left_tail_pvalue=&Math::CDF::pnorm( ( ($high - $mu)/$sigma) );
    return($high_left_tail_pvalue - $low_left_tail_pvalue);
}

sub quantileNormal { # call with $x = quantileNormal($quantile, $mu, $sigma)
	my ($quantile, $mu, $sigma) = @_;
	if (not (0 <= $quantile and $quantile <= 1) ) {return(undef);}
	return( $sigma*&Math::CDF::qnorm($quantile) + $mu);
#	return( $sigma*&CDF::qnorm($quantile) + $mu);
} 

########
## Sets
## A set is a reference to a hash whose range is {0,1}
#######

sub listed_set_to_set {
	my $listing = shift;
	$listing =~ s/\{//;
    $listing =~ s/\}//;
	$listing =~ s/ //g;
	@members = split(',', $listing);
	my $set = {};
	foreach my $x (@members) {
		$set -> {$x} = 1;
	}
	return($set);
}

sub is_set {
	my $hash = shift;
	if (ref($hash) ne 'HASH') {return(0);}
	my %hash = %{$hash};
	foreach my $key (keys(%hash)) {
		if ($hash{$key} != 0 and $hash{$key} != 1) {return(0);}
	}
	return(1);
}

sub is_subset { # is $_[0] a subset of $_[1]
	my ($a, $b) = @_;
	if (! is_set($a) or ! is_set($b) ) {return(undef);}
	foreach my $key (keys(%{$a})) {
		if ($a -> {$key} == 1 && (!defined($b -> {$key}) || $b -> {$key} == 0) )
			{return(0);}
	}
	return(1);
}

sub members_of {
	my $a = shift;
	if (! is_set($a)) {return(undef);}
	my @m = ();
	foreach my $key (keys(%{$a})) {
		if ($a ->{$key} == 1) {push @m, $key;}
	}
	return(\@m);
}
	

sub set_union {
	my ($a, $b) = @_;
	if (! is_set($a) or ! is_set($b) ) {return(undef);}
	my $u = {};
	my $key;
	foreach $key (keys(%{$a})) {
		$u -> {$key} = $a -> {$key};
	}
	foreach $key (keys(%{$b})) {
		$u ->{$key} = (defined($u->{$key})) ? max($u->{$key}, $b->{$key}) : $b->{$key};
	}
	return($u);
}

sub set_intersection {
	my ($a, $b) = @_;
	if (! is_set($a) or ! is_set($b) ) {return(undef);}
	my $u = {};
	my $key;
	foreach $key (keys(%{$a})) {
		if ( defined($b ->{$key}) ) {
			$u -> {$key} = ( $a->{$key} == 1 and $b->{$key} == 1) ? 1 : 0;
		}
	}
	return($u);
}

sub set_difference {
	my ($a, $b) = @_;
	if (! is_set($a) or ! is_set($b) ) {return(undef);}
	my $u = {};
	my $key;
	foreach $key (keys(%{$a})) {
		if ( defined($b ->{$key}) ) {
			$u -> {$key} = ( $a->{$key} == 1 and $b->{$key} == 0) ? 1 : 0;
		}
		else
			{$u -> {$key} = $a -> {$key};}
	}
	return($u);
}


sub set_complement {
	my $a = shift;
	if (! is_set($a) ) {return(undef);}
	my $u = {};
	foreach my $key (keys(%{$a})) {
		$u->{$key} = 1 - $a -> {$key};
	}
	return($u);
}

sub set_relative_complement {
	my ($a, $u) = @_;
	if (! is_set($a) or ! is_set($u) ) {return(undef);}
	my $c = {};
	$c = set_difference($u, $a);
	return($c);
}
 
	





1;

__END__

=head1 NAME

PGcombinatorics.pl - This is a WeBWorK library of functions for elementary combinatorics
and probability to support WeBWorK problems in Finite Mathematics, Discrete Mathematics,
and Elementary Statistics.

=head1 SYNOPSIS

loadModules("PGcombinatorics.pl");

=head2 Typing Predicates

Boolean C<number($x)>

Boolean C<integer($x)>

Boolean C<non_negative_integer($x)>

Boolean C<positive_integer($x)>

Boolean  C<pdf(\%PDF_Function)>

=head2 Rounding

$y = C<roundSig($x, $n)>

$y = C<roundDecDig($x, $n)>

=head2 Randomness

$rn = C<cbrandom($low, $high)>

$rn = C<cbrandom($low, $high, $increment)>

@perm = C<randomperm($N)>  

@perm = C<randomperm($N, $R)>

@part = C<partition($N,$T,$G)>

=head2 Powers, Factorials, Combinations, Permutations

$z = C<pow($x, $y)>

$a = C<factorial($n)>

$a = C<binomial($n, $r)>

$a = C<combination($n, $r)>

$a = C<comb($n, $r)>

$a = C<multinomial($n, $r1, $r2, ...)>

$a = C<permutation($n, $r)>

$a = C<perm($n, $r)>

=head2 Counting Outcomes for Bipartite Sampling

=head2 When Outcomes are Sets (i.e., combinations)

$number_of_outcomes = C<hnqdf($r, $p, $q, $n)>

$cumulative_number_of_outcomes = C<hnqcdf($low, $high, $p, $q, $n)>

=head2 When Outcomes are Sequences with Repetitions Permitted (i.e., Cartesian Powers)

$number_of_outcomes = C<bnqdf($r, $p, $q, $n)>

$cumulative_number_of_outcomes = C<bnqcdf($low, $high, $p, $q, $n)>

=head2 When Outcomes are Sequences without Repetitions (i.e. permutations) 

$number_of_outcomes = C<pnqdf($r, $p, $q, $n)>

$cumulative_number_of_outcomes = C<pnqcdf($low, $high, $p, $q, $n)>

=head2 Probabilities and Statistics for Bipartite Sampling

=head2 Sampling without Replacement (Hypergeometric Random Variables)

$probability = C<hpdf($r, $p, $q, $n)>

$probability = C<hcdf($low, $high, $p, $q, $n)>

$expected_value = C<hev($p, $q, $n)>

$variance = C<hvar($p, $q, $n)>

$std_dev = C<hstddev($p, $q, $n)>

=head2 Sampling With Replacement (Binomial Random Variables)

$probability = C<bpdf($r, $p, $q, $n)>

$probability = C<bcdf($low, $high, $p, $q, $n)>

$probability = C<bernoulli($num,$suc,$p)>

$probability = C<bernoulli_range($num,$min_s,$max_s,$p)>

$expected_value = C<bev($p, $q, $n)>

$variance = C<bvar($p, $q, $n)>

$std_dev = C<bstddev($p, $q, $n)>

=head2 Statistics for Arbitrary PDF Functions

$expected_value = C<ev_pdf(\%PDF_Function)>

$var_pdf = C<var_pdf(\%PDF_Function)>

$stddev_pdf = C<stddev_pdf(\%PDF_Function)>

=head2 Normal Probability Distributions

$probability = C<npdf($x, $mu, $signma)>

$probability = C<ncdf($low, $high, $mu, $sigma)>


=head1 DESCRIPTION


=head1 FUNCTION DESCRIPTIONS


=over 4

=item 


=back


=head1 AUTHOR

=over 4

=item *

PGcombinatorics was put together by William Wheeler, wheeler@indiana.edu

Department of Mathematics
Indiana University
Bloomington, IN, 47405

=back

=head1 SEE ALSO


=cut

