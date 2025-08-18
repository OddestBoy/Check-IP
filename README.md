Gives data about a given IP address, like location, ASN, Hostname using https://ip-api.com/

Check-IP 1.1.1.1

Query         : 1.1.1.1
Country       : Australia
City          : South Brisbane
ISP           : Cloudflare, Inc
AS            : AS13335 Cloudflare, Inc.
Org           : APNIC and Cloudflare DNS Resolver project
Proxy         : False
Hosting       : True
Hostname      : one.one.one.one

Arguments:
-IP : the IP address to check, also taken from the pipeline
-NoDNS : skip DNS lookup for speed
-CSV : output the results into a CSV file in the script directory
-TXT : output results into a txt file in the script directory
-Ping : also try pinging the IP

Notes:
The script will accept an IP address from the pipeline : ((Resolve-DnsName "dns.google.com").IPAddress)[0] | Check-Ip
The output is an object, you can use fl and ft, or select properties and pipe them : (Check-IP 1.1.1.1).hostname | Write-Host -ForegroundColor Green
To bulk check IPs, you can read them from a CSV with your own script, or from an array with foreach-object : @("1.1.1.1","1.1.1.2","1.1.1.3") | %{Check-IP $_ -CSV -NoDNS}

ip-api.com has a ratelimit of 45 requests per minute, so there's a 1.35 second delay after giving results to avoid going over if done in bulk
