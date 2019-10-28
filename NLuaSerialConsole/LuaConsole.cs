using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
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
        private Lua _scriptL;
        private SerialPortStream src;
        private static readonly ILog Log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);
        static string SettingsFile = "settings.lua";
        private const string PROCESS_LUA = "!";
        private const string PROCESS_CONSOLE_CMD = ">";
        private const string PROCESS_LUA_PRINT = "?";
        private const string PROCESS_BUFFER_INPUT = "+";
        private const string PROCESS_END_BUFFER = "=";
        private string _lineEnding = "\r\n";
        private string _lastMessage = "";
        private bool _logging;
        private StreamWriter _scriptLog;
        private bool _binary = false;

        public LuaConsole()
        {
            L = NewEnv();
            src = new SerialPortStream();
            byte[] readBuffer = new byte[8192];
            src.DataReceived += (s, e) =>
            {
                
                int bytes = ((SerialPortStream)s).Read(readBuffer, 0, readBuffer.Length);
                byte[] buf = new byte[bytes];
                Buffer.BlockCopy(readBuffer, 0, buf, 0, bytes);
                string str = "";
                if (_binary)
                {
                    
                    for(int i = 0; i < bytes; i++)
                    {
                        str += string.Format("{0:X} ", buf[i]);
                    }
                }
                else
                {
                    str = Encoding.ASCII.GetString(buf);
                    int len = _lastMessage.Length;
                        //This is to stip off whatever the user typed. It's a terrible idea.
                    if (!string.IsNullOrEmpty(_lastMessage) && str.Length >= len && str.Substring(0, len) == _lastMessage)
                    {
                        str = str.Substring(len);
                    }
                }
                WriteConsole(str);

            };

            src.ErrorReceived += (s, e) =>
            {
                WriteConsole($"===> EventType: {e.EventType}");
            };
        }

        public void help()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("There is no help for you.");
            string help = @"
Commands:
>q - quit.
>open <port> - open a serial port. Opens the port specified or the currently configured port. See Settings File.
>close - close any open port.
>run <filename> - execute a lua script.
>load settings - reload the settings file. Hard coded to ./settings.lua in the executable directory.
>script [close] | <filename> - Opens a file and dumps all stdin and stdout to that file. >script close will close the file. Only one file is allowed at a time.
>show [version|ports] - 'version' displays the current version. 'ports' lists all the ports on the computer.
>clear - clears the screen.

Switches:
> - Execute a console command. See Commands.
! - Execute lua command. To buffer multiple lines use '! <line one> + ' and then end your final line with =.
    Example:
    ! t = {'a','b','c'} =
    ! for i,v in pairs(t) do
    ! print(i,v)
    ! end =
? - Print a value from lua.  
    Example: ?src.PortName
    (Equivelent to the lua command print(src.PortName)

Important Lua Functions:

log - The application logger. Uses log4net. example: log:Error(""Oops"")
    [Error|Warn|Info|Debug].
";
            WriteConsole(sb.ToString());
            Console.Write(help);
        }

        private Lua NewEnv()
        {
            Lua env = new Lua();
            env["SetBinary"] = new Action<bool>(SetBinary);
            env["WriteConsole"] = new Action<string>(WriteConsole);
            env["print"] = new Action<string>(WriteConsole);
            env["ReadConsole"] = new Func<string>(ReadConsole);
            //env["SendString"] = new Action<string,bool>(Send);
            env["SendBinary"] = new Action<byte[]>(Send);
            env["Script"] = new Action<string>(Script);
            env["OpenPort"] = new Action<string>(OpenPort2);
            env["Open"] = new Action(OpenPort);
            env["ClosePort"] = new Action(ClosePort);
            env["Show"] = new Action<string>(Show);
            env["IsOpen"] = new Func<bool>(() => src.IsOpen);
            env["GetPort"] = new Func<string>(() => src.PortName);            
            env["SetPort"] = new Action<string>((portname) => src.PortName = portname);
            env["GetSettings"] = new Func<string>(() => "Not Implemented");
            env["Log"] = Log;
            return env;
        }

        private void SetBinary(bool isBinary)
        {            
            _binary = isBinary;
            WriteConsole($"SetBinary = {isBinary}");
        }

        /// <summary>
        /// Run a Lua file.
        /// </summary>
        /// <param name="args"></param>
        private void RunFile(string file)
        {
            try
            {
                _scriptL = NewEnv();
                //TODO: Check for relative path and append script_path if it's available
                //HACK...
                Directory.SetCurrentDirectory((string)L["settings.script_path"]);
                System.IO.FileInfo f = new System.IO.FileInfo(file);
                if (f.Exists && f.Length > 0)
                {
                    _scriptL["RUNNING__"] = true;
                    _scriptL.DoFile(file);
                    _scriptL.Close();
                    _scriptL = null;

                }
                else
                {
                    Log.WarnFormat("File Not Found: {0}\r\n", file);
                }
            }
            catch(Exception ex)
            {
                Log.Error(ex.Message, ex);
                if (_logging) { Script("close"); }
                _scriptL.Close();
                _scriptL = null;

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
                WriteConsole(ex.Message);
            }
        }

        public void Main(string[] args)
        {
            
            LoadSettings();
            try
            {
                src.PortName = (string)L["settings.serial_port.com_port"];
                src.BaudRate = Convert.ToInt32(L["settings.serial_port.baud_rate"]);
                string le = (string)L["settings.line_ending"];
                if (le == "unix")
                {
                    _lineEnding = "\n";
                }
                else if(le == "windows")
                {
                    _lineEnding = "\r\n";
                }

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
                    input = ReadConsole();
                    if (input.Length > 0)
                    {
                        if (bufferMode)
                        {
                            input = PROCESS_LUA + input;
                        }
                        if (input == ">q")
                        {
                            running = false;                            
                            if(_scriptL != null) { _scriptL.Close(); _scriptL.Dispose(); }
                            ClosePort();
                            Log.Info("Exiting Application...");
                            continue;
                        }
                        else if (input == ">d")
                        {
                            if (_scriptL != null)
                            {
                                _scriptL["RUNNING__"] = false;
                            }
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
                                case PROCESS_CONSOLE_CMD: /*Raw write to the serial port if it's open*/
                                    input = input.Substring(1).Trim();
                                    string[] cmds = input.Split(' ');

                                    switch (cmds[0].ToLower())
                                    {
                                        case "close":                                            
                                             ClosePort();                                             
                                            break;
                                        case "open":
                                            if (cmds.Length == 2)
                                                OpenPort2(cmds[1].ToLower());
                                            else
                                                OpenPort();
                                            break;
                                        case "run":
                                            if (cmds.Length == 2)
                                            {
                                                if (_scriptL == null)
                                                {
                                                    System.Threading.ThreadPool.QueueUserWorkItem(delegate
                                                    {                                                        
                                                        RunFile(cmds[1].ToLower());
                                                    }, null);
                                                }
                                                else
                                                {
                                                    Log.Warn("Script already running. >d to close it.");
                                                }
                                            }
                                            else
                                                help();
                                            break;
                                        case "load":
                                            if (cmds.Length == 2 && cmds[1].ToLower() == "settings")
                                                LoadSettings();
                                            else
                                                help();
                                            //configurations
                                            break;
                                        case "script":
                                            if (cmds.Length == 2)
                                                Script(cmds[1].ToLower());
                                            else
                                                help();
                                            break;
                                        case "show":
                                            if (cmds.Length == 2)
                                                Show(cmds[1].ToLower());
                                            else
                                                help();
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
                                case PROCESS_LUA_PRINT:
                                    //wrap the string in a lua print(...) statement
                                    L.DoString(string.Format("print({0})", input.Substring(1)));
                                    break;
                                default:
                                    if (src.IsOpen)
                                    {
                                        Send(input);
                                        _lastMessage = input;
                                    }
                                    else
                                    {
                                        Log.Warn("Serial port not open.");
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

        public void Script(string cmds)
        {
            if(cmds == "close")
            {
                if (_scriptLog != null)
                {
                    _scriptLog.Close();
                }
                _logging = false;
                string now = DateTime.Now.ToString("yyyy-MMM-dd HH:mm:ss.fff");
                WriteConsole($"-----------Closed file at {now} -----------------");
            }
            else
            {
                // This is not an adiquite solution, but it works for the moment. 
                // none of the log4net messages get into this log. It may be better
                // to use log4net instead and toggle timesamps on and off through the appender?
                _scriptLog = new StreamWriter(cmds);
                _scriptLog.AutoFlush = true;
                _logging = true;
                string now = DateTime.Now.ToString("yyyy-MMM-dd HH:mm:ss.fff");
                WriteConsole($"------------- Opened {cmds[1]} at {now} -----------------");
            }
        }

        public void Show(string cmds)
        {

            if (cmds == "version")
            {
                System.Reflection.Assembly assembly = System.Reflection.Assembly.GetExecutingAssembly();
                FileVersionInfo fvi = FileVersionInfo.GetVersionInfo(assembly.Location);
                string version = fvi.FileVersion;
                WriteConsole(version);
            }
            else if (cmds == "ports")
            {
                foreach (PortDescription desc in SerialPortStream.GetPortDescriptions())
                {
                    WriteConsole("Port Name: " + desc.Port + " Description: " +
                        ((desc.Description == string.Empty) ? "No Description provided" : desc.Description));
                }
            }
            else
            {
                WriteConsole("Show command: Show version | ports");
            }
        }

        public void OpenPort2(string cmds)
        {
            src.PortName = cmds;
            OpenPort();
        }

        public void OpenPort()
        {
            try
            {
                if (src.IsOpen)
                {
                    WriteConsole("Port open. Close it first.");
                    return;
                }
                src.Open();
                Log.InfoFormat("{0} is open.\r\n", src.PortName);
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
                        
        }

        public void ClosePort()
        {
            try
            {
                if (src.IsOpen)
                {                        
                    src.Close();
                    WriteConsole("Serial Port Closed.");
                }
                else
                {
                    WriteConsole("Port is not open.");
                }
            }
            catch (Exception ex)
            {
                Log.Error(ex);
            }
        }

        public void WriteConsole(string data)
        {
            if(_logging)
            {
                _scriptLog.WriteLine(data);                
            }
            Console.WriteLine(data);
        }

        public string ReadConsole()
        {
            string dataIn = Console.ReadLine();
            if(_logging)
            {
                _scriptLog.WriteLine(dataIn);
            }
            return dataIn;
        }

        public void Send(string data, bool appendLineEnding = true)
        {
            if(_logging)
            {
                _scriptLog.WriteLine(data);
            }
            data = appendLineEnding ? data + _lineEnding : data;
            src.Write(data);
        }

        public void Send(byte[] buffer)
        {
            if (buffer != null)
            {
                if (_logging)
                {
                    _scriptLog.WriteLine(buffer);
                }
                src.Write(buffer, 0, buffer.Length);
            }
            else
            {
                Log.Error("Buffer was null");
            }
        }
    }
}
