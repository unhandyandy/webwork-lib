# PGgraphtheory.pl

loadMacros("PGnauGraphics.pl",      
          );      


##################################################### Nandor

######################################
#Name: GRmatrix_graph
#Input: 
#Output: 
######################################
sub GRmatrix_graph {
my $graph = pop @_;
$graph =~ s/\A\s*//;
$graph =~ s/;\s*\Z//;
my @m=split /\s*[;]\s*/ , $graph;
my $size=scalar @m;
my @matrix=();
my ($i, $j, @r);
for ($i=0; $i<$size ; $i++) {
  @r=split /\s+/, $m[$i];
  for ($j=0; $j<$size;$j++) {
    $matrix[$i][$j]=$r[$j];
  }
}
@matrix;
}


######################################
#Name: GRgraph_matrix
#Input: 
#Output: 
######################################
sub GRgraph_matrix {
my @matrix = @_;
my $size = scalar @matrix; 
my $graph='';
my ($i,$j);
for ($i=0;$i<$size;$i++) {
  for ($j=0;$j<$size;$j++) {
    $graph .= " $matrix[$i][$j]";
  }
  $graph .= ";";
}
$graph;
}


######################################
#Name: GRshuffledgraph_graph
#Input: 
#Output: 
######################################
sub GRshuffledgraph_graph {
my $graph = pop @_;
my @matrix = &GRmatrix_graph($graph);
my ($i,$j,$size,@shmatrix);
$size=scalar @matrix;
@perm =  shuffle($size);
# @invperm inverted_shuffle(@perm);
for ($i=0;$i<$size;$i++) {
  for ($j=0;$j<$size;$j++) {
    $shmatrix[$perm[$i]][$perm[$j] ] = $matrix[$i][$j];
  }
}
$graph = &GRgraph_matrix(@shmatrix);
}


######################################
#Name: GRgraph_size_random
#Input: 
#Output: 
######################################
sub GRgraph_size_random {
my ($size,$prob)=@_;
my ($i,$j,$ra,@matrix);
for ($i=0;$i<$size;$i++) {
  $matrix[$i][$i]=0;
  for ($j=0;$j<$i;$j++) {
    $ra=random(0,1,.05);
    if ($ra <= $prob) {
      $matrix[$i][$j]=1;
      $matrix[$j][$i]=1;
    }
    else {
      $matrix[$i][$j]=0;    
      $matrix[$j][$i]=0;    
    }
  }
}
&GRgraph_matrix(@matrix);
}


######################################
#Name: GRgraph_size_random_weight_dweight
#Input: 
#Output: 
######################################
sub GRgraph_size_random_weight_dweight {
my ($size,$prob,$weight,$dweight)=@_;
my ($i,$j,$ra,@matrix);
for ($i=0;$i<$size;$i++) {
  $matrix[$i][$i]=0;
  for ($j=0;$j<$i;$j++) {
    $ra=random(0,1,.05);
    if ($ra <= $prob) {
      $matrix[$i][$j]=$weight;
      $matrix[$j][$i]=$weight;
      $weight += $dweight;
    }
    else {
      $matrix[$i][$j]=0;    
      $matrix[$j][$i]=0;    
    }
  }
}
&GRgraph_matrix(@matrix);
}


######################################
#Name: GRlabel_vertex_labels
#Input: 
#Output: 
######################################
sub GRlabel_vertex_labels {
my ($vertex,$labels) = @_;
substr $labels,$vertex,1;
}


######################################
#Name: GRlabels_vertices_labels
#Input: 
#Output: 
######################################
sub GRlabels_vertices_labels {
my $labels = pop @_;
my @vertices = @_;
my $result = '';
my $a;
foreach $a (@vertices) {
  $result .= GRlabel_vertex_labels($a,$labels).' ';
}
$result;
}


######################################
#Name: GRvertex_label_labels
#Input: 
#Output: 
######################################
sub GRvertex_label_labels {
my ($label,$labels) = @_;
index $labels, $label;
}


######################################
#Name: GRvertices_labels_size
#Input: 
#Output: 
######################################
sub GRvertices_labels_size {
my ($labels,$size) = @_;
my ($i, $result);
$result="";
for ($i=0;$i<$size ;$i++) {
  $result .= (substr $labels,$i,1) . ", ";
}
if (length $result >2) {
  chop $result;
  chop $result;
}
"{".$result."}";
}


######################################
#Name: GRedges_graph
#Input: 
#Output: 
######################################
sub GRedges_graph {
my ($graph) = @_;
my @matrix=&GRmatrix_graph($graph);
my $size = scalar( @matrix );
my ( $i, $j );
my $edges = 0;
for $i ( 0..($size - 1) ) {
    for $j ( $i..($size - 1) ) {
        if ( $matrix[$i][$j] != 0) {
            $edges += 1; } } }
$edges; }


######################################
#Name: GRedgesstr_graph_labels
#Input: 
#Output: 
######################################
sub GRedgesstr_graph_labels {
my $labels = pop @_;
my $graph = pop @_;
my @matrix=&GRmatrix_graph($graph);
my ($i,$j,$size,$result,$li,$lj);
$result="";
$size=scalar @matrix;
for($i=0;$i<$size;$i++) {
 for($j=$i+1;$j<$size;$j++) {
   if ($matrix[$i][$j]==1) {
     $li=substr $labels, $i,1;
     $lj=substr $labels, $j,1;
     $result .= "{$li,$lj}, ";
   }
 }
}
if (length $result >2) {
  chop $result;
  chop $result;
}
"{".$result."}";
}


######################################
#Name: GRdegree_graph_vertex
#Input: 
#Output: 
######################################
sub GRdegree_graph_vertex {
my $vert = pop @_;
my $graph = pop @_;
my @matrix=GRmatrix_graph($graph);
my ($i,$j,$size,$result);
$result=0;
$size=scalar @matrix;
 for($j=0;$j<$size;$j++) {
   if ($matrix[$vert][$j]==1) {
     $result++;
   }
 }
$result;
}


######################################
#Name: GRdegrees_graph
#Input: 
#Output: 
######################################
sub GRdegrees_graph {
my $graph = pop @_;
my @matrix=&GRmatrix_graph($graph);
my ($i,$j,$size,@result);
$size=scalar @matrix;
 for($i=0;$i<$size;$i++) {
    push @result, &GRdegree_graph_vertex($graph,$i);
 }
@result;
}


######################################
#Name: GRncomponents_graph
#Input: 
#Output: 
######################################
sub GRncomponents_graph {
my $graph = pop @_;
my @matrix = &GRmatrix_graph($graph);
my $size = scalar @matrix;
my ($i,$j,$k,$result,$con);
$result=$size;
for ($i=0;$i<$size;$i++) {
  $con=0;
  for ($j=$i+1;$j<$size;$j++) {
     if ($matrix[$i][$j] != 0) {
       $con++;
       for ($k=0;$k<$size;$k++) {
         $matrix[$j][$k] += $matrix[$i][$k];
	 $matrix[$k][$j] += $matrix[$k][$i];
       }
     }
  }
  if ($con>0) {
    $result--;
  }
}
$result;
}


######################################
#Name: GRpic_graph_labels
#Input: 
#Output: without weights
######################################
sub GRpic_graph_labels {
my $labels = pop @_;
my $graph = pop @_;
my @matrix=&GRmatrix_graph($graph);
my ($i,$j,$k,$lab);
my $pic = init_graph(-1.5,-1.5,1.5,1.5,'pixels'=>[300,300]);
my $size=scalar @matrix;
my $gap=2.0*3.14/$size;
for ($i=0;$i<$size;$i++) {
  $pic->stamps(closed_circle(cos($i*$gap),sin($i*$gap),"blue"));
  $lab=new Label(1.25*cos($i*$gap),1.25*sin($i*$gap),
           &GRlabel_vertex_labels($i,$labels),'blue','center','center');
  $pic->lb($lab);
}
for ($i=0;$i<$size;$i++) {
  for ($j=$i+1;$j<$size;$j++) {
     if ($matrix[$i][$j]!=0) {
       $pic->moveTo(cos($i*$gap),sin($i*$gap));
       $pic->lineTo(cos($j*$gap),sin($j*$gap),1);        
     }
  }
}
$pic;
}


######################################
#Name: GRlabelpic_graph(_labels)
#Input: 
#Output: with weights
######################################
sub GRlabelpic_graph {
my $labels = pop @_;
my $graph = pop @_;
my @matrix=&GRmatrix_graph($graph);
my ($i,$j,$k,$lab);
my $pic = init_graph(-1.5,-1.5,1.5,1.5,'pixels'=>[400,400]);
my $size=scalar @matrix;
my $gap=2.0*3.14/$size;
for ($i=0;$i<$size;$i++) {
  $pic->stamps(closed_circle(cos($i*$gap),sin($i*$gap),"blue"));
  $lab=new Label(1.2*cos($i*$gap),1.2*sin($i*$gap),
           &GRlabel_vertex_labels($i,$labels),'blue','center','center');
  $pic->lb($lab);
}
for ($i=0;$i<$size;$i++) {
  for ($j=$i+1;$j<$size;$j++) {
     if ($matrix[$i][$j]!=0) {
       $pic->moveTo(cos($i*$gap),sin($i*$gap));
       $pic->lineTo(cos($j*$gap),sin($j*$gap),9);
       if ( $matrix[$i][$j] != 1  ) {
           $lab=new Label(.25*cos($i*$gap)+.75*cos($j*$gap),
                          .25*sin($i*$gap)+.75*sin($j*$gap),
                          $matrix[$i][$j],'red','center','center');
           $pic->lb($lab); 
       }     }  } }
$pic;
}


######################################
#Name: GRnearestnbr_graph_vertex
#Input: 
#Output: 
######################################
sub GRnearestnbr_graph_vertex {
my $origvert = pop @_;
my $graph = pop @_;
my @matrix = &GRmatrix_graph($graph);
my ($i,$j,$size,@path,$weight,@used,$min,$vert,$newvert);
$used[$origvert]=1;
@path=($origvert);
$weight=0;
$size=scalar @matrix;
$vert=$origvert;
while ($size>scalar @path) {
  $min=0;
  for ($i=0;$i<$size;$i++) {
    my $a = $matrix[$vert][$i];
    if ($i == $vert || defined $used[$i] || $a==0) {
      next;
    }
    if ($min == 0 || $a < $min) {
      $min = $a;
      $newvert = $i;	
    }
  }
  push @path, $newvert;
  $used[$newvert]=1;
  $weight += $matrix[$vert][$newvert];
  $vert = $newvert;
}
push @path, $origvert;
$weight += $matrix[$vert][$origvert];
push @path, $weight;
@path;
}


######################################
#Name: GRkruskal_graph
#Input: 
#Output: 
######################################
sub GRkruskal_graph {
my $graph2 = pop @_;
my $graph=$graph2;
my @matrix = &GRmatrix_graph($graph);
my $size = scalar @matrix;
my $ncomp = &GRncomponents_graph($graph);
my $tree = &GRgraph_size_random($size,-1);
my $ntreecomp = &GRncomponents_graph($tree);
my @treematrix = &GRmatrix_graph($tree);
my ($i,$j,@path,$weight,$treeweight);
$weight=0;
my @weights=();
my @treeweights=();
for ($i=0;$i<$size;$i++) {
  for ($j=$i+1;$j<$size;$j++) {
    if ($matrix[$i][$j] != 0) {
      push @weights, $matrix[$i][$j];
    }
  }
}
@weights = num_sort(@weights);
while (0 < scalar @weights) {
  $weight = shift @weights;
  for ($i=0;$i<$size;$i++) {
    for ($j=$i+1;$j<$size;$j++) {
      if ($matrix[$i][$j] == $weight) {
         $matrix[$i][$j] = 0;
         $matrix[$j][$i] = 0;
         $treematrix[$i][$j] = $weight;
         $treematrix[$j][$i] = $weight;
	 $tree = &GRgraph_matrix(@treematrix);
	 my $nntreecomp = &GRncomponents_graph($tree);
	 if ($nntreecomp < $ntreecomp) {
	    $ntreecomp=$nntreecomp;
	    $treeweight += $weight; 
	    push @treeweights, $weight;
	 }
	 else {
           $treematrix[$i][$j] = 0;
           $treematrix[$j][$i] = 0;	 
	   $tree = &GRgraph_matrix(@treematrix);
	 }
         last;
      }
    } 
  }
}

unshift @treeweights, ($tree,$treeweight);
@treeweights;
}


######################################
#Name: GRtex_braces
#Input: 
#Output: 
######################################
sub GRtex_braces {
  my $a = shift;
  $a =~ s/{/ $LB /g;
  $a =~ s/}/ $RB /g;
  $a;
}


######################################
#Name: GRvertexlist_edgesstr_labels
#Input: 
#Output: 
######################################
sub GRvertexlist_edgesstr_labels {
  my ($edgesstr,$labels) = @_;
  $edgesstr = uc $edgesstr;
  $edgesstr =~ s /[^$labels]//g;
  split '', $edgesstr;
}


######################################
#Name: GRgraph_size_labels_edgesstr
#Input: 
#Output: 
######################################
sub GRgraph_size_labels_edgesstr {
my ($size, $labels, $edgesstr) = @_;
my ($i,$j,$graphm);
# create a graph with no edges
for ($i=0;$i<$size;$i++) {    
  for ($j=0;$j<$size;$j++) {
    $graphm[$i][$j] = 0;
  }
}
#clean up the edges string
my @pairs = GRvertexlist_edgesstr_labels($edgesstr,$labels);
my $nedges = (scalar @pairs)/2;
# erase a vertex if not even
if ( $nedges != int($nedges) ) {
  pop @pairs;
  $nedges = (scalar @pairs)/2;
}
# add th edges to the empty graph
while (scalar @pairs) {
  $i=shift @pairs;
  $j=shift @pairs;
  $i=GRvertex_label_labels($i,$labels);
  $j=GRvertex_label_labels($j,$labels);
  $graphm[$i][$j]=1;
  $graphm[$j][$i]=1;
}
$graphin= GRgraph_matrix(@graphm);
}

####################################################################### Edgar Fisher


######################################
#Name: VertDegree
#Input: Vertex number followed by adjacency matrix for a graph
#Output: Degree of the indicated vertex
######################################
sub VertDegree{
  my ($vert, @matrix) = @_;
  my ($i, $size, $degree);

  $size = scalar @matrix;
  $degree = 0;

  for ($i = 0; $i < $size; $i++){
    if ($matrix[$vert][$i] != 0){
      $degree++;
    }
  }

  $degree;
};


######################################
#Name: GRgraph_degrees
#Input: List of degree values
#Output: A graph with the indicated degree values if possible or 'DNE' if not.
######################################
sub GRgraph_degrees{
  my (@input) = @_;
  my ($i, $j, @adj, $ind, $val, $size, $graph, @degrees);
  
  @degrees = reverse num_sort(@input);
  
  $size = scalar @degrees;
  
  if ($degrees[0] >= $size){
    $graph = 'DNE';
  } else {
    @adj = GRmatrix_graph(GRgraph_size_random($size, -1));
    $val = 0;
    $loc = 0;
    
    while ($loc < $size && $val == 0){
      $val = $degrees[$loc] - VertDegree($loc, @adj);
      $ind = $loc + 1;
      while ($val > 0 && $ind < $size){
        if (VertDegree($ind, @adj) < $degrees[$ind]){
	  $adj[$loc][$ind] = 1;
	  $adj[$ind][$loc] = 1;
	  $ind++;
	  $val--;
	} else {
	  $ind++;
	}
      }
      $loc++;
    }

    if ($val != 0){
      $graph = 'DNE';
    } else {
      $graph = GRgraph_matrix(@adj);
    }
  }
  $graph;
};


######################################
#Name: ChangeWeight
#Input: Vertex numbers to change, weight to change the edge to and graph
#Output: A graph with the edge between the indicated vertices changed to weight
######################################
sub ChangeWeight{
  my ($i, $j, $weight, $graph) = @_;
  my (@matrix);
  
  @matrix = GRmatrix_graph($graph);
  $matrix[$i][$j] = $weight;
  $matrix[$j][$i] = $weight;
  
  $graph = GRgraph_matrix(@matrix);
};


######################################
#Name: GRhaseulercircuit_graph
#Input: Graph
#Output: A list containing a value and message.  The value is 0 if it is not 
#an Euler circuit and 1 otherwise.  The message relays why it is not.
######################################
sub GRhaseulercircuit_graph{
  my ($graph) = @_;
  my ($val, $comp, @answer, @degrees, $message, $isCircuit);

  $isCircuit = 1;
  $message = "Good";
  $comp = GRncomponents_graph($graph);

  if ($comp != 1){
    $isCircuit = 0;
    $message = "Not connected";
  }

  @degrees = GRdegrees_graph($graph);

  foreach $val (@degrees){
    if ($val%2 != 0){
      $isCircuit = 0;
      $message = "Incorrect degrees";
    }
  }

  @answer = ($isCircuit, $message);
};


######################################
#Name: GRhaseulertrail_graph
#Input: Graph
#Output: A list containing a value and message.  The value is 0 if it is not 
#an Euler path and 1 otherwise.  The message relays why it is not.
######################################
sub GRhaseulertrail_graph{
  my ($graph) = @_;
  my ($val, $odd, $comp, $even, $total, @answer, @degrees, $message, $isCircuit);

  $isCircuit = 1;
  $message = "Good";
  $comp = GRncomponents_graph($graph);

  if ($comp != 1){
    $isCircuit = 0;
    $message = "Not connected";
  }
  
  @degrees = GRdegrees_graph($graph);
  
  $odd = 0;
  $even = 0;
  $total = scalar @degrees;
  
  foreach $val (@degrees){
    if ($val % 2 == 0){
      $even++;
    } else {
      $odd++;
    }
  }

  if ($even != $total && $odd != 2){
    $isCircuit = 0;
    $message = "Incorrect degrees";
  } 
  
  @answer = ($isCircuit, $message);
};


######################################
#Name: GReulercircuit_size
#Input: Size of graph
#Output: A graph that is an Euler Circuit
######################################

sub GReulercircuit_size{
  my ($size) = @_;

  my ($i, @deg, $pic, $comp, $diff, $graph, @lowdeg);

  if ($size <= 4){
    die "Incorrect Size";
  }
  
  do {
    @deg = ();
    for ($i = 0; $i < $size; $i++){
      push @deg, random(2,$size - 1,2);
    }
    $graph = GRgraph_degrees(@deg);
    $comp = GRncomponents_graph($graph);
  } while ($graph eq 'DNE' || $comp > 1);

  $graph = GRshuffledgraph_graph($graph);
  
};

######################################
#Name: GReulertrail_size
#Input: Size of graph
#Output: A graph that is an Euler Path but not an Euler Circuit
######################################

sub GReulertrail_size{
  my ($size) = @_;

  my ($i, @deg, $pic, $comp, $diff, $temp, $graph, @index, @lowdeg);

=pod
  for ($i = 0; $i < $size; $i++){
    push @lowdeg, 2;
  }

  $comp = 2;
  while ($graph eq 'DNE' || $comp > 1){
    @deg = ();
    for ($i = 0; $i < $size; $i++){
      push @deg, random($lowdeg[$i],$size - 1,2);
    }
    $graph = GRgraph_degrees(@deg);
    $comp = GRncomponents_graph($graph);
    
    do {
      $diff = random (0, $size - 1, 1);
    } until ($lowdeg[$diff] < $size - 2);
    $lowdeg[$diff] += 2;
  }
=cut

  if ($size <= 4) {
    die "Incorrect size";
  }
  do {
    @deg = ();
    for ($i = 0; $i < $size; $i++){
      push @deg, random(2,$size - 1,2);
    }
    $graph = GRgraph_degrees(@deg);
    $comp = GRncomponents_graph($graph);
  } while ($graph eq 'DNE' || $comp > 1);

  do {
    @index = NchooseK($size,2);
    $temp = ChangeWeight(@index, 0, $graph);
  } while ($temp eq $graph);

  $graph = GRshuffledgraph_graph($temp);
};



######################################
#Name: GRnoneuler_size
#Input: Size of graph
#Output: A graph that is not an Euler path
######################################

sub GRnoneuler_size{
  my ($size) = @_;

  my ($i, @ans, @deg, $pic, $diff, $graph, @lowdeg);
  
  for ($i = 0; $i < $size; $i++){
    push @lowdeg, 2;
  }

  @ans = (1,'');

=pod
  while ($graph eq 'DNE' || $ans == 1){
    @deg = ();
    for ($i = 0; $i < $size; $i++){
      push @deg, random($lowdeg[$i],$size - 1,1);
    }
    $graph = GRgraph_degrees(@deg);
    if ($graph ne 'DNE'){
      @ans = GRiseulertrail_graph($graph);
    }
    
    do {
    $diff = random (0, $size - 1, 1);
    } until ($lowdeg[$diff] < $size - 1);
    $lowdeg[$diff]++;
  }
=cut

  do {
    @deg = ();
    @ans = (1,'');
    for ($i = 0; $i < $size; $i++){
      push @deg, random(2,$size - 1,1);
    }
    $graph = GRgraph_degrees(@deg);
    if ($graph ne 'DNE'){
      @ans = GRhaseulertrail_graph($graph);
    }
  } while ($graph eq 'DNE' || $ans[0] == 1);

  $graph = GRshuffledgraph_graph($graph);
};


######################################
#Name: Matr_graph_Mult
#Input: 
#Output: 
######################################
sub Matr_graph_Mult {
  my($graph1, $graph2) = @_;
  
  my ($i, $j, $k, @M1, @M2, $sum, $Gnew, @Mnew, $size);
  
  @M1 = GRmatrix_graph($graph1);
  @M2 = GRmatrix_graph($graph2);
  $size = scalar @M1;

  for ($i = 0; $i < $size; $i++){
    for ($j = 0; $j < $size; $j++){
      $sum = 0;
      for ($k = 0; $k < $size; $k++){
        $sum += $M1[$i][$k] * $M2[$k][$j];
      }
      $Mnew[$i][$j] = $sum;
    }
  }

  $Gnew = GRgraph_matrix(@Mnew);
}


######################################
#Name: GRhascircuit_graph
#Input: A graph
#Output: 1 if the graph has a circuit, 0 otherwise
######################################
sub GRhascircuit_graph{
  my ($graph) = @_;

  my ($i, $j, $sum, $size, @matrix, $hasCircuit);

  @matrix = GRmatrix_graph($graph);
  $size = scalar @matrix;

  for ($i = 0; $i < $size; $i++){
    $sum = 0;
    for ($j = 0; $j < $size; $j++){
      $sum += $matrix[$i][$j];
    }
    if ($sum == 1){
      for ($j = 0; $j < $size; $j++){
        $matrix[$i][$j] = 0;
        $matrix[$j][$i] = 0;
      }
      $i = -1;
    }
  }

  for ($i = 0; $i < $size; $i++){
    for ($j = $i + 1; $j < $size; $j++){
      if ($matrix[$i][$j] != 0){
        $hasCircuit = 1;
        last;
      }
    }
  }
  
  $hasCircuit;
};


######################################
#Name: GRistree_graph
#Input: A graph 
#Output: A list containing a 1 if it is a tree, 0 if not a tree and a 
#        message about why it was not a tree.
######################################
sub GRistree_graph{
  my ($graph) = @_;
  
  my (@ans);
  
  @ans = (1,'Good');
  if (GRhascircuit_graph($graph)){
    @ans = (0, 'Has a circuit.');
  } elsif (GRncomponents_graph($graph) > 1){
    @ans = (0, 'Not connected.');
  }
  @ans;
}


######################################
#Name: GRisforest_graph
#Input: A graph
#Output: A list containing a 1 if it is a forest, 0 if not a forest and a 
#        message about why it was not a forest.
######################################
sub GRisforest_graph{
  my ($graph) = @_;

  my (@ans);
  
  @ans = (1, 'Good');
  
  if (GRhascircuit_graph($graph)){
    @ans = (0, 'Has a circuit');
  }
  
  @ans;
}


######################################
#Name: GoodEdge
#Input: A graph
#Output: A 1 if the edge should be placed in a sorted edges based graph
#        0 if not.
######################################
sub GoodEdge {
  my ($graph) = @_;
  
  my ($i, @adj, $ans, $sum, $val, $size);

  @adj = GRmatrix_graph($graph);
  
  $size = scalar @adj;
  $ans = 1;
  $sum = 0;

  for ($i = 0; $i < $size; $i++){
    $val = VertDegree($i, @adj);
    $sum += $val;
    if ($val > 2){
      $ans = 0;
    }
  }

  if ($sum < 2 * $size && GRhascircuit_graph($graph)){
    $ans = 0;
  }

  $ans;
};


######################################
#Name: GRsortededges_graph
#Input: A graph
#Output: A list of the values of the edges included in the graph 
#        in the order of their inclusion, and ref to circuit
######################################
sub GRsortededges_graph{
  my ($graph) = @_;
  my ($i, $j, $val, $size, @path, @matrix, @weights, @newmatrix, $newgraph);

  @matrix = GRmatrix_graph($graph);
  $size = scalar @matrix;

  for ($i = 0; $i < $size; $i++){
    $newmatrix[$i][$i] = 0;
    for ($j = $i + 1; $j < $size; $j++){
      $newmatrix[$i][$j] = 0;
      $newmatrix[$j][$i] = 0;
      push @weights, $matrix[$i][$j];
    }
  }

  @weights = num_sort(@weights);

  @path = ();

  do {
    $val = shift @weights;
    for ($i = 0; $i < $size; $i++){
      for ($j = $i + 1; $j < $size; $j++){
        if ($val == $matrix[$i][$j]){
	  $newmatrix[$i][$j]++;
	  $newmatrix[$j][$i]++;
	  $newgraph = GRgraph_matrix(@newmatrix);
	  if (GoodEdge($newgraph)){
	    push @path, $val;
	  } else {
	    $newmatrix[$i][$j]--;	  
	    $newmatrix[$j][$i]--;	  
	  }
	}
      }
    }

  } while (scalar @path < $size && scalar @weights > 0);

  my @circuit = (0);
  for $i (1..$size) {
      my $prev = $circuit[$#circuit];
      my @next = grep { $newmatrix[$prev][$_] == 1 } (0..$#newmatrix);
      push @circuit, $next[0];
      $newmatrix[$next[0]][$prev] = 0; }
       
  return ( @path, \@circuit );
};


######################################
#Name: GRiseulertrail_graph_vertices
#Input: A graph and list of selected vertices
#Output: A list containing a 1 if the indicated list of 
#        vertices is an euler path in the graph or 0 if 
#	 it is not and a message indicating the reason.
######################################
sub GRiseulertrail_graph_vertices{
  my ($graph, @verts) = @_;
  
  my($i, $j, @adj, @ans, $sum, $size);
  
  @adj = GRmatrix_graph($graph);
  $size = scalar @adj;
  @ans = (1, 'Good');
  
  $i = shift @verts;
  do {
    $j = shift @verts;
    if ($adj[$i][$j] == 0){
      @ans = (0, 'Incorrect edge included');      
    }
    $adj[$i][$j] -= 1;
    $adj[$j][$i] -= 1;
    $i = $j;
  } while ($ans[0] == 1 && scalar @verts > 0);

  $sum = 0;
  for ($i = 0; $i < $size; $i++){
    for ($j = $i + 1; $j < $size; $j++){
      $sum += $adj[$i][$j];
    }
  }
  
  if ($ans[0] != 0 && $sum != 0){
    @ans = (0, 'Not all edges used');
  }
  
  @ans;
}


######################################
#Name: GRiseulercircuit_graph_vertices
#Input: A graph and list of selected vertices
#Output: A list containing a 1 if the indicated list of 
#        vertices is an euler circuit in the graph or 0 if 
#	 it is not and a message indicating the reason.
######################################
sub GRiseulercircuit_graph_vertices{
  my ($graph, @verts) = @_;
  
  my($i, $j, @adj, @ans, $sum, $size);
  
  @adj = GRmatrix_graph($graph);
  $size = scalar @verts;

  @ans = GRiseulertrail_graph_vertices($graph, @verts);

  if ($ans[0] != 0 && $verts[0] != $verts[$size - 1]){
    @ans = (0, 'Not an Euler circuit');
  }

  @ans;
}

######################################
#Name: GRforest_size
#Input: Size of the desired graph to be a forest
#Output: A graph that is a forest
######################################
sub GRforest_size{
  my ($size) = @_;

  my ($i, $j, $new, $graph);

  $graph = GRtree_size($size);

  do {
  ($i, $j) = NchooseK($size, 2);
  $new = ChangeWeight($i, $j, 0, $graph);
  } while ($new eq $graph);

  $new;
}

######################################
#Name: GRtree_size
#Input: size of desired tree
#Output: A graph that is a tree
######################################
sub GRtree_size{
  my ($size) = @_;
  
  my ($i, $j, @adj, @used, @avail, $graph, @shuffle);

  for ($i = 0; $i < $size; $i++){
    for ($j = 0; $j < $size; $j++){
      $adj[$i][$j] = 0;
    }
  }
  $graph = GRgraph_matrix(@adj);

  @avail = (0..$size-1);
  @shuffle = NchooseK($size, $size);
  @avail = @avail[@shuffle];

  $j = pop @avail;
  push @used, $j;
  do {
    $j = pop @avail;
    $i = random(0, scalar @used - 1,1);
    $graph = ChangeWeight($used[$i], $j, 1, $graph);
    push @used, $j;
  } while (scalar @avail > 0);

  $graph;
};


######################################
#Name: GRisbipartite_graph
#Input: Graph object
#Output: A 1 is the graph is bipartite, 0 otherwise
######################################
sub GRisbipartite_graph{
  my ($graph) = @_;
  
  my ($i, @adj, $ans, $col, $done, $size, $vert, @color, @verts, $colored, $orig_col, @Vertcolor);
  @adj = GRmatrix_graph($graph);
  $size = scalar @adj;
  
  for ($i = 0; $i < $size; $i++){
    push @Vertcolor, 0;
  }
  $ans = 1;
  @color = (1,2);

  do {
    $i = 0;
    while ($Vertcolor[$i] != 0){
      $i++;
    }
    $Vertcolor[$i] = $color[0];
    push @verts, $i;
    
    do {
      $vert = shift @verts;
      $orig_col = $Vertcolor[$vert];
      for ($i = 0; $i < $size; $i++){
        if ($adj[$vert][$i] != 0){
	  $col = $Vertcolor[$i];
	  if ($orig_col == $col){
	    $ans = 0;
	    last;
	  } elsif ($col == 0){
	    push @verts, $i;
	    $Vertcolor[$i] = $color[2 - $orig_col];
	  }
	}
      }
    } while (scalar @verts > 0 && $ans == 1);
    
    $done = 1;
    for ($i = 0; $i < $size; $i++){
      $done *= $Vertcolor[$i];
    }
  } while ($done == 0 && $ans == 1);
  
  $ans;
}

######################################
#Name: GRbipartite_size
#Input: Size of the desired graph
#Output: A graph that has is bipartite
######################################
sub GRbipartite_size{
  my ($size) = @_;
  
  my($i, @P1, @P2, $s1, $s2, $max, $rnd1, $rnd2, $count, $graph);
  
  $graph = GRgraph_size_random($size, -1);
  
  $s1 = random(2, $size - 2, 1);
  $s2 = $size - $s1;
  
  if ($s1 > $s2){
    $max = $s1;
  } else {
    $max = $s2;
  }
  
  $count = random($max, 3 * $s1*$s2 / 4, 1);
  
  do {
    $ind1 = random(0, $s1 - 1, 1);
    $ind2 = $s1 + random(0, $s2 - 1, 1);
    $graph = ChangeWeight($ind1, $ind2, 1, $graph);
    @deg = GRdegrees_graph($graph);
    $sum = 0;
    for ($i = 0; $i < $size; $i++){
      $sum += $deg[$i];
    }
  } while ($sum < 2 * $count);
  
  $graph = GRshuffledgraph_graph($graph);
};


######################################
#Name: GRdijkstra_graph_vertex_vertex
#Input: A graph, starting vertex and ending vertex for Dijkstra's algorithm
#Output: Two lists, the first, a list of distances from the start vertex 
#        to every other vertex. The second a list of the vertices preceding (following?)
#	 the current vertex to achieve the shortest path.
######################################
sub GRdijkstra_graph_vertex_vertex{
  my ($graph, $start, $end) = @_;
  
  my ($i, @adj, $ind, $loc, $min, $new, @dist, $done, $left, @path, @prev, $size, @used, @avail, $weight);

  @adj = GRmatrix_graph($graph);
  $size = scalar @adj;
  for ($i = 0; $i < $size; $i++){
    $dist[$i] = -1;
    $prev[$i] = -1;
  }
  $dist[$start] = 0;

  @avail = (0..$size -1 );
  $left = scalar @avail;
  
  
  while ($left > 0){# && $new != $end){
    $min = 1000000000;
    for ($i = 0; $i < $left; $i++){
      $loc = $avail[$i];
      if ($dist[$loc] >= 0 && $dist[$loc] < $min){
        $new = $loc;
	$ind = $i;
	$min = $dist[$new];
      }
    }
    push @used, $new;
    splice @avail, $ind, 1;
    @used = num_sort(@used);
    
    for ($i = 0; $i < $size; $i++){
      $weight = $adj[$new][$i];
      if ($weight != 0){
        if ($dist[$i] > $min + $weight || $dist[$i] < 0){
	  $dist[$i] = $min + $weight;
	  $prev[$i] = $new;
	}      }    }
    $left = scalar @avail;
  };

  $loc = $end;
  while ($loc != $start){
    unshift @path, $loc;
    $loc = $prev[$loc];
  }
  unshift @path, $start;
    
  ($dist[$end], @path);
};


######################################
#Name: GRgraphpic_dim_random_labels_weight_dweight
#Input: Dimensions of the table in (row, column) format, a value to determine 
#	the probability of an edge existing between vertices, labels for the vertices,
#	starting weight and weight difference for edge weights.
#Output: A graph with weights and a picture of the graph in tabular format.
######################################
sub GRgraphpic_dim_random_labels_weight_dweight {
  my ($row, $col, $prob, $labels, $weight, $dweight) = @_;

  my ($i, $j, $u, $v, $x, $y, $up, @adj, $lab, $loc, $pic, $val, $base, $grid, $poss, $rght, 
      $rtdn, $rtup, $size, $new_x, $new_y, $shift, $down_y, $orig_x, $orig_y, $rght_x);
  
  @adj = GRmatrix_graph(GRgraph_size_random($row * $col, -1));
  
  $base = 10;
  $grid = 20;
  $shift = $grid / 15;
  $width = ($col - 1) * $grid;
  $height = ($row - 1) * $grid;
  $pic = init_graph(0, 0, ($col - .25) * $grid, ($row - .25) * $grid,'pixels'=>[7 * $width, 7 * $height]);
  
  for ($i = 0; $i < $row; $i++) {
    for ($j = 0; $j < $col; $j++){
      $x = $base + $grid * $j;
      $y = $base + $grid * $i;
      $pic->stamps(closed_circle($x, $y,"blue"));
      $lab = new Label($x - $shift, $y + 2 * $shift, GRlabel_vertex_labels($i + $row * $j,$labels),'blue','center','center');
      $pic->lb($lab);
    }
  }

  for ($i = 0; $i < $row; $i++) {
    for ($j = 0; $j < $col; $j++) {
      $loc = $j * $row + $i;
      $rght = $loc + $row;
      $up = $loc + 1;
      $rtup = $loc + $row + 1;
      $rtdn = $loc + $row - 1;

      if ($j + 1 < $col && random(0,1,.01) <= $prob){
        $count++;
	$adj[$loc][$rght] = 1;
	$adj[$rght][$loc] = 1;
      }
      if ($i + 1 < $row && random(0,1,.01) <= $prob){
        $count++;
	$adj[$loc][$up] = 1;
	$adj[$up][$loc] = 1;
      }
      if ($i + 1 < $row && $j + 1 < $col && random(0,1,.01) <= $prob){
        $count++;
        $adj[$loc][$rtup] = 1;
	$adj[$rtup][$loc] = 1;
      }
      if ($i - 1 >= 0 && $j + 1 < $col && random(0,1,.01) <= $prob){
        $count++;
        $adj[$loc][$rtdn] = 1;
	$adj[$rtdn][$loc] = 1;
      }
    }
  }
  
  for ($i = 0; $i < $count; $i++){
    push @weights, $weight + $i * $dweight;
  }
  @weights = @weights[NchooseK($count, $count)];

  $u = .3333;
  $v = 1 - $u;
  
  for ($i = 0; $i < $row * $col; $i++) {
    for ($j = $i + 1; $j < $row * $col; $j++) {
      if ($adj[$i][$j] != 0){
        if ($dweight == 0){
          $val = random(2, 15, 1);
	} else {
          $val = shift @weights;
	}
        $adj[$i][$j] = $val;
        $adj[$j][$i] = $val;
        $orig_x = $base + int($i / $row) * $grid;
        $orig_y = $base + $i % $row * $grid;
        $new_x = $base + int($j / $row) * $grid;
        $new_y = $base + $j % $row * $grid;
        $pic->moveTo($orig_x, $orig_y);
	$pic->lineTo($new_x, $new_y, 9);
        $lab=new Label($u * $orig_x + $v * $new_x, $u * $orig_y + $v * $new_y + $shift, $val, 'red', 'center', 'center');
        $pic->lb($lab);
      }
    }
  }
  
  $graph = GRgraph_matrix(@adj);
  
  $graph, $pic;
};

######################################
#Name: GRhamiltonian_size
#Input: Size of the desired graph (5 or greater)
#Output: A graph that has is hamiltonian
######################################
sub GRhamiltonian_size{
  my ($size) = @_;
  
  my($i, $j, @adj, $low, $comp, $high, $count, $edges, $graph);

  @adj = GRmatrix_graph(GRgraph_size_random($size,-1));
  $comp = $size * ($size - 1) / 2;
  if ($size <= 5){
    $low = $size + 1;
    $high = $comp - 1;
  } else {
    $low = int ($comp / 3) + 1;
    $high = int($comp / 2) + 1;
  }
  $edges = int random ($low, $high, 1);
  
  for ($i = 0; $i < $size; $i++){
    $j = ($i + 1) % $size;
    $adj[$i][$j] = 1;
    $adj[$j][$i] = 1;
  }
  
  $count = $size;
  while ($count < $edges){
    ($i, $j) = NchooseK($size,2);
    if ($adj[$i][$j] == 0){
      $adj[$i][$j] = 1;
      $adj[$j][$i] = 1;
      $count++;
    }
  } 
  
  $graph = GRshuffledgraph_graph(GRgraph_matrix(@adj));
};


######################################
#Name: GRnonhamiltonian_size_type
#Input: Size of the desired graph and a type of non hamiltonian graph:
#	odd: Has two cycles joined by a single edge
#	even: Has a vertex of degree one
#	If the odd type, size must be at least 6
#Output: A graph that has is not hamiltonian of the specified type
######################################
sub GRnonhamiltonian_size_type{
  my ($size, $type) = @_;
  
  my($i, $j, $v1, $v2, @adj, $val, $count, $edges, $graph, $ncomp, $split);

  $type = $type % 2;
  @adj = GRmatrix_graph(GRgraph_size_random($size,-1));

  if ($type == 0){
    $ncomp = ($size - 1) * ($size - 2) / 2;
    $edges = random ($size + 1, 2 * $ncomp / 3 + 1, 1);
    
    for ($i = 0; $i < $size - 1; $i++){
      $j = $i + 1;
      $adj[$i][$j] = 1;
      $adj[$j][$i] = 1;
    }
    $adj[$size - 2][0] = 1;
    $adj[0][$size - 2] = 1;
    
    $count = $size;
    do {
      ($i, $j) = NchooseK($size - 1,2);
      if ($adj[$i][$j] == 0){
        $adj[$i][$j] = 1;
        $adj[$j][$i] = 1;
        $count++;
      }
    } while ($count < $edges);
  } else { #type 1
    if ($size < 6){die}
    $split = int ($size / 2);
    
    for ($i = 0; $i < $split; $i++){
      $j = ($i + 1) % $split;
      $adj[$i][$j] = 1;
      $adj[$j][$i] = 1;
    }
    for ($i = $split; $i < $size; $i++){
      $j = ($i + 1) % $size;
      $adj[$i][$j] = 1;
      $adj[$j][$i] = 1;
    }
    $adj[$size - 1][$split] = 1;
    $adj[$split][$size - 1] = 1;

    $edges = ($size + 1) + ($size - 6);
    $count = $size + 1;

    $maxtry=4;                                      # Nandor: I don't know if this is needed, just to be sure
    while ($count < $edges && $maxtry>0){           # 
      $maxtry--;                                    #
      $v1 = random (0, $split - 1, 1);
      $v2 = ($v1 + 2) % $split;
      if ($adj[$v1][$v2] == 0){
        $adj[$v1][$v2] = 1;
        $adj[$v2][$v1] = 1;
	$count++;
      }
      if ($adj[$v1 + $split][$v2 + $split] == 0){
        $adj[$v1 + $split][$v2 + $split] = 1;
        $adj[$v2 + $split][$v1 + $split] = 1;
	$count++;
      }
    }
  }
  $graph = &GRshuffledgraph_graph(GRgraph_matrix(@adj));
#  $graph = &GRgraph_matrix(@adj);
};


######################################
#Name: GRcycle_size
#Input: Size for cycle
#Output: A picture of a graph that is a cycle (with no labels).
######################################
sub GRcycle_size{
  my ($size) = @_;
  
  my($i, $j, $gap, $pic);
  
  $pic = init_graph(-1.5,-1.5,1.5,1.5,'pixels'=>[220,220]);
  $gap = 2.0 * 3.14 / $size;

  for ($i = 0; $i < $size; $i++) {
    $j = ($i + 1) % $size;
    $pic->stamps(closed_circle(cos($i * $gap),sin($i * $gap),"blue"));
    $pic->moveTo(cos($i * $gap),sin($i * $gap));
    $pic->lineTo(cos($j * $gap),sin($j * $gap), 1);        
  }
  $pic;
};


######################################
#Name: GRcomplete_size
#Input: Size for complete graph
#Output: A picture of a complete graph (with no labels).
######################################
sub GRcomplete_size{
  my($size) = @_;
  
  my($i, $j, $gap, $pic);
  $pic = init_graph(-1.5,-1.5,1.5,1.5,'pixels'=>[220,220]);
  $gap = 2.0 * 3.14 / $size;  

  for ($i = 0; $i < $size; $i++) {
    $pic->stamps(closed_circle(cos($i * $gap),sin($i * $gap),"blue"));
    for ($j = $i + 1; $j < $size; $j++){
      $pic->moveTo(cos($i * $gap),sin($i * $gap));
      $pic->lineTo(cos($j * $gap),sin($j * $gap), 1);        
    }
  }
  $pic;
}

######################################
#Name: GRcompleteGraph_size
#Input: Size for complete graph
#Output: adj matrix (ref) of complete graph
######################################
sub GRcompleteGraph_size{
  my($size) = @_;
  my( $i, $j );
  my @matrix = &makeEmptyAdjMatrix( $size );
  for $i (0..($size-2) ) {
      for $j(($i+1)..($size-1)) {
          $matrix[$i][$j] = 1;
          $matrix[$j][$i] = 1;}  }
  return \@matrix;
}

######################################
#Name: GRwheel_size
#Input: Size for wheel
#Output: A picture of a graph that is a wheel (with no labels).
######################################
sub GRwheel_size{
  my ($size) = @_;
  
  my($i, $j, $gap, $pic);
  
  $pic = init_graph(-1.5,-1.5,1.5,1.5,'pixels'=>[220,220]);
  $gap = 2.0 * 3.14 / $size;

  $pic->stamps(closed_circle(0,0,"blue"));
  for ($i = 0; $i < $size; $i++) {
    $j = ($i + 1) % $size;
    $pic->stamps(closed_circle(cos($i * $gap),sin($i * $gap),"blue"));
    $pic->moveTo(cos($i * $gap), sin($i * $gap));
    $pic->lineTo(cos($j * $gap), sin($j * $gap), 1);        
    $pic->moveTo(0,0);
    $pic->lineTo(cos($i * $gap), sin($i * $gap), 1);        
  }
  $pic;
};


######################################
#Name: GRcompletebipartite_size_size
#Input: Size for upper and size for lower bipartite graph
#Output: A picture of a bipartite graph with size and 
#	 size labels on top and bottem (and no labels).
######################################
sub GRcompletebipartite_size_size{
  my($m, $n) = @_;
  
  my($i, $j, $low, $pic, $diff, $high, @shft, $width, $x_max);
  
  $low = 5;
  $high = 20;
  $width = 20;
  @shft = (10,10);

  $diff = $m - $n;
  
  if ($diff == 0){
    $x_max = $m * $width + $shft[0];
  } elsif ($diff % 2 == 0 && $diff > 0){
    $x_max = $m * $width + $shft[0];
    $shft[1] += $width * $diff / 2;
  } elsif ($diff % 2 == 0) {
    $x_max = $n * $width + $shft[0];
    $shft[0] += -$width * $diff / 2;
  } elsif ($diff > 0) {
    $x_max = $m * $width + $shft[0];
    $shft[1] += ($width / 2) * $diff;
  } else {
    $x_max = $n * $width + $shft[0];
    $shft[0] += (-$width / 2)* $diff;
  }
  
  $pic = init_graph(0,0,$x_max,25,'pixels'=>[220,220]);
  
  for ($i = 0; $i < $m; $i++){
    $pic->stamps(closed_circle($i * $width + $shft[0], $high,"blue"));
  }
  for ($j = 0; $j < $n; $j++){
    $pic->stamps(closed_circle($j * $width + $shft[1], $low,"blue"));
  }

  for ($i = 0; $i < $m; $i++){
    for ($j = 0; $j < $n; $j++){
    $pic->moveTo($i * $width + $shft[0], $high);
    $pic->lineTo($j * $width + $shft[1], $low, 1);
    }
  }
  $pic;
};


######################################
#Name: GRcube
#Input: None
#Output: A picture of a graph that is a flattened cube.
######################################
sub GRcube{
  my($i, $j, $S1, $min, $pic, @prev, @PREV, $Step, @large, @small);
  
  $min = 5;
  $S1 = 30;
  $Step = 7.5;

  $pic = init_graph(0, 0, $S1 + 2 * $min, $S1 + 2 * $min, 'pixels'=>[220,220]);

  push @large, $min, $min + $S1, $min + $S1, $min;
  push @small, $min + $Step, $min + $S1 - $Step, $min + $S1 - $Step, $min + $Step;
  
  @PREV = ($large[0], $large[0]);
  @prev = ($small[0], $small[0]);
  
  for ($i = 0; $i < 4; $i++){
    $j = ($i + 1) % 4;
    $pic->stamps(closed_circle($large[$i], $large[$j],"blue"));
    $pic->stamps(closed_circle($small[$i], $small[$j],"blue"));
    $pic->moveTo(@PREV);
    $pic->lineTo($large[$i], $large[$j]);
    $pic->lineTo($small[$i], $small[$j],1);
    $pic->lineTo(@prev);
    @PREV = ($large[$i], $large[$j]);
    @prev = ($small[$i], $small[$j]);
  }
  $pic;
};


######################################
#Name: GRpetersen
#Input: None
#Output: A picture of the Petersen graph.
######################################
sub GRpetersen{
  my($i, $R1, $R2, $gap, $pic, $val, @prev, $val2, $shift);

  $R1 = 1;
  $R2 = 2;
  $pic = init_graph(-$R2 - .5,-$R2 - .5,$R2 + .5,$R2+ .5,'pixels'=>[220,220]);
  $gap = 2.0 * 3.14 / 5;
  $shift = $PI/10;

  @prev = ($R2 * cos ($shift), $R2 * sin($shift));
  for ($i = 0; $i < 5; $i++) {
    $val = $i * $gap + $shift;
    $val2 = ($i + 2) % 5 * $gap + $shift;
    $pic->stamps(closed_circle($R1 * cos($val),$R1 * sin($val),"blue"));
    $pic->stamps(closed_circle($R2 * cos($val),$R2 * sin($val),"blue"));
    $pic->moveTo(@prev);
    $pic->lineTo($R2 * cos($val),$R2 * sin($val));
    $pic->lineTo($R1 * cos($val),$R1 * sin($val), 1);
    $pic->lineTo($R1 * cos($val2),$R1 * sin($val2), 1);
    @prev = ($R2 * cos($val), $R2 * sin($val));
  }
  $pic->moveTo(@prev);
  $pic->lineTo($R2 * cos ($shift), $R2 * sin($shift));

  $pic;
}


######################################
#Name: GRdodecahedron
#Input: None
#Output: A picture of a graph that is a flattened dodecahedron.
######################################
sub GRdodecahedron{
  my($i, $P1, $P2, $P3, $P4, $gap, $pic, $val, $val2, $shift, $space);
  
  $P1 = 4;
  $P2 = 2.75;
  $P3 = 2;
  $P4 = 1;
  
  $pic = init_graph(-$P1 - .5,-$P1 - .5,$P1 + .5,$P1 + .5,'pixels'=>[220,220]);
  $gap = 2.0 * 3.14 / 5;
  $space = $gap / 2;
  $shift = $PI/10;
  
  @prev = ($P1 * cos ($shift), $P1 * sin($shift));
  for ($i = 0; $i < 5; $i++) {
    $val = $i * $gap + $shift;
    $val2 = $val + $space;
    $pic->stamps(closed_circle($P1 * cos($val),$P1 * sin($val),"blue"));
    $pic->stamps(closed_circle($P2 * cos($val),$P2 * sin($val),"blue"));
    $pic->stamps(closed_circle($P3 * cos($val2),$P3 * sin($val2),"blue"));
    $pic->stamps(closed_circle($P4 * cos($val2),$P4 * sin($val2),"blue"));
    $pic->moveTo(@prev);
    $pic->lineTo($P1 * cos($val),$P1 * sin($val));
    $pic->lineTo($P2 * cos($val),$P2 * sin($val), 1);
    $pic->lineTo($P3 * cos($val2),$P3 * sin($val2), 1);
    $pic->lineTo($P4 * cos($val2),$P4 * sin($val2), 1);
    $pic->lineTo($P4 * cos($val2 - $gap),$P4 * sin($val2 - $gap), 1);
    $pic->moveTo($P2 * cos($val),$P2 * sin($val));
    $pic->lineTo($P3 * cos($val2 - $gap),$P3 * sin($val2 - $gap), 1);
    @prev = ($P1 * cos($val), $P1 * sin($val));
  }
  $pic->moveTo(@prev);
  $pic->lineTo($P1 * cos ($shift), $P1 * sin($shift));

  $pic;
}


######################################
#Name: GRvertices_labels_labels
#Input: string of labels, string of all graph labels
#Output: Returns a list of vertex numbers corresponding to the 
#	 labels in the first string.
######################################
sub GRvertices_labels_labels{
  my ($labels, $orig_labels) = @_;
  
  my ($i, $label, @vertices);
  
  for ($i = 0; $i < length $labels; $i++){
    $label = substr $labels, $i, 1;
    push @vertices, GRvertex_label_labels($label, $orig_labels);
  }
  
  @vertices;
}


######################################
#Input: graph
#Output: list of valences of vertices
######################################
sub GRvalences_graph{
    my $graph = shift;
    my @matrix = GRmatrix_graph( $graph );
    my $size = scalar( @matrix );
    my @res = ();
    my ($i,$rowsum);
    for $i (0..($size - 1)) {
        $rowsum = &sum(@{$matrix[$i]});
        push @res, $rowsum ; }
    \@res; 
}

sub makeEmptyAdjMatrix{
    my $size = shift;
    my @matrix = map { [ map { 0 } 1..$size ] } 1..$size;
    return @matrix; }


######################################
# Input: size, circuit lenth
#Output: graph with Euler circuit, adj matrix ref, circuit as list ref
######################################
sub GR_EulerCircuitGraph{
    my ( $size, $circlen ) = @_;
    my @matrix      = &makeEmptyAdjMatrix( $size );
    my @circuit     = (0);
    my ( @excludeds, $i, $j, $lastvertex, $nextvertex  );

    for ($i=0; $i < $circlen - 1; $i+=1 ) {
        @excludeds = ();
        # for ( $j=0; $j<$circlen; $j+=1 ) {
        #     if ( $matrix[$i][$j] > 0 ) {
        #         push @excludeds, $j; } }
        $lastvertex = $circuit[$#circuit];
        push @excludeds, $lastvertex;
        if ( $i == $circlen - 2 ) {
            push @excludeds, 0; }
        $nextvertex = random_excluding( 0, $size - 1, 1, @excludeds );
        push @circuit, $nextvertex;
        $matrix[$lastvertex][$nextvertex] += 1;
        $matrix[$nextvertex][$lastvertex] += 1; }
    $lastvertex = $circuit[$#circuit];
    push @circuit, 0;
    $matrix[$lastvertex][0] += 1;
    $matrix[0][$lastvertex] += 1;
    return GRgraph_matrix( @matrix ), \@matrix, \@circuit;
}

######################################
# Input: matrix ref, new edge ref
#Output: new matrix 
######################################
sub GR_matrixAddEdge{
    my ($matrix, $edge) = @_;
    my ($i,$j) = @$edge;
    $matrix->[$i][$j] += 1;
    $matrix->[$j][$i] += 1;
    return $matrix;
}

######################################
# Input: two matrix refs
#Output: matrix ref of combination
######################################
sub GR_combineComponents{
    my ($m1,$m2) = @_;
    my ($s1,$s2) = ( scalar(@$m1), scalar(@$m2) );
    my @newmat = ();
    my $i;
    for ( $i=0; $i<$s1; $i+=1 ){
        push @newmat, [ @{$m1->[$i]}, (0) x $s2 ]; }
    for ( $i=0; $i<$s2; $i+=1 ) {
        push @newmat, [ (0) x $s1, @{$m2->[$i]} ]; }
return \@newmat; }


######################################
# Input: label list ref, label
#Output: position of label in list
######################################
sub positionInList{
    my ( $listref, $el ) = @_;
    my $len = scalar(@$listref) - 1;
    my @positions = grep { $listref->[$_] eq $el } (0..$len);
    return $positions[0]; }

######################################
# answer checker for Euler path with given start
# start and labelList must be passed through ansHash
######################################
sub EulerAnsChecker{
    my ( $empty, $str, $ansHash ) = @_;
    my $start = $ansHash->{start};
    my $labelList = $ansHash->{labels};
    my @path = split( ",", $str );
    @path = map { trim($_) } @path;
    if ( !($path[0] eq $start) ) {
        return 0; }
    my @pathinds = map { &positionInList( $labelList, $_ ) } @path;
    if ( grep { ! defined $_ } @pathinds ) {
        return 0; }
    my @ans = GRiseulertrail_graph_vertices( $graph, @pathinds );
    return @ans[0]; }

######################################
#  Input: adj matrix ref
# Output: sum of weights of edges
######################################
sub GR_totalWeight{
    my $matref = shift;
    my @rows = map { sum( @{$_} ) } @$matref;
    return sum( @rows ) / 2;
}

######################################
# Input: string of sidewalk, labels ref
#Output: ref of list of edges
######################################
sub sidewalkToEdge{
    my ( $sw, $labelsref ) = @_;
    my @strlist = split( "", $sw );
    @strlist = grep { /[A-Z]/ } @strlist;
    my $v1;
    my $v2 = shift @strlist;
    my @edge;
    my @res = ();
    while ( @strlist ) {
        $v1 = $v2;
        $v2 = shift @strlist;
        @edge = map { &positionInList( $labelsref, $_ ) } ( $v1, $v2 );
        push( @res, [$edge[0],$edge[1]] ); }
    return \@res; 
}

######################################
# Input: pic ref, vertices hash ref, vertices' locs hash ref
#Output: pic (updated with new vertices
######################################
sub GR_pic_addVertices{
    my ( $pic, $verthashref, $vertlocref ) = @_;
    my ( $lab, @point );
    for $v ( keys( %$verthashref ) ) {
        # if ( ! $verthashref->{$v} ) {
        #     next; }
        @point = @{$vertlocref->{$v}};
        $pic->stamps(closed_circle( @point,"black"));
        $point[0] += 1;
        $lab = new Label( @point, $v,'blue','center','center');
        $pic->lb($lab); } }
######################################
# Input: pic ref, vertices' locs hash ref
#Output: pic (updated with new vertices
######################################
sub GR_pic_addAllVertices{
    my ( $pic, $vertlocref ) = @_;
    my ( $lab, @point );
    for $v ( keys( %$vertlocref ) ) {
        @point = @{$vertlocref->{$v}};
        $pic->stamps(closed_circle( @point,"black"));
        $point[0] += 1;
        $lab = new Label( @point, $v,'blue','center','center');
        $pic->lb($lab); } }

######################################
# Input: pic ref, vertices' locs hash ref, tasks hash ref
#Output: pic (updated with new vertices and task priorities)
######################################
sub GR_pic_addAllVerticesSched{
    my ( $pic, $vertlocref, $tasks, $times ) = @_;
    my ( $lab, @point );
    for $v ( keys( %$vertlocref ) ) {
        @point = @{$vertlocref->{$v}};
        $pic->stamps(closed_circle( @point,"blue"));
        $point[0] += 1;
        $lab = new Label( @point, 'T'.$tasks->{$v},'blue','center','center');
        $pic->lb($lab);
        $point[0] -= 1;
        $point[1] -= 1;
        $lab = new Label( @point, $times->{$v},'red','center','center');
        $pic->lb($lab);
    } }

######################################
# Input: graph, vertices hash ref, labels list ref
#Output: list of questions on the valence of each vertex
######################################
sub GR_valenceQuestions_graph{
    my ( $graph, $verthashref, $labelsref ) = @_;
    $valences = GRvalences_graph( $graph );
    $valenceQuestions = "";
    for $i (0..($size - 1)) {
        $letter = $labelsref->[$i];
        if ( $verthashref->{$letter} ) {
            $valenceQuestions .= "$letter: [___]{$valences->[$i]}  
"; } }
    return $valenceQuestions; }

######################################
#Name: GR_isHamiltonianCircuit_graph_vertices
#Input: A graph and list of selected vertices (as indices)
#Output: A list containing a 1 if the indicated list of 
#        vertices is a Hamiltonian circuit in the graph or 0 if 
#	 it is not and a message indicating the reason.
######################################
sub GR_isHamiltonianCircuit_graph_vertices{
    my ($graph, @verts) = @_;
  
    my($i, $j, @adj, @ans, $sum, $size);

    if ( $verts[0] != $verts[$#verts] ) {
        return (0, "Not a circuit");
    }
  
    @adj = GRmatrix_graph($graph);
    $size = scalar @adj;
    @ans = (1, 'Good');

    if ( $#verts != $size ) {
        return (0, "Path of wrong length"); }

    $i = shift @verts;
    my %vertsUsed = ( $i => 1 );
    do {
        $j = shift @verts;
        $vertsUsed{$j} = 1;
        if ($adj[$i][$j] == 0) {
            @ans = (0, 'Incorrect edge included');      
        }
        $adj[$i][$j] -= 1;
        $adj[$j][$i] -= 1;
        $i = $j;
    } while ($ans[0] == 1 && scalar @verts > 0);
  
    if ($ans[0] != 0 && scalar(keys(%vertsUsed)) != $size ) {
        @ans = (0, 'Not all vertices used');
    }
    @ans; }

######################################
# answer checker for Hamiltonian Circuit with given start
# start and labelList must be passed through ansHash
######################################
sub HamiltonianCircuitAnsChecker{
    my ( $empty, $str, $ansHash ) = @_;
    my $labelList = $ansHash->{labels};
    my @path = split( ",", $str );
    @path = map { trim($_) } @path;
    my @pathinds = map { &positionInList( $labelList, $_ ) } @path;
    if ( grep { ! defined $_ } @pathinds ) {
        return 0; }
    my @ans = GR_isHamiltonianCircuit_graph_vertices( $graph, @pathinds );
    return @ans[0]; }

######################################
# Input: circuit as ref, start
#Output: variant of crcuit with given start
######################################
sub GR_rotateCircuit{
    my ( $circuitref, $start ) = @_;
    my @pos = grep { $circuitref->[$_] == $start } (0..$#$circuitref);
    if ( $pos[0] == 0 ) {
        return $circuitref; }
    my @newcircuit = ( @$circuitref[ ( $pos[0]..$#$circuitref) ],
                       @$circuitref[ ( 1..$pos[0] ) ] );
    return \@newcircuit; }

######################################
# Input: number of vertices in complete graph
#Output: list ref of all possible Hamiltonian circuits starting at 0 
######################################
sub GR_allHamiltonianInComplete{
    my $size = shift;
    my $top = $size - 1;
    my $res = [];
    my @verts = ( 1..$top );
    sub iter{
        my ( $sofar, $tocome ) = @_;
        if ( scalar( @$tocome ) == 0 ) {
            return [ @$sofar, 0 ]; }
        return map { &iter( [ @$sofar, $_ ], [ &removeElement( $_, @$tocome ) ] ) }
            @$tocome; }
    my @dups = &iter( [0], \@verts );
    my @res = ();
    for $x (@dups) {
        my $r = [ reverse( @$x ) ];
        if ( ! (grep { &shallowEquals( $_, $r ) } @res) ) {
            push @res, $x; }} 
    return \@res; }

######################################
# Input: matrix ref, path ref
#Output: total weight of path
######################################
sub GR_totalWeightOfPath{
    my ( $mat, $path ) = @_;
    my $res = 0;
    my ( $prev, $next, $i );
    $next = $path->[0];
    for $i (1..$#$path) {
        $prev = $next;
        $next = $path->[$i];
        $res += $mat->[$prev][$next]; }
    return $res; }

######################################
# Input: vertex label list ref, edge list ref, min, max
#Output: weighted adj matrix with given edges and distinct weights between min and max
######################################
sub GR_randomWeights{
    my ( $labels, $edges, $min, $max ) = @_;
    my $size = scalar( @$labels );
    my @matrix = &makeEmptyAdjMatrix( $size );
    my @used = ();
    my $lbl;
    for $i (0..($size-2) ) {
        for $j(($i+1)..($size-1)) {
            $lbl = join( "", @$labels[$i,$j] );
            if ( grep { $lbl eq $_ } @$edges ) {
                $w = random_excluding( $wmin, $wmax, 1, @used );
                $matrix[$i][$j] = $w;
                $matrix[$j][$i] = $w;
                push @used, $w; }  }  }
    return \@matrix; }

######################################
# Input: pic, vertices hash ref, labels ref, edges ref, matrix ref
#Output: updated pic
######################################
sub GR_updatePicEdges{
    my ( $pic, $verthashref, $labels, $edgesref, $matref ) = @_;
    my ( $start, $end, $weight, $lab, $e, $i, $j, @edgelabels, @point );
    for $e ( @$edgesref ) {
        @edgelabels = split( "", $e );
         ( $start, $end ) = map { $verthashref->{$_} } @edgelabels;
        $pic->moveTo( @$start );
        $pic->lineTo( @$end, 'black', 2 );
        @point = ( .25*($start->[0]) + .75*($end->[0]),
                   .25*($start->[1]) + .75*($end->[1]) );
        ( $i, $j ) = map { &positionInList($labels,$_) } @edgelabels;
        $weight = $matref->[$i][$j];
        $lab = new Label( @point, $weight,'red','center','center');
        $pic->lb($lab); }
    return $pic; }

######################################
# Input: pic, vertices hash ref, edges ref
#Output: updated pic
######################################
sub GR_updatePicEdgesPriority{
    my ( $pic, $verthashref, $edgesref ) = @_;
    my ( $start, $end, $e, $i, $j, @edgelabels, @point );
    for $e ( @$edgesref ) {
        @edgelabels = split( "", $e );
         ( $start, $end ) = map { $verthashref->{$_} } @edgelabels;
        $pic->moveTo( @$start );
        $pic->arrowTo( @$end, 'black', 2 ); }
    return $pic; }


######################################
# Input: labels ref, edges ref, tasks hash ref, times hash ref, # procs
#Output: ref of schedule table
######################################
sub GR_listProcessingAlg{
    my ( $labels, $edges, $tasks, $times, $numprocs, $tasknames ) = @_;
    my @waits = (0) x $numprocs;
    if ( !defined($tasknames) ) {
        $tasknames = $tasks; }
    return &listProcAlg( $labels, $edges, $tasks, $times,
                         0, [], {}, [], \@waits, $tasknames );
}

######################################
# Input: 
#Output: ref of schedule table
######################################
sub listProcAlg{
    my ( $labels, $edges, $tasks, $times,
         $t, $completed, $current, $sched, $timerem, $tasknames ) = @_;
    if ( sum( @$timerem ) == 0 && $#$sched > -1 ) {
        return $sched; }
    my $wait;
    my @nonzeros = grep { $_ != 0 } @$timerem;
    if ( scalar(@nonzeros) > 0 ) {
        $wait = min( @nonzeros ); }
    elsif ( $#$sched = -1 ) {
        $wait = 0; }
    else {
        $wait = 1000000000; }
    my @newtimerem = map { max( 0, $_ - $wait ) } @$timerem;
    my @procsidle = grep { $newtimerem[$_] == 0 } 0..$#$timerem;

    my %newcurrent = %$current;
    my @newcompleted = @$completed;
    my ( $cur, $curproc );
    for $cur(keys(%$current)) {
        $curproc = $current->{$cur};
        if ( &listHasString( \@procsidle, $curproc ) ) {
            push @newcompleted, $cur;
            delete $newcurrent{$cur}; } }
    
    my @newcell = ( $t + $wait );
    my @availtasks = @{ &listAvailableTasks( $labels, $edges,
                                             \@newcompleted, [ keys(%newcurrent) ] ) };
    my @priorities = map { $tasks->{$_} } @availtasks;

    my ( $p, $newentry, @oldcell );
    if ( $#$sched > -1 ) {
        @oldcell = @{ $sched->[$#$sched] };
        shift @oldcell; }
    else {
        @oldcell = ('-') x scalar( @$timerem );  }
    for $p( 0..$#$timerem ) {
        if ( &listHasString( \@procsidle, $p ) ) {
            if ( $#availtasks > -1) {
                # choose next task
                my $min = min( @priorities );
                my $nextind = &positionInList( \@priorities, $min );
                my $nextlabel = $availtasks[ $nextind ];
                my $nexttask = $tasknames->{ $nextlabel };
                # update according to task chosen
                push @newcell, 'T'.$nexttask;
                @availtasks = &removeNth( $nextind, @availtasks );
                @priorities = &removeNth( $nextind, @priorities );
                $newtimerem[$p] += $times->{$nextlabel};
                $newcurrent{ $nextlabel } = $p; }
            else {
                push @newcell, '-'; } }
        else {
            push @newcell, $oldcell[$p]; } }
    my @newsched = @$sched;
    push @newsched, \@newcell;
    return &listProcAlg( $labels, $edges, $tasks, $times,
                         $t + $wait, \@newcompleted, \%newcurrent,
                         \@newsched, \@newtimerem, $tasknames );
}

######################################
# Input: labels ref, edges ref, completed labels ref, current labels ref
#Output: ref of list of tasks available for scheduling
######################################
sub listAvailableTasks{
    my ( $labels, $edges, $completed, $current ) = @_;
    my ( $l, $k );
    my $unavail = [ @$completed, @$current ];
    my @res = grep { !&listHasString( $unavail, $_ ) } @$labels;
    my @startlist = @res;
    for $l( @startlist ) {
        for $k(@$labels) {
            if ( &listHasString( $edges, $k . $l ) &&
                     !&listHasString( $completed, $k ) ) {
                @res = &removeString( $l, @res ); } } }
    return \@res; }

######################################
# Input: labels ref, edges ref, completed labels ref, current labels ref
#Output: ref of list of tasks available for scheduling
######################################
sub criticalPathOrdering{
    my ( $labels, $edges, $tasks, $times ) = @_;
    my @critlist = ();
    my ( $e, $i, $p );
    my ( $start, $end, $max );
    my ( @paths, @oldpaths, @todelete, @lengths );
    sub pathlength{
        my $p = shift;
        my @tasktimes = map { $times->{$_} } (split("",$p));
        return sum( @tasktimes );
    }
    #my $flag = 0;
    for $i(0..$#$labels) {
        @paths = ($labels->[$i]);
        @oldpaths = ();
        until ( &shallowEquals( \@paths, \@oldpaths ) ) {
            @oldpaths = @paths;
            @todelete = ();
            for $e(@$edges) {
                ($start, $end) = split( '', $e );
                for $p(@oldpaths) {
                    #$flag += 1;
                    if ( $start eq substr( $p, -1 ) ) {
                        push @paths, $p.$end;
                        push @todelete, $p;
                    }
                }
            }
            @paths = grep { !&listHasString( \@todelete, $_ ) } @paths;
        }
        @lengths = map { &pathlength($_) } @paths;
        $max = max( @lengths );
        push @critlist, $max;
    }
    sub orderfun{
        my ( $l1, $l2 ) = @_;
        my @inds = map { &positionInList( $labels, $_ ) } ( $l1, $l2 );
        my ( $c1, $c2 ) = map { $critlist[$_] } @inds;
        return $c1 > $c2 ||
            ( $c1 == $c2 && $tasks->{$l1} > $tasks->{$l2} ); }
    my @ordering = PGsort( \&orderfun, @$labels );
    my %newtasks = ();
    for $i(0..$#$labels) {
        $newtasks{$ordering[$i]} = $i + 1; }
    return \%newtasks;
}

######################################
# Input: binsize, weight list ref
#Output: packing list, i.e. list of weights in each bin
######################################
sub nextFit{
    my ( $binsize, $weights ) = @_;
    if ( max( @$weights ) > $binsize )  {
        die "Impossible packing problem!"; }
    my @answer = ();
    my ( $i, $curW, $cursum, @curbin );
    @curbin = ();
    for $i (0..$#$weights) {
        my $curW = $weights->[$i];
        my $cursum = sum( @curbin );
        if ( $cursum + $curW <= $binsize ) {
            push @curbin, $curW; }
        else {
            push @answer, [ @curbin ];
            @curbin = ( $curW ); } }
    if ( @curbin ) {
        push @answer, [ @curbin ]; }
    return \@answer; }

######################################
# Input: packing list ref
#Output: table of packing list, with bins as columns
######################################
sub transposePackingList{
    my $pkglist = shift;
    my @heights = map { scalar( @$_ ) } @$pkglist;
    my $mrow = max( @heights ) - 1;
    my $mcol = scalar( @$pkglist ) - 1;
    my @table = ();
    my ( $b, $i, $bin, $w );
    for $b ( 0..$mcol ) {
        $bin = $pkglist->[$b];
        for $i (0..$mrow) {
            $w = $bin->[$i];
            if ( $w ) {
                $table[$i][$b] = $w; }
            else {
                $table[$i][$b] = '-'; } } }
    @table = reverse( @table );

    return \@table; }

######################################
# Input: table of answers
#Output: string of PGML for answer blanks
######################################
sub makeAnswerBlanksFromTable{
    my $answers = shift;
    my $mrow = $#$answers;
    my $mcol = $#{$answers->[0]};
    my ( $blanks ) = ( "" );
    my ( $r, $c,  );
    for $r (0..$mrow) {
        for $c (0..$mcol) {
            $blanks .= "[___]{$answers->[$r][$c]}  "; }
        $blanks .= qq(
); }
    
    return $blanks; }


######################################
# Input: binsize, weight list ref
#Output: packing list, i.e. list of weights in each bin
######################################
sub firstFit{
    my ( $binsize, $weights ) = @_;
    if ( max( @$weights ) > $binsize )  {
        die "Impossible packing problem!"; }
    my @answers = ([]);
    my ( $i, $curW, $ind, @cursums, @gaps );
    @cursums = (0);
    for $i (0..$#$weights) {
        $curW = $weights->[$i];
        @gaps = grep { $cursums[$_] + $curW <= $binsize } 0..$#answers;
        if ( @gaps ) {
            $ind = $gaps[0];
            push @{$answers[$ind]}, $curW;
            $cursums[$ind] += $curW; }
        else {
            push @answers, [ $curW ];
            push @cursums, $curW; } }
    return \@answers; }

######################################
# Input: binsize, weight list ref
#Output: packing list, i.e. list of weights in each bin
######################################
sub worstFit{
    my ( $binsize, $weights ) = @_;
    if ( max( @$weights ) > $binsize )  {
        die "Impossible packing problem!"; }
    my @answers = ([]);
    my ( $i, $curW, $min, $minind, @cursums );
    @cursums = (0);
    for $i (0..$#$weights) {
        $curW = $weights->[$i];
        $min = min( @cursums );
        $minind = &positionInList( \@cursums, $min );
        if ( $cursums[$minind] + $curW <= $binsize ) {
             push @{$answers[$minind]}, $curW;
            $cursums[$minind] += $curW; }
        else {
            push @answers, [ $curW ];
            push @cursums, $curW; } }
    return \@answers; }

######################################
# Input: binsize, weight list ref
#Output: packing list, i.e. list of weights in each bin
######################################
sub bestFit{
    my ( $binsize, $weights ) = @_;
    if ( max( @$weights ) > $binsize )  {
        die "Impossible packing problem!"; }
    my @answers = ([]);
    my ( $i, $curW, $min, $bestind, @openings, @gaps, @cursums );
    @cursums = (0);
    for $i (0..$#$weights) {
        $curW = $weights->[$i];
        @openings = grep { $cursums[$_] + $curW <= $binsize } 0..$#cursums;
        if ( @openings ) {
            @gaps = map { $binsize - $cursums[$_] - $curW } @openings;
            $min = min( @gaps );
            $bestind = $openings[ &positionInList( \@gaps, $min ) ];
            push @{$answers[$bestind]}, $curW;
            $cursums[$bestind] += $curW; }
        else {
            push @answers, [ $curW ];
            push @cursums, $curW; } }
    return \@answers; }


######################################
#  Input: adj matrix ref, labels list ref
# Output: latex code of adjacency table
######################################
sub GR_adjMatrixToLatexTable{
    my ( $adj, $labs ) = @_;
    my ( $r, $c );
    my $maxr = $#$adj;
    my $bulk = "";
    for $r (0..$maxr) {
        $bulk .= $labs->[$r]." ";
        for $c (0..$maxr) {
            if ( $adj->[$r][$c] ) {
                $bulk .= "& X "; }
            else {
                $bulk .= "& - "; } }
        $bulk .= "\\\\ "; }
    my $cstring = "c" x ($maxr + 1);
    my $labels = join( " & ", @$labs );

    return "\\begin{tabular}{l|$cstring}
& $labels \\\\ \\hline
$bulk
\\end{tabular}";
}

######################################
#  Input: adj matrix ref, string of vertices in desired order
# Output: coloring that tries to maximize size of first color group
######################################
sub GR_findLargestColorGroup{
    my ( $adj, $start ) = @_;
    my $size = scalar( @$adj );
    my @groups = ( $start );
    my ( $i, $grind, @connected );
    sub findGroup{
        my $v = shift;
        my $g = 0;
        while ( !($groups[$g] =~ /$v/) ) {
            $g += 1; }
        return $g; }
    for $i (0..$#$adj) {
        $grind = &findGroup( "$i" );
        my @grouplist = split( "", $groups[$grind] );
        @connected = grep { $adj->[$i][$_] } @grouplist;
        if ( @connected ) {
            my $remstring = join( "", @connected );
            $groups[$grind] =~ s/[$remstring]//g;
            push @groups, join( "", @connected ); } }
    my @lens = map { length } @groups;
    return max( @lens ); }
            

        

1;
