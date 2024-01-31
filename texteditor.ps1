Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Dark Notepad"
$form.Size = New-Object System.Drawing.Size(1000, 800)  # Default window size
$form.BackColor = [System.Drawing.Color]::FromArgb(33, 33, 33)  # Dark background color

# Create a textbox for text input
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Multiline = $true
$textbox.Dock = 'Fill'
$textbox.BackColor = [System.Drawing.Color]::FromArgb(42, 42, 42)  # Darker background color
$textbox.ForeColor = [System.Drawing.Color]::White  # Text color
$textbox.Font = New-Object System.Drawing.Font("Consolas", 16)  # Default font size

# Add event handler for Ctrl+A (select all)
$textbox.Add_KeyDown({
    if ($_.Control -and $_.KeyCode -eq 'A') {
        $textbox.SelectAll()
    }
    elseif ($_.Control -and $_.KeyCode -eq 'S') {
        # Ctrl+S pressed, show Save As dialog
        Show-SaveAsDialog
    }
})

function Show-SaveAsDialog {
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    $saveFileDialog.InitialDirectory = [System.IO.Path]::GetTempPath()
    
    if ($saveFileDialog.ShowDialog() -eq 'OK') {
        $textbox.Text | Out-File -FilePath $saveFileDialog.FileName -Encoding UTF8
    }
}

# Create a menu strip
$menustrip = New-Object System.Windows.Forms.MenuStrip
$menustrip.BackColor = [System.Drawing.Color]::FromArgb(33, 33, 33)  # Dark background color
$menustrip.ForeColor = [System.Drawing.Color]::White  # Text color

# Create "File" menu
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"

# Create "Save" menu item
$saveMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$saveMenuItem.Text = "Save"
$saveMenuItem.Add_Click({
    # Handle Save menu click by showing Save As dialog
    Show-SaveAsDialog
})

# Create "Save As" menu item
$saveAsMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$saveAsMenuItem.Text = "Save As"
$saveAsMenuItem.Add_Click({
    Show-SaveAsDialog
})

# Create "Open" menu item
$openMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$openMenuItem.Text = "Open"
$openMenuItem.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    $openFileDialog.InitialDirectory = [System.IO.Path]::GetTempPath()
    
    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $textbox.Text = Get-Content -Path $openFileDialog.FileName -Raw
    }
})

# Create "Font" menu
$fontMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fontMenu.Text = "Font"

# Create "Change Font" menu item
$changeFontMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$changeFontMenuItem.Text = "Change Font"
$changeFontMenuItem.Add_Click({
    $fontDialog = New-Object System.Windows.Forms.FontDialog
    
    if ($fontDialog.ShowDialog() -eq 'OK') {
        $textbox.Font = $fontDialog.Font
        $menustrip.Font = New-Object System.Drawing.Font("Segoe UI", $textbox.Font.Size)
    }
})

# Create "Font Color" menu item inside "Font" submenu
$fontColorMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$fontColorMenuItem.Text = "Font Color"
$fontColorMenuItem.Add_Click({
    $colorDialog = New-Object System.Windows.Forms.ColorDialog
    
    if ($colorDialog.ShowDialog() -eq 'OK') {
        $textbox.ForeColor = $colorDialog.Color
    }
})
$fontMenu.DropDownItems.Add($fontColorMenuItem)

# Add menu items to "File" menu
$fileMenu.DropDownItems.Add($openMenuItem)
$fileMenu.DropDownItems.Add($saveMenuItem)
$fileMenu.DropDownItems.Add($saveAsMenuItem)

# Add "Font" menu items to "File" menu
$fileMenu.DropDownItems.Add($fontMenu)
$fontMenu.DropDownItems.Add($changeFontMenuItem)

# Add "File" menu to the menu strip
$menustrip.Items.Add($fileMenu)

# Add controls to the form
$form.Controls.Add($textbox)
$form.Controls.Add($menustrip)

# Display the form
$form.Add_Shown({ $form.Activate() })
$form.ShowDialog() | Out-Null
