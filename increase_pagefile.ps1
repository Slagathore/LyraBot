# This script requires administrator privileges
# Right-click this file and choose "Run as administrator"

$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
$physicalMemory = [Math]::Round($computerSystem.TotalPhysicalMemory / 1GB)
$recommendedPageFile = $physicalMemory * 2

# Display current page file settings
Write-Host "Current page file settings:" -ForegroundColor Cyan
$currentPageFile = Get-WmiObject -Class Win32_PageFileSetting
foreach ($pf in $currentPageFile) {
    Write-Host "  Drive: $($pf.Name)" -ForegroundColor Yellow
    Write-Host "  Initial Size (MB): $($pf.InitialSize)"
    Write-Host "  Maximum Size (MB): $($pf.MaximumSize)"
}

Write-Host "`nSystem information:" -ForegroundColor Cyan
Write-Host "  Physical memory: $physicalMemory GB"
Write-Host "  Recommended page file: $recommendedPageFile GB"

# Ask for confirmation before changing settings
$confirm = Read-Host "`nDo you want to set the page file to $recommendedPageFile GB? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Operation canceled." -ForegroundColor Red
    exit
}

try {
    # Disable automatic page file management
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    $computerSystem.AutomaticManagedPagefile = $false
    $computerSystem.Put()

    # Set custom page file size on C: drive
    $pageFileSetting = Get-WmiObject -Class Win32_PageFileSetting
    
    if ($pageFileSetting) {
        # Modify existing page file
        $pageFileSetting.InitialSize = $recommendedPageFile * 1024
        $pageFileSetting.MaximumSize = $recommendedPageFile * 1024
        $pageFileSetting.Put()
    } else {
        # Create new page file
        $newPageFile = ([WMIOBject]"root\cimv2:Win32_PageFileSetting").CreateInstance()
        $newPageFile.Name = "C:\pagefile.sys"
        $newPageFile.InitialSize = $recommendedPageFile * 1024
        $newPageFile.MaximumSize = $recommendedPageFile * 1024
        $newPageFile.Put()
    }
    
    Write-Host "`nPage file successfully modified! You need to restart your computer for changes to take effect." -ForegroundColor Green
} catch {
    Write-Host "`nError modifying page file: $_" -ForegroundColor Red
    Write-Host "Make sure you're running this script as Administrator." -ForegroundColor Yellow
}

Read-Host "Press Enter to exit"
