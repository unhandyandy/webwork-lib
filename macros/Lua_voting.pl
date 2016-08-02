#-*-perl-*-


$LaTeXmacros = '\\newcommand{\\voteProfileABC}[6]{
\\begin{tabular}{rcccccc}
\\toprule
Votes: & #1 & #2 & #3 & #4 & #5 & #6 \\\\
\\hline
Preferences: & A & A & B & B & C & C \\\\
             & B & C & A & C & A & B \\\\
             & C & B & C & A & B & A \\\\
\\bottomrule
\\end{tabular}
}
\\newcommand{\\agendaC}[5]{
\\begin{picture}(60,60)(30,50)
 \\put(0,80){\\line(1,0){30}}
 \\put(0,60){\\line(1,0){30}}
 \\put(30,70){\\line(1,0){40}}
 \\put(40,50){\\line(1,0){30}}
 \\put(70,60){\\line(1,0){40}}
 \\put(30,80){\\line(0,-1){20}}
 \\put(70,70){\\line(0,-1){20}}
\\put(11,84){\\cand{#1}}
\\put(11,64){\\cand{#2}}
\\put(51,54){\\cand{#3}}
\\put(51,74){\\cand{#4}}
\\put(91,64){\\cand{#5}}
\\end{picture}
}';

Lua_PGMLproblem::setRandomSeed( $envir{problemSeed} );

sub VotingCalcPRC { Lua_Voting::getVotingCalcPRC(@_) }
sub VotingCalcAgenda { Lua_Voting::getVotingCalcAgenda(@_) }
sub FairnessViolations { Lua_Voting::getFairnessViolations(@_) }

sub generatePGML{
    my $probObj = shift;
    my @args = @_;
    return $probObj->{generate}->( $probObj, @args ); }
