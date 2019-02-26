using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using log4net;

namespace NLuaSerialConsole
{
    class Program
    {

        static void Main(string[] args)
        {
            LuaConsole lc = new LuaConsole();
            lc.Main(args);
        }
    }
}
