. (Join-Path $PSScriptRoot "ColorCoder.ps1")

# Could as well be $Data = [System.Text.Encoding]::ASCII.GetBytes($Base64String)
$Data = Get-Content C:\temp\original.file.exe -Encoding Byte
$Bitmap = ConvertTo-Bitmap -Data $Data
$Bitmap.Save("C:\image.bmp")

# transfer file to another computer

$NewBitmap = [System.Drawing.Bitmap]::FromFile("C:\Downloads\image.bmp")
$Data = ConvertFrom-Bitmap -Bitmap $NewBitmap
Set-Content -Path C:\copy.of.original.file.exe -Value ([byte[]]$Data) -Encoding Byte
