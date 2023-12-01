#!/bin/bash
#ssh ec2-user@HOST_IP_ADDR -i ~/.ssh/aws-ec2-1.pem
#sudo su  
# injected bash script, EC2 > Advanced > User Data, runs as root 
#yum update -y  # Update kernel 
yum install httpd -y  # install Apache Web Server
service httpd start   # start Apache Web Server
chkconfig httpd on    # start Apache Web Server on boot, henceforth 
service httpd status  # server status check
# if apropos S3 role assumed by this instance, then can pull from S3 ... 
#aws s3 cp s3://sempernow-static-site-1 /var/www/html --recursive
# OR ...
cd /var/www/html      # go to public web server folder
# healthy.html
echo '<html>' > healthy.html
echo "<h1>Healthy! @ <code>$( curl http://169.254.169.254/latest/meta-data/public-ipv4 )</code></h1>" > healthy.html
echo '</html>' >> healthy.html
# index.html
echo '<html>' > index.html
echo '<h1>Apache Web Server</h1>' >> index.html
echo -e "<h2><pre>\n$(date '+%Y-%m-%d %H:%M:%S')\n</pre></h2>"  >> index.html
echo "<h2><code>$( curl http://169.254.169.254/latest/meta-data/public-hostname )</code></h2>" >> index.html
echo "<h2><code>$( curl http://169.254.169.254/latest/meta-data/public-ipv4 )</code></h2>" >> index.html
echo "<h2><code>$( curl http://169.254.169.254/latest/meta-data/instance-type )</code></h2>" >> index.html
echo "<h2><code>$( curl http://169.254.169.254/latest/meta-data/instance-id )</code></h2>" >> index.html
echo "<h2><code>$( curl http://169.254.169.254/latest/meta-data/mac )</code></h2>" >> index.html
echo "<h2><code>ip route</code></h2>" >> index.html
echo -e "<pre>\n$(ip route)\n</pre>"  >> index.html
echo "<h2><code>ip -r -4 addr</code></h2>" >> index.html
echo -e "<pre>\n$(ip -r -4 addr | grep -v 'valid')\n</pre>"     >> index.html
echo '</html>' >> index.html
#ls; cat 'index.html'


