--*-lua-*-

PGMLproblem = {}
--PGMLproblem.mt = {__index = PGMLproblem}

PGMLproblem.mcP = false
PGMLproblem.template = [[What time is it?]]
--PGMLproblem.numberChoices = 8
PGMLproblem.chcFun = [[\chcSix]]
PGMLproblem.subFun = 'table'

function setRandomSeed( s )
   math.randomseed( s )
end

function PGMLproblem.mkchc( self, lst ) 
   return randPerm( distinctElems( self.numberChoices, lst ) )
end

--dummy to be overwritten
function PGMLproblem.submaker( self) 
   return {}, {1,2,3,4,5,6}
end


function PGMLproblem:selVer( lst )
   local t = type( lst )
   if t ~= 'table' or mathTypeQ( lst ) then
      return lst
   else 
      return lst[ self.vernum ]
   end
end

function PGMLproblem.gsub_interp( self, str, tab )
   return str.gsub( str, '(@[^%s%p@%%%}\\]*)', 
        	    function(w) 
        	       local arg = w.sub( self,2)
        	       local val = tab[ arg ] or w
        	       return self.selVer( self, val )
        	    end )
end

function PGMLproblem:generate( ... ) 
   local pgml, template, subs, chcs
   if type( self.template ) == 'table' then 
      if self.vernum == 0 then
	 self.vernum = math.random( #self.template ) 
      end
      template = self.template[ self.vernum ]
   else 
      template = self.template
   end
   -- local submkstr = string.dump( self.submaker )
   -- local env = setmetatable( {}, { __index = _ENV } )
   -- local submkfun = load( submkstr, submkstr, 'b', env )
   -- local subs, chcs = submkfun( self, ... )
   subs, chcs = self:submaker( ... )
   if chcs == nil then self.subFun = 'self' end
   chcs = chcs or subs
   if type(subs)=='table'  and self.subFun == 'table' then
      pgml = string.format( template, table.unpack( subs ) )
   elseif self.subFun == 'table' then
      pgml = self.gsub_interp( self, template, subs )
   elseif self.subFun == 'self' then
      pgml = PGMLproblem:interp( template )
   end
   if self.mcP then
      local blanks = createBlankList( self.numberChoices, [[{%s}]] )
      blanks = table.concat( blanks )
      pgml = pgml .. [[ \\ \\ %s]] .. blanks
      chcpgml = self.listToPGML( chcs )
      pgml = string.format( pgml, self.chcFun, 
			     table.unpack( self.mkchc( self, chcpgml ))) 
   else
      local ans = chcs
      if type( ans ) == 'table' and not mathTypeQ( ans ) then
         ans = chcs[1]
      end 
      if mathTypeQ( ans ) then
         pgml = pgml .. "  \n    [___________]{ " .. ans:toPGML() .. " } ";
      elseif type( ans ) == 'string' then
         pgml = pgml .. "  \n    [___________]{ '" .. ans .. "' } ";
      else
         pgml = pgml .. "  \n    [___________]{ " .. ans .. " } ";
      end
   end
   return pgml
end

local function objToPGML( x, surround )
   if surround == nil then surround = true end
   local t = type( x )
   if t == 'number' or t == 'string' then
      return x
   elseif surround then
      return [[ [@ ]] .. x.toPGML( x) .. [[ @]** ]]
   else 
      return x.toPGML( x)
   end
end
   
   
function PGMLproblem.listToPGML( lst )
   return map( lst, objToPGML )
end


function PGMLproblem:interp( str )
   return string.gsub( str, '(@[^%s%p@%%%}\\]*)', 
        	  function(w) 
        	     local arg = w:sub(2)
                     --local res = _G[arg]
        	     local res = self:selVer( _G[arg] ) or w
                     res = objToPGML( res, false )
        	     return res
        	  end )
end


function PGMLproblem:new( tmpl, mksubs, chcstr )
   chcstr = chcstr or self.chcFun
   tmpl = tmpl or self.template
   mksubs = mksubs or self.submaker
   local instance = copy( self )
   instance.template = tmpl
   instance.submaker = mksubs
   instance.chcFun = chcstr
   instance.subFun = self.subFun
   instance.mcP = self.mcP
   instance.vernum = 0
   return instance
   --return setmetatable( instance, PGMLproblem.mt )
end

testProblem = PGMLproblem:new( 
   [[ What is the square root of @sq? ]],
   function  ( self )
      local root = math.random( 0, 9 )
      sq = root * root
      return root
   end
)

function pgmlProto()
   return testProblem
end
