
## arguments: R name,       C name,
##            R strategies, C strategies (refs)
##            ref to payoff matrix (assumed to be 3D tendor)
sub gameMatrix {
    my $rowname = shift;
    my $colname = shift;
    my $rowstratref = shift;
    my $colstratref = shift;
    my @rowstrat = @$rowstratref;
    my @colstrat = @$colstratref;
    my $payoffref = shift;
    my @payoff = @$payoffref;

    my $numrows = scalar @rowstrat;
    my $numcols = scalar @colstrat;
    my $midrow = ( $numrows + 1 ) / 2;
    my $bump = ( $midrow != int( $midrow ) ) ? 1 : 0;
    $midrow = int( $midrow );
    my $cstring = "c"x$numcols;
    my $colstratheaders = "&&" . shift( @colstrat );
    for my $i ( 2..$numcols ){
	$colstratheaders .= "&" . shift( @colstrat ); }
    my $bulk = "";
    for my $i ( 1..$numrows ) {
	#my $name = ( $i == $midrow ) ? "\\raisebox{-1.0ex}{$rowname}" : "";
	my $name = ( $i == $midrow ) ? "{\\bf $rowname}" : "";
	$bulk .= $name . "&" . shift( @rowstrat ) . &payoffRow( shift( @payoff ) ) . " \\\\"; }

    return "\\begin{tabular}{ll|$cstring}
&&  \\multicolumn{$numcols}{c}{\\bf $colname} \\\\  
$colstratheaders \\\\ \\hline
$bulk
\\end{tabular}";
}

# sub gameMatrix {
#     my $rowname = shift;
#     my $colname = shift;
#     my $rowstratref = shift;
#     my $colstratref = shift;
#     my @rowstrat = @$rowstratref;
#     my @colstrat = @$colstratref;
#     my $payoffref = shift;
#     my @payoff = @$payoffref;
#     my $questQ = shift;

#     my $numrows = scalar @rowstrat;
#     my $numcols = scalar @colstrat;
#     my $midrow = ( $numrows + 1 ) / 2;
#     my $bump = ( $midrow != int( $midrow ) ) ? 1 : 0;
#     $midrow = int( $midrow );
#     my $cstring = "c"x$numcols;
#     my $colstratheaders = "&&" . shift( @colstrat );
#     my $colnamerow = "";
    
#     for my $i ( 2..$numcols ){
# 	$colstratheaders .= "&" . shift( @colstrat ); }
#     my $bulk = "";
#     for my $i ( 1..$numrows ) {
# 	#my $name = ( $i == $midrow ) ? "\\raisebox{-1.0ex}{$rowname}" : "";
# 	my $name = ( $i == $midrow ) ? "{\\bf $rowname}" : "";
# 	$bulk .= $name . "&" . shift( @rowstrat ) . &payoffRow( shift( @payoff ) ) . " \\\\"; }

#     return LayoutTable(
# &&  \\multicolumn{$numcols}{c}{\\bf $colname} \\\\  
# $colstratheaders
# $bulk
# align => 'll|$cstring' )
# }


sub pairString {
    my $ref = shift;
    my ( $a, $b ) = @$ref;
    return "\\($a,$b\\)";
}

# sub pairQuestion {
#     return "ans_rule(1), ans_rule(1)"; }

sub payoffRow {
    my $ref = shift;
    my @row = @$ref;
#    my $questQ = shift;
#    my $fun = $questQ ? \&pairQuestion : \&pairString;
    my $res = "";
    for my $s ( @row ){
	$res .= "&" . &pairString( $s ); }
    return $res;
}

sub symmetrifyPayoffs {
    my $arref = shift;
    my $nr = scalar(@$arref) - 1;
    my $nc = scalar(@{$arref->[0]}) - 1;
    my @res = ();
    for $i(0..$nr) {
        my @line = ();
        for $j(0..$nc) {
            push @line, [$arref->[$i]->[$j],$arref->[$j]->[$i]]; }
        push @res, \@line; }
    return \@res; }

sub gameMatrixSymm {
    my $rowname = shift;
    my $colname = shift;
    my $rowstratref = shift;
    my $colstratref = shift;
    my $payoffref = shift;
    my $newpayoff = symmetrifyPayoffs($payoffref);
    return gameMatrix( $rowname, $colname,
		       $rowstratref, $colstratref,
		       $newpayoff ); }

sub double {
    my $e = shift;
    my @res = ( $e, $e );
    return \@res; }

sub doubleRow {
    my $rowref = shift;
    my @row = @$rowref;
    my @res = map { &double( $_ ) } @row ;
    return \@res; }

## oldlist must be sorted!
sub listComplement {
    my $max = shift;
    my @oldlist = @_;
    if ( $#oldlist == -1 ) {
        return [ 0..$max ]; }
    my $i = 0;
    my @res = ();
    my $e = shift @oldlist;
    while ( $i <= $max ){
	if ( $i == $e ){
	    if ( $#oldlist > -1 ){
		$e = shift @oldlist; }}
	else {
	    push @res, $i; }
	$i += 1; }
    return \@res; }

## $sought, @list; returns ref
sub getIndicesFor {
    my $sought = shift;
    my @list = @_;
    my @indices = grep { $list[$_] eq $sought } 0..$#list;
    return \@indices; }

sub welfarerow {
    my $rowref = shift;
    my @res = map { sum( @$_ ) } @$rowref;
    return \@res; }

sub welfaremat {
    my $payoffref = shift;
    my @res = map { &welfarerow( $_ ) } @$payoffref;
    return \@res; }

sub getColI {
    my ( $mat, $i ) = @_;
    my @res = map { $_->[$i] } @$mat;
    return \@res; }

sub getRowI {
    my ( $mat, $i ) = @_;
    return $mat->[$i]; }

## check for complete subsets Si of form mk + i
## $list ref, $m, $len = max of elements + 1
sub checkCohortsM {
    my ( $list, $m, $len ) = @_;
    my @res = ();
    my ( $i, $j, $b );
    for $i ( 0..($m - 1) ){
        $b = 1;
        $j = $i;
        while ( $b && $j < $len ) {
            my $inds = &getIndicesFor( $j, @$list );
            if ( $#$inds == -1 ){ $b = 0; }
            $j += $m; }
        if ( $b ){ push( @res, $i ); } }
    return \@res; }

sub doubleNeg {
    my $x = shift;
    return [ $x, -$x ]; }

sub gameMatrixZeroSum {
    my $rowname = shift;
    my $colname = shift;
    my $rowstratref = shift;
    my $colstratref = shift;
    my $payoffref = shift;
    my $newpayoff = &map2( \&doubleNeg, $payoffref ); 
    return gameMatrix( $rowname, $colname,
		       $rowstratref, $colstratref,
		       $newpayoff ); }


## convert row and col numbers to linear index
## $c = number columns
sub indsToInd {
    my ( $i, $j, $c ) = @_;
    return $i * $c + $j;
}

## check whether $i,$j is pareto optimal for $mat
sub paretoCheck {
    my ( $i, $j, $mat, $reflist ) = @_;
    my ( $testR, $testC ) = @{ $mat->[$i][$j] };
    my $res = 1;
    my $k = 0;
    while ( $res && $k <= $#$reflist ){
        my $curref = $reflist->[$k];
        my ( $curi, $curj ) = @$curref;
        my $curvals = $mat->[ $curi ][ $curj ];
        my ( $curR, $curC ) = @$curvals;
        if ( ( $curR > $testR || $curC > $testC) &&
             ( $curR >= $testR && $curC >= $testC ) ){
            $res = 0; }
        else { $k += 1; } }
    return $res; }

## find r,c pairs of Pareto optimal strategies
sub pareto {
    my $mat = shift;
    my $r = $#$mat;
    my $c = $#{$mat->[0]};
    my $refs = &outer( [ 0..$r ], [ 0..$c ] );
    my $reflist = &flattenN( $refs, 2 );
    my @res = grep { &paretoCheck( $_->[0], $_->[1], $mat, $reflist ) } @$reflist;
    return \@res; }

sub nashCheck {
    my ( $i, $j, $mat, $r, $c ) = @_;
    my ( $testR, $testC ) = @{ $mat->[$i][$j] };
    my $res = 1;
    my $k = 0;
    while ( $res && $k <= $r ){
        my $curR = $mat->[ $k ][ $j ][0];
        if ( $curR > $testR ){
            $res = 0; }
        else {
            $k += 1; } }
    $k = 0;
    while ( $res && $k <= $c ){
        my $curC = $mat->[ $i ][ $k ][1];
        if ( $curC > $testC ){
            $res = 0; }
        else {
            $k += 1; } }
    return $res; }

sub nash {
    my $mat = shift;
    my $r = $#$mat;
    my $c = $#{$mat->[0]};
    my $refs = &outer( [ 0..$r ], [ 0..$c ] );
    my $reflist = &flattenN( $refs, 2 );
    my @res = grep { &nashCheck( $_->[0], $_->[1], $mat, $r, $c ) } @$reflist;
    return \@res; }

sub randomPayoff {
    my ( $r, $c, $a, $b, $del ) = @_;
    if ( !$del ) { $del = 1; }
    my @res;
    for ( 1..$r ) {
        my @row = ();
        for ( 1..$c ) {
            push( @row, [ random( $a, $b, $del ), random( $a, $b, $del ) ] ); }
        push( @res, \@row ); }
    return \@res; }
    

sub subMat {
    my ( $pomat, $player ) = @_;
    my $fun = sub {
        my $pair = shift;
        return $pair->[$player]; };
    my $mat = &mapN( $fun, 2, $pomat );
    return $mat; }

sub mixedStrat {
    my ( $pomat, $player ) = @_;
    my $mat = &subMat( $pomat, $player );
    my ( $a00, $a01, $a10, $a11 ) = @{&flatten( $mat )};
    return Formula("p q $a00 + p (1 - q) $a01 + (1 - p) q $a10 + (1 - p) (1 - q) $a11");
}


# return 1 so that this file can be included with require
1;
