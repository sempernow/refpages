# How to mute (radically lower the volume of) Win10 OS `*.wav` file(s) 

The malware that is Win10 OS entirely ignores the user's sound volume settings, playing the WAV files instead at ear-popping volumes per OS-triggered events. This is how to fix that.

1. Take ownership of the folder, subfolders and files 
    - `C:\Windows\Media` > Properties > Security > Advanced 
        - Owner > Change > Administrators
            - Checkbox @ apply to all objects thereunder.
2. Close the window
3. Reset ACLs of all thereunder 
    - `C:\Windows\Media` > Properties > Security 
    - Administrators > Edit > Full ...
4. Adjust volume per file 
    - @ PortableApps > Audacity
        - Open > `C:\Windows\Media` > `FNAME.wav`
        - Select > All 
        - Effects > Amplify
            - -24 (db)
        - Export > WAV (to a temp dir)
5. Copy the modified files back to their origin.

### &nbsp;
<!-- 

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")


# Link @ (HTML | MD)

([HTML](___.md "___"))   


# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->

