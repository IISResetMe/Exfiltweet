#requires -Version 1

<#

  byte <-> bitmap color encoder for @moo_pronto's twitter based file system:

  https://twitter.com/moo_pronto/status/647116370820378624

  1) compress the binary 
  2) encrypt
  3) base64
  6) convert to hex
* 7) cut up in groups of 6 chars
* 8) img using html color codes
  9) up to twitter

#>

function ConvertTo-Bitmap
{
  param(
    [Parameter(Mandatory = $true)]
    [byte[]]$Data
  )

  $ColorList = for($i = 0; $i -lt $Data.Count; $i += 3)
  {
    # We need 3 bytes (24 bits) per pixel
    ,@($Data[$i..($i+2)])
  }
  Write-Verbose "$($ColorList.Count) pixels"

  $PaddingByte = $ColorList[-1][-1] -bxor 0xFF
  Write-Verbose "PaddingByte: $PaddingByte"

  $Width = $Height = [Math]::Floor([Math]::Sqrt($ColorList.Count + 1) + 1) -as [int]
  Write-Verbose -Message "Width: $Width"
  Write-Verbose -Message "Height: $Height"

  $InnerPadding = 3 - $ColorList[-1].Count
  Write-Verbose -Message "Inner padding: $InnerPadding"

  $BitMap = New-Object -TypeName System.Drawing.Bitmap -ArgumentList $Width, $Height

  for($y, $i = 0, 0; $y -lt $Height; $y++)
  {
    for($x = 0; $x -lt $Weight; $x, $i = ($x + 1), ($i + 1))
    {
      if($null -ne $ColorList[$i]) 
      {
        if($ColorList[$i].Count -le 3)
        {
          $InnerPadding..2 |ForEach-Object -Process {
            $ColorList[$i] += $PaddingByte
          }
        }
        $R, $G, $B = $ColorList[$i] -as [int[]]
        $Color = [System.Drawing.Color]::FromArgb($R,$G,$B)
      }
      else 
      {
        $Color = [System.Drawing.Color]::FromArgb($PaddingByte,$PaddingByte,$PaddingByte)
      }
      $BitMap.SetPixel($x,$y,$Color)
    }
  }

  return $BitMap
}

function ConvertFrom-Bitmap
{
  param(
    [Parameter(Mandatory = $true)]
    [System.Drawing.Bitmap]$BitMap
  )

  $Width = $BitMap.Width
  $Height = $BitMap.Height

  Write-Verbose -Message "Width: $Width"
  Write-Verbose -Message "Height: $Height"

  $PaddingColor = $BitMap.GetPixel($Width - 1, $Height - 1)
  $PaddingByte = $PaddingColor.B

  Write-Verbose -Message "Padding byte: $PaddingByte"

  $ColorList = for($y = 0; $y -lt $Height; $y++)
  {
    for($x = 0; $x -lt $Width; $x++)
    {
      $BitMap.GetPixel($x,$y)
    }
  }

  Write-Verbose -Message "$($ColorList.Count) pixels found"

  $PaddingLength = 0

  for($i = $ColorList.Count - 1; $i -ge 0; $i--) 
  {
    if($ColorList[$i] -ne $PaddingColor)
    {
      break
    }
    $PaddingLength++
  }
  Write-Verbose -Message "PaddingLength: $PaddingLength"

  $ColorList = $ColorList |Select-Object -First ($ColorList.Count - $PaddingLength)

  $Data = for($i = 0; $i -lt $ColorList.Count; $i++) 
  {
    $Color = $ColorList[$i]
    Write-Output -InputObject $Color.R
    Write-Output -InputObject $Color.G
    Write-Output -InputObject $Color.B
  }

  if($Data[-1] -eq $PaddingByte)
  {
    if($Data[-2] -eq $PaddingByte)
    {
      return $Data | Select-Object -First ($Data.Count - 2)
    } else 
    {
      return $Data | Select-Object -First ($Data.Count - 1)
    }
  } 
  return $Data 
}
