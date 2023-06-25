# Electron: an open source library by GitHub; began 2013 as atom editor
# Framework for building cross-platform desktop apps w/ HTML, JS, CSS
# It's a JavaScript runtime that bundles Node.js + Chromium, so, tricky versioning
# https://electron.atom.io/
# https://github.com/electron/electron
# 
# 134 MB <==> for the "Hello World" 'electron-quick-start' app.

	# Install as a development dependency
	npm install electron --save-dev
	# Install the `electron` command globally in your $PATH
	npm install electron -g
	# Install dependencies
	npm install
	# Run the app; per 'package.json' :: "scripts" > "start"
	npm start # E.g., 'electron .' per package.json

# GitHub repo pattern
	git clone REPO_NAME_URL # from PARENT dir; repo-name-dir NOT EXIST yet
	cd REPO_NAME_DIR        # run npm commands LOCALLY; target repo-name-dir
	npm install             # optional; install dependencies LOCALLY, if desired
	npm start               # run the app; task per './package.json' @ 'start' key value

# Tools  https://electron.atom.io/community/
# Tutorials https://github.com/electron/electron/tree/master/docs/tutorial
# App Packaging - bundle/make executable[s] per platform
# App Distribution - include in electron distribution
# https://github.com/electron/electron/blob/master/docs/tutorial/application-distribution.md

# Electron Userland [GitHub] 
# https://github.com/electron-userland

	# electron-packager 
	# Customize and package your Electron app with OS-specific bundles via JS or CLI
	# https://github.com/electron-userland/electron-packager
	# https://electron.atom.io/docs/tutorial/application-packaging/

		# install @ npm scripts [preferred]
		npm install electron-packager --save-dev
		# install @ cli
		npm install electron-packager -g
		
		# package :: per platform/arch
		electron-packager <sourcedir> <appname> --platform=<platform> --arch=<arch> [optional flags...]
		# package :: ALL
		electron-packager <sourcedir> <appname> --all [optional flags...]
		
		npm run package-win # IFF @ package.json > "scripts" key ...
			"package-win": "electron-packager . --overwrite --asar=true --platform=win32 --arch=ia32 --icon=assets/icons/win/icon.ico --prune=true --out=release-builds --version-string.CompanyName=UzerNOW --version-string.FileDescription=\"UzerNOW, LLC\" --version-string.ProductName=\"UzerApp\"", ...

		# Interactive [wrapper] 
		# A better way to use electron-packager
		npm install -g electron-packager-interactive # install it
		epi # use it

	# electron-builder [untested]
	# package and build a ready for distribution Electron app with “auto update” support out of the box
	# https://github.com/electron-userland/electron-builder

	# autoUpdater 
	# Enable apps to automatically update themselves; provides an interface for the Squirrel framework; can quickly launch a multi-platform release server for distributing your app, per nuts, electron-release-server, squirell-release-server,...
	# https://electron.atom.io/docs/api/auto-updater/
	
# Quick Start  
# https://electron.atom.io/docs/tutorial/quick-start/
# https://github.com/electron/electron-quick-start

# API Demos
# https://github.com/electron/electron-api-demos
# BrowserWindow 
#  Render Process - each browser window is its own process; may be visible [show:true] or invisible [show:false]; default/no-key is visible
  let win = new BrowserWindow({ width: 400, height: 320, show:true })

