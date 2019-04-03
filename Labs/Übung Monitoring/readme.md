# Monitoring von onpremise VMs (z.B. CPU Auslastung) #

In dieser Übung sammeln wir über einen Agenten Daten von einer onpremise VM ein und werten diese in Azure aus.  
Siehe: [Configure Log Analytics agent for Windows computers in a hybrid environment](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-collect-windows-computer) 

**Ablauf**
* [1. Log Analytics Workspace erstellen](#1)
* [2. Onpremise Agent / Software installieren und mit LA-Workspace verbinden.](#2)
* [3. Zu sammelnde Daten festlegen.](#3)
* [4. Abfrage ('Query') erstellen und Darstellung auf Dashboard 'pinnen'](#4)

## 1
## Log Analytics Workspace erstellen
```
[Azure Portal] -> '+ Create a resource' -> 'Log analytics' -> Create
Create New
Log Analytics Workspace: your choice (needs to be unique)
(new) Resource Group: 
	Name: 'ACDMY-LogAnalytics'
	Location: 'West Europe'
```
LogAnalyticsScreenshot

## 2
## Onpremise Agent / Software installieren und mit LA-Workspace verbinden.
```
[Azure Portal] -> Home -> Resource Groups ->'ACDMY-LogAnalytics' 
  -> e.g. your workspace -> Settings: Advanced Settings

Connected Source -> Windows Servers -> Copy the...
Workspace ID: ......
Primary Key: .......

copy to notepad. You will need it soon.
Download Windows Agent (64 bit) - or take c:\temp\MMASetup-AMD64.exe
Run and install MMASetup-AMD64.exe
Enter Workspace and Primary Key
Click 'Advanced'
enter 172.16.101.1:800 as the proxy

Control Panel\System and Security
->Microsoft Monitoring Agent Properties
```

## 3
## Zu sammelnde Daten festlegen.
```
[Azure Portal] -> Home -> Resource Groups ->'ACDMY-LogAnalytics' 
  -> e.g. bfrank0815WSpace -> Settings: Advanced Settings
    ->"Data" -> "Windows Event Logs.
       -> type 'System' -> +.
          ->check the severities Error and Warning.
            -> Click Save at the top of the page to save the configuration.
    
    ->"Data" -> "Windows Performance Counters"
        ->select some counters unselect some others.
add the following counter
Processor Information(_Total)\% Processor Time

    -> Click Save at the top of the page to save the configuration.
```
## 4
## Abfrage ('Query') erstellen und Darstellung auf Dashboard 'pinnen'
```
[Azure Portal] -> Resource groups -> ACDMY-LogAnalytics -> bfrankworkspace - Logs
```
In the query window type:

_Perf_

->hit 'Run' and see what happens.

try:

_Perf | where CounterName =='% Processor Time'_
   
->Check out the 'Chart' view 
   ->Click the PIN button on the right
      ->Can you pin it to the dashboard?
       (if not: [Azure Portal] -> Dashboard -> Hit 'Share' -> then try again.)


_Perf | where CounterName == '% Free Space'
Perf | where InstanceName == 'C:' | where CounterName == '% Free Space' | summarize any(CounterValue) by bin(TimeGenerated, 1m)_