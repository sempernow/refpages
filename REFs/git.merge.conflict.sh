# Initialize repo
mkdir merge-demo && cd merge-demo
git init -b main

# Create initial file
echo "Line 1
Line 2
Line 3" > demo.txt
git add demo.txt
git commit -m "Initial commit"

# Create feature branch with changes
git checkout -b feature
echo "Line 1
Line 2 (modified in feature)
Line 3" > demo.txt
git commit -am "Feature branch modification"

# Switch back to main with conflicting changes
git checkout main
echo "Line 1
Line 2 (modified in main)
Line 3" > demo.txt
git commit -am "Main branch modification"

exit $?
#######

☩ git merge feature
Auto-merging demo.txt
CONFLICT (content): Merge conflict in demo.txt
Automatic merge failed; fix conflicts and then commit the result.

☩ cat demo.txt
Line 1
<<<<<<< HEAD
Line 2 (modified in main)
=======
Line 2 (modified in feature)
>>>>>>> feature
Line 3

☩ git diff --theirs
* Unmerged path demo.txt
diff --git a/demo.txt b/demo.txt
index 2481be2..02eeb46 100644
--- a/demo.txt
+++ b/demo.txt
@@ -1,3 +1,7 @@
 Line 1
+<<<<<<< HEAD
+Line 2 (modified in main)
+=======
 Line 2 (modified in feature)
+>>>>>>> feature
 Line 3

Ubuntu (main|MERGING) [19:20:56] [1] [#0] /c/TEMP/merge-demo
☩ git checkout --ours demo.txt
Updated 1 path from the index

Ubuntu (main|MERGING) [19:21:39] [1] [#0] /c/TEMP/merge-demo
☩ cat demo.txt
Line 1
Line 2 (modified in main)
Line 3