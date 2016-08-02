sub _PGmusic_init {

}
loadMacros("PGcommonFunctions.pl",
           "PGnauGraphics.pl"
       );



=head1 NAME

PGmusic.pl - Describe the usage of script briefly

=head1 SYNOPSIS

PGmusic.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for PGmusic.pl, 

=head1 AUTHOR

, E<lt>dabrowsa@ajd2008.localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by 

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut


=head3

Provides:
makeCircle
necklace

=cut



sub makeCircle {
    my ($pic,$x,$y,$r,$col,$thick,$fill) = @_;
    my ($a, $b) = ($x - $r, $x + $r);
    my ($del1, $del2) = (0.0001,0.1);
    while ( $x - $a >= $r ) {
        $a += $del1; }
    while ( $b - $x >= $r ) {
        $b -= $del1; }
    my $fun = Formula("sqrt($r^2 - (x - $x)^2)");
    my $funstr = "$fun for x in [$a,$b] using color:$col and weight:$thick";
    my @circles = ("$y + " . $funstr,"$y - " . $funstr);
    add_functions($pic,@circles);
    $pic->moveTo($a, $y - $del2);
    $pic->lineTo($a, $y + $del2, $col);
    add_functions($pic, @circles);
    $pic->moveTo($b, $y - $del2);
    $pic->lineTo($b, $y + $del2, $col);
    
    if ($fill) {
        $pic->fillRegion([$x,$y,$col]); } }

sub necklace {
    my @beads = @_;
    my $size = scalar( @beads );
    my $pic = init_graph(-2,-2,2,2,'pixels'=>[300,300]);
    my $gap = 2.0*pi/$size;
    my $radius = 1.5;
    my $i;
    for $i(0..$#beads) {
        my $x = roundTo($radius*cos(pi/2 - $i*$gap),.001);
        my $y = roundTo($radius*sin(pi/2 - $i*$gap),.001);
        if ($beads[$i]) {
            makeCircle($pic,$x,$y,0.3,"black",6,1); }
        else {
            makeCircle($pic,$x,$y,0.3,"black",6,0);
        }}
    #makeCircle($pic,0,0,$radius,'yellow',6,0);
    $pic->fillRegion([0,0,"gray"]);
    return $pic; }

sub rotateList {
    my ($rot,@lst) = @_;
    return (@lst[$rot..$#lst],@lst[0..($rot - 1)]); }

sub reflectList {
    my ($rot,@lst) = @_;
    my @revlst = reverse(@lst);
    return rotateList(scalar(@lst) - $rot - 1,@revlst); }

sub listEq {
    my ($l1,$l2) = @_;
    if ( $#$l1 != $#$l2 ) {
        return 0; }
    if ( scalar(@$l1) == 0 ) {
        return 1; }
    if ( not $l1->[0] eq $l2->[0] ) {
        return 0; }
    return listEq([@$l1[1..$#$l1]],[@$l2[1..$#$l2]]); }

sub findRotSyms {
    my @lst = @_;
    my $i;
    my @syms = (); 
    for $i(0..$#lst) {
        if ( listEq(\@lst,[rotateList($i,@lst)]) ) {
            push @syms, $i; } }
    return @syms; }

sub findRflSyms {
    my @lst = @_;
    my $i;
    my @syms = (); 
    for $i(0..$#lst) {
        if ( listEq(\@lst,[reflectList($i,@lst)]) ) {
            push @syms, $i; } }
    return @syms; }
    
sub makeAllSyms {
    my ($rots,$rfls) = @_;
    my @rightrots = ();
    my @rightrfls = ();
    my @wrongrots = ();
    my @wrongrfls = ();
    for my $i(0..11) {
        if ( listHas($rots,$i) ) {
            push @rightrots, "T$i"; }
        else {
           push @wrongrots, "T$i"; } 
        if ( listHas($rfls,$i) ) {
            push @rightrfls, "I$i"; }
        else {
            push @wrongrfls, "I$i"; } }

    return (\@rightrots,\@wrongrots,\@rightrfls,\@wrongrfls); }

sub countModes {
    my @pitchset = @_;
    my @rotsyms = findRotSyms(@pitchset);
    my $len;
    if (scalar(@rotsyms) == 1) {
        $len = 11; }
    else {
        $len =  $rotsyms[1] - 1; }
   return sum(@pitchset[0..$len]); }

sub pitchesToNecklace {
    my @pitches = @_;
    my @necklace = ();
    my ($i,$b);
    for $i(0..11) {
        $b = listHas(\@pitches,$i) ? 1 : 0;
        push @necklace, $b; }
    return @necklace; }

sub necklaceToPitches {
    my @necklace = @_;
    my @pitches = grep { $necklace[$_] == 1 } (0..11);
    return @pitches; }

sub getPitchClassNames {
    return ('A','Bb','B','C','C#','D','Eb','E','F','F#','G','Ab'); }

sub getIntervalNames {
    return ('unison','minor second','major second','minor third', 'major third','fourth','tritone','fifth','minor sixth','major sixth','minor seventh','major seventh'); }

sub getPythagoreanTuning {
    return (1,Fraction(256,243),Fraction(9,8),Fraction(32,27),Fraction(81,64),
            Fraction(4,3),Fraction(729,512),Fraction(3,2),Fraction(128,81),
            Fraction(27,16),Fraction(16,9),Fraction(243,128)); }

sub getJustIntonation {
    return (1, Fraction(16,15),Fraction(9,8),Fraction(6,5),Fraction(5,4),
            Fraction(4,3),Fraction(45,32),Fraction(3,2),Fraction(8,5),
            Fraction(5,3),Fraction(9,5),Fraction(15,8)); }

sub randBeat {
    my $num = shift;
    my @factors = getFactors( $num );
    return ( listHas(\@factors,3) ) ? 3 : 1; }

sub getNotes {
    return ('whole','half','quarter','eighth','sixteenth'); }

sub arithMean {
    my @vals = @_;
    my $len = scalar @vals;
    return sum(@vals) / $len; }

sub geomMean {
    my @vals = @_;
    my $len = scalar @vals;
    return Real(product(@vals))**(1/$len); }

sub harmMean {
    my @vals = @_;
    my @invs = map { 1/$_ } @vals;
    my $len = scalar @vals;
    return 1 / arithMean(@invs); }

sub beatsBtwFreqs {
    my ($pa,$pb) = num_sort(@_);
    my $dif = $pb - $pa;
    if ( $dif < 16 ) {
        return $dif; }
    else {
        return beatsBtwFreqsAux(2*$pa,$pb,$pa,$pb); }}

sub beatsBtwFreqsAux {
    my ($p1,$p2,$f1,$f2) = @_;
    my ($pa,$pb) = ($p1 < $p2) ? ($p1 + $f1,$p2) : ($p1,$p2 + $f2);
    my $dif = abs($pa - $pb);
    if ( $dif < 16 ) {
        return $dif; }
    else {
        return beatsBtwFreqsAux($pa,$pb,$f1,$f2); }}

sub randFreqsFromBeatsAux {
    my $b = shift;
    my $harm1 = random(100,1000,10);
    my $dif = ( random(0,1) == 0 ) ? $b : -$b;
    my $harm2 = $harm1 + $dif;
    my $deg = random(2,5);
    return ( $harm1/$deg, $harm2/($deg + 1) ); }

sub randFreqsFromBeats {
    my $b = shift;
    my @res = randFreqsFromBeatsAux($b);
    if ( beatsBtwFreqs(@res) == $b ) {
        return @res; }
    else {
        return randFreqsFromBeats($b); }}

sub midiToString {
    my $m = shift;
    my @prefixes = getPitchClassNames();
    my $nameIndex = ( $m - 57 ) % 12;
    my $prefix = $prefixes[$nameIndex];
    my $oct = floor( ($m - 59.5)/12 ) + 4;
    return $prefix . $oct; }

sub midiToFreq {
    my $m = shift;
    return 220 * 2**(($m - 57)/12); }

sub intToName {
    my $i = shift;
    my @names = getIntervalNames();
    return $names[$i]; }

# return 1 so that this file can be included with require
1;

