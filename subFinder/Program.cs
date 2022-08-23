using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace subFinder
{
    internal class Program
    {
        const int STD_OUTPUT_HANDLE = -11;
        const uint ENABLE_VIRTUAL_TERMINAL_PROCESSING = 4;

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll")]
        static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

        [DllImport("kernel32.dll")]
        static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);


        private static void Main(string[] args)
        {
            var handle = GetStdHandle(STD_OUTPUT_HANDLE);
            uint mode;
            GetConsoleMode(handle, out mode);
            mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
            SetConsoleMode(handle, mode);

            const string UNDERLINE = "\x1B[4m";
            const string RESET = "\x1B[0m";



            //--------------------------------------------- Start



            // get args
            string movieName = args[0]; // The_Blacklist_S01E01_720p_BluRay_PaHe
            string subPath = args[1];   // C:\Users\YourName\Desktop\mySubFolder


            // -------step 1-------
            // find chapter e.g S01E01
            string chapter = String.Empty;
            int x = 0; // last index for last loop
            int lastIndex = movieName.LastIndexOf('S') + 1; // last index (for end loop)
            while (x < lastIndex)
            {
                x = movieName.IndexOf('S', x + 6);

                if (x != -1)
                {
                    if (char.IsDigit(movieName[x + 1])
                        && char.IsDigit(movieName[x + 2])
                        && movieName[x + 3] == 'E'
                        && char.IsDigit(movieName[x + 4])
                        && char.IsDigit(movieName[x + 5]))
                    {
                        chapter = movieName.Substring(x, 6);
                        break;
                    }
                }
                else
                {                    
                    break;
                }
            }

            // failed to find chapter
            if (chapter == string.Empty)
            {
                LogImport("failed", "chapter or episode not found", null);
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;                
                Console.WriteLine(UNDERLINE + "Your movie name is not valid!" + RESET);
                Console.ResetColor();
                Console.Write("Press any key to continue ");
                Console.ReadKey();
                Console.WriteLine();
                Environment.Exit(0);
            }


            
            // -------step 2-------
            // get all files (.srt, .ass) in user subtitle folder
            var subExtensions = new List<string> { ".srt", ".ass" };
            string[] subFiles = Directory.GetFiles(subPath, "*.*", SearchOption.AllDirectories)
                                .Where(f => subExtensions.IndexOf(Path.GetExtension(f)) >= 0).ToArray();


            // find subtitle related to movie chapter
            string subFile = string.Empty;
            foreach (string file in subFiles)
            {
                if (file.Contains(chapter))
                {
                    subFile = file;
                    break;
                }
            }


            // failed to find subtitle
            if (subFile == string.Empty)
            {
                LogImport("failed", "subtitles for the chapter or episode not found", null);
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(UNDERLINE + "No subtitle file found for your entry" + RESET);
                Console.ResetColor();
                Console.Write("Press any key to continue ");
                Console.ReadKey();
                Console.WriteLine();
                Environment.Exit(0);
            }


            // -------step 3-------
            // final: import related subtitle to commands file & log file
            string commandsPath = Environment.CurrentDirectory + "\\Commands\\commands.txt";
            string subCommand = "--sub-file=" + subFile;
            File.AppendAllText(commandsPath, subCommand + Environment.NewLine, System.Text.Encoding.UTF8);
            
            LogImport("success", null, subFile);
        }

        // import to logfile
        private static void LogImport(string status, string comment, string subPath)
        {
            string logPath = Environment.CurrentDirectory + "\\Database\\subFinder.log";

            if (!File.Exists(logPath))
            {
                File.Create(logPath).Close();
            }

            string currentDate = DateTime.Now.ToString("yyyy/MM/dd");
            string currentTime = DateTime.Now.ToString("HH:mm:ss");

            string log = currentDate + " " + currentTime + " [" + status.ToUpper() + "]";
            if (status == "success")
            {
                log += " " + subPath;
            }
            else
            {
                log += "  " + comment;
            }

            // set limit for line of file
            int lineCount = File.ReadAllLines(logPath).Length;
            if  (lineCount >= 10)
            {
                File.Create(logPath).Close();
            }

            File.AppendAllText(logPath, log + Environment.NewLine, System.Text.Encoding.ASCII);
        }
    }
}
