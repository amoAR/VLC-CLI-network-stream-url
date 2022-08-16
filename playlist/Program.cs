using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Runtime.InteropServices;
using System.Diagnostics;


namespace validateURL
{
    class Program
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
            // get args
            string listPath = args[0]; // C:\Users\YourNmae\Desktop\playlist.txt
            string playlistPath = args[1]; // C:\Users\YourNmae\Desktop\CLI\Database\playlist.xspf
            string commandsPath = args[2]; // C:\Users\YourNmae\Desktop\CLI\Commands\commands.txt
            string subPath = args[3]; // C:\Users\YourNmae\Desktop\mySubFolder

            bool sub = true;
            if (string.IsNullOrWhiteSpace(subPath) || string.IsNullOrEmpty(subPath))
            {
                sub = false;
            }


            // -------step 1-------
            // get content of user list line by line
            string[] lines = File.ReadAllLines(listPath);

            // find mathches to HTTP(s) URL pattern
            string[] matches = new string[lines.Length];
            for (int i = 0; i < lines.Length; i++)
            {
                if (Regex.IsMatch(lines[i], @"^http(s)?://([\w-]+.)+[\w-]+(/[\w- ./?%&=])?$"))
                {
                    matches[i] = lines[i];
                }
            }

            // remove null items
            string[] urls = matches.Where(m => m != null).ToArray();


            // -------step 2-------
            // set xml pattern
            // start
            string s1 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
            string s2 = "<playlist xmlns=\"http://xspf.org/ns/0/\" xmlns:vlc=\"http://www.videolan.org/vlc/playlist/ns/0/\" version=\"1\">";
            string s3 = "	<title>playlist</title>";
            string s4 = "	<trackList>";

            // end
            string e1 = "	</trackList>";
            string e2 = "	<extension application=\"http://www.videolan.org/vlc/playlist/0\">";
            string e3 = "	</extension>";
            string e4 = "</playlist>";


            // options
            string space = "				";
            string[] options = File.ReadAllLines(commandsPath);            


            // write to playlist
            using (var streamWriter = new StreamWriter(playlistPath))
            {
                // header
                streamWriter.WriteLine(s1);
                streamWriter.WriteLine(s2);
                streamWriter.WriteLine(s3);
                streamWriter.WriteLine(s4);
                

                // main --> tracks + options (include subtitle)
                if (sub)
                {
                    goto writeSub;
                }
                else
                {
                    goto writeNoSub;
                }

            writeSub:
                for (int i = 0; i < urls.Length; i++)
                {
                    // header main (track)
                    streamWriter.WriteLine("		<track>");
                    streamWriter.WriteLine($"			<location>{urls[i]}</location>");
                    streamWriter.WriteLine("			<extension application=\"http://www.videolan.org/vlc/playlist/0\">");
                    streamWriter.WriteLine($"				<vlc:id>{i}</vlc:id>");

                    // options
                    foreach (string option in options)
                    {
                        streamWriter.WriteLine(space + option);
                    }

                    // sub option
                    string fileName = urls[i].Substring(urls[i].LastIndexOf('/') + 1);
                    string movieName = fileName.Substring(0, fileName.Length - 4);                    
                    streamWriter.WriteLine(space + getSub(movieName, subPath));

                    // footer main (track)
                    streamWriter.WriteLine("			</extension>");
                    streamWriter.WriteLine("		</track>");
                }
                goto footer;

            writeNoSub:
                for (int i = 0; i < urls.Length; i++)
                {
                    // header main (track)
                    streamWriter.WriteLine("		<track>");
                    streamWriter.WriteLine($"			<location>{urls[i]}</location>");
                    streamWriter.WriteLine("			<extension application=\"http://www.videolan.org/vlc/playlist/0\">");
                    streamWriter.WriteLine($"				<vlc:id>{i}</vlc:id>");

                    // options
                    foreach (string option in options)
                    {
                        streamWriter.WriteLine(space + option);
                    }

                    // footer main (track)
                    streamWriter.WriteLine("			</extension>");
                    streamWriter.WriteLine("		</track>");
                }

            footer:
                // footer
                streamWriter.WriteLine(e1);
                streamWriter.WriteLine(e2);
                
                for (int i = 0; i < urls.Length; i++)
                {
                    streamWriter.WriteLine($"		<vlc:item tid=\"{i}\"/>");
                }
                
                streamWriter.WriteLine(e3);
                streamWriter.WriteLine(e4);
            }            
        }


        // get related subtitle file path
        private static string getSub(string movieName, string subPath)
        {
            var handle = GetStdHandle(STD_OUTPUT_HANDLE);
            uint mode;
            GetConsoleMode(handle, out mode);
            mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
            SetConsoleMode(handle, mode);

            const string UNDERLINE = "\x1B[4m";
            const string RESET = "\x1B[0m";



            //--------------------------------------------- Start



            // set sub Finder path
            string subFinderPath = Environment.CurrentDirectory + "\\subFinder.exe";

            // start process & wait
            ProcessStartInfo subFinder = new ProcessStartInfo();
            subFinder.FileName = subFinderPath;
            subFinder.Arguments = movieName + " " + subPath;
            subFinder.WindowStyle = ProcessWindowStyle.Hidden;
            subFinder.CreateNoWindow = true;
            Process.Start(subFinder).WaitForExit();

            // get related subtitle file path from log file if process successed
            string logFilePath = Environment.CurrentDirectory + "\\Database\\subFinder.log";
            string lastLog = File.ReadLines(logFilePath).Last();

            string commandsPath = Environment.CurrentDirectory + "\\Commands\\commands.txt";
            
            if (lastLog.Substring(20, 1) == "S")
            {
                string[] lines = File.ReadAllLines(commandsPath);
                File.WriteAllLines(commandsPath, lines.Take(lines.Length - 1));

                return "<vlc:option>sub-file=" + lastLog.Substring(29) + "</vlc:option>";
            }
            // failed to find related subtitle --> bad URL or no subtitle to that name
            else
            {
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine(UNDERLINE + "Failed to find subtitles for your playlist!" + RESET);
                Console.ResetColor();
                return null;
            }
        }
    }
}