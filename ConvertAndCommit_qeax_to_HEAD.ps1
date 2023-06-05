$repositoryPath = "Path/To/Repo"
$emptyQEAX = "Path/To/Empty.qeax"
$oldEAPX = "Model.eapx"
$newQEAX = "Model.qeax"




# Step 1: Change to the repository directory
Set-Location $repositoryPath

# Step 2: Fetch the latest changes from remote
git fetch

# Step 3: Get a list of all branches
$branches = git branch --list --format "%(refname:lstrip=2)"

# Step 4: Iterate through each branch
foreach ($branch in $branches) {
	git checkout $branch
	
	# Step 6: Merge the old EAPX with the QEAX file and output to the new QEAX file within the repository
	&"C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe" merge --theirs $emptyQEAX --mine $oldEAPX --out $newQEAX

	# Step 6: Commit the merged changes, adding QEAX and removing EAPX
	git add $newQEAX
	git rm $oldEAPX
	git commit -m "Convert to EA16 .qeax type"
	git push
}
