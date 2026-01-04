#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  Deploy Stack @ DigitalOcean 
# -----------------------------------------------------------------------------

export vm='d1' # reset to master
export m1=$vm  # Swarm Master/Leader

# Deploy 
app='swm'
docker stack deploy -c 'stack-app.yml' $app

# Verify 
docker stack ls
docker stack ps $app
ID                  NAME                IMAGE                             NODE     
ibmjwcz8ow6k        swm_redis.1         redis:latest                      d1       
6qu4h579s74i        swm_visualizer.1    dockersamples/visualizer:stable   d1       
21d9p7xkjwdv        swm_web.1           semperdocker/app-1:pt4            d1       
y0naxtwxpx4c        swm_web.2           semperdocker/app-1:pt4            d2       
fb6zjm8b4hd7        swm_web.3           semperdocker/app-1:pt4            d3       

docker stack ps $app --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"
ID                  NAME                IMAGE                             NODE 
ibmjwcz8ow6k        swm_redis.1         redis:latest                      d1   
6qu4h579s74i        swm_visualizer.1    dockersamples/visualizer:stable   d1   
21d9p7xkjwdv        swm_web.1           semperdocker/app-1:pt4            d1   
y0naxtwxpx4c        swm_web.2           semperdocker/app-1:pt4            d2   
fb6zjm8b4hd7        swm_web.3           semperdocker/app-1:pt4            d3   

svc='web'
docker service ls
docker service ps "${app}_${svc}"  # service replicas at all nodes

ID                  NAME                IMAGE                    NODE         
ur14ix0kjtx0        swm_web.1           semperdocker/app-1:pt4   s2           
t4nsb7ydqa2o        swm_web.2           semperdocker/app-1:pt4   s3           
q2nle06igock        swm_web.3           semperdocker/app-1:pt4   s1           

docker container ls  # @ $m1 node only 
CONTAINER ID        IMAGE                             COMMAND                  PORTS        NAMES
67dc9616dfb9        dockersamples/visualizer:stable   "npm start"              8080/tcp     swm_visualizer.1.6qu4h579s74i4f66xex1yssey
4ec00bd66909        redis:latest                      "docker-entrypoint.s…"  6379/tcp     swm_redis.1.ibmjwcz8ow6k7a8kjcscmwa46
a274b43b41b3        semperdocker/app-1:pt4            "python app.py"          80/tcp       swm_web.1.21d9p7xkjwdv4dvwjem39f1kd

docker node ps $(docker node ls -q)
ID                  NAME                   IMAGE                             NODE        
ibmjwcz8ow6k         \_ swm_redis.1        redis:latest                      d1        
ibmjwcz8ow6k         \_ swm_redis.1        redis:latest                      d1        
ibmjwcz8ow6k         \_ swm_redis.1        redis:latest                      d1        
6qu4h579s74i         \_ swm_visualizer.1   dockersamples/visualizer:stable   d1        
6qu4h579s74i         \_ swm_visualizer.1   dockersamples/visualizer:stable   d1        
6qu4h579s74i         \_ swm_visualizer.1   dockersamples/visualizer:stable   d1        
21d9p7xkjwdv         \_ swm_web.1          semperdocker/app-1:pt4            d1        
21d9p7xkjwdv         \_ swm_web.1          semperdocker/app-1:pt4            d1        
21d9p7xkjwdv         \_ swm_web.1          semperdocker/app-1:pt4            d1        
y0naxtwxpx4c         \_ swm_web.2          semperdocker/app-1:pt4            d2        
y0naxtwxpx4c         \_ swm_web.2          semperdocker/app-1:pt4            d2        
fb6zjm8b4hd7        swm_web.3              semperdocker/app-1:pt4            d3        

# Validate SWARM LOAD BALANCING ...different (random) container (id) per request:
ip=$(docker-machine ip $m1) #... PUBLIC IP 

curl $ip 
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> f19a972d83eb<br/><b>Visits:</b> 10
curl $ip 
<h3>App FooBar Mod @ pt4</h3><b>Hostname:</b> a274b43b41b3<br/><b>Visits:</b> 11

# -----------------------------------------------------------------------------
#  Teardown
# -----------------------------------------------------------------------------
docker stack rm $app 

# Disintegrate Swarm
docker-machine ssh d3 docker swarm leave
docker-machine ssh d2 docker swarm leave
docker-machine ssh d1 docker swarm leave --force

# Shutdown servers 
docker-machine stop {d1,d2,d3}

