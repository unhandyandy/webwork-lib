
local fraction = {}
fraction.__index = fraction

function gcf( x, y )
   if x > y then return gcf( y, x ) end
   if x == 0 then return y end
   return gcf( y % x, x )
end

local function checkFraction( fr )
   local check =  fr.denom ~= 0 and fr.numer == math.floor( fr.numer ) and fr.denom == math.floor( fr.denom )
   assert( check, 'Fraction check failed!' )
   return check
end

function fraction.one()
   return fraction.new( 1, 1 )
end

function fraction.isfraction( m )
   return getmetatable( m ) == fraction 
end

function fraction:tonumber()
   return self.sign * self.numer / self.denom
end

function fraction:__tostring()
   local sgn = coeffToStr( self.sign )
   if self.numer == 0 then 
      return '0' 
   elseif self.denom == 1 then
      return string.format( '%s%d', sgn, self.numer )
   else
      --print( '\n numer = ' .. self.numer .. '\n' )
      return string.format( '%s%d/%d', sgn, self.numer, self.denom )
   end
end

function fraction:clone()
   return fraction.new( self.sign * self.numer, self.denom )
end

function fraction.__unm( fr )
   local res = fr:clone()
   res.sign = -res.sign
   return res
end

function fraction.__lt ( a, b )
   if fraction.isfraction( a ) then
      if fraction.isfraction( b ) then
	 return a:tonumber() < b:tonumber()
      else
	 return a:tonumber() < b
      end 
   else 
      return a < b:tonumber()
   end 
end

function fraction.__le ( a, b )
   if fraction.isfraction( a ) then
      if fraction.isfraction( b ) then
	 return a:tonumber() <= b:tonumber()
      else
	 return a:tonumber() <= b
      end 
   else 
      return a <= b:tonumber()
   end 
end


local function addFractions( f1, f2 )
   local newdenom = f1.denom * f2.denom
   local newnumer = f1.sign * f1.numer * f2.denom + f2.sign * f2.numer * f1.denom
   return fraction.new( newnumer, newdenom )
end

function fraction.__add( f1, f2 )
   if fraction.isfraction( f1 ) then
      if fraction.isfraction( f2 ) then
	 return addFractions( f1, f2 )
      else
	 local newfr = fraction.new( f2, 1 )
	 return addFractions( f1, newfr )
      end
   else 
      return fraction.__add( f2, f1 )
   end
end

function fraction.__sub( f1, f2 )
   return fraction.__add( f1, -f2 )
end

local function multFractions( f1, f2 )
   return fraction.new( f1.sign * f1.numer * f2.sign * f2.numer,
			f1.denom * f2.denom )
end

function fraction.__mul( f1, f2 )
   if fraction.isfraction( f1 ) then
      if fraction.isfraction( f2 ) then
	 return multFractions( f1, f2 )
      elseif type( f2 ) == 'number' then
	 local newfr = fraction.new( f2, 1 )
	 return multFractions( f1, newfr )
      end 
   end 
   return f2 * f1 
end

function fraction.invert( fr )
   if fraction.isfraction( fr ) then
      local res = fr:clone()
      assert( res.numer ~= 0, 'Not invertible!' )
      res.numer, res.denom = res.denom, res.numer
      return res
   else
      return fraction.new( 1, fr )
   end
end
 
function fraction.__div( f1, f2 )
   return fraction.__mul( f1, fraction.invert( f2 ) )
end

function fraction.__eq( f1, f2 )
   if not fraction.isfraction( f1 ) then
      if type( f1 ) == "number" then
	 return fraction.__eq( fraction.fromDecimal( f1 ), f2 )
      else
	 return false
      end
   elseif not fraction.isfraction( f2 ) then
      if type( f1 ) == "number" then
	 return fraction.__eq( f1, fraction.fromDecimal( f2 ) )
      else
	 return false
      end
   else
      return f1.sign * f1.numer * f2.denom == f2.sign * f2.numer * f1.denom
   end
end

function fraction.__pow( fr, p )
   local res = fr:clone()
   res.sign, res.numer, res.denom = res.sign ^ p, res.numer ^ p, res.denom ^ p
   return res
end

function fraction.fromDecimal( x )
   if x == math.floor( x ) then
      return frc.one() * x
   else 
      return fraction.fromDecimal( 10 * x ) / 10
   end
end


function fraction:tolatex()
   local sgn = coeffToStr( self.sign )
   --print( '\n sgn = ' .. sgn .. '\n' )
   if self.numer ~= 0 and self.denom ~= 1 then
      local tmpl = [[%s\sfrac{%s}{%s}]]
      return string.format( tmpl, sgn, self.numer, self.denom )
   else
      return self:__tostring()
   end
end

function fraction.random( an, bn )
   local a, b = an * fraction.one(), bn * fraction.one()
   local d = 2 * a.denom * b.denom / gcf( a.denom, b.denom )
   local l = a.numer * a.sign * d / a.denom
   local r = b.numer * b.sign * d / b.denom
   local n = math.random( l + 1, r - 1 )
   return fraction.new( n, d )
end


function fraction.new( n, d )
   local sign = 1
   if n * d < 0 then sign = -1 end
   local res = {}
   local numer, denom = math.floor( math.abs( n ) ), math.floor( math.abs( d ) )
   local cf = gcf( denom, numer )
   res.numer, res.denom = numer / cf, denom / cf
   res.sign = sign
   return setmetatable( res, fraction )
end

return fraction
