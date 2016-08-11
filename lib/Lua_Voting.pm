#-*-lua-*-

package Lua_Voting;

use Inline 'Lua';
use Inline (Config => DIRECTORY => "/tmp/");

use Inline Lua => '/opt/webwork/pg/lib/Lua/mylib.lua';
use Inline Lua => '/opt/webwork/pg/lib/Lua/PGMLproblem.lua';
use Inline Lua => '/opt/webwork/pg/lib/Lua/fraction.lua';
use Inline Lua => '/opt/webwork/pg/lib/Lua/vector.lua';
use Inline Lua => '/opt/webwork/pg/lib/Lua/matrix.lua';
use Inline Lua => '/opt/webwork/pg/lib/Lua/voting.lua';

1;
