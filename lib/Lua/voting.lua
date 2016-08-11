-- -*-two-mode-*-

-- set module path
--package.path = '/home/dabrowsa/.lib/lua/5.2/?.lua'
--print(package.path)

--vec = require('vector')
--mat = require('matrix')
--mp = require('mathProblem')
--mp.mcP = true
--mp.numberChoices = 6
--mp.chcFun = [[\chcLSixN]]

socOrders = { "A, B, C", "A, C, B", "B, A, C", "B, C, A", "C, A, B", "C, B, A" };

votingCalcPRC = PGMLproblem:new(
   [[ Three candidates, Abner, Barbara, and Chris, are running for mayor, 
   and the voters have the following profile.
   
   [`` [$LaTeXmacros]  \voteProfileABC{@abc}{@acb}{@bac}{@bca}{@cab}{@cba} ``]
     
     Determine the social choice ordering under the @system
     system.  ]],
  function( self, q )
      q = q or math.random( 4 )
      local systemLst = { "Plurality", "Hare", "Condorcet", "Borda Count"}
      system = systemLst[ q ]
      local at, bt, ct = distinctSummands( 3, 100 )
      while math.min( at, bt, ct, 100 - at, 100 - bt, 100 - ct ) < 15 do
	 at, bt, ct = distinctSummands( 3, 100 )
      end
      abc = math.random( at - 1 )
      acb = at - abc
      bac = math.random( bt - 1 )
      bca = bt - bac
      cab = math.random( ct - 1 )
      cba = ct - cab
      local ctab = condorcetCrossTab( abc, acb, bac, bca, cab, cba )
      local anslst = { plurality( abc, acb, bac, bca, cab, cba ),
		       runoff( abc, acb, bac, bca, cab, cba ),
		       parseCrossTab( ctab ),
		       borda( abc, acb, bac, bca, cab, cba )  }
      return { anslst[ q ], unpack( socOrders ) }
   end,
   [[\chcLSixN]]
)

function getVotingCalcPRC()
   return votingCalcPRC
end

function plurality( abc, acb, bac, bca, cab, cba )
   local profile = makeProfileTab( abc, acb, bac, bca, cab, cba )
   local order = {1,2,3}
   table.sort( order,
	       function (x,y)
		  return ( profile[x][1] > profile[y][1] ) or ( profile[x][1] == profile[y][1] and x < y )
	       end )
   return orderToString( order )
end 


function runoff( abc, acb, bac, bca, cab, cba )
   local profile = makeProfileTab( abc, acb, bac, bca, cab, cba )
   local order = {1,2,3}
   table.sort( order,
	       function (x,y)
		  return ( profile[x][1] > profile[y][1] ) or ( profile[x][1] == profile[y][1] and x < y )
	       end )
   local t1, t2 = profile[ order[1] ][1], profile[ order[2] ][1]
   t1 = t1 + profile[ order[ 3 ] ][2][ order[ 1 ] ]
   t2 = t2 + profile[ order[ 3 ] ][2][ order[ 2 ] ]
   local winner = 1
   if t1 < t2 then winner = 2 end
   if winner == 2 then
      order[1], order[2] = order[2], order[1]
   end
   return orderToString( order ) 
end 



function makeProfileTab( abc, acb, bac, bca, cab, cba )
   local at = abc + acb
   local bt = bac + bca
   local ct = cab + cba
   local res = { { at, { 0, abc, acb } },
		 { bt, { bac, 0, bca } },
		 { ct, { cab, cba, 0 } } }
   return res
end

function tableToProfile( tab )
   return tab[1][2][2], tab[1][2][3], tab[2][2][1], tab[2][2][3], tab[3][2][1], tab[3][2][2]
end 

function oneOnOne( profile, c1, c2 )
   local c3 = 6 - c1 - c2
   local t1, t2 = profile[ c1 ][1], profile[ c2 ][1]
   t1 = t1 + profile[ c3 ][2][ c1 ]
   t2 = t2 + profile[ c3 ][2][ c2 ]
   return ( t1 > t2 ) or ( t1 == t2 and c1 < c2 ), t1 == t2
end 


function condorcetCrossTab( abc, acb, bac, bca, cab, cba )
   local profile = makeProfileTab( abc, acb, bac, bca, cab, cba )
   local crossTab = matrix.zero( 3,3 )
   for i = 1, 3 do
      for j = 1, 3 do
	 if i ~= j then
	    local iwins, tie = oneOnOne( profile, i, j )
	    local entry
	    if iwins then 
	       entry = 1
	    -- elseif tie then
	    --    entry = 0
	    else
	       entry = -1
	    end
	    crossTab[i][j] = entry
	 end
      end
   end
   return crossTab
end 

function parseCrossTab( tab )
   local one = matrix.splitVector( vector.new({1,1,1}), 1 )
   local scores = matrix.mul( tab, one )
   local order = {1,2,3}
   table.sort( order,
	       function (x,y)
		  return ( scores[x][1] > scores[y][1] ) or ( scores[x][1] == scores[y][1] and x < y )
	       end )
   return orderToString( order )
end 

function agenda( aglst, abc, acb, bac, bca, cab, cba )
   local profile = makeProfileTab( abc, acb, bac, bca, cab, cba )
   local order = {}
   local r1
   local w1, t12 = oneOnOne( profile, aglst[1], aglst[2] )
   if w1 then
      r1, order[3] = aglst[1], aglst[2]
   else 
      r1, order[3] = aglst[2], aglst[1]
   end
   local wr1, tr13 = oneOnOne( profile, r1, aglst[3] )
   if wr1 then
      order[1], order[2] = r1, aglst[3]
   else
      order[1], order[2] = aglst[3], r1
   end 
   return orderToString( order )  
end 

function orderToString( ord )
   local res = map( ord, numToUpper )
   res = table.concat( res, ',' )
   return res   
end 

function borda( abc, acb, bac, bca, cab, cba, ptlst )
   ptlst = ptlst or {3,2,1}
   local profileV = matrix.splitVector( vector.new({ abc, acb, bac, bca, cab, cba }), 1 ) 
   local scrM = matrix.new({ { ptlst[1],ptlst[1],ptlst[2],ptlst[3],ptlst[2],ptlst[3] },
			  { ptlst[2],ptlst[3],ptlst[1],ptlst[1],ptlst[3],ptlst[2] },
			  { ptlst[3],ptlst[2],ptlst[3],ptlst[2],ptlst[1],ptlst[1] } })   
   local scores = scrM:mul( profileV )
   local order = {1,2,3}
   table.sort( order,
		       function (x,y)
			  return ( scores[x][1] > scores[y][1] ) or ( scores[x][1] == scores[y][1] and x < y )
		       end )
   return orderToString( order )
end



fairnessViolations = PGMLproblem:new(
   [[ Three candidates [`A`], [`B`], and [`C`] are running for
office, and there is one block of voters, 
the @block block,
who all favor the ranking [`ABC`].
If the election were held today
under the @sys Voting System  the
   result would be the social ranking [` @or1 @or2 @or3 `].

Now suppose that some of the @block block of voters are thinking about
changing their preferred ranking to [` @np1 @np2 @np3 `].  
If the vote were held under the @sys system with _only_ those
changes in the voters\' profile, then the resulting social ranking
would be [` @nr1 @nr2 @nr3 `].

Based on only these two examples, does the @sys system
necessarily violate Monotonicity, Independence of Irrelevant
Alternatives, both, or neither?
Give your answer as "Mono", "IIA", "Both", or "Neither".
]],
   function( self, blockname, sysname )
      block = blockname
      sys = sysname
      local oldorder = {false,false,false,false,false}
      local neworder = {false,false,false,false,false}
      local newprof = {1,2,3}
      local rnd1 = math.random(0,1)
      local posa = 3 - 2 * rnd1
      local posx, posy = 1 + rnd1, 2 + rnd1
      newprof[ posx ], newprof[ posy ] = newprof[ posy ], newprof[ posx ] 
      np1, np2, np3 = numToUpper(newprof[1]), numToUpper(newprof[2]), numToUpper(newprof[3]) 
      local mono, iia = randBool(), randBool()
      local ansstr = ''
      if not mono then
	 ansstr = 'Mono'
      end
      if not iia then
	 ansstr = ansstr .. 'IIA'
      end
      if ansstr == '' then
	 ansstr = 'Neither'
      end
      if ansstr == 'MonoIIA' then
	 ansstr = 'Both'
      end

      if not mono then
	 oldorder[2], oldorder[4] = newprof[ posx ], newprof[ posy ]
	 neworder[2], neworder[4] = posx, posy
	 if iia then
	    local place = 1 + 4 * math.random(0,1)
	    oldorder[ place ], neworder[ place ] = posa, posa
	 else
	    local place1, place2 = 1, 1
	    while ( place1 == 1 and place2 == 1 ) or (place1 == 5 and place2 == 5) do
	       place1, place2 = 1 + 2 * math.random(0,2), 1 + 2 * math.random(0,2)
	    end
	    oldorder[ place1 ], neworder[ place2 ] = posa, posa
	 end
      else
	 local switch, alpha = randBool(), randBool()
	 if switch then
	    oldorder[2], oldorder[4] = posx, posy
	    neworder[2], neworder[4] = newprof[ posx ], newprof[ posy ]
	 else
	    if alpha then
	       oldorder[2], oldorder[4] = posx, posy
	       neworder[2], neworder[4] = posx, posy
	    else
	       oldorder[2], oldorder[4] = posy, posx
	       neworder[2], neworder[4] = posy, posx
	    end
	 end
	 if iia then
	    if switch then
	       local place = 1 + 4 * math.random(0,1)
	       oldorder[ place ], neworder[ place ] = posa, posa
	    else
	       local place = 1 + 2 * math.random(0,2)
	       oldorder[ place ], neworder[ place ] = posa, posa
	    end
	 else
	    if switch then
	       local place1, place2 = 1, 1
	       while ( place1 == 1 and place2 == 1 ) or (place1 == 5 and place2 == 5) do
		  place1, place2 = 1 + 2 * math.random(0,2), 1 + 2 * math.random(0,2)
	       end
	       oldorder[ place1 ], neworder[ place2 ] = posa, posa
	    else
	       local place1, place2
	       --while ( place1 == place2 ) do
		  --place1, place2 = 1 + 2 * math.random(0,2), 1 + 2 * math.random(0,2)
	       --end
	       --oldorder[ place1 ], neworder[ place2 ] = posa, posa
	       if alpha then
		  --print("alpha\n")
		  place1 = 3
		  place2 = 1 + 4 * math.random(0,1)
	       else
		  --print("nonalpha\n")
		  place2 = 3
		  place1 = 1 + 4 * math.random(0,1)
	       end
	       oldorder[ place1 ], neworder[ place2 ] = posa, posa
	    end
	 end
      end
      or1, or2, or3 =  unpack( map( pruneList( oldorder ), numToUpper ) )
      nr1, nr2, nr3 =  unpack( map( pruneList( neworder ), numToUpper ) )
      return { ansstr, 'Mono', 'IIA', 'Both', 'Neither' }
   end,
   [[\chbl]]
)
--fairnessViolations.mcP = true
--fairnessViolations.numberChoices = 4

function getFairnessViolations()
   return fairnessViolations
end

votingCalcAgenda = PGMLproblem:new(
   [[ Three candidates, Althea, Barney, and Caspar, are running for D.A., 
   and the voters have the following profile.
  
[`` [$LaTeXmacros] \voteProfileABC{@abc}{@acb}{@bac}{@bca}{@cab}{@cba} ``]
  
Determine the social choice ordering under the Agenda 
system, with the specific agenda given below.

  [`` [$LaTeXmacros] \agendaC{@agX}{@agY}{@agZ}{}{}  ``]  ]],

   function( self )
      local at, bt, ct = distinctSummands( 3, 100 )
      while math.min( at, bt, ct, 100 - at, 100 - bt, 100 - ct ) < 15 do
	 at, bt, ct = distinctSummands( 3, 100 )
      end
      abc = math.random( at - 1 )
      acb = at - abc
      bac = math.random( bt - 1 )
      bca = bt - bac
      cab = math.random( ct - 1 )
      cba = ct - cab
      local ag1, ag2, ag3 = distinctRands( 3, 1, 3 )
      local cands = { "A", "B", "C" }
      agX, agY, agZ = cands[ ag1 ], cands[ ag2 ], cands[ ag3 ]

      return { agenda( { ag1, ag2, ag3}, abc, acb, bac, bca, cab, cba ),
	       unpack( socOrders ) }
   end,
   [[\chcLSixN]]
)

function getVotingCalcAgenda()
   return votingCalcAgenda
end

function strategicRunoff()
   local tmpl = [[Three candidates, %s, %s, and %s, 
   are running for school board president, and the voters have the
   following profile.  

   [` [$LaTeXmacros] \voteProfileABC{%d}{%d}{%d}{%d}{%d}{%d} `]
   Assuming the voting system is Plurality with a runoff, the winner
   of the election would be %s {\em if the voters voted sincerely.}
   Is there any way one of the other candidates might be able to
   ``steal'' the election through strategic voting?  Explain how.]]
   local cands = { 'Abercrombie', 'Bennett', 'Calhoun' }
   local w, l, s = distinctRands( 3, 1, 3 )
   local wname, lname, sname = cands[ w ], cands[ l ], cands[ s ]
   local wt, lt, st = 32, 31, 37
   local wlt = math.random( math.floor( wt/2 ) )
   local wst = wt - wlt
   local wsdiff = wt - st
   local lst = math.random( math.floor( (lt + wsdiff)/2 ) )
   local lwt = lt - lst
   local swt = math.random( math.floor( st/2 ) )
   local slt = st - swt
   local tab = {}
   tab[ w ], tab[ l ], tab[ s ] = { wt, {} }, { lt, {} }, { st, {} }
   tab[ w ][2][w], tab[ w ][2][l], tab[ w ][2][s] = 0, wlt, wst
   tab[ l ][2][w], tab[ l ][2][l], tab[ l ][2][s] = lwt, 0, lst
   tab[ s ][2][w], tab[ s ][2][l], tab[ s ][2][s] = swt, slt, 0 
   local abc, acb, bac, bca, cab, cba = tableToProfile( tab )
   appendAns( sname .. ' gives 2 top votes to ' .. lname )
   local sublst = listJoin( cands, 
			    { abc, acb, bac, bca, cab, cba },
			    { wname } )
   return mklatex( tmpl, sublst )
end 


function strategicAgenda()
   local tmpl = [[Three candidates, %s, %s, and %s, 
   are running for Student President, and the voters have the
   following profile.  

   [` [$LaTeXmacros] \voteProfileABC{%d}{%d}{%d}{%d}{%d}{%d} `]
   Assuming the voting system is the Agenda shown below, the winner
   of the election would be %s {\em if the voters voted sincerely.}
   Is there any way one of the other candidates might be able to
   ``steal'' the election through strategic voting?  Explain how.
   
[``  [$LaTeXmacros]   \agendaC{%s}{%s}{%s}{}{} ``]
     ]]
     local cands = { 'Argle', 'Bargle', 'Cargle' }
   local inits = { 'A', 'B', 'C' }
   local w, l, s = distinctRands( 3, 1, 3 )
   local wname, lname, sname = cands[ w ], cands[ l ], cands[ s ]
   local wt, lt, st = 34, 33, 33
   local wlt = math.random( math.floor( wt/2 ) - 1 )
   local wst = wt - wlt
   local lst = math.random( math.floor( lt/2 ) - 1 )
   local lwt = lt - lst
   local slt = math.random( math.floor( st/2 ) )
   local swt = st - slt
   local tab = {}
   tab[ w ], tab[ l ], tab[ s ] = { wt, {} }, { lt, {} }, { st, {} }
   tab[ w ][2][w], tab[ w ][2][l], tab[ w ][2][s] = 0, wlt, wst
   tab[ l ][2][w], tab[ l ][2][l], tab[ l ][2][s] = lwt, 0, lst
   tab[ s ][2][w], tab[ s ][2][l], tab[ s ][2][s] = swt, slt, 0 
   local abc, acb, bac, bca, cab, cba = tableToProfile( tab )
   appendAns( sname .. ' gives middle votes to ' .. lname )
   local sublst = listJoin( cands, 
			    { abc, acb, bac, bca, cab, cba },
			    { wname },
			    { inits[ w ], inits[ l ], inits[ s ] } )
   return mklatex( tmpl, sublst )
end
   






