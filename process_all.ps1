$collectionPath = 'Path\to\parent\directory'
$pdfDir = 'Path\to\where\pdf\should\be\saved'
$counter = 0

function Process-To-PDF {

      param (
        $resolvedPath,
        $parentName
      )

      $StartTime = $(get-date)
      magick -quiet $resolvedPath\*.tif -resample 200 -unsharp 1.5x1+0.7+0.02 -compress JPEG -quality 60 -depth 8 $pdfDir\$parentName.pdf
      $elapsedTime = $(get-date) - $StartTime
      $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
      Write-Host "Time to process" $parentName : $totalTime
}

Get-ChildItem –Path $collectionPath |Foreach-Object {

    # if starting from scratch, counter is 0
    # change the counter check if your process fell over and you want to start from where you left off
    # e.g. `if ($counter -gt 23) {`

    if ($counter -gt -1) {

      # change the Test-Path values to match your needs
      # this will check each directory within $collectionPath for directories named "Renamed TIF", "Renamed TIFF", or "TIFFs renamed" in that order, and process the first one it finds

      if (Test-Path -Path $_\"Renamed TIF") {
        $resolvedPath = Resolve-Path $_\"Renamed TIF"
        Write-Host "Processing" $_.Name
        Process-To-PDF -resolvedPath $resolvedPath -parentName $_.Name
        }

        elseif (Test-Path -Path $_\"Renamed TIFF") {
        $resolvedPath = Resolve-Path $_\"Renamed TIFF"
        Write-Host "Processing" $_.Name
        Process-To-PDF -resolvedPath $resolvedPath -parentName $_.Name
        }

        elseif (Test-Path -Path $_\"TIFFs renamed") {
        $resolvedPath = Resolve-Path $_\"TIFFs renamed"
        Write-Host "Processing" $_.Name
        Process-To-PDF -resolvedPath $resolvedPath -parentName $_.Name
        }

        else {
        Write-Host "Skipping" $_.Name
        }
    }
    $counter++
}