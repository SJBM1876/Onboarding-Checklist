# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Define an array to store checklist items
$ChecklistItems = @()

# Add checklist items to the array
$ChecklistItems += [ordered]@{ Task = "Assign License"; Status = $false }
$ChecklistItems += [ordered]@{ Task = "Create Mailbox"; Status = $false }
$ChecklistItems += [ordered]@{ Task = "Grant OneDrive Permissions"; Status = $false }
$ChecklistItems += [ordered]@{ Task = "Add to Teams"; Status = $false }
$ChecklistItems += [ordered]@{ Task = "Set Up MFA"; Status = $false }
$ChecklistItems += [ordered]@{ Task = "Configure SharePoint Access"; Status = $false }

# Log file for completed tasks
$LogFilePath = "$env:USERPROFILE\Desktop\ChecklistLog.txt"

# Function to log completed tasks
function Log-Task {
    param (
        [string]$TaskName
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "$Timestamp - Completed: $TaskName"
}

# Function to display the checklist in a GUI
function Show-ChecklistGUI {
    # Create the form
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "Task Checklist"
    $Form.Size = New-Object System.Drawing.Size(400, 400)
    $Form.StartPosition = "CenterScreen"

    # Create a ListBox to display tasks
    $ListBox = New-Object System.Windows.Forms.ListBox
    $ListBox.Size = New-Object System.Drawing.Size(350, 200)
    $ListBox.Location = New-Object System.Drawing.Point(20, 20)

    # Populate the ListBox with tasks
    foreach ($Item in $ChecklistItems) {
        $StatusText = if ($Item.Status) { "[Completed]" } else { "[Pending]" }
        $ListBox.Items.Add("$StatusText - $($Item.Task)")
    }

    # Create a button to mark tasks as complete
    $CompleteButton = New-Object System.Windows.Forms.Button
    $CompleteButton.Text = "Mark as Complete"
    $CompleteButton.Size = New-Object System.Drawing.Size(150, 30)
    $CompleteButton.Location = New-Object System.Drawing.Point(20, 240)

    # Create a button to close the form
    $CloseButton = New-Object System.Windows.Forms.Button
    $CloseButton.Text = "Close"
    $CloseButton.Size = New-Object System.Drawing.Size(150, 30)
    $CloseButton.Location = New-Object System.Drawing.Point(200, 240)

    # Add event handler for the Complete button
    $CompleteButton.Add_Click({
        if ($ListBox.SelectedIndex -ge 0) {
            # Mark the selected task as complete
            $SelectedTaskIndex = $ListBox.SelectedIndex
            if (-not $ChecklistItems[$SelectedTaskIndex].Status) {
                $ChecklistItems[$SelectedTaskIndex].Status = $true

                # Update the ListBox item text
                $ListBox.Items[$SelectedTaskIndex] =
                "[Completed] - " + $ChecklistItems[$SelectedTaskIndex].Task

                # Log the completed task
                Log-Task -TaskName $ChecklistItems[$SelectedTaskIndex].Task

                # Notify the user of completion
                [System.Windows.Forms.MessageBox]::Show(
                        "Task marked as complete: " +
                                $ChecklistItems[$SelectedTaskIndex].Task,
                        "Success",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                )
            } else {
                [System.Windows.Forms.MessageBox]::Show(
                        "This task is already marked as complete.",
                        "Warning",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Warning
                )
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show(
                    "Please select a task to mark as complete.",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
    })

    # Add event handler for the Close button
    $CloseButton.Add_Click({
        if ($ChecklistItems | Where-Object { $_.Status -eq $false }) {
            [System.Windows.Forms.MessageBox]::Show(
                    "Some tasks are still pending.",
                    "Reminder",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        } else {
            [System.Windows.Forms.MessageBox]::Show(
                    "All tasks are completed!",
                    "Congratulations",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
            )
        }
        $Form.Close()
    })

    # Add controls to the form
    $Form.Controls.Add($ListBox)
    $Form.Controls.Add($CompleteButton)
    $Form.Controls.Add($CloseButton)

    # Display the form as a modal dialog box
    $Form.ShowDialog()
}

# Run the GUI checklist application
Show-ChecklistGUI
