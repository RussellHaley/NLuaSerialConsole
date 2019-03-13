using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using log4net;
using NLua;
using RJCP.IO.Ports;

namespace NLuaSerialConsole
{
    public class LuaConsole
    {
        private Lua L;
        private SerialPortStream src;
        private static readonly ILog Log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        static string SettingsFile = "settings.lua";
        private const string PROCESS_LUA = "!";
        private const string PROCESS_RAW_SEND = ">";
        private const string PROCESS_LUA_PRINT = "?";
        private const string PROCESS_BUFFER_INPUT = "+";
        private const string PROCESS_END_BUFFER = "=";

        public LuaConsole()
        {
            L = new Lua();
            src = new SerialPortStream();
            byte[] readBuffer = new byte[8192];
            src.DataReceived += (s, e) =>
            {
                
                int bytes = ((SerialPortStream)s).Read(readBuffer, 0, readBuffer.Length);
                byte[] buf = new byte[bytes];
                Buffer.BlockCopy(readBuffer, 0, buf, 0, bytes);
                string str = Encoding.ASCII.GetString(buf);
                Console.Write(str);
            };

            src.ErrorReceived += (s, e) =>
            {
                Console.WriteLine("===> EventType: {0}", e.EventType);
            };
            L["src"] = src;
            L["log"] = Log;
        }

        private void help()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("There is no help for you.");
            string help = @"
Commands:
q - quit.
open serial - open the currently configured serial port.
run <filename> - execute a lua script.
load settings - reload the settings file. Hard coded to ./settings.lua in the executable directory.
show [version|ports] - 'version' displays the current version. 'ports' lists all the ports on the computer.
clear - clears the screen.

Switches:
> - Send raw output
! - execute lua command. To buffer multiple lines use '! <line one> + ' and then end your final line with =.
    Example:
    ! t = {'a','b','c'} =
    ! for i,v in pairs(t) do
    ! print(i,v)
    ! end =
? - Print a value from lua.  
    Example: ?src.PortName
    (Equivelent to the lua command print(src.PortName)

Important Variables:
src - The serial port. example: !src.PortName = 'COM14'
    Other helpfuls:
    src:Open()
    src:Close()
    src:BuadRate = 
log - The application logger. Uses log4net. example: log:Error(""Oops"")
    [Error|Warn|Info|Debug].
";
            Console.WriteLine(sb.ToString());
            Console.Write(help);
        }

        /// <summary>
        /// Run a Lua file.
        /// </summary>
        /// <param name="args"></param>
        private void RunFile(string[] args)
        {
            Lua local = new Lua();
            System.IO.FileInfo f = new System.IO.FileInfo(args[1]);
            if (f.Exists && f.Length > 0)
            {
                local.DoFile(args[1]);
            }
            else
            {
                Log.WarnFormat("File Not Found: {0}\r\n", args[1]);
            }
        }

        private void LoadSettings()
        {
            try
            {
                L.DoFile(SettingsFile);
            }
            catch(Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

        public void Main(string[] args)
        {
            
            LoadSettings();
            try
            {
                src.PortName = (string)L["settings.serial_port.com_port"];
                src.BaudRate = Convert.ToInt32(L["settings.serial_port.baud_rate"]);
            }
            catch(Exception ex)
            {
                Log.Warn("Failed to load com settings:");
                Log.Warn(ex.Message);
            }
            Log.Info(string.Format("Starting {0}.", L["settings.console_name"]));

            string input;
            bool running = true;
            bool bufferMode = false;
            StringBuilder buffer = new StringBuilder();
            while (running)
            {
                try
                {
                    if (bufferMode)
                    {
                        Console.Write(PROCESS_LUA);
                    }
                    input = Console.ReadLine();
                    if (input.Length > 0)
                    {
                        if (bufferMode)
                        {
                            input = PROCESS_LUA + input;
                        }
                        if (input == "q")
                        {
                            running = false;
                            Log.Info("Closing...");
                            continue;
                        }
                        else
                        {

                            switch (input.Substring(0, 1))
                            {
                                //Make a lua call
                                case PROCESS_LUA:
                                    input = input.Substring(1);
                                    if (input.Substring(input.Length - 1) == PROCESS_BUFFER_INPUT)
                                    {
                                        bufferMode = true;
                                        input = input.Substring(0, input.Length - 1);
                                        buffer.AppendLine(input);
                                    }
                                    else if (bufferMode)
                                    {
                                        if (input.Substring(input.Length - 1) == PROCESS_END_BUFFER)
                                        {
                                            buffer.Append(input.Substring(0, input.Length - 1));
                                            input = buffer.ToString();
                                            buffer.Clear();
                                            bufferMode = false;
                                        }
                                        else
                                        {
                                            buffer.AppendLine(input.Substring(0));
                                        }
                                    }

                                    if (!bufferMode)
                                    {
                                        L.DoString(input);
                                    }

                                    break;
                                case PROCESS_RAW_SEND: /*Raw write to the serial port if it's open*/
                                    if(src.IsOpen)
                                    {
                                        src.Write(input.Substring(1) + "\n");
                                    }
                                    else
                                    {
                                        Log.Warn("Serial port not open.");
                                    }
                                    break;
                                case PROCESS_LUA_PRINT:
                                    //wrap the string in a lua print(...) statement
                                    L.DoString(string.Format("print({0})",input.Substring(1)));
                                    break;
                                default:
                                    string[] cmds = input.Split(' ');

                                    switch (cmds[0])
                                    {
                                        case "open":
                                            Open(cmds);
                                            break;
                                        case "run":
                                            RunFile(cmds);
                                            break;
                                        case "load":
                                            if(cmds[1] == "settings")
                                            {
                                                LoadSettings();
                                            }
                                            //configurations
                                            break;
                                        case "show":
                                            Show(cmds);
                                            break;
                                        case "clear":
                                            Console.Clear();
                                            break;
                                        case "help":
                                            help();
                                            break;
                                        default:
                                            Log.WarnFormat("{0} is not a command.", input);
                                            break;
                                    }

                                    break;
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    Log.Warn(ex);
                    if (ex.InnerException != null)
                    {
                        Log.Warn(ex.InnerException);
                    }
                }
            }
        }

        private void Show(string[] cmds)
        {
            
            if(cmds.Length < 2 || cmds[1] == "version")
            {
                System.Reflection.Assembly assembly = System.Reflection.Assembly.GetExecutingAssembly();
                FileVersionInfo fvi = FileVersionInfo.GetVersionInfo(assembly.Location);
                string version = fvi.FileVersion;
                Console.WriteLine(version);
            }
            else if (cmds[1] == "ports")
            {
                foreach (PortDescription desc in SerialPortStream.GetPortDescriptions())
                {
                    Console.WriteLine("Port Name: " + desc.Port + " Description: " + 
                        ((desc.Description == string.Empty)? "No Description provided" : desc.Description));
                }
            }
        }

        private void Open(string[] cmds)
        {
            if(cmds.Length < 2 )
            {
                help();
                return;
            }
            if (cmds[1] == "serial")
            {
                try
                {
                    if (src.IsOpen)
                    {
                        Console.WriteLine("Port open. Close it first.");
                        return;
                    }
                    src.Open();
                }
                catch (Exception ex)
                {
                    Log.Error(ex);
                }
            }            
        }
    }
}
