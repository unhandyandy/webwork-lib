
vector = {}
--vector.__index = vector
vector.isMathType = true
vector.isvector = true

function vector.zero( len, con )
   con = con or 0
   local v = {}
   for i = 1, len do
      v[i] = con
   end
   return vector.new( v )
end

-- function vector.isvector( v )
--    return getmetatable( v ) == vector
-- end

function vector:tostring( parensQ )
   parensQ = parensQ or true   
   local res = ''
   if parensQ then res = '( ' end
   local selfstr = map( self, mathToStr )
   res = res .. table.concat( selfstr, ', ' )
   if parensQ then res = res .. ')' end
   return res
end

function vector:clone()
   local tmp = table.pack( table.unpack( self ) )
   return vector.new( tmp )
end

function vector.unm(a)
   local res = a:clone()
   for i = 1, #a do
      res[i] = -res[i]
   end
   return res
end

function vector.add(a,b)
   assert(a.isvector and b.isvector, "Add: wrong argument types (<vector> expected)")
   assert( #a == #b, "Add: wrong argument lengths (same dim expected)")
   local sum = {}
   for i = 1, #a do
      sum[i] = a[i] + b[i]
   end
   return vector.new( sum )
end


function vector.sub(a,b)
   assert( a.isvector and b.isvector, "Add: wrong argument types (<vector> expected)")
   assert( #a == #b, "Add: wrong argument lengths (same dim expected)")
   local dif = {}
   for i = 1, #a do
      dif[i] = a[i] - b[i]
   end
   return vector.new( dif )
end

function vector.scalarMult( s, v )
   --io.write("Scalar mult...")
   local res = {}
   for i = 1, #v do
      table.insert( res, s * v[i] )
   end
   return vector.new( res )
end


function dotProd( v1, v2 )
   assert( #v1 == #v2, "Add: wrong argument lengths (same dim expected)")
   local res = 0
   for i = 1, #v1 do
      res = res + v1[i] * v2[i]
   end
   return res
end


function vector.mul(a,b)
   local tanQ, tbnQ = type(a)=='number' or frc.isfraction(a), type(b)=='number' or frc.isfraction(b)
   if tanQ and b.isvector then
      return scalarMult( a, b )
   elseif tbnQ and a.isvector then
      return scalarMult( b, a )
   else
      assert(a.isvector and b.isvector, "Mul: wrong argument types (<vector> or <number> expected)")
      return dotProd( a, b )
   end
end

function vector.div(a,b)
        assert(a.isvector and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
        return scalarMult( 1 / b , a )
end

function vector.eq(a,b)
   if #a ~= #b then return false end
   local res = true
   for i = 1, #a do
      res = res and ( a[i] == b[i] )
   end
   return res
end

function vector:len()
   local sqs = 0
   for _, x in ipairs( self ) do
      sqs = sqs + x * x
   end
   return math.sqrt( sqs )
end

function vector.random( l, max, sgnF )
   if sgnF == nil then sgnF = true end
   local lst = {}
   for i = 1, l do
      if sgnF then
	 table.insert( lst, math.random( -max, max ) )
      else 
	 table.insert( lst, math.random( 0, max ) )
      end 
   end
   return vector.new( lst )
end

function vector.randomNonNeg( l, max )
   local lst = {}
   for i = 1, l do
      table.insert( lst, math.random( max ) )
   end
   return vector.new( lst )
end

function vector:tolatex()
   local ltx = map( self, mathToLatex )
   ltx = table.concat( ltx, [[\ \ ]] )
   --return [[ (\,]] .. (self:__tostring()):sub(2,-2) .. [[\,)]]
   return [[ [\ ]] .. ltx .. [[\ ] ]]
end


-- -- return setmetatable({new = new, isvector = isvector, zero = zero,
-- -- 		     random = random, randomNonNeg = randomNonNeg },
-- -- {__call = function(_, ...) return new(...) end})

function vector.new( lst )
   local newvec = copy( vector )
   for k,v in ipairs(lst) do
      newvec[k] = v
   end
   return newvec
end

return vector
