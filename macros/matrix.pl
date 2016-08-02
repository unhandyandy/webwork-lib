
local vec = require('vector')
local frc = require('fraction')

local matrix = {}
matrix.__index = matrix

local function checkMatrix( lst )
   local check = true
   for i = 2 , #lst do
      check = check and #lst[1] == #lst[i]
   end
   return check
end



function matrix:getDim()
   return table.unpack( self.dim )
end

function matrix:setDim( r, c )
   self.dim = { r, c }
end



function matrix.zero( r, c )
   local m = {}
   for i = 1, r do
      m[i] = vec.zero( c )
   end
   return matrix.new( m )
end

function matrix.ismatrix( m )
   return getmetatable( m ) == matrix and checkMatrix( m )
end

function matrix:__tostring( parensQ )
   if parensQ == nil then parensQ = true end
   local endline = '\n'
   if not parensQ then endline = [[\\ ]] .. endline end
   local str = ''
   for _, v in ipairs( self ) do
      str = str .. v:__tostring( parensQ ) .. endline
   end
   return str
end

function matrix:clone()
   res = {}
   for _, v in ipairs( self ) do
      table.insert( res, v:clone() )
   end
   return matrix.new( res )
end

function matrix.__unm(a)
   local res = a:clone()
   for i = 1, #res do
      res[i] = -res[i]
   end
   return res
end

function matrix.__add(a,b)
   assert(matrix.ismatrix(a) and matrix.ismatrix(b), "Add: wrong argument types (<matrix> expected)")
   assert( a.dim == b.dim, "Add: wrong argument lengths (same dim expected)")
   local sum = vec.zero( a.dim[2] )
   for i = 1, a.dim[1] do
      sum[i] = a[i] + b[i]
   end
   return matrix.new( sum )
end
function matrix.__sub(a,b)
   assert(matrix.ismatrix(a) and matrix.ismatrix(b), "Add: wrong argument types (<matrix> expected)")
   assert( a.dim == b.dim, "Add: wrong argument lengths (same dim expected)")
   local sum = vec.zero( a.dim[2] )
   for i = 1, a.dim[1] do
      sum[i] = a[i] - b[i]
   end
   return matrix.new( sum )
end


local function scalarMult( s, m )
   local res = {}
   for i = 1, m.dim[1] do
      table.insert( res, s * m[i] )
   end
   return matrix.new( res )
end

local function matProd( m1, m2 )
   assert( m1.dim[2] == m2.dim[1], "Add: wrong argument lengths (same dim expected)")
   local res = {}
   for i = 1, m1.dim[1] do
      local newrow = vec.zero( m2.dim[2] )
      for j = 1, m1.dim[2] do
	 newrow = newrow + m1[i][j] * m2[j]
      end
      table.insert( res, newrow )
   end
   return matrix.new( res )
end



function matrix.__mul(a,b)
   if ( type(a) == "number" or frc.isfraction(a) ) and matrix.ismatrix(b) then
      return scalarMult( a, b )
   elseif ( type(b) == "number" or frc.isfraction(b) ) and matrix.ismatrix(a) then
      return scalarMult( b, a )
   else
      assert(matrix.ismatrix(a) and matrix.ismatrix(b), "Mul: wrong argument types (<matrix> or <number> expected)")
      return matProd( a, b )
   end
end

function matrix.__div(a,b)
        assert(matrix.ismatrix(a) and type(b) == "number", "wrong argument types (expected <matrix> / <number>)")
        return scalarMult( 1 / b , a )
end

function matrix.__eq(a,b)
   if a.dim ~= b.dim then return false end
   local res = true
   for i = 1, a.dim[1] do
      res = res and ( a[i] == b[i] )
   end
   return res
end


function matrix.random( r, c, max, sgnF )
   --print( '\n sgnF = ' .. ifset(sgnF,'true','false') .. '\n' )
   local lst = {}
   for i = 1, r do
      table.insert( lst, vec.random( c, max, sgnF ) )
   end
   return matrix.new( lst )
end

function matrix.newDiag( lst )
   local res = matrix.zero( #lst, #lst )
   for i = 1, #lst do
      res[i][i] = lst[i]
   end
   return res
end

function matrix.splitVector( v, c )
   local r = math.floor( #v / c )
   local tab = {}
   for i = 1, r do
      table.insert( tab, {} )
      for j = 1, c do
	 table.insert( tab[i], v[ ( i - 1 ) * c + j ] )
      end 
   end 
   return matrix.new( tab )
end 

function matrix.identity( d )
   local diag = {}
   for i = 1, d do
      table.insert( diag, 1 )
   end
   return matrix.newDiag( diag )
end 

function matrix.__pow( m, p, tot )
   tot = tot or matrix.identity( m.dim[1] )
   if p == 0 then
      return tot
   elseif p % 2 == 0 then
      return matrix.__pow( m * m, p / 2, tot )
   else 
      return matrix.__pow( m * m, (p - 1) / 2, m * tot )
   end
end 

function matrix.transpose( m )
   local c, r = m:getDim()
   local res = matrix.zero( r, c )
   for i = 1,r do
      for j = 1,c do
	 res[i][j] = m[j][i]
      end
   end
   return matrix.new( res )
end


function matrix:removeRow( r )
   local res = self:clone()
   table.remove( res, r )
   return matrix.new( res )
end

function matrix:removeCol( c )
   local res = matrix.transpose( self )
   res = res:removeRow( c )
   return matrix.transpose( res )
end

function matrix:minor( r, c )
   local res = self:removeRow( r )
   res = res:removeCol( c )
   return res
end

function matrix:determinant()
   assert( self.dim[1] == self.dim[2], 'Not a square matrix!' )
   local len = self.dim[1]
   if len == 1 then
      return self[1][1]
   end
   local col1 = matrix.transpose( self )[1]
   for i = 2, len, 2 do
      col1[i] = - col1[i]
   end
   local mins = {}
   for i = 1, len do
      local m = self:minor( i, 1 )
      table.insert( mins, m:determinant() )
   end
   mins = vec.new( mins )
   return col1 * mins
end

function matrix:inverse()
   --print( '\n inverting...' )
   local det = self:determinant()
   local r, c = self:getDim()
   assert( det ~= 0 and r == c, "Matrix is not invertible!" )
   local res = matrix.zero(r,r)
   for i = 1,r do
      for j = 1,r do
	 res[j][i] = (-1)^(i+j) * self:minor(i,j):determinant()
      end 
   end 
   --print( '...done \n' )
   return frc.one() / det * res
end 

function matrix:tolatex( augmented )
   if augmented == nil then augmented = false end
   local tmpl = [[\begin{bmat}{%s}
%s
\end{bmat} ]]
   local r, c = self:getDim()
   local cols = string.rep( 'c', c - 1 )
   if augmented then cols = cols .. '|' end
   cols = cols .. 'c'
   --cols = table.concat( cols )
   --local matstr = self:__tostring( false )
   local matstr = {}
   for i = 1, r do
      local selfstr = map( self[i], mathToLatex )
      table.insert( matstr, table.concat( selfstr, ' & ' ) )
   end 
   matstr = table.concat( matstr, [[ \\ ]] )
   return string.format( tmpl, cols, matstr )
end

function matrix:hasZeros()
   local r,c = self:getDim()
   for i = 1,r do
      for j = 1,c do
	 if self[ i ][ j ] == 0 * one then
	    return true
	 end 
      end 
   end 
   return false
end

function matrix:isregular( n )
   local r = self:getDim()
   n = n or 0
   if self:hasZeros() then
      if n > r  then
	 return false
      else
	 return (self*self):isregular( n + 1 )
      end 
   else 
      return true
   end 
end

function matrix:tonumbers()
   local res = self:clone()
   local r, c = self:getDim()
   for i = 1,r do
      for j = 1,c do
	 if frc.isfraction( self[ i ][ j ] ) then
	    res[ i ][ j ] = self[ i ][ j ]:tonumber()
	 end end end
   return res
end 



-- Last function!!

function matrix.new( lst )
   --print('\n lst length = '..#lst)
   assert( checkMatrix( lst ), "Lengths of vectors do not match." )
   local res = {}
   for _, v in ipairs( lst ) do
      table.insert( res, vec.new( v ) )
   end
   res.dim = vec.new( { #lst, #lst[1] } )
   return setmetatable( res, matrix)
end


return matrix


-- return setmetatable({ new = new, ismatrix = ismatrix, zero = zero, random = random, newDiag = newDiag, splitVector = splitVector, identity = identity },
-- {__call = function(_, ...) return new(...) end})
