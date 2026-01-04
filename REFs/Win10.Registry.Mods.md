# Windows (7|10) Registry Mods 
Negotiating the labyrinth.  

## Keys affecting File Type Association (FTA) and other useful mods 

Change a filetype's __icon__, reported __type__, and __handler__(s), and/or add a (custom) app to File Explorer's context menu. The relevant registry keys, and two CLI-based methods for modifying them, are detailed herein. One method involves exporting, modifying, and then adding back `.reg` files. The other method is entirely programmatic. Both allow for scripting to batch process any list of such mods. 

- Some (protected) file types require a two-step process to modify their FTA app or icon; first delete the key, then add it back. This is due to restrictions written into a type's subkey(s). Examples of such are detailed below.  

- If changes aren't immediately apparent after modifications, then toggle the targeted type's handler, e.g., to `Notepad` and then back, per "`Open with`"->"`Always use ...`", and/or refresh Windows icon cache per `ie4uinit.exe -show`. 

Lots of mystery, paranoia, and misinformation surround the Windows registry. Having worked with it quite a bit over the decades, experience indicates that any target key(s) should first be exported and archived, unaltered, as can be the entire registry. Keys can then be restored simply and reliably, unless the damage is too extensive. Again from experience, just about the only way to truly screw things up beyond the target key is to programmatically insert a malformed key or entry. That is, to inject improper syntax. Even then, it takes a very unfortunate mix of such syntax to harm the registry irreparably, or otherwise even affect it beyond the target key. The registry is not fragile.

## FTA entries 
- Most reside at subkeys of HKEY_CLASSES_ROOT (`HKCR`)

### `HKCR\.{TYPE}`  

- Modify only by pointing to a (created) key where the FTA mods reside. A standard naming convention used by applications for their FTAs is `HKCR\{APP}.{TYPE}` or `HKCR\{APP}{TYPE}`. Absent any such app, the naming convention is `HKCR\{TYPE}file` or `HKCR\{TYPE}_auto_file`. All such keys are equivalents; they're for FTA settings, as detailed later. This key should point to the one desired. E.g., ... 

    ````
    [HKEY_CLASSES_ROOT\.{TYPE}]
    @="{TYPE}file"
    ```` 

- Two entry values prevent certain other filetype mods. __Delete them__ as necessary, if they exist.  

    ````
    [HKEY_CLASSES_ROOT\.{TYPE}]
    @="{TYPE}"
    "EditFlags"=dword:002...
    "FriendlyTypeName"="@C:\\...\\ieframe.dll,-914"
    ````
    - `"EditFlags"=-`  
    - `"FriendlyTypeName"=-`

    >These entries may also exist at other registry keys regarding the filetype, e.g., at subkeys under the `HKCU` hive (`HKCU\SOFTWARE\...\Explorer\FileExts\.{TYPE}`). Such keys regenerate any required subkey per user-select actions, and so may be deleted entirely, as discussed later.  

- Add `{TYPE}` filetype to the `New` file (creation) list @ File Explorer's context menu, along with an optional template file:   

    ````
    [HKEY_CLASSES_ROOT\.{TYPE}\ShellNew]
    "NullFile"=""
    "FileName"="C:\\path to\\optional template file\\New.{TYPE}"
    ````

    >This __optional__ `New` list mod is __orthogonal__ to FTA mod(s). It's __a very useful mod__, spawining the custom per-type template file anew in the current folder with a single click. 

### `HKCR\{TYPE}file`   
- __This is where most FTA customizations should reside__. Mods in this hive (`HKCR`) persist, survive, and recover from subsequent user-select FTA actions, unlike those in the `HKCU` hive. Be sure the primary file-type key, `HKCR\.{TYPE}`, is modified to point to this key, whatever this key is actually named. (See __naming convention__ discussed above.)   

    ````
    [HKEY_CLASSES_ROOT\{TYPE}file]
    @="{TYPE}"
    "Content Type"="text/{TYPE}"
    "PerceivedType"="text"
    ````  
    > *Here only*, at the `@="{TYPE}"` entry, `{TYPE}` can be __any string__; it's the __term for the file type__ reported by File Explorer, __not a key-name reference__ as is that same entry under the `HKCR\.{TYPE}` key. *Confusions abound!*  

- Create `"NeverShowExt"=""` entry, optionally, to __hide the extension__ of `{TYPE}` __regardless of settings__  at   
File Explorer GUI. The entry is typically inserted here, though elsewhere for certain cases.   

    ````
    [HKEY_CLASSES_ROOT\{TYPE}file]
     "NeverShowExt"=""
    ````

    >`NeverShowExt` mod is only worth the trouble if in developer mode, whereof the File Explorer GUI setting is `display known file extensions`, which applies to all types. This method overrides that setting per target type, affecting no others.

- Set `DefaultIcon` to the desired (custom) __icon__ (path): 

    ````
    [HKEY_CLASSES_ROOT\{TYPE}file\DefaultIcon]
    @="C:\\ICONS\\{TYPE}.ico,0"
    ````

- Add FTA app(s) to File Explorer's context menu, as __handlers__  
for `Open`, `Edit`, `Run`, ... actions per `{TYPE}` filetype.  

    ````
    [HKEY_CLASSES_ROOT\{TYPE}file\shell]

    [HKEY_CLASSES_ROOT\{TYPE}file\shell\edit]

    [HKEY_CLASSES_ROOT\{TYPE}file\shell\edit\command]
    @="\"C:\\Program Files\\Microsoft VS Code\\Code.exe\" \"%1\""

    [HKEY_CLASSES_ROOT\{TYPE}file\shell\open]

    [HKEY_CLASSES_ROOT\{TYPE}file\shell\open\command]
    ; This would run the file and any args directly, e.g., '.bat' type
    @="\"%1\" %*"

    [HKEY_CLASSES_ROOT\{TYPE}\shell\run]
    @="Process per typeProcessor"
    "Icon"="S:\\path to\\the app\\typeProcessor.exe,0"

    [HKEY_CLASSES_ROOT\{TYPE}\shell\run\command]
    @="\"S:\\path to\\the app\\typeProcessor.exe\" \"%1\""

    ````  

    >Entries in this hive (`HKCR`) are __not overwritten__ by subsequent user actions, unlike those at `HKCU`. That is, though FTAs (app/icon) are __hijacked__ upon any subsequent "`Open with`"->"`Always use ...`" user-select action (`UserChoice`), they __do restore__ whenever that selection is back to the app designated herein. Contrarily, mods @ `HKCU` __never restore__, since they are overwritten upon any user-select. (See `HKCU\...\.{TYPE}\UserChoice` section.) 


>Again, __this subkey name__, `{TYPE}file`, is __just an example__. Such keys may be __auto-generated__ by some related app, per install or other process; or created by us. As mentioned in the section on the primary file-type key, `HKCR\.{TYPE}`, the standard naming convention for this FTA key, used by applications for their FTAs, is `HKCR\{APP}.{TYPE}` or `HKCR\{APP}{TYPE}`. And absent any such app, the naming convention is `HKCR\{TYPE}file` or `HKCR\{TYPE}_auto_file`. All such keys are equivalents; they're for these FTA settings. Just make sure the primary key points to the one containing the desired mods, whatever its name. It's okay for several such keys to exist for a given file-type, even though only one is used. 

### `HKCR\Applications\{APPNAME}`  

- Add an (unregistered) app to File Explorer's Context Menu. Use only when __not__ an FTA app; otherwise, use the method shown above, at a `HKCR\{TYPE}file\shell` sub-key.

    ````
    [HKEY_CLASSES_ROOT\Applications\{APP}.exe]

    [HKEY_CLASSES_ROOT\Applications\{APP}.exe\DefaultIcon]
    @="S:\\path to\\the app\\{APP}.exe,0"

    [HKEY_CLASSES_ROOT\Applications\{APP}.exe\shell]

    [HKEY_CLASSES_ROOT\Applications\{APP}.exe\shell\run]

    [HKEY_CLASSES_ROOT\Applications\{APP}.exe\shell\run\command]
    @="\"S:\\path to\\the app\\{APP}.exe\" \"%1\""
    ````


### `HKCU\SOFTWARE\...\Explorer\FileExts\.{TYPE}`  

- This key has __3 subkeys__, `OpenWithList`, `OpenWithProgids`, and `UserChoice`. They __can all be deleted__ and then, for good measure, recreated sans entries. They automatically regenerate/repopulate on any subsequent user-select.

- `UserChoice` sets the FTA; the one system-wide app associated with the filetype.   
Delete the `ProgId` entry. Okay to also (re)set it, but that is usually unnecessary.   

    ````
    [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.{TYPE}\UserChoice]
    "ProgId"="{TYPE}file"
    ````

    - Special cases, such as `url` and `html` ...

    ````
    [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice]
    "ProgId"="FirefoxHTML-308046B0AF4A39CB"
    ````

>`UserChoice` is where FTA and icon settings are __hijacked__ per app. The __subkey is overwritten__  per subsequent user-select (`UserChoice`) actions, "`Open with`"->"`Always use ...`", unlike setting(s) at the `HKCR\{TYPE}file` key. Comparing mods at the two hives, `HKCR` vs. `HKCU`, while the *immediate* effects from any user-select actions are the same, the big difference is that `HKCR` __settings recover__ (FTA & icon) upon user-select back to whatever handlers were programmed therein. Whereas any mods here (`HKCU\...\UserChoice`) are gone, having been overwritten. This is the cause of much user unhappiness. 

### `HKCR\Directory`   

- Add (non-FTA) apps to File Explorer's context menu.  
Example:  

    ````
    [HKEY_CLASSES_ROOT\Directory\Background\shell\CyghereAdmin]
    @="Cygwin Admin Here"
    "Icon"="C:\\Cygwin\\Cygwin-Terminal.ico,0"

    [HKEY_CLASSES_ROOT\Directory\Background\shell\CyghereAdmin\command]
    @=":\\cygwin\\bin\\minttyAdmin.exe -i /Cygwin-Terminal.ico -e /bin/xhere /bin/bash.exe"
    ; This method requires Cygwin's 'chere' package.
    ````
    >Such mods, in the `HKCR\Directory` subkey, are __orthogonal__ to FTA.   

## Programmatically Add/Modify/Delete Registry Keys 

- Two methods, using Windows native command-line tools
    - `regedit.exe /s|/e   FILE.reg`
    - `reg.exe add|delete  KEYpath`

### `regedit /s FILE.reg` method. 

- Simple, quick, and quite legible:  
    - Export the target (sub)key to a `.reg` file:  
`regedit /e "HKCR.foo.reg" "HKCR\.foo"`.   
    - Edit the file, and then load (merge) it back:   
`regedit /s "HKCR.foo.reg"`.

- Can be made as programmatic as the other method by having some orthogonal process auto-generate the `FILE.reg`. 

#### Delete
`regedit /s FILE.reg`

- Delete (sub)__keys__ by __prepending__ a hyphen, `-`, e.g., `[-HKEY...]`
- Delete __entries__ by __appending__ a hyphen, `-`, e.g., `"Entry"=-`

>At times when the `reg delete KEYpath /f` method fails per `DENIED: ...`, this method succeeds.  

#### Add  
`regedit /s FILE.reg`

- Merges the data. Same as double-click on the file, sans query/report GUI. That is, it does NOT remove keys/vals which do not exist in `FILE.reg`. So, manual or programmatic deletion is required for such effect. Likewise, __before (re)loading__ a (modified) key, __remove all irrelevant keys__ from the file. If not, it increases the chances of the key merge (partially) failing due to some active process(es) involving those irrelvant subkeys.  

### `reg add|delete KEYpath` method. 

- Accepts __abbreviations__ for the four main __hive__ key-names:  
    ````
    HKEY_LOCAL_MACHINE      HKLM
    HKEY_CURRENT_USER       HKCU
    HKEY_USERS              HKU
    HKEY_CURRENT_CONFIG     HKCC
    ````

- `reg query|save ...` are also useful here. 

#### Delete  

````
reg delete ROOTKEY\SubKey /f 

    ROOTKEY  [ HKLM | HKCU | HKCR | HKU | HKCC ]

    /va        delete all values under this key.

    /f         Forces the deletion without prompt.
````

> E.g., delete the key and all subkeys thereunder:  

```` 
reg delete HKCR\foofile /f   
````  

#### Add  

````
reg add ROOTKEY\SubKey ...

    ROOTKEY  [ HKLM | HKCU | HKCR | HKU | HKCC ]

    /v       The value name, under the selected Key, to add.

    /ve      adds an empty value name (Default) for the key

    /t       RegKey data types (defaults to REG_SZ)
             [ REG_SZ  | REG_MULTI_SZ | REG_EXPAND_SZ |
             REG_DWORD | REG_QWORD    | REG_BINARY    | REG_NONE ]

    /d       The data to assign to the registry ValueName being added.

    /f       Force overwriting the existing registry entry without prompt.
````
### Examples 

#### Add default (custom) icon for filetype `foo`:  

````
reg add HKCR\foofile\DefaultIcon /ve /d "C:\ICONS\foo.ico"  
````

Creates a default (`REG_SZ`) data-type value at an "empty value name", `@=...`, entry:   

````
[HKEY_CLASSES_ROOT\foofile\DefaultIcon]  
@="C:\\ICONS\\foo.ico"  
````

#### Add the `NeverShowExt` value (flag) for filetype `foo`:  
 
````
reg add HKCR\foofile /v "NeverShowExt"
````

Creates a value name having an empty string value of default (`REG_SZ`) data type:    

````
[HKEY_CLASSES_ROOT\foofile]  
"NeverShowExt"=""  
````

#### Add `foo` filetype and its template file, `New.foo`, to File Explorer's `New` menu:  
 
````
reg add HKCR\.foo\ShellNew /v "FileName" /d "C:\ICONS\ShellNew\New.foo"
reg add HKCR\.foo\ShellNew /v "Nullfile"
````

Creates:   

````
[HKEY_CLASSES_ROOT\.foo\ShellNew]
"FileName"="C:\\ICONS\\ShellNew\\New.foo"
"Nullfile"=""
````

#### `FTA`; associate filetype `foo` with its `edit` handler (app):

````
reg add HKCR\foofile\shell\edit\command /ve /t REG_EXPAND_SZ   
/d "\"C:\\Program Files\\Microsoft VS Code\\Code.exe\" \"^%1\""  
````  

Creates a `REG_EXPAND_SZ` data type:   

````
[HKEY_CLASSES_ROOT\foofile\shell\edit\command]  
@=hex(2):22,00,43,00,3a,00,5c,00,5c,00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,\  
00,20,00,46,00,69,00,6c,00,65,00,73,00,5c,00,5c,00,4d,00,69,00,63,00,72,00,\  
6f,00,73,00,6f,00,66,00,74,00,20,00,56,00,53,00,20,00,43,00,6f,00,64,00,65,\  
00,5c,00,5c,00,43,00,6f,00,64,00,65,00,2e,00,65,00,78,00,65,00,22,00,20,00,\  
22,00,25,00,31,00,22,00,00,00  
````  

#### `FTA`, same as above, using the default data-type:  

```` 
reg add HKCR\foofile\shell\edit\command /ve   
/d "\"C:\Program Files\Microsoft VS Code\Code.exe\" \"^%1\"" /f  
````  

Creates:  

````
[HKEY_CLASSES_ROOT\foofile\shell\edit\command]  
@="\"C:\\Program Files\\Microsoft VS Code\\Code.exe\" \"%1\""  
````  

### &nbsp;