# Set the default branch name and empty QEAX file path
$branchName = "main"
$emptyQEAX = "C:\Users\piasm1\OneDrive - Medtronic PLC\Documents\empty.qeax"

# Change to the directory containing the Git repository
Set-Location "C:\Users\piasm1\OneDrive - Medtronic PLC\Documents\sr-hugo-model"

# Get the list of local branches in the repository
$branches = git branch --format "%(refname:lstrip=2)"

# Get total commit count
$totalCommits = git rev-list --all --count

# Ser Commit total count index
$totalCommitsConverted = 0

foreach ($branch in $branches) {
    Write-Host "---------------------------------------"
    Write-Host "Branch: $branch"

    # Switch to the branch
    git checkout $branch --quiet

	# Get the commit history for the specified branch & number of commits on the branch
	$commitHashes = git log --reverse --pretty=format:"%h" $branch
	$totalBranchCommits = $commitHashes.Length
	
	# Set branch commit convert count
	$branchCommitsConverted = 0
	
	# Iterate through each commit
	foreach ($commitHash in $commitHashes) {
		
		
		Write-Host "---------------------------------------"
		Write-Host "Branch: $branch"
        Write-Host "Current Time: $(Get-Date -Format "HH:mm")"
        Write-Host "Commit: $commitHash"
		Write-Host "Remaining Branch Commits: $($totalBranchCommits - $branchCommitsConverted)"
        Write-Host "Remaining Total Commits: $($totalCommits - $totalCommitsConverted)"
		
		# Check out the commit
		git checkout $commitHash --quiet

		# Perform conversion of eapx to qeax
		$files = Get-ChildItem -Filter *.eapx
		$files | ForEach-Object -Process {
			$name=".\"+$_.Name
			$newName=".\"+$_.BaseName+".qeax"
			Write-Host "Converting $name to $newName"
			&"C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe" merge --theirs $emptyQEAX --mine $name --out $newName
			echo "Exitcode $LASTEXITCODE"
		}
		

		
		# Stage the modified file and remove & delete the old file
		git add $newName
		git rm $name
		
		# Create a new commit with the modified file
		git commit --no-edit --amend --quiet
		
		# Uptick commit conversion indices
		branchCommitsConverted = branchCommitsConverted + 1
		totalCommitsConverted = totalCommitsConverted + 1
		
		Write-Host "---------------------------------------"
		Write-Host "Current Time: $(Get-Date -Format "HH:mm")"
	}
}
# Switch back to the default branch
git checkout $branchName --quiet