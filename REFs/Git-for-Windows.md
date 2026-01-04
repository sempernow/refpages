# [Git-for-Windows](https://gitforwindows.org/ "GitForWindows.org") 

## Versioning/Module Incompatibilities of `git`/`go`

Deleting cache (@ `GOPATH`) does nothing for versioning. Git tags (versions) are immutable; entirely orthogonal to, and override, commits. For example, even if an old tag (version) is deleted from its commit (both locally and at origin) and then added back to a newer commit, the old commit remains hard welded thereto regardless. The only way to update its imported Golang package (@ `/vendor`) to the new commit is to either update the version number (@ `git`) and manually change to it at `go.mod`, not use `git` versioning (tags) at all, or "version" per repo name, e.g., `repo/v3`. That last method gets declared at `go.mod` as `v0.0.0-...-<SVN-reference>`. Note also that `go get ...` behavior changes per `GO111MODULE` setting; to include that it may or may not download to `GOPATH` if `on`, and that declaring the version (per `path@version` syntax) is forbidden if `off`.


## [Install](https://chocolatey.org/packages?q=git&moderatorQueue=&moderationStatus=all-statuses&prerelease=false&sortOrder=package-download-count "Chocolatey.org/packages") 

```bat
choco install git.install
```

## Usage 

### [Git for Windows](https://gitforwindows.org/)

```bat
rem -- MINGW64 @ cmd [/bin/bash.exe] --
bash.exe --init-file "%USERPROFILE%\.bash_profile" 

rem --MINGW64 @ mintty [git-bash.exe] --
start git-bash.exe 

rem -- git @ sub-shell [git-cmd.exe] --
"%ProgramFiles%\Git\git-cmd.exe" 

rem -- git GUI --
"%ProgramFiles%\Git\cmd\git-gui.exe"
```

#### [`winpty` @](https://github.com/rprichard/winpty "GitHub") `mintty`
```bash
winpty bash  # Launches TTY emulator @ sub-shell
```

### [Git-for-Windows SDK](https://github.com/git-for-windows/build-extra/ "GitHub") (`GitSDK.bat`)
> ... files and scripts to help build Git for Windows on MSYS2
```bat
rem TYPE: msys|msys2|mingw32|mingw64
msys2_shell.cmd -%_TYPE% -where %_FOLDER%
```

### [GitHub Desktop](https://desktop.github.com/) (`GitHub.bat`)

## Install

### 2018 
	Installed per downloaded installer  https://gitforwindows.org/
	Try choco tool next time.


### 2017
	See git.bat for the various Git launch commands/configs 
	Integrates fairly well with Cygwin and cmdlib environments, 
	though some namespace collisions; adjust per configs @ git.bat

	ssh config @ `/Git/etc/ssh` folder; 
	replaced it with symlink to Cygwin's 
	ssh config @ `/home/$USERNAME/.ssh` 
	sucessfully tested by tunneling into router 

 
	Git for Windows is git-scm 
	https://github.com/git-for-windows 

	Includes MinGW64 & MSYS2 (projects) binaries; 
	runs @ Window Env., @ cmd or mintty terminals

		mintty Wiki [GitHub]  https://github.com/mintty/mintty/wiki/Tips

		mintty app, @ /usr/bin, launches GUI 
		select/menu for MSYS2/MINGW32/MINGW64. 
		launches terminal per selection; includes @ $PATH ...
		
		binaries [@ '/c/Program Files/Git']

			/usr/local/bin        non-existent 
			/usr/bin              MAIN REPOSITORY  
			/bin                  3 files; bash, git, sh

		+ MSYS2 specific binaries 

			/opt/bin              non-existent

		+ MINGW64 specific binaries 

			/mingw64/bin          MINGW64 specific (git) + overlapping (openssl)

### 2016
Git for Windows SDK https://github.com/git-for-windows/build-extra/

	MinGW + Msys + Git forms the build 
	environment for Git development [GCC + make + Git]

Git for Windows

	Installed 2016-11-09

	Use 'Git.bat B' from commandline [Git for Windows] [MinGW64] [mintty]

	Cygwin's version was uninstalled after SSL/cert
	failure errors on 'git clone <repository>', and
	don't care to muck w/ every little utility @ Cygwin ...
	http://codinggorilla.domemtech.com/?p=1416
		
		(See Git.bat @ UzerX cmd-library)
		
		'git add ...' is NOT reversible, even after removing per 'git rm ...'
		I.e., .git retains massive size, including that of what was 'removed'.
		
		Do NOT use Git-for-Windows [MinGW64] @ Cygwin Env.
		Use mintty launched per git-bash.exe --cd-to-home [Git.bat B]
		
		git-bash.exe [Git-for-Windows] CONFIGs per '.bash_profile' @ %USERPROFILE% 
		
			'.bash_profile' mod ...

				HOME='/c/Cygwin/home/USERNAME'
				source "${HOME}/etc/_UzerX.cfg"