
// Configuration script to create
//     MonoDevelop.FSharpBinding/MonoDevelop.FSharp.mac-linux.fsproj (unix)
//     MonoDevelop.FSharpBinding/MonoDevelop.FSharp.windows.fsproj (windows)
//     MonoDevelop.FSharpBinding/FSharpBinding.addin.xml

open System
open System.Collections.Generic
open System.Linq
open System.Text
open System.IO
open System.Diagnostics
open System.Text.RegularExpressions

let FSharpVersion = "3.2.22"

let UnixPaths = 
    [ "/usr/lib/monodevelop"
      "/usr/local/monodevelop/lib/monodevelop"
      "/usr/local/lib/monodevelop"
      "/Applications/MonoDevelop.app/Contents/MacOS/lib/"
      "monodevelop"
      "/opt/mono/lib/monodevelop"
      "/Applications/Xamarin Studio.app/Contents/MacOS/lib/monodevelop" ]

let WindowsPaths = 
    [ @"C:\Program Files\Xamarin Studio"
      @"C:\Program Files\MonoDevelop"
      @"C:\Program Files (x86)\Xamarin Studio"
      @"C:\Program Files (x86)\MonoDevelop" ]

let MdCheckFile = "bin/MonoDevelop.Core.dll"


let isWindows = (Path.DirectorySeparatorChar = '\\')

let GetPath (str: string list) =
    Path.GetFullPath (String.Join (Path.DirectorySeparatorChar.ToString (), str.Select(fun (s:string) -> s.Replace ('/', Path.DirectorySeparatorChar))))


let Grep (file, regex, group:string) =
    let m = Regex.Match (File.ReadAllText (GetPath [file]), regex)
    m.Groups.[group].Value

let FileReplace (file, outFile, toReplace:string, replacement:string) =
    File.WriteAllText (GetPath [outFile], File.ReadAllText(GetPath [file]).Replace(toReplace, replacement))

let Run (file, args) =
    let currentProcess = new Process ()
    currentProcess.StartInfo.FileName <- file
    currentProcess.StartInfo.Arguments <- args
    currentProcess.StartInfo.RedirectStandardOutput <- true
    currentProcess.StartInfo.UseShellExecute <- false
    currentProcess.StartInfo.WindowStyle <- ProcessWindowStyle.Hidden
    currentProcess.Start () |> ignore
    currentProcess.StandardOutput


let paths = if isWindows then WindowsPaths else UnixPaths

Console.WriteLine "MonoDevelop F# add-in configuration script"
Console.WriteLine "------------------------------------------"

let args = fsi.CommandLineArgs.[1..]
if Array.exists ((=) "--help") args then
  Console.WriteLine "Options:\n"
  Console.WriteLine "--prefix=PATH\n"
  Console.WriteLine "  MonoDevelop library directory. Currently searched:\n"
  for p in paths do Console.WriteLine("  {0}", p)
  exit 0

let searchPaths =
  let getPrefix (s: string) =
    let xs = s.Split('=')
    if xs.Length = 2 && xs.[0] = "--prefix" then Some xs.[1]
    else None
  match Array.tryPick getPrefix args with
  | None -> paths
  | Some p -> p :: paths

let mutable mdDir = null
let mutable mdVersion = "4.1.6"

// Look for the installation directory

if (File.Exists (GetPath ["../../../monodevelop.pc.in"])) then
    // Local MonoDevelop build directory
    mdDir <- GetPath [Environment.CurrentDirectory + "/../../../build"]
    if (File.Exists (GetPath [mdDir;  "../../main/configure.in"])) then 
        mdVersion <- Grep (GetPath [mdDir; "../../main/configure.in"], @"AC_INIT.*?(?<ver>([0-9]|\.)+)", "ver")
else
    // Using installed MonoDevelop
    mdDir <- searchPaths.FirstOrDefault (fun p -> File.Exists (GetPath [p; MdCheckFile]))
    if (mdDir <> null) then
        let mdExe = 
            if (File.Exists (GetPath[mdDir; "../../XamarinStudio"])) then
                GetPath[mdDir; "../../XamarinStudio"]
            elif (File.Exists (GetPath [mdDir; "../../MonoDevelop"])) then
                GetPath [mdDir; "../../MonoDevelop"]
            elif (File.Exists (GetPath[mdDir; "bin/XamarinStudio.exe"])) then
                GetPath[mdDir; "bin/XamarinStudio.exe"]
            elif (File.Exists (GetPath [mdDir; "bin/MonoDevelop.exe"])) then
                GetPath [mdDir; "bin/MonoDevelop.exe"]
            else
                null
        if (mdExe <> null) then
            let outp = Run(mdExe, "/?").ReadLine()
            mdVersion <- outp.Split([| ' ' |], StringSplitOptions.RemoveEmptyEntries).Last()

if not isWindows then
    // Update the makefile. We don't use that on windows
    FileReplace ("Makefile.orig", "Makefile", "INSERT_MDROOT", mdDir)
    FileReplace ("Makefile", "Makefile", "INSERT_MDVERSION4", mdVersion)
    FileReplace ("Makefile", "Makefile", "INSERT_VERSION", FSharpVersion)
    
if (mdDir = null) then
    Console.WriteLine ("MonoDevelop binaries not found. Continuing anyway")
else
    Console.WriteLine ("MonoDevelop binaries found at: {0}", mdDir)

Console.WriteLine ("Detected version: {0}", mdVersion)

let tag = if isWindows then "windows" else "mac-linux"

let fsprojFile = "MonoDevelop.FSharpBinding/MonoDevelop.FSharp." + tag + ".fsproj"
let xmlFile = "MonoDevelop.FSharpBinding/FSharpBinding.addin.xml"

FileReplace ("MonoDevelop.FSharpBinding/MonoDevelop.FSharp.fsproj.orig", fsprojFile, "INSERT_FSPROJ_MDROOT", mdDir)
FileReplace (fsprojFile, fsprojFile, "INSERT_FSPROJ_MDVERSION4", mdVersion)
FileReplace (fsprojFile, fsprojFile, "INSERT_FSPROJ_MDTAG", tag)
FileReplace ("MonoDevelop.FSharpBinding/FSharpBinding.addin.xml.orig", xmlFile, "INSERT_FSPROJ_VERSION", FSharpVersion)
FileReplace (xmlFile, xmlFile, "INSERT_FSPROJ_MDVERSION4", mdVersion)
