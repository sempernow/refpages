exit
# Workflow (iterative)      |=> Dev => Test => Deploy =|  
#                           |<=========================|   
# 
# Code deploy @ SINGLE CONTAINER Setup
# - Push to github 
# - Travis auto pulls repo 
# - Travis builds image; tests code 
# - Travis pushes code to AWS EB 
# - EB builds image (AGAIN); deploys it 
#     A redundant rebuild/resources @ EB, 
#     detracting from its primary role as public endpoint.
# 
#   Developer => |-----  GitHub-Repo  ------| => Travis-CI => AWS
#                Feature =(pull-req)=> Master     (YAML)     (EB)
#                |--------  Code-deploy (Automated)  -----------|
#
# Code deploy @ MULTI-CONTAINER Setup 
# - Push to github 
# - Travis auto pulls repo 
# - Travis builds TEST image; tests code 
# - Travis builds PROD images (worker, client, api, nginx)
# - Travis pushes PROD images to Docker Hub 
# - Travis pushes project (msg) to AWS EB 
# - EB pulls images from Docker Hub; deploys 
#
#   Developer => |-----  GitHub-Repo  ------| => Travis-CI => Docker-Hub  => AWS
#                Feature =(pull-req)=> Master     (YAML)     (Image Repo)   (EB)
#                |---------------  Code-deploy (Automated)  -------------------|
#
# Project frontend :: Workflow (Code-deploy) for a React app 
# - SINGLE CONTAINER 
# - React project generator tool (create-react-app)
# - Automating workflow is the focus here, not the code 
    npm install -g create-react-app  # install tool (as Administrator)
    # use it to create 'frontend' project under a workspace dir
    create-react-app frontend
    pushd frontend
    ./frontend
        ./src/App.js  # The React app
    # dev workflow commands 
    npm start         # Start dev server, e.g., localhost:3000, which loads the app.
    npm test          # Starts the test runner; deploy if all tests pass.
    npm run build     # Bundles app into static files prod; concat to ONE file
        ./build/static/js/     # creates 'build' dir, and ...
             main.d1cb61c2.js   # the BUNDLED app (minified) 
        # In Development      In Production     <== Docker containers 
        # --------------      -------------
          npm run start       npm run build
          Dockerfile.dev      Dockerfile

        ./Dockerfile.dev
            FROM node:alpine
            WORKDIR '/app'  # folder @ container
            COPY package.json .
            RUN npm install 
            COPY . .  # copies all node_modules (116MB), so can delete (locally) after build
            CMD ["npm", "run", "start"]
    # build app
    npm run build 
    npm start  # verifies app build 
    # build container (containing the app)
    docker build -f Dockerfile.dev .  # specify since not standard fname 
    # now can DELETE local ./node_modules dir (116MB), due to 
    # judicious ordering of Dockerfile tasks; and REBUILDS QUICKLY;
    docker build -t semperdocker/frontend -f Dockerfile.dev .
    # run the app (from the container)
    docker run -p 3000:3000 $IMAGE_ID 
    docker stop $(docker ps -q)  # stop all running containers
    # make CHANGEs to app, e.g., HTML, and run again
    ./frontend/src/App.js  # The React app
        # dockerfile `COPY` does nothing for CHANGEs to app, WITHOUT REBUILD, 
        # but can use `docker run -v ...`, VOLUMEs, to establish a REFERENCE ...
        # BIND MOUNT a volume; --volume LIST; -v LIST; 
        # https://docs.docker.com/storage/bind-mounts/  
            -v LOCAL:CONTAINER  # MAP
            -v CONTAINER        # placeholder; do NOT map
        #
        #	local folder       Docker container
        #   ------------       ----------------
        #	/frontend           /app
        #	         <==========  /node_modules  (local deleted)
        #	/src     <==========  /reference 
        #	/public  <==========  /reference 
    docker run -p '3000:3000' -v '/app/node_modules' -v $(pwd):/app  $IMAGE_ID 
    #                          bookmark               map (local to container) 
    # Hot-loaded changes per React. Mapped dirs (local-to-container) per Docker.
    ./src/App.js 
    # All implemented per docker-compose CLI tool; instructions per YAML file: 
    ./docker-compose.yml
        services: 
          web:
            build:                            # `build: .` would fail due to `Dockerfile.dev`
              context: .                      #  point to project root
              dockerfile: Dockerfile.dev
            ports: 
              - "3000:3000"                   # local:container (port map)
            volumes:                          # volume mapping; analogous to that at docker tool
              - /app/node_modules             # container (nothing @ local)
              - .:/app                        # local:container 
    # run the app (from the container)
    docker-compose up [--build]  # optionally rebuild 

# MULTIPLE CONTAINERS 
    # Architecture @ EB
                     -------------            ---------
                     |  if /     |<=(p.3000)=>| Nginx |<=> React
          <=(p.80)==>|  Nginx    |            ---------
                     |  if /api  |<=(p.5000)=> Express Server 
                     -------------
        # Second Nginx is NOT necessary for this app;
        /client/nginx/default.conf  # directives; p.3000, etc
    # Mod(s) for PROD ...
    Dockerfile  # @ each service; create & copy its Dockerfile.dev 
    CMD ["npm", "run", "start"] # merely change "dev" to "start"
    # manually build/run/validate (before pull-req @ GitHub master)
    docker-compose build --force-rm --no-cache  
    docker-compose up  

    # Travis-CI
    # - pull from GitHub
    # - build test 
    # - run test
    # - build PROD on success
    # - push to Docker Hub repo
    .travis.yml  # @ GitHub repo/master

    # AWS-EB specific file; Container Definitions; analogous to 'docker-compose.yml'
    Dockerrun.aws.json 
