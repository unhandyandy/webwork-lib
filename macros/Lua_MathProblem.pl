package Lua_PGML;

use Inline 'Lua';
use Inline (Config => DIRECTORY => "/tmp/");
use Inline Lua => <<LUA;

--frc = require('fraction')
--vec = require('vector')
--st = require('sets')
--mat = require('matrix')

local mathProblem = {}
mathProblem.mt = {__index = mathProblem}

mathProblem.mcP = false
mathProblem.template = [[What time is it?]]
--mathProblem.numberChoices = 8
--mathProblem.chcFun = [[\chcSix]]
mathProblem.subFun = 'table'


function mathProblem:mkchc( lst ) 
   return randPerm( distinctElems( self.numberChoices, lst ) )
end

--dummy to be overwritten
function mathProblem:submaker() 
   return {}, {1,2,3,4,5,6}
end


function mathProblem:selVer( lst )
   local t = type( lst )
   if t ~= 'table' or mathTypeQ( lst ) then
      return lst
   else 
      return lst[ self.vernum ]
   end
end

function mathProblem:gsub_interp( str, tab )
   return str:gsub( '(@[^%s%p@%%%}\\]*)', 
		    function(w) 
		       local arg = w:sub(2)
		       local val = tab[ arg ] or w
		       return self:selVer( val )
		    end )
end

function mathProblem:generate( ... ) 
   local pgml, template
   if type( self.template ) == 'table' then 
      if self.vernum == 0 then
	 self.vernum = math.random( #self.template ) 
      end
      template = self.template[ self.vernum ]
   else 
      template = self.template
   end
   local submkstr = string.dump( self.submaker )
   local env = setmetatable( {}, { __index = _ENV } )
   local submkfun = load( submkstr, submkstr, 'b', env )
   local subs, chcs = submkfun( self, ... )
   if chcs == nil then self.subFun = 'self' end
   chcs = chcs or subs
   if subs[1] and self.subFun == 'table' then
      pgml = string.format( template, table.unpack( subs ) )
   elseif self.subFun == 'table' then
      pgml = self:gsub_interp( template, subs )
   elseif self.subFun == 'self' then
      pgml = self:interp( template, env )
   end
   if self.mcP then
      local blanks = createBlankList( self.numberChoices, [[{%s}]] )
      blanks = table.concat( blanks )
      pgml = pgml .. [[ \\ \\ %s]] .. blanks
      chcpgml = self.listToPGML( chcs )
      pgml = string.format( pgml, self.chcFun, 
			     table.unpack( self:mkchc( chcpgml ))) 
   else
      local ans = chcs
      if type( ans ) == 'table' and not mathTypeQ( ans ) then
         ans = chcs[1]
      end 
      if mathTypeQ( ans ) then
         template = template .. [[  
[___________]{ans:toPGML} ]]
      else 
         template = template .. [[  
[___________]{ans} ]]
      end
   end
   _G = oldEnv
   return pgml, ans
end

local function objToPGML( x, surround )
   if surround == nil then surround = true end
   local t = type( x )
   if t == 'number' or t == 'string' then
      return x
   elseif surround then
      return [[ [@ ]] .. x:toPGML() .. [[ @]** ]]
   else 
      return x:toPGML()
   end
end
   
   
function mathProblem.listToPGML( lst )
   return map( lst, objToPGML )
end


function mathProblem:interp( str, env )
   return str:gsub( '(@[^%s%p@%%%}\\]*)', 
		  function(w) 
		     local arg = w:sub(2)
		     local res = self:selVer( env[ arg ] ) or w 
		     res = objToPGML( res, false )
		     return res
		  end )
end


function mathProblem:new( tmpl, mksubs, chcstr )
   chcstr = chcstr or mathProblem.chcFun
   tmpl = tmpl or mathProblem.template
   mksubs = mksubs or mathProblem.submaker
   local instance = {}
   instance.template = tmpl
   instance.submaker = mksubs
   instance.chcFun = chcstr
   instance.subFun = mathProblem.subFun
   instance.mcP = mathProblem.mcP
   return setmetatable( instance, mathProblem.mt )
end



return mathProblem


LUA
