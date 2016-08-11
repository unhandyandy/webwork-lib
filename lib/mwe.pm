#-*-lua-*-

package mwe;

use Inline 'Lua';
use Inline (Config => DIRECTORY => "/tmp/");

use Inline 'Lua' => <<'LUA';

local tab = {1,2,3}

function ternary(x,y,z)
   return x * y + z
end

function test()
   return ternary( unpack( tab ) )
end

LUA

1;
