$collectionPath = 'Path\to\parent\directory'
$pdfDir = 'Path\to\where\pdf\should\be\saved'
# change the Test-Path values to match your needs
# this will check each directory within $collectionPath for directories named "Renamed TIF", "Renamed TIFF" etc, and process them
# if you are sensible, you will choose a single naming convention and this array will only contain one name!
$tiffDirectoryNames = @("Renamed TIF", "Renamed TIFF", "TIFFs renamed", "TIFFs for conversion")

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

  # adjust this list to your needs
  # these should be the names of subdirectories within $collectionPath that are NOT to be processed
  $RecordsToExclude = @("sb00009", "sb00010", "sb00011")
  if (-Not ($RecordsToExclude -contains $_.Name )) {

    $dir = $_
    Get-ChildItem $dir |ForEach-Object {
      if ($tiffDirectoryNames -contains $_.Name ) {
        if (Test-Path -Path $_) {
          $resolvedPath = Resolve-Path $_
          Write-Host "Processing" $dir.Name
          Process-To-PDF -resolvedPath $resolvedPath -parentName $dir.FullName
          }
      }
    }
  }

}