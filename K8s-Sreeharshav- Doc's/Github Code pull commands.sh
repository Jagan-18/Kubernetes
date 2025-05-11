

#GitHub Commands list to pull code to Github Repo.

1. git init
2. git add .
3. git commit -m "Commit message"
4. git branch -M main or (if case you want to pull other branch give that branch-name)
5. git remote add origin <GitHub link>
6. git push -u origin main

 ===>#while pull code in main branch get any error (error: failed to push some refs to <Git-url>)]
 
7. creating othere git branch and pull code to there.

   ==> git checkout -b <New-BranchName>
8. git add .
9. git commit -m "commit message"
10. git push -u origin <New BranchName>


create a new repository on the command line:
=============================================
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/Jagan-18/Netflix-clone.git
git push -u origin main




push an existing repository from the command line:
====================================================
git init
git add .
git commit -m "Push existing project to GitLab"
git remote add origin https://github.com/Jagan-18/Netflix-clone.git
git branch -M main
git push -u origin main
git push -u origin main