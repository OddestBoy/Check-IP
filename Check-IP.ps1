<#
.SYNOPSIS
    Quick IP address checker
.DESCRIPTION
    Check an IP address to fetch metadata like locaion, ASN, DNS etc
.EXAMPLE
    Check-IP 1.1.1.1 : return info about the given IP
    Check-IP 1.1.1.1 -txt -ping : write information about the IP (including pingability) to a TXT file
    The output is an object, so you can select properties or pipe it: (Check-IP 1.1.1.1).hostname | Write-Host -ForegroundColor Green
    It will also accept pipeline information: ((Resolve-DnsName "dns.google.com").IPAddress)[0] | Check-Ip
    Can be used to easily bulk check IPs and output to a CSV (using NoDNS for speed): @("1.1.1.1","1.1.1.2","1.1.1.3") | foreach-object {Check-IP $_ -CSV -NoDNS}
.NOTES
    Made by Oddestboy - https://github.com/OddestBoy/Check-IP
    Uses the IP checking API from - https://ip-api.com/
#>

param( 
    [parameter(Mandatory=$true,ValueFromPipeline,HelpMessage="The IP address to check")][string]$IP #The IP address to check
    ,[parameter()][switch]$NoDNS #Skip DNS lookup, for speed
    ,[parameter()][switch]$CSV #Output to CSV file in script folder
    ,[parameter()][switch]$TXT #Output to TXT file in script folder
    ,[parameter()][switch]$Ping #Check if address is pingable
    )

$Result = Invoke-RestMethod "http://ip-api.com/json/$($IP)?fields=status,message,country,city,isp,org,as,proxy,hosting,query" 
if($Result.status -eq "success"){
    $IPInfo = [PSCustomObject]@{
        Query = $Result.query
        Country = $Result.country
        City = $Result.city
        ISP = $Result.isp
        AS = $Result.as
        Org = $Result.org
        Proxy = $Result.proxy
        Hosting = $Result.hosting
        }
    if(!$NoDNS){
        $Name = (Resolve-DNSName $IP -erroraction 'silentlycontinue').NameHost
        $IPInfo | Add-Member -Name "Hostname" -Value $Name -MemberType NoteProperty
    }
    if($Ping){
        $Ping = (Test-NetConnection $IP).PingSucceeded
        $IPInfo | Add-Member -Name "PingSucceeded" -Value $Ping -MemberType NoteProperty
    }
} else { 
    Write-warning "Lookup failed for $IP! Message: $($Result.message)" 
}

if($TXT -or $CSV){
    Write-Host $IPInfo.Query
    if($TXT){
        Write-output $IPInfo | Out-File "$PSScriptroot\IPDetails.txt" -Append
    }
    if($CSV){
        $IPInfo | Export-Csv "$PSScriptroot\IPDetails.csv" -Append
    }
} else {
    Write-Output $IPInfo
}
Start-Sleep 1.5 #To avoid going over rate limit of 45 requests per minute when done in bulk
