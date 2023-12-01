exit
# Node.js 
#  An I/O Platform; talk to networks, file systems or other I/O sources; 
#  asynch-ly handles I/O per CALLBACKS (do X then Y), EVENTS (when X do Y), STREAMS and MODULES;
#  a single node process/broker between 3rd party I/O endpoints; 
#  IO: APIs, databases, HTTP/WebSockets, Files 
# npm: Node-Packaged Modules
#  They are just a folder of files wrapped up in a .tar.gz, 
#  and a file called package.json that declares the module version 
#  and a list of all modules that are dependencies of the module.
#  - Automatic install/upgrade
#  - Dependencies installed, per module, at known working versions
#  https://maxogden.com/node-packaged-modules.html
#
# Install @ Linux  
    nvm # Install per nvm Node Version Manager
    # A bash script to manage multiple node versions https://github.com/nvm-sh/nvm
    install.node@nvm.sh  # @ ... /IT/OS/Linux/Distros/Ubuntu/pkg-installs
    # Other install schemes ...
        # DEPRICATED ...  https://github.com/nodesource/distributions 
        #     # Download source; NodeJS 10.x
        #     curl -sL https://deb.nodesource.com/setup_10.x | bash -  
        #     # installs/updates node, npm, and all dependencies (python, ...)
        #     apt-get install -y nodejs  
        #     # Optional: install build tools to compile and install native addons
        #     apt-get install -y build-essential  
        # # AWS/RHEL (as root)  
        #     curl -sL https://rpm.nodesource.com/setup_10.x | bash -  
        #     yum install -y nodejs npm --enablerepo=epel
        #     # Optional: install build tools
        #     yum install gcc-c++ make 
        #     # or 
        #     yum groupinstall 'Development Tools'
    
    # Install Node.js per nvm 
    nvm ls                      # show currently used versions
    nvm ls-remote --lts         # list available LTS versions 
    nvm install 'lts/*'         # install latest LTS version
    nvm install --lts=dubnium   # install latest LTS Dubnium 
    nvm install 'lts/dubnium'   # ... same 

        # BUG: suddenly appeared. 
        # REF: https://stackoverflow.com/questions/49449719/nvm-n-a-version-n-a-n-a-is-not-yet-installed
        # @ ~/.bashrc :: line inserted per nvm install. Recreate:
            $ . ~/.nvm/nvm.sh  # ... recreates bug ...
            Error: N/A: version "N/A -> N/A" is not yet installed
            $ nvm ls
            ...
            default -> lts/* (-> N/A)      # Points to non-existent Node version.
        # FIX ... 
            $ nvm alias default node       # Point "default" to latest Node version.
            $ nvm ls                       # Validate fix ...
            ...
            default -> node (-> v10.15.3)  # Points to valid/latest Node version. Fixed!

# Install @ Windows
    choco search nodejs
    choco install nodejs-lts
    choco upgrade nodejs-lts
    choco list --lo  # list all local (installed) pkgs

    # # Download Node & npm [LTS]
    # #   https://nodejs.org/en/download/ 
    # 	# - first DELETE all existing files @ %ProgramFiles%\nodejs
    # 	# - then EXTRACT/COPY+PASTE (the new) FILES into that same folder.
    # # Packages
    # #   https://docs.npmjs.com/
    # #
    # # Win7 config for Node.js Env.
    #   # for Node.js Env. MACHINE-WIDE
    #   SETx NODE_PATH "%AppData%\npm\node_modules" /M
    #   SET NODE_PATH=%AppData%\npm\node_modules
    #   # for Node.js Env. LOCAL to current CMD
    #   CALL "%ProgramFiles%\nodejs\nodevars.bat"

# Validate installation	
    node -v  
    npm -v

# run a javascrpt file
    node fname.js

# test that it's working ... 
    $ echo "console.log('Test foo!')" > index.js
    node index.js  #=> Test foo!

# passing arguments
# modules

  # See:  REF.Node.REPL.js

