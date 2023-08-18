
# Create an encrypted text file and then call the .txt file
$startParams = @{
    FilePath     = 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe'
    ArgumentList = ' /generateEncryptedPassword -encryptionKey=Dell!23 -password=Dell123 -outputPath=C:\Temp'
    Wait         = $true
    PassThru     = $true
}
$proc = Start-Process @startParams
$proc.ExitCode



$startParams = @{
    FilePath     = 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe'
    ArgumentList = ' /applyUpdates-encryptedPasswordFile=C:\Temp\EncryptedPassword.txt'
    Wait         = $true
    PassThru     = $true
}
$proc = Start-Process @startParams
$proc.ExitCode 


# dcu-cli /generateEncryptedPassword -encryptionKey="Dell!23" -password="Dell123" -outputPath=C:\Temp

# dcu-cli /applyUpdates-encryptedPasswordFile=C:\Temp\EncryptedPassword.txt