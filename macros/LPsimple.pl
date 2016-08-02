

sub nonnegativityBlanks {
    if ( scalar @_ == 0 ){
	return ""; }
    else {
	my $var = shift;
	return "\\(" . $var . "\\,\\)" . ans_rule(3) . ans_rule(3) . ", $SPACE$SPACE$SPACE$SPACE" . nonnegativity(@_);
    }
}

sub nonnegativity {
    if ( scalar @_ == 0 ){
	return ""; }
    else {
	my $var = shift;
	return "\\(" . $var . "\\geq 0\\,\\)" . ", $SPACE$SPACE$SPACE$SPACE" . nonnegativity(@_);
    }
}

sub linearExpr {
    my $arref = shift;
    my ( $cx, $cy ) = @$arref;
    return Compute( "$cx x + $cy y" )->reduce->TeX;
}

sub chooseIneq {
    return ( @_[0] eq "<=" ) ? "&\\leq&" : "&\\geq&"; }

sub printConstraints {
    my $res = "\\begin{array}{rcl}";
    while ( scalar @_ > 1 ){
	$res = $res . shift . ",\\\\"; }
    $res = $res . shift . "\\end{array}";
    return $res;
}


sub stripList {
    my $arg = shift;
    my $list = shift @$arg;
    my @res = ();
    while ( scalar @$list > 0 ) {
	my $brack = shift @$list;
	push @res, @$brack[0]; }
    #die "res: @res";
    return @res;
}

sub stripMat {
    my $arg = shift;
    my $list = shift @$arg;
    return @$list;
}

## enter two 2-vectors and sign
## return linear expression in x and y, with
## coefficient of x matching given sign,
## and constant.
sub makeLine {
    my ( $p1, $p2 ) = @_;
    my ( $x1, $y1 ) = @$p1;
    my ( $x2, $y2 ) = @$p2;
    my $sign = $_[2] || 1;
    my ( $c, $frm );
    if ( $x1 == $x2 ){
	$frm = Formula( "x" );
	$c = $x1; }
    else {
	my $a = $y2 - $y1;
	my $b = -($x2 - $x1);
	if ( $a * $sign < 0 ){
	    $a = -$a;
	    $b = -$b; }
	$c = $a * $x1 + $b * $y1;
	$frm = Formula( "$a * x + $b * y" ); }
    return ( $frm, $c );
}

sub makeIneq {
    my ( $p1, $p2, $fp ) = @_;
    my ( $frm, $c ) = makeLine( $p1, $p2 );
    my ( $x0, $y0 ) = @$fp;
    my $val = $frm->eval( x=>$x0, y=>$y0 );
    my $ineq = ( $val <= $c ) ? "&\\leq&" : "&\\geq&";
    return $frm->reduce->TeX . $ineq . $c;
}

sub systemFromPts {
    my $fp = pop;
    my @pts = @_;
    my @n = scalar @pts;
    unshift @pts, $pts[-1];
    my @latex = ();
    while ( scalar @pts > 1 ){
	push @latex, makeIneq( $pts[0], $pts[1], $fp );
	shift @pts; }
    return @latex;
}


1;
