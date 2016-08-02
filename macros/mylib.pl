
-- set module path
--package.path = '/home/dabrowsa/.lib/lua/5.2/?.lua'

--plp = require( 'pl.pretty' )

--dofile( '/home/dabrowsa/.lib/lua/5.2/save.lua' )

--ef = require('enumForm')
frc = require('fraction')
vec = require('vector')
st = require('sets')
mat = require('matrix')
line, hp  = require('line')()

--alphabet = {'a','b','c','d','e','f','g','h'}
alphabet = "abcdefgh"
uppers = "ABCDEFGH"

romanNums = { [1] = 'i', [2] = 'ii', [3] = 'iii', [4] = 'iv',
	      [5] = 'v', [6] = 'vi', [7] = 'vii', [8] = 'viii' }

switchNumLet = true

function mathTypeQ( x )
   return mat.ismatrix( x ) or frc.isfraction( x ) or
      vec.isvector( x ) or st.isset( x ) or line.isline( x ) or
      hp.ishalfplane( x )
end

function perm( n, r, res )
   res = res or 1
   if r == 0 then return res end
   return perm( n - 1, r - 1, n * res )
end

function comb( n, r, numer, denom )
   if r > n then return 0 end
   numer = numer or 1
   denom = denom or 1
   if r == 0 then return numer / denom end
   return comb( n - 1, r - 1, numer * n, denom * r )
end

function writeAnswers( fnm )
--   io.write( fnm .. ', ' .. table.concat( answers, ', ') .. '\n' )
   local header = [[{\bf Version %s} \\ \\ \\ ]]
   io.write( header:format( fnm ) .. [[\begin{multicols}{2} ]] .. answers:tolatex() .. [[ \end{multicols} ]] .. '\n' )
end

function letToNum( ltt )
   local pos, _ = alphabet:find( ltt )
   return pos
end

function numToLet( num )
   return alphabet:sub( num, num )
end

function numToUpper( num )
   if type( num ) == 'number' then
      return uppers:sub( num, num )
   else
      return num
   end
end

function numToRom( num )
   return romanNums[ num ]
end

function testprint ()
   return "OK"
end


function prL( lst, ... )
   if ... then io.write( ... ) end
   local loc = copy( lst )
   local nxt = table.remove( loc, 1 )
   local t = type( nxt )
   if t == 'string' or t == 'number' then
      print( nxt )
   elseif t == 'table' then
      prL( nxt, '\t', ... )
   end
   if #loc ~= 0 then prL( loc, ... ) end
end

function printTable( tab )
   for k,v in pairs( tab ) do
      print( ('%s = %s'):format( k, v ) )
   end 
end

function randElem ( lst )
   return lst[ math.random( #lst ) ]
end

--Destructive !!
function listConcat ( lst, ... )
   local arg = table.pack(...)
   --print( "arg.n = ", arg.n )
   if arg.n == 0 then return  end
   listConcatAux( lst, table.remove( arg, 1 ) )
   --arg.n = nil
   --print( "arg = " )
   --plp.dump( arg )
   listConcat( lst, table.unpack( arg ) )
end
   
function listConcatAux ( l1, l2 )
   --print( "Aux called" )
   local len = #l1
   for i, x in ipairs( l2 ) do
      l1[ len + i ] = x
   end
end

function listJoin( ... )
   local res = {}
   listConcat( res, ... )
   return res
end

-- Destructive!
function randPerm ( lst, start, ans )
   start = start or {}
   ans = ans or 0
   if #lst == 0 then return start  end
   local pos = math.random( #lst )
   if ( pos == 1 and ans == 0 ) then 
      ans = #start + 1 
      prans = ans
      if switchNumLet then 
	 --prans = numToLet( ans ) 
	 prans = numToUpper( ans )
      else 
	 prans = numToRom( ans ) 
      end 
      appendAns( prans )
   end
   table.insert( start, table.remove( lst, pos ) )
   return randPerm( lst, start, ans )
end

-- Destructive!
function rndPrm( lst, start )
   start = start or {}
   if #lst == 0 then return start end
   local pos = math.random( #lst )
   table.insert( start, table.remove( lst, pos ) )
   return rndPrm( lst, start )
end


function appendAns( ans )
   --table.insert( answers, ans )
   answers:add( ans )
end

function applyLatexF ( fun, ... )
   local res = "\\" .. fun
   local arg = table.pack(...)
   for i, v in ipairs(arg) do
      res = res .. string.format("{%s}", v)
   end
   return res
end

function chsprm ( a, b, ans, ver )
   local c, d, e
   c = a + b
   d = b + c
   e = c + d
   --return string.format("\\chsprmaux{%d}{%d}{%d}{%d}{%d}", a, b, c, d, e)
   if ans then appendAns( numToUpper( prmCh( ans, ver ) ) ) end
   return applyLatexF( "chsprmaux", a, b, c, d, e )
end

function prmCh( n, v )
   res = n - 1
   if     v == 'x' then res = 7 - res 
   elseif v == 'y' then res = (4 + res) % 8
   elseif v == 'z' then 
      if res % 2 == 0 then
	 res = res + 1
      else
	 res = res - 1
      end
      if     res > 5 then res = res - 4 
      elseif res > 1 then res = res + 2
      end
   end
   res = res + 1
   return res
end

function createBlankList( len, val )
   local res = {}
   val = val or 1
   for i = 1, len do
      res[ i ] = val
   end
   return res
end

function blankListToFormatStr( lst )
   local frmstr = ''
   for i = 1, #lst do
      frmstr = frmstr .. ',' .. i
      local jmax = math.max( lst[i], 1 )
      for j = 2, jmax do
	 frmstr = frmstr .. ','
      end
   end
   frmstr = frmstr .. '\n'
   for i = 1, #lst do
      if lst[i] < 2 then
	 frmstr = frmstr .. ','
      else 
	 local jmax = math.max( lst[i], 1 )
	 for j = 1, jmax do
	    frmstr = frmstr .. ',' .. numToLet(j)
	 end
      end
   end
   frmstr = frmstr .. '\n'
   return frmstr
end
	 

function qsize( lst )
   local res = 0
   for _, v in ipairs( lst ) do
      res = res + v
   end
   return res
end

function convertQtab( lst )
   local res = {}
   local line = [[\underline{\hsp{4}}]]
   for i, v in ipairs( lst ) do
      if v == 1 then
	 table.insert( res, string.format( "%d.\\\'%s ", i, line ) )
      elseif v > 1 then
	 table.insert( res, string.format( "%d.\\\'%s. %s", 
					   i, numToLet( 1 ), line))
	 for j = 2, v do
	    table.insert( res, string.format( "\\\'%s. %s", 
					      numToLet( j ), line))
	 end
      else
	 table.insert( res, string.format( "%d.\\\'", i ) )
      end
   end
   return res
end

function writeTabExpr( lst, collen, colsep )
   local res = createBlankList( collen, '' )
   local space = string.format( [[\hsp{%s}]], colsep )
   for i, v in ipairs( lst ) do
      local row = ((i - 1) % collen ) + 1
      local tabsgn = [[\>]]
      if row == 1 then
	 tabsgn = [[\=]]
      end
      local sp = space
      if row == i then
	 sp = ''
      end
      res[ row ] = res[ row ] .. sp .. tabsgn .. v
   end
   return res
end

function drawBlanks( tab, collen )
   local len = qsize( tab )
   collen = collen or 10
   local colwid = 18
   local numcol = math.floor( len / collen )
   local excess = len % collen
   if excess > 0 then numcol = numcol + 1 end
   local texstr = [[
\begin{tabbing}
\hsp{2} ]]
   
   local colsep = 0
   if numcol > 1 then
      colsep = colwid / ( numcol - 1 )
   end
   print( 'colsep = ' .. colsep )
   local longtab = convertQtab( tab )
   local tabexpr = writeTabExpr( longtab, collen, colsep )
   texstr = texstr .. '\n' .. table.concat( tabexpr, [[\\ \\]]..'\n'
					  )..'\n'..[[\end{tabbing}]]
   return texstr
end

function randSign()
   if math.random() < .5 then
      return 1
   else
      return -1
   end
end

function csvElem( s )
   return [["]]..s..[["]]
end

function latexEncl( x )
   return [[\(]] .. x:tolatex() .. [[\)]]
end

function map( t, f )
   if type(t)=="string" then print( "\n t: " .. t .. "\n" ) end 
   local res = {}
   for k in pairs( t ) do
      res[ k ] = f( t[ k ] )
   end
   return res
end

function randBool()
   local res = true
   if math.random() < .5 then res = false end
   return res
end

function pruneList( lst )
   local res = {}
   for _, v in ipairs( lst ) do
      --print('v = ' .. v )
      if v then
	 table.insert( res, v )
      end
   end
   return res
end

-- function gcf( x, y )
--    if x > y then return gcf( y, x ) end
--    if x == 0 then return y end
--    return gcf( y % x, x )
-- end

function removeOneCoeffs( str, vars )
   vars = vars or 'wxyz'
   local srchstr = '1([' .. vars .. '])'
   local res, _ = string.gsub( str, srchstr, function(v) return v end ) 
   return res
end

function integerSeq( a, b, del )
   del = del or 1
   local res = {}
   for i = a, b, del do
      table.insert( res, i )
   end
   return res
end

function distinctRands( n, a, b )
   local poss = integerSeq( a, b )
   local res = {}
   for i = 1, n do
      table.insert( res, distinctRandsAux( poss ) )
   end
   return table.unpack( res )
end

-- returns new rand and deletes that from lst
-- Destructive!
function distinctRandsAux( lst )
   local pos = math.random( #lst )
   local rnd = table.remove( lst, pos )
   return rnd
end


function distinctElems( n, lst, res )
   res = res or {}
   if #lst == 0 or n == 0 then return res end
   local cur = table.remove( lst, 1 )
   if listHas( res, cur ) then
      return distinctElems( n, lst, res )
   else
      table.insert( res, cur )
      return distinctElems( n - 1, lst, res )
   end
end

function listHas( lst, el )
   local res = false
   for _, v in ipairs( lst ) do
      if v == el then
	 res = true
	 break
      end
   end
   return res
end 

function bernoulli( n, p, k )
   return comb( n, k ) * p^k * (1-p)^(n-k)
end

function bernCum( n, p, a, b )
   local res = 0
   for i = a, b do
      res = res + bernoulli( n, p, i )
   end
   return res
end 

local function listSum( lst )
   local res = 0
   for _, v in ipairs( lst ) do
      res = res + v
   end
   return res
end

--shallow copy
function copy( tab )
   local res = {}
   for k,v in pairs( tab ) do
      res[ k ] = v
   end
   return res
end

   

function treeSize( max, avail, vallst )
   if max > 0 then
      local res = 0
      for newcoin = 1,3 do
	 if avail[ newcoin ] > 0 then
	    local newavail = copy( avail )
	    newavail[ newcoin ] = newavail[ newcoin ] - 1
	    local newval = vallst[ newcoin ]
	    res = res + treeSize( max - newval, newavail, vallst )
	 end
      end
      return res
   else
      return 1
   end
end

function mklatex( tmpl, sub )
   return string.format( tmpl, table.unpack( sub ) )
end


function randSummands( n, sum )
   local p = math.floor( sum / n + 0.5 )
   local diff = sum - n * p
   local pd = p + math.floor( diff / n + 0.5 )
   local res = {}
   for i = 1, n - 1 do
      local plus = randSign() * math.random( 0, pd )
      diff = diff - plus
      table.insert( res, p + plus )
   end
   if diff >= 0 then
      table.insert( res, p + diff )
      return table.unpack( res )
   else
      return randSummands( n, sum )
   end
end


function distinctSummands( n, sum )
   local p = math.floor( sum / n + 0.5 )
   local lst = table.pack( distinctRands( n, 0, 2 * p ) )
   local diff = sum - listSum( lst )
   local sign = 1
   if diff < 0 then 
      sign = -1
      diff = - diff
   end
   while diff > 0 do
      local pos = math.random( n )
      local new = lst[ pos ] + sign
      if new >= 0 and not listHas( lst, new ) then
	 lst[ pos ] = new
	 diff = diff - 1
      end
   end
   return table.unpack( lst )
end


function flatten( tab )
   if type( tab ) == 'table' and not mathTypeQ( tab ) then
      return listJoin( table.unpack( map( tab, flatten ) ) )
   else
      return { tab }
   end
end

function flatten1( tab )
   return listJoin( table.unpack( tab ) )
end

function coeffToStr( x )
   if math.abs( x ) ~= 1 then
      local res = '%s'
      return res:format( x )
   elseif x < 0 then
      return '-'
   else 
      return ''
   end
end 

function monoToStr( c, x )
   if c == '1' or c == 1 then
      return x
   elseif c == '-1' or c == -1 then 
      return '-' .. x
   elseif c == '0' or c == '-0' or c == 0 then
      return ''
   else
      return c .. x
   end 
end 

function removeLeadingPlus( str )
   local res = str
   while res:sub( 1, 1 ) == ' ' or res:sub( 1, 1 ) == '+' do
      res = res:sub(2)
   end 
   return res
end
function removeTrailingPlus( str )
   local res = str
   while res:sub( -1, -1 ) == ' ' or res:sub( -1, -1 ) == '+' do
      res = res:sub(1,-2)
   end 
   return res
end

function polyToStr ( txt )
   if type( txt ) == "number" then
      return txt
   end 
   local pat = '([%-%.0-9]?%d*)(%a+)'
   local res = txt:gsub( pat, monoToStr )
   res = res:gsub( '%+%s*%-', '- ' )
   res = res:gsub( '%-%s*%-', '+ ' )
   local plss = '[%s%+]*%+[%s%+]*'
   local non = '([^%d%a%s%+%-])'
   res = res:gsub( non..plss, "%1" )
   res = res:gsub( plss..non, "%1" )
   res = removeLeadingPlus( res )
   res = removeTrailingPlus( res )
   if res:find( "^%s*$" ) then res = "0" end
   return res
end

function mathToStr(x)
   local t = type(x)
   if t == 'number' or t == 'string' then
      return x
   else
      return x:__tostring()
   end 
end

function mathToLatex(x)
   local t = type(x)
   if t == 'number' or t == 'string' then
      return x
   else
      return x:tolatex()
   end 
end

function getAnsTab( name )
   --print( '\n getAnsTab... \n' )
   local fnm = name .. '_answers_table.lua'
   local tab, err = table.load( fnm )
   if err then tab = {} end
   --print( '\n tab = ' .. table.concat( tab ) .. '\n' )
   return ef.drawBlanks( tab )
   --print( 'ansBlanks: ' .. ansBlanks )
end

function putAnsTab( name )
   local fnm = name .. '_answers_table.lua'
   table.save( answers.form, fnm )
end

function mkPlural( sing, plural )
   plural = plural or sing .. 's'
   local res = {}
   res.forms = { sing, plural }
   res.ch = function( self, n )
      if n == 1 then
	 return n ..' '.. self.forms[ 1 ]
      else 
	 return n ..' '.. self.forms[ 2 ]
      end
   end
   return res
end


-- -- Mark Edgar via lua-users.org
-- function replace_vars(str, vars)
--   -- Allow replace_vars{str, vars} syntax as well as replace_vars(str, {vars})
--   if not vars then
--     vars = str
--     str = vars[1]
--   end
--   return (string_gsub(str, "%$(%b%{%})",
--     function(whole,i)
--       return vars[i] or whole
--     end))
-- end


-- Rici Lake via lua-users.org
function string_interp( str, tab )
   return str:gsub( '(@[^%s%p@%%%}\\]*)', 
		    function(w) 
		       local arg = w:sub(2)
		       return tab[ arg ] or w 
		    end)
end
getmetatable("").__mod = string_interp


function two( x )
   return x, x
end


function listTake( tab, n )
   res = {}
   for i = 1,n do
      table.insert( res, tab[ i ] )
   end
   return res
end

function listDrop( tab, n )
   res = {}
   for i = n+1, #tab do
      table.insert( res, tab[ i ] )
   end
   return res
end

function listSub( lst, a, b )
   return listDrop( listTake( lst, b ), a - 1 )
end

function listReverse( lst )
   if #lst == 0 then return {} end
   local res = {}
   return listJoin( listReverse( listDrop( lst, 1 ) ),
		    listTake( lst, 1 ) )
end 

function numToSigns( n, dig, frm )
   dig = dig or - math.floor( - math.log( n ) / math.log( 2 ) )
   frm = frm or string.rep( 'd', dig )
   local res = { n }
   local next = n
   for i = 1, dig do
      local j = dig - i + 1
      local quo, rem = math.floor( next / 2 ), next % 2
      if rem == 0 then
	 if frm:sub( j, j ) == 'd' then
	    table.insert( res, 1 )
	 else
	    table.insert( res, true )
	 end 
      else 
	 if frm:sub( j, j ) == 'd' then
	    table.insert( res, -1 )
	 else
	    table.insert( res, false )
	 end 
      end 
      next = quo
   end 
   return listReverse( res )
end 

function sleep(n)
  os.execute("sleep " .. tonumber(n))
end

function signIter( d, frm )
   if type( d ) ~= 'number' then
      if frm == nil then
	 frm = d
	 d = #frm
      end 
   end 
   local i = -1
   local function res()
      i = i + 1
      if i < 2^d then 
	 return table.unpack( numToSigns( i, d, frm ) )
      end
   end 
   return res
end 

function signsToStr( ... )
   local lst = {...}
   lst = map( lst, function(x) 
		 if x > 0 then
		    return '+'
		 elseif x == 0 then
		    return '0'
		 else 
		    return '-'
		 end
		   end  )
   return table.concat( lst )
end

function ifset( c, x, y )
   if c then
      return x
   else 
      return y
   end 
end


function cartesianX( l1, l2 )
   local res = {}
   for i = 1,#l1 do
      table.insert( res, {} )
      for j = 1,#l2 do
	 table.insert( res[ i ], { l1[ i ], l2[ j ] } )
      end 
   end
   return res
end 

function getOrdinal( n )
   local ords = { 'first', 'second', 'third', 'fourth', 'fifth', 
		  'sixth', 'seventh', 'eighth', 'ninth', 'tenth' }
   return ords[ n ]
end 

function getCardinal( n )
   local ords = { 'one', 'two', 'three', 'four', 'five', 
		  'six', 'seven', 'eight', 'nine', 'ten' }
   return ords[ n ]
end 

function mkRandSeq( l, fun, ... )
   local res = {}
   for i = 1,l do
      table.insert( res, fun(...) )
   end 
   return table.unpack( res )
end 

function mkSeqFrFun( l, fun, ... )
   local res = {}
   for i = 1,l do
      table.insert( res, fun( i, ... ) )
   end 
   return table.unpack( res )
end 

function integerInBase( n, b, d )
   d = d or - math.floor( - math.log( n ) / math.log( b ) )
   local res = {  }
   local next = n
   for i = 1, d do
      local quo, rem = math.floor( next / b ), next % b
      table.insert( res, rem )
      next = quo
   end 
   return table.unpack( listReverse( res ) )
end 

function simplifyMatrix( mat )
   res = mat:clone()
   r, c = mat:getDim()
   for i = 1, r do
      for j = 1, c do
	 res[i][j] = polyToStr( res[i][j] )
      end
   end 
   return res
end 

