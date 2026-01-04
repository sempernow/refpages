exit
# AWS CLI 
# =======
# Reference           https://docs.aws.amazon.com/cli/latest/index.html
# CLI v2              https://awscli.amazonaws.com/v2/documentation/api/latest/reference/index.html
# User Guide          https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html   
# GitHub              https://github.com/aws/aws-cli
# cheatsheet          https://github.com/toddm92/aws/wiki/AWS-CLI-Cheat-Sheet  
# 10 useful commands  https://cloudacademy.com/blog/aws-cli-10-useful-commands/  
# AWS Dev Tools/SDKs  https://aws.amazon.com/tools/  
# AWS LABS GitHub  https://github.com/awslabs/awscli-aliases
# aws-cli :: app for comms/ctrl between AWS and, EITHER remote-machine, OR a running EC2 Instance 
# In this context, the remote-machine is you, the user of the AWS account.
# - Automation through scripting; infrastructure per code; 
# - Command set & services; similar to Dev SDKs; JS, Python, ...  
# - Both Highl-level and API-level commands, e.g., `aws s3 ...` and `aws s3api ...`
    aws [options] <command> <subcommand> [parameters]  

# INSTALL/UPDATE aws-cli  [pip/choco/msi]
    pip install awscli    # Python 2 @ XPC; FAILed at Python 3 @ HTPC
    pip install awscli --upgrade --user  # Update

    choco install awscli  # https://chocolatey.org/packages?q=aws 
    # Windows cmd [AWSCLI64.msi]  https://s3.amazonaws.com/aws-cli/AWSCLI64.msi 
    # Autocomplete
        complete -C aws_completer aws  # command completion; test ... `aws s<TAB>`
    # aws-shell 
        pip install aws-shell  # https://github.com/awslabs/aws-shell  
    # CONFIG/CRED 
        # per user & profile
            ~/.aws
                /config        
                /credentials  

            # Session Tokens [1hr] @ 
            ~/.aws/cache/$_PROFILE_NAME.json

            # Assume Role / MFA 
            # https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-mfa

        # PROFILEs
            aws ... --profile foo  # defaults to `default`

            /config  # @ ~/.aws/
            #-----------------------
            [profile foo-bar]  # convention: NAME-ROLE
            region = us-east-1
            role_arn = arn:aws:iam::NNNNNNNNNNNN:role/bar
            source_profile = foo
            mfa_serial = arn:aws:iam::NNNNNNNNNNNN:mfa/foo
            duration_seconds =  43200 # 12 hrs; if =< MaxSessionDuration; (1 hr default) 

            /credentials  # @ ~/.aws/
            #----------------------
            [foo]
            aws_access_key_id = aZ09...20
            aws_secret_access_key = aZ09...40

        # config PER TERMINAL/SESSION
            export AWS_PROFILE=foo
            export AWS_ACCESS_KEY_ID=aZ09...20
            export AWS_SECRET_ACCESS_KEY=aZ09...40
            export AWS_DEFAULT_REGION=us-east-1
            # OR
            # authenticate; config per command/query; used @ EC2 instance, 
            # (use ROLEs @ resource (EC2) instead of embedding credentials.)
            aws configure  # queries for access-key-id, secret-access-key, region  
                # ... launchs process to authenticate against this EC2 instance   
                # Requires user input: Access Key ID, Secret Access Key, region name   
                # if resource has assumed the proper ROLE(s), then use this config utility only to enter 'Default region', bypassing 'AWS Access Key ID' and 'AWS Secret Access Key' queries (press enter).

    # Case 1. Remote AWS-CLI to AWS Management Console/Services

        # {remote-machine + AWS-CLI}  <==[HTTPS-API]==>  {AWS}  

            # - install AWS-CLI on Windows, Mac or Linux PC  
            # - Windows PowerShell Tools for AWS  
            # - Optionally +AWS-Shell; GitHub project   https://github.com/aws/aws-cli  

    # Case 2. Remote SSH into EC2 Instance

        # {remote-machine}  <==[SSH]==>  {EC2 + AWS-CLI}<=>{AWS}   

            # - EC2 must have AWS-CLI installed; is pre-installed @ Amazon Linux AMI
            # - Manually install AWS CLI onto any other Linux distro, per PIP  
              pip install awscli --upgrade --user  
              aws --version  # validate install  
            # IAM roles; EC2 instance must have authorization; either IAM role or credentials (`aws configure`); use (assumed) roles, so no creds embedded in instance, i.e., roles are more secure.

# DryRun 
    aws COMMAND ... --dry-run  # as implied; no real effect; very useful
                    --dry-run 2>&1 | grep -v 'DryRun flag'
    # or per JSON key:val : "DryRun": true, ...

# GENERATE/INPUT JSON PARAMS : Skeleton/Input  
    # Creates default key-val pairs for all possible params available per COMMAND
    # ... available @ most commands  https://docs.aws.amazon.com/cli/latest/userguide/generate-cli-skeleton.html
    aws COMMAND SUBCOMMAND --generate-cli-skeleton [input|output] > 'this.json'  # generate json k-v skeleton
    aws COMMAND SUBCOMMAND --cli-input-json 'file://this.json'                   # input per json file

# Date/Time/Nonce Generators: 
    cat /proc/sys/kernel/random/uuid                 # UUID (36-chars)  @ Linux
    $(date "+%s" | openssl sha1 | awk '{print $2}')  # SHA1 (40 chars)  @ MINGW64|Linux
    $(date "+%s.%N")  # e.g., 1539174436.886534100
    $(date "+%F-%a-%H.%M.%S.%N") # 2018-10-10-Wed-08.28.31.268750400
    date "+%F_%H.%M.%S"
    # generate 32 random alphanum (ASCII) 
    $(cat /dev/urandom |tr -dc 'a-zA-Z0-9' |fold -w 32 |head -n 1)

# JSON QUERY (--query) / FILTERS (--filters)
    # https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html#cli-usage-filter-client-side-identifiers
    # JMESPath : JSON Query Language : http://jmespath.org/  
    # CHEATSHEET: https://gist.github.com/magnetikonline/6a382a4c4412bbb68e33e137b9a74168
    # DICTIONARY NOTATION requires an ALIAS for each JSON key : {Alias1:JSONKey1,Alias2:JSONKey2}
    --query 'Volumes[*].{ID:VolumeId,InstanceId:Attachments[0].InstanceId,AZ:AvailabilityZone,Size:Size}'
    --filters "Name=status,Values=available"
# OUTPUT : json (default)|table|text|yaml 
    --output json  # https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output.html

# EKS  https://docs.aws.amazon.com/cli/latest/reference/eks/index.html
    aws eks create-cluster ... --profile $EKS_USER
# ACM (AWS Certificate Manager) :: HTTPS (SSL/TLS)  
    # https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html  
    # - validates by adding its generated cert CNAME to DNS record of the target domain 
    #   @ the Route53 hosted zone, else thru email notification process    
    # - must request for EVERY (SUB)DOMAIN targeted; wildcard handles all subdomains, e.g.,    
    #     '*.foo.com' handles: 'cdn.foo.com', 'www.foo.com, etc'; hence, request for foo.com & *.foo.com 
    # request-certificate  https://docs.aws.amazon.com/cli/latest/reference/acm/request-certificate.html
    # @ '*.foo.com' == ANY.foo.com ; token =< 32 chars ; opt-out of public record
     aws acm request-certificate 
        --domain-name 'foo.com' \
        --validation-method 'DNS' \
        --subject-alternative-names "*.foo.com" \
        --idempotency-token 123456
        --options CertificateTransparencyLoggingPreference=DISABLED 
        # Outputs Cert ARN ...
        { "CertificateArn": "arn:aws:acm:us-east-1:972..." } # JSON
    # DESCRIBE (includes Name/Value of CNAME)
        aws acm describe-certificate --certificate-arn $_CERT_ARN > 'acm.describe-cert.json'
    # GET (@ CloudFront, merely select it; installs automatically)
        aws acm get-certificate --certificate-arn $_CERT_ARN > 'acm.get-cert.pem'
# Route53  https://docs.aws.amazon.com/cli/latest/reference/route53/index.html  
    _DOMAIN='gd9.ch' 
    _ZONE_ID='Z03661092A3ARWLAMYFZE' 
    # LIST hosted zone(s) 
        aws route53 list-hosted-zones > 'route53.list.hosted-zones.json' 
        # Hosted Zones : ALL : Names & IDs ("Id", not "ID")
        aws route53 list-hosted-zones | jq '.HostedZones[] | .Name, .Id'
        # Or, sans jq 
        aws route53 list-hosted-zones --query "HostedZones[].[Name,Id]" --output text 

        # Hosted Zones : Zone ID of a DOMAIN
        _DOMAIN='uqrate.org'
        _ZONE_ID="$(aws route53 list-hosted-zones \
            | jq -r ".HostedZones[] | select(.Name | contains(\"$_DOMAIN\")) | .Id")"
        _ZONE_ID="${_ZONE_ID#/hostedzone/}"

        # Resource records @ Zone ID
        aws route53 list-resource-record-sets \
            --hosted-zone-id $_ZONE_ID > "route53.list.record-sets-${_DOMAIN}.json"

        # Hosted Zones : ALL resource records @ ALL zones 
        aws route53 list-hosted-zones | jq -M .HostedZones[].Id \
            | xargs -n1 aws route53 list-resource-record-sets --hosted-zone-id
        # Or, sans jq 
        aws route53 list-hosted-zones --query "HostedZones[].Id" --output text \
            | xargs -n1 aws route53 list-resource-record-sets --hosted-zone-id

    # Test DNS 
        aws route53 test-dns-answer --hosted-zone-id $_ZONE_ID \
            --record-name $_DOMAIN --record-type 'A'

    # CREATE hosted zone
        aws route53 create-hosted-zone --name $_DOMAIN \
            --caller-reference $(date +%H.%M) > "route53.create.${_DOMAIN}.json"
    # LIST records
        aws route53 list-resource-record-sets --hosted-zone-id $_ZONE_ID
        aws route53 list-resource-record-sets --hosted-zone-id $_ZONE_ID \
            --query 'ResourceRecordSets[0].ResourceRecords[*].{Value:Value}'

    # UPSERT : Route traffic to IP(s)
        # See "auto-update-route53-ips.sh"

    # Route53Domains  https://docs.aws.amazon.com/cli/latest/reference/route53domains/index.html
# S3  (High Level) 
    # REF: https://docs.aws.amazon.com/cli/latest/reference/s3/  
    # UG:  https://docs.aws.amazon.com/cli/latest/userguide/cli-s3.html  

    # List buckets
        aws s3 ls 
        
    # List ALL OBJECTS, total NUMBER and SIZE
        aws s3 ls s3://$_BUCKET --recursive  --human-readable --summarize
            # ...
            # Total Objects: 114
            #    Total Size: 3.3 MiB

    # S3 bucket ENDPOINT if hosted @ Route53 (BUCKET NAME MUST be domain-name)  
        https://s3-${_REGION}.amazonaws.com/${_BUCKET}  # Orthogonal to Route53 Endpoint.
        https://s3.amazonaws.com/${_BUCKET}             # @ us-east-1  
    # S3 bucket ENDPOINT if NOT hosted @ Route53 
        http://${_BUCKET}.s3-website-${_REGION}.amazonaws.com 
    # Create (make bucket)  
        aws s3 mb s3://$_BUCKET --region 'us-east-1'  # See 's3api put-bucket-policy ...'
    # Delete (remove bucket) 
        aws s3 rb s3://$_BUCKET          # if empty
        aws s3 rb s3://$_BUCKET --force  # if not empty
    # Remove file (object)
        aws s3 rm s3://$_BUCKET/$_OBJ
    # Move bucket to new region  
        aws s3 sync s3://$OLDbucket s3://$NEWbucket --source-region 'us-east-1' --region 'eu-west-2'
    # Static Website Enable + Configure  https://docs.aws.amazon.com/cli/latest/reference/s3/website.html
        printf '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}\n' > 'website.json'
        aws s3api put-bucket-website --bucket $_BUCKET --website-configuration file://website.json
        # or
        aws s3 website s3://$_BUCKET/ --index-document 'index.html' --error-document 'error.html'
        # put {index,error}.html docs 
        printf "<html>\n<h1>$_BUCKET</h1>\n<html>\n" > 'index.html'
        printf "<html>\n<h1>$_BUCKET</h1>\n<h2>Nope. (<code>404</code>)</h2>\n<html>" > 'error.html'
        aws s3 cp 'index.html' "s3://$_BUCKET"
        aws s3 cp 'error.html' "s3://$_BUCKET"

    # Setup www. subdomain-name bucket for naked-domain-name bucket (the JSON is NOT a bucket policy)
        aws s3 mb s3://www.$_BUCKET  --region 'us-east-1' 
    # Redirect www. subdomain-name bucket to naked-domain-name bucket (the JSON is NOT a bucket policy)
        printf '{"RedirectAllRequestsTo":{"HostName": "%s"}}\n' $_BUCKET > 'redirect.json'
        aws s3api put-bucket-website --bucket www.$_BUCKET --website-configuration file://redirect.json

    # Upload ONE file to S3 
        fpath='file://source.file'
        aws s3 cp $fpath s3://$_BUCKET/$fname --dryrun
            --exclude "*" --include "*.log"  # copy ONLY log files
            --exclude "*.jpg"                # exclude .jpg files
            --prefix "$rnd" --delimiter "/"  # set prefix + delimiter
            --content-type 'text/html'       # set mime-type 
            # text/html|image/jpg|application/{javascript,json,zip}|image/svg+xml
            # Content Type a.k.a. Media Type a.k.a. MIME 
            # (Multipurpose Internet Mail Extensions) type
            # https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/ 
            # 'text/plain' is default for textual files; human-readable, non-binary
            # 'application/octet-stream' is default for all other cases.
            --expires '2018-10-01T20:30:00Z' # ISO 8601 timestamp 
            --acl public-read-write          # assoc. IAM policies must incl. "s3:PutObjectAcl" action
            --storage-class 'REDUCED_REDUNDANCY'|'STANDARD_IA'  # ('IA'; infrequent access)
            # Grant permissions:  Permission=Grantee_Type=Grantee_ID
            --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers full=emailaddress=user@example.com  
    # Upload ALL files in SOURCE to S3
        aws s3 cp $SOURCE s3://$_BUCKET/ --recursive --content-type 'text/html'
    # Copy S3 objects from bucket1 to bucket2  
        aws s3 cp s3://$BUCKET_1/ s3://$BUCKET_2/ --recursive --region 'REGION-of-bucket1'
            --acl public-read-write  # set ACLs on copy; REQUIRES policy: `s3:PutObjectAcl`  
            --region 'SOURCE_REGION'   # MAY NEED @ SOME regions, so always use it  
    # Synch bucket w/ PWD (w/ optional delete)
        aws s3 sync . s3://$_BUCKET --delete  # delete target (@bucket) if not @ source (PWD)
            --exclude "*another/*"
    # Clone/Replicate objects Bucket to Bucket (region to region)
        aws s3 --recursive s3://$BUCKET_1 s3://$BUCKET_2
    # Download all objects to PWD 
        aws s3 cp s3://${_BUCKET}/ . --recursive
    # DELETE ALL objects 
        aws s3 rm s3://$_BUCKET --recursive

    # PRESIGN a URL : Allow anyone to GET using that special URL
        aws s3 presign s3://$_BUCKET/$_OBJECT --expires-in 604800 # seconds

        # The URL (example):
        # https://<BUCKET>.s3.us-west-2.amazonaws.com/key?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAEXAMPLE123456789%2F20210621%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20210621T041609Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=EXAMBLE1234494d5fba3fed607f98018e1dfc62e2529ae96d844123456

# S3API (API Level)  https://docs.aws.amazon.com/cli/latest/reference/s3api/
    # Static Website Enable + Configure  https://docs.aws.amazon.com/cli/latest/reference/s3/website.html
        printf '{"IndexDocument": {"Suffix": "index.html"},"ErrorDocument": {"Key": "error.html"}\n' > 'website.json'
        aws s3api put-bucket-website --bucket $_BUCKET --website-configuration file://website.json
    # Static Website Redirect www. subdomain-name bucket to naked-domain-name bucket (the JSON is NOT a bucket policy)
        printf '{"RedirectAllRequestsTo":{"HostName": "%s"}}\n' $_BUCKET > 'redirect.json'
        aws s3api put-bucket-website --bucket www.$_BUCKET --website-configuration file://redirect.json
    # list objects in bucket; ALL THE DATA
        aws s3api list-objects --bucket $_BUCKET --output 'json|text|table'  
    # LIST objects in bucket; NAME (KEY) & SIZE per OBJECT  
        aws s3api list-objects --bucket $_BUCKET \
            --query "Contents[].[Key,Size]" --output text  
            # TOTALs [size-total,number-of-objects]
            --query "[sum(Contents[].Size), length(Contents[])]"  
    # head-object (GET object INFO)  https://docs.aws.amazon.com/cli/latest/reference/s3api/head-object.html
        aws s3api head-object --bucket $_BUCKET --key $_OBJ
    # put-object (ADD object)  https://docs.aws.amazon.com/cli/latest/reference/s3api/put-object.html
        aws s3api put-object --bucket $_BUCKET --key $_OBJ --body 'FILE'  
        # --content-type (mime-types): text/html, image/jpg, application/json; `--body` sets object CONTENTs
        aws s3api put-object --bucket $_BUCKET \
            --key $_OBJ \
            --body 'FILE' \
            --content-type 'text/html; charset=utf-8' \
            --content-encoding 'STRING' \
            --acl public-read
    # copy-object (REPLACE|COPY object)  https://docs.aws.amazon.com/cli/latest/reference/s3api/copy-object.html
        aws s3api copy-object --bucket $_BUCKET --content-type 'application/rss+xml' \
            --copy-source $_BUCKET/$_OBJ --key $_OBJ \
            --metadata-directive 'REPLACE'  # COPY|REPLACE
    # Bucket Policy 
        # Add|Replace  https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html
            aws s3api put-bucket-policy --bucket $_BUCKET --policy file://policy.json
        # Get 
            aws s3api get-bucket-policy --bucket $_BUCKET

    # VERSIONING 
        # Enabled|Disabled 
            aws s3api put-bucket-versioning \
                --bucket $_BUCKET \
                --versioning-configuration "Status=Enabled"

        # List bucket VERSIONs per VersionId & Key
            aws s3api list-object-versions \
                --bucket $_BUCKET \
                --query "Versions[*].[Key,VersionId]" \
                --output text

        # DELETE ALL objects @ ALL VERSIONs
            # Get DeleteMarkers; construct obj-string and print to file 
            aws s3api list-object-versions \
                --bucket $_BUCKET \
                --query "DeleteMarkers[*].[Key,VersionId]" \
                --output text \
                | xargs -n 2 /bin/bash -c 'printf "{Key=$1,VersionId=$2}," >> "objstr"' _
            # lopp off last char (,)
            sed -i s'/.$//' 'objstr'  
            # Wrap in necessaries ...
            printf "Objects=[$(cat objstr)],Quiet=false" > 'delete'  
            # delete-objects per file of Keys & VersionIDs  
            aws s3api delete-objects --bucket $_BUCKET --delete file://delete
            # Validate is 'null' ... 
            aws s3api list-objects --bucket $_BUCKET 
            aws s3api list-object-versions --bucket $_BUCKET
            # Delete bucket 
            aws s3 rb s3://$_BUCKET

    # Get Canonical User ID
        aws s3api list-buckets 

# CloudFront  https://docs.aws.amazon.com/cli/latest/reference/cloudfront/index.html 
    # LIST distributions 
        aws cloudfront list-distributions 
    # ENDPOINTs
        aws cloudfront list-distributions | grep DomainName
    # Monitor (wait) until DEPLOYED
        aws cloudfront wait distribution-deployed --id $DISTRO_ID
    # CREATE Distribution  https://docs.aws.amazon.com/cli/latest/reference/cloudfront/create-distribution.html
        aws cloudfront create-distribution --distribution-config file://cf.create.dist.config.json  
    # GET distribution 
        aws cloudfront get-distribution --id $DISTRO_ID
    # GET distribution config (subset of dist json)
        aws cloudfront get-distribution-config --id $DISTRO_ID > 'cf.get.dist.config.json'
        # Use THIS schema @ CREATE dist, but REMOVE ETag
    # OAI (origin-access-identity); public access thru CloudFront ONLY, not S3
        # LIST identities
            aws cloudfront list-cloud-front-origin-access-identities
        # GET oai CONFIG (CallerReference, Comment, ETag)
            aws cloudfront get-cloud-front-origin-access-identity-config --id $OAI_ID
            # Use, sans ETag, to CREATE an identity
                "CloudFrontOriginAccessIdentityConfig": {
                    "Comment": "S3 sempernow.com ",
                    "CallerReference": "1538570058728" # UNIQUE; $(date "+%s")
                },
                "ETag": "E1YN4WSQB769DK" 
        # GET oai (CallerReference, Comment, ETag, Id, S3CanonicalUserId)
            aws cloudfront get-cloud-front-origin-access-identity --id $OAI_ID
        # CREATE (cannot modify once created; delete and create anew)
            aws cloudfront create-cloud-front-origin-access-identity \
              --cloud-front-origin-access-identity-config "CallerReference=$(date "+%s"),Comment=S3 $_BUCKET"
        # DISABLE distribution 
        # 1. get-distribution > JSON
        # 2. update-distribution : JSON @ "Enabled": false,
        # DELETE distribution (if disabled)
        aws cloudfront delete-distribution \
            --id $DISTRO_ID \
            --if-match E2QWRUHEXAMPLE
# EC2   https://docs.aws.amazon.com/cli/latest/reference/ec2/  
    # Configure, e.g., running aws-cli in SSH session @ EC2 instance (but don't)
        aws configure  # SECURITY ISSUE; don't store credentials in EC2 instance; use Roles instead.
        #=> AWS Access Key ID [None]:   
        #=> AWS Secret Access Key [None]:   
        #=> Default region name [None]: us-east-1  
        #=> Default output format [None]: json  
        # CAN use `aws configure` to set region (only); i.e., skip creds by leaving blank (ENTER)
    # List regions
        aws ec2 describe-regions \
            --query 'Regions[].[RegionName,Endpoint]' \
            --output 'text'
    # List zones per specified region
        aws ec2 describe-availability-zones \
            --region $_REGION \
            --query 'AvailabilityZones[].[ZoneName]' \
            --output 'text'

    # EIPs (Elastic IPs) : ID of EC2 instance, and its IP
        aws ec2 describe-addresses  --query "Addresses[*].{ID:InstanceId,IP:PublicIp}" --output text
        
        i-085c0ad6b1fa8648c     34.206.99.48
        i-02c1bff2a19d52222     35.171.56.124

    # Attach IGW to VPC (yeah, here) 
        aws ec2 attach-internet-gateway --vpc-id "vpc-0413d21389a2102de" --internet-gateway-id "igw-008e247b9557b4ba2" --region us-east-1
    # Security Groups (SG)
        # Get SGs : describe-security-groups
        aws ec2 describe-security-groups \
            --query 'SecurityGroups[].[GroupName,GroupId]'
        # Create SG : create-security groups https://docs.aws.amazon.com/cli/latest/reference/ec2/create-security-group.html
            aws ec2 create-security-group --group-name "RDS-sg" --vpc-id "$_VPC" --description "for RDS mgmnt"
        # Get SG Rule : describe-security-group-rules : https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-group-rules.html
            aws ec2 describe-security-group-rules \
                --filter Name="group-id",Values="$_SG"
        # Add SG (Firewall) Rule : authorize-security-group-ingress : https://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html
            # add SSH ingress from a single IP Address
                aws ec2 authorize-security-group-ingress --group-id "$_SG" --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=73.163.207.77/32,Description='SSH @ HQ IP'}]"
            #... same, sans description
                aws ec2 authorize-security-group-ingress --group-id "$_SG" --protocol 'tcp' --port '22' --cidr '73.163.207.77/32'  
            # add TCP port 31170 : access from internet
                aws ec2 authorize-security-group-ingress --group-id "$_SG" \
                    --protocol 'tcp' --port $_NodePort --cidr '0.0.0.0/0' 
            # add SSH access from Public subnet 
                aws ec2 authorize-security-group-ingress --group-id 'sg-01addb4967c063e94' \
                    --protocol 'tcp' --port '22' --cidr '10.0.0.0/28' 
            # add RDP access from all IPs @ specified CIDR block (Network ID: 203.0.113)
                aws ec2 authorize-security-group-ingress --group-id $_SG \
                    --protocol 'tcp' --port '3389' --cidr '203.0.113.0/24'  
            # add MYSQL/Aurora access from Public subnet 10.0.0.0/28
                aws ec2 authorize-security-group-ingress --group-id $_SG \
                    --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges=' [{CidrIp=10.0.0.0/28,Description="from Public subnet"}]'
        # Revoke SG Ingress : revoke-security-group-ingress  https://docs.aws.amazon.com/cli/latest/reference/ec2/revoke-security-group-ingress.html  
            aws ec2 revoke-security-group-ingress --group-id "$_SG" \
                --protocol 'tcp' --port $_NodePort --cidr '0.0.0.0/0' 
            # Revoke SSH from single IP
            aws ec2 revoke-security-group-ingress --group-id "$_SG" \
                --protocol 'ssh' --port '22' --cidr '73.212.137.137/32' 
        # Revoke SG Egress : revoke-security-group-egress  https://docs.aws.amazon.com/cli/latest/reference/ec2/revoke-security-group-egress.html
            aws ec2 revoke-security-group-egress --group-id "$_SG" \
                --ip-permissions '[{IpProtocol=tcp,FromPort=0,ToPort=0,IpRanges=[{CidrIp=73.54.63.44/32}]'
        # Update CIDR for SSH ingress : SG name: "ssh"
            # Revoke old
                aws ec2 revoke-security-group-ingress --group-id "$_SG" --protocol 'tcp' --port '22' --cidr '73.212.137.137/32' 
            # Add new
                aws ec2 authorize-security-group-ingress --group-id "$_SG" --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges="[{CidrIp=73.163.207.77/32,Description='SSH @ HQ IP'}]"
            # Show results
                aws ec2 describe-security-group-rules --filter Name="group-id",Values="$_SG"
        # Update CIDR for Docker comms : SG name: "managers"
            # Revoke old
                aws ec2 revoke-security-group-ingress --group-id "$_SG" --protocol 'tcp' --port '2377' --cidr '73.212.137.137/32' 
                aws ec2 revoke-security-group-ingress --group-id "$_SG" --protocol 'tcp' --port '3376' --cidr '73.212.137.137/32' 
            # Add new
                aws ec2 authorize-security-group-ingress --group-id "$_SG" --ip-permissions IpProtocol=tcp,FromPort=2377,ToPort=2377,IpRanges="[{CidrIp=73.163.207.77/32,Description='Cluster Management'}]"
                aws ec2 authorize-security-group-ingress --group-id "$_SG" --ip-permissions IpProtocol=tcp,FromPort=3376,ToPort=3376,IpRanges="[{CidrIp=73.163.207.77/32,Description='docker-machine : Comms btwn Docker client and remote Swarm Manager'}]"
            # ... more @ web, managers, & workers
        # Delete SG
        # delete-security-group per sg-ID    (EC2-VPC)
            aws ec2 delete-security-group --group-id 'sg-903004f8'
        # delete-security-group per sg-name  (EC2-Classic)
            aws ec2 delete-security-group --group-name 'SG_NAME'
        # describe-security-group per sg-ID; JSON formatted, so GUI to CLI code creation
            aws ec2 describe-security-groups --group-ids 'sg-07cd6004e2ae78c86'   # per sg-ID
            aws ec2 describe-security-groups --group-names 'WebDMZ'               # per sg-name

    # EBS (Elastic Block Storage) Volumes
        # EC2 Storage
        # Types : EBS (remote) or Instance store (IS) (per instance) 
        # Defined @ AMI; overridden @ EC2 instance creation
        # Concepts https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/block-device-mapping-concepts.html
        # Device Names: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
        # Device Mappings:
        # @ HVM : root : /dev/sda1 | /dev/xvda (per AMI)
        # @ HVM : IS   : /dev/sd[b-e]
        # @ HVM : EBS  : /dev/sd[f-p] ... so /dev/sdf is the 1st-attached EBS.

        # Volumes : List 
            aws ec2 describe-volumes \
                --query 'Volumes[].Attachments[][Device,VolumeId]' \
                --output text
            # /dev/sdf        vol-07e4e65b266d18f23
            # /dev/sda1       vol-0ca4c4c02a460a5a4
            # /dev/sda1       vol-0048300537502686b
            # Or, using jq ...
            aws ec2 describe-volumes \
                |jq '.Volumes | .[].Attachments | .[] | .Device, .VolumeId'

        # Volumes : Get VolumeId per Device (name) : EC2 instance MUST BE RUNNING
            dev='/dev/sdf'
            target=$(
                aws ec2 describe-volumes \
                    --query 'Volumes[].Attachments[][Device,VolumeId]' \
                    --output text |grep $dev
            )
            volid=$(echo $target |awk '{print $2}')

        # Volumes : Detach/Attach
        # Detach explicitly or by terminating EC2 instance. 
        # - If EC2 is NOT running, then EBS is detached; AWS GUI: "available" (vs "in-use")
        # - If EC2 running, then UNMOUNT before detaching, 
        #   else possible data loss, and mount point @ reattach may change.
        # - If EBS is root device, then must stop EC2 prior to detach

        # Volumes : Detach
            aws ec2 detach-volume --volume-id $volid
        
        # Volumes : Attach
            ec2id='i-010f37900f7f4c588'
            aws ec2 attach-volume \
                --volume-id $volid \
                --instance-id $ec2id \
                --device '/dev/sdf'

    # EC2 : MODIFY instance

        # Modify : EBS : Persist (on the fly) : Modify an EC2 instance 
        # ... https://docs.aws.amazon.com/cli/latest/reference/ec2/modify-instance-attribute.html
            aws ec2 modify-instance-attribute --instance-id $ec2id \
                --block-device-mappings \
                    '[{"DeviceName": "/dev/sda1","Ebs":{"DeleteOnTermination":false}}]'
        # Modify : Security Groups (replaces all with list @ `--groups`)
            ec2id='i-09475096cf06a9a1d'
            aws ec2 modify-instance-attribute --instance-id $ec2id \
                --groups "sg-0b922c76294ba0fca" "sg-02e5700d8f82435b6" "sg-01c3c253618e6ee18"
    # VPCs 
        aws ec2 describe-vpcs 
    # Key Pairs  https://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-keypairs.html
        # Create; 2048-bit RSA; key-name + fpr sent to AWS; See @ AWS-console > EC2 > Key Pairs
            export key='KEY_NAME'
            aws ec2 create-key-pair \
                --key-name $key \
                --query 'KeyMaterial' \
                --output text > ~/.ssh/${key}.pem   # RSA private key; unencrypted UTF-8 encoded PEM
            chmod 400 ~/.ssh/${key}.pem             # store @ ~/.ssh/
        # Get/Save PUBLIC KEY of the pair
            ssh-keygen -y -f ~/.ssh/${key}.pem > ~/.ssh/${key}.pem.pub
        # Delete a key pair  
            aws ec2 delete-key-pair --key-name $key
        # Describe
            aws ec2 describe-key-pairs  # shows all, JSON formatted; keys: "KeyName" + "KeyFingerprint"
            # Note `KeyMaterial` only available upon creation (NOT stored [@ JSON]); MUST SAVE to file  
            # Ref:  http://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html  
            # UG:   http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-keypairs.html  
            # Output is an ASCII version of the private key and key fingerprint. 
                # KeyName ->         key pair name.  
                # KeyMaterial ->     RSA private key; unencrypted PEM encoded (NOT stored).  
                # KeyFingerprint ->  SHA-1 digest of DER encoded private key.  
             # @ Windows CMD; use DOUBLE-QUOTES instead of SINGLE
             # @ Windows PowerShell (PS), the file redirect, `>`, defaults to UTF-8 encoding; FAILs @ some SSH clients. So, explicitly specify ASCII encoding ...  
                aws ec2 create-key-pair --key-name "ec2-keypair-1" --query "KeyMaterial" --output "text" | out-file -encoding ascii -filepath ec2-keypair-1.pem  # Note command following pipe is PS not aws-cli
    # EC2 Instances/Images
        # start|stop|reboot|terminate
            export iid='i-006fe920766c49ff5'
            aws ec2 start-instances     --instance-ids "$iid"
            aws ec2 stop-instances      --instance-ids "$iid"
            aws ec2 reboot-instances    --instance-ids "$iid"
            aws ec2 terminate-instances --instance-ids "$iid"  
        # Launch Templates  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html  
            # get-launch-template-data FROM instance-id
                aws ec2 get-launch-template-data \
                    --instance-id $iid \
                    --query "LaunchTemplateData" > 'LaunchTemplate-i-0b34cc.json'
            # create-launch-template FROM launch-template-data   
                # Creates @ EC2 > INSTANCES > Launch Templates, but FAILs to launch @ > Actions > Launch instance from template (all are network related errors)
                aws ec2 create-launch-template \
                    --launch-template-name 'TemplateApacheWS' \
                    --version-description 'WebVersion1' \
                    --launch-template-data 'file://LaunchTemplate-i-0b34cc.json'
            # run-instances FROM launch-template
                aws ec2 run-instances \
                    --launch-template 'LaunchTemplateId=lt-01e17ad648d761eff,Version=1'   
        # Launch (create) instance  (EC2-VPC)  
            aws ec2 --image-id 'ami-abc12345' \
                --count '1' \
                --instance-type 't2.micro' --key-name 'MyKeyPair' \
                --security-group-ids 'sg-903004f8' \
                --subnet-id 'subnet-6e7f829e'  \
                --user-data file://FILE.txt  # bash script FILE injected @ launch; AWS base64-encodes it; runs as root 
        # Create+Run  http://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html  
            aws ec2 run-instances --image-id 'ami-xxxxxxxx' \
                --subnet-id 'subnet-xxxxxxxx' \
                --security-group-ids 'sg-07cd6004e2ae78c86' \
                --count '1' \
                --instance-type 't2.micro' \
                --key-name 'aws-ec2-1' --query 'Instances[0].InstanceId' \
                --user-data 'file://aScript.txt'  # User Data (bash script; autoruns on boot)
            #=> "i-0787e4282810ef9cf"
            # User Data (bash script)  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html  
                # SG of EC2 must allow SSH (port 22), HTTP (port 80), and HTTPS (port 443) connections
                # cloud-init - app by Canonical, modified by AWS, specifies boot Linux images @ cloud environ.;  https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-ami-basics.html#amazon-linux-cloud-init
                /etc/cloud/cloud.cfg.d  # cloud-init config
                # See launch log @ /var/log/cloud-init-output.log
                # EXAMPLE bash script [.txt]; a 'User Data' script runs as root, on boot:  
                #!/bin/bash  
                yum update -y         # update kernel
                yum install httpd -y  # install Apache server
                service httpd start   # start server
                chkconfig httpd on    # config to start server on boot
                service httpd status  # server status check
                # if apropos S3 role assumed by this instance, then can pull from S3 ... 
                aws s3 cp 's3://sempernow-static-site-1/index.html' '/var/www/html'
                # OR ...
                cd '/var/www/html'    # go to public web server folder
                echo '<html>' > 'index.html'
                echo '<h1>AWS EC2 :: Apache Web Server</h1>' >> 'index.html'
                echo '<h2><code>$( curl http://169.254.169.254/latest/meta-data/public-hostname )</code></h2>' >> 'index.html'
                echo '<h2><code>$( curl http://169.254.169.254/latest/meta-data/public-ipv4 )</code></h2>' >> 'index.html'
                echo -e "<pre>\n$(ip -r -4 addr | grep -v 'valid')\n</pre>"     >> 'index.html'
                echo '</html>' >> 'index.html'
                ls; cat 'index.html'
        # Modify a STOPPED instance; add User Data (bash script; base64 encoded)   
            aws ec2 modify-instance-attribute --instance-id 'i-1234567890abcdef0' \
                --attribute 'userData' \
                --value 'file://aScript_base64_encoded.txt'
            # CAN modify the "User Data" of a STOPPED instance;  
            # AWS does NOT base64 encode here, so must do MANUALLY  
                # @ Linux:   
                base64 'SOURCE' > 'ENCODED_SOURCE' 
                # @ Windows: 
                certutil -encode "SOURCE" "ENCODED_SOURCE"  
        # Describe Volumes 
            aws ec2 describe-volumes \
                --query 'Volumes[*].{ID:VolumeId,InstanceId:Attachments[0].InstanceId,AZ:AvailabilityZone,Size:Size}' | jq .
        # Describe Instances  http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html  
            # FILTER per TAGs :: key:val
            --filters "Name=tag:Name,Values=a1a"
            --filters "Name=tag:$key,Values=$val" #... CSV list of values, but UNORDERED.
            # FILTER per Tag(s) :: key:val
                --filters "Name=tag:$key,Values=$val" #... CSV list of values, but UNORDERED.
                export name='machine1'
                aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" \
                    --query 'Reservations[*].Instances[*].[KeyName,InstanceId]' 
                export id=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${name}" \
                    --query 'Reservations[*].Instances[*].[InstanceId]' --output text)
                # Get ENI (primary) by instance Name (Tag)
                    eniPrimary=$(aws ec2 describe-instances \
                        --filters "Name=tag:Name,Values=${name}" \
                        --query 'Reservations[*].Instances[*].NetworkInterfaces[*].[Attachment.AttachmentId]' \
                        --output text \
                    )

            # List Block Storage (EBS) devices (Root +)
                aws ec2 describe-instances |jq '.[] |.[].Instances |.[].BlockDeviceMappings'
                # OR (better; includes name)
                aws ec2 describe-instances --query "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,ID:InstanceId,State:State.Name,Storage:BlockDeviceMappings}" |jq .

            # LIST INSTANCES (a useful subset of k-v pairs) : JSON
                aws ec2 describe-instances --query "Reservations[*].Instances[*].{Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,IPpvt:PrivateIpAddress,IPweb:PublicIpAddress,ID:InstanceId,State:State.Name,KeyName:KeyName,AZ:Placement.AvailabilityZone,Arch:Architecture,AMI:ImageId,VPC:VpcId,SubNet:SubnetId,SG:NetworkInterfaces[0].Groups[*],Storage:BlockDeviceMappings}" |jq .

            filters="--filters=Name=tag:Name,Values='${vm}'"
            aws ec2 describe-instances $filters --query "Reservations[*].Instances[*].{Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,IPpvt:PrivateIpAddress,IPweb:PublicIpAddress,ID:InstanceId,State:State.Name,KeyName:KeyName,AZ:Placement.AvailabilityZone,Arch:Architecture,AMI:ImageId,VPC:VpcId,SubNet:SubnetId,SG:NetworkInterfaces[0].Groups[*],Storage:BlockDeviceMappings}" |jq .


            # per ANY filter (string)
                aws ec2 describe-instances --output text | grep -- $filter

            # per ANY filter (string) against query: IP, ID, AZ, Type, State
            filter='stopped'
            aws ec2 describe-instances \
                --query 'Reservations[*].Instances[*].{Type:InstanceType,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' \
                --output text | grep -- $filter
            # List ALL by AZ, ID, IP, Type, State (TABLE)
            state=running # running stopped 
            aws ec2 describe-instances \
                --filters "Name=instance-state-name,Values=${state}" \
                --query 'Reservations[*].Instances[*].{Type:InstanceType,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' \
                --output table
            # List ALL by AZ, ID, IP, Type, State (TABLE) :: FILTER by Tag
            key='Name'
            val='a1b'
            aws ec2 describe-instances \
                --filters "Name=instance-state-name,Values=${state}" \
                --filters "Name=tag:$key,Values=$val" \
                --query 'Reservations[*].Instances[*].{Type:InstanceType,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' 
                --output table

            # List ALL by AZ, ID, IP, Type, State, Tags[Name]  (TABLE)
            aws ec2 describe-instances \
                --filters "Name=instance-state-name,Values=${state}" \
                --query "Reservations[*].Instances[*].{Type:InstanceType,Name:Tags[?Key=='Name']|[0].Value,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}" \
                --output table | sed 1,2d
                # +------------+-----------------------+-----------------+-------+----------+------------+
                # |     AZ     |          ID           |       IP        | Name  |  State   |   Type     |
                # +------------+-----------------------+-----------------+-------+----------+------------+
                # |  us-east-1a|  i-0a6e9ac6cfb8cd8ea  |  54.234.90.253  |  a1a  |  running |  t3.micro  |
                # |  us-east-1b|  i-072ad98848742e098  |  34.203.199.19  |  a1b  |  running |  t3.micro  |
                # |  us-east-1c|  i-022f64744500d8808  |  52.203.203.157 |  a1c  |  running |  t3.micro  |
                # +------------+-----------------------+-----------------+-------+----------+------------+

            # List ALL by AZ, ID, IP
            aws ec2 describe-instances \
                --filters "Name=instance-state-name,Values=${state}" \
                --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, InstanceId, PublicIpAddress]' \
                --output text 
                # Get IP per AZ
                az=us-east-1a
                ip=$(aws ec2 describe-instances \
                    --filters "Name=instance-state-name,Values=running" \
                    --query 'Reservations[*].Instances[*].[Placement.AvailabilityZone, PublicIpAddress]' \
                    --output text | grep -- "$az" | awk '{print $2}' | head -n1)
                # Get IP per Name
                vm='a1b'
                ip=$(aws ec2 describe-instances \
                    --filters "Name=instance-state-name,Values=running" \
                    --query "Reservations[*].Instances[*].{Tags:Tags[?Key=='Name']|[0].Value,IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}" \
                    --output text | grep -- "$vm" | awk '{print $3}' | head -n1)
            # List ALL Describe subset info; all VMs 
            aws ec2 describe-instances --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,State:State.Name,Name:KeyName,AZ:Placement.AvailabilityZone,Arch:Architecture,AMI:ImageId,Type:InstanceType,VPC:VpcId,SubNet:SubnetId,SG:NetworkInterfaces[0].Groups[*],Storage:RootDeviceType}' |jq .[]
            # List ALL to JSON file
            aws ec2 describe-instances --filters "Name=instance-state-name,Values=${state}" \
                > aws.ec2.describe-instances.running.json
            # Get IP per instance-id (null if not running)
                aws ec2 describe-instances \
                    --instance-id $iid \
                    --query 'Reservations[].Instances[].PublicIpAddress'  
            # ALL @ $_STATE :: Zone, State, Id, SG-Id
            # STATE = pending | running | shutting-down | terminated | stopping | stopped
                _STATE='running'
                aws ec2 describe-instances \
                    --filters "Name=instance-state-name,Values=$_STATE" \
                    --query 'Reservations[*].Instances[*].[KeyName,PublicIpAddress,Placement.AvailabilityZone,InstanceId,SecurityGroups[0].GroupId]' \
                    --output text
            # ALL RUNNING :: Id only
                aws ec2 describe-instances \
                    --filters "Name=instance-state-name,Values=running" \
                    --query 'Reservations[*].Instances[*].[InstanceId]' \
                    --output text
            # ALL RUNNING :: filter out all but IP per `jq` tool
            aws ec2 describe-instances \
                --filters "Name=instance-state-name,Values=running" \
                --query 'Reservations[*].Instances[*].{IP:PublicIpAddress,ID:InstanceId,AZ:Placement.AvailabilityZone,State:State.Name}' \
                | jq .[] | jq .[].IP  # -r option for sans quotes.
            # ALL RUNNING :: ID, AZ, IP
                aws ec2 describe-instances \
                    --filters "Name=instance-state-name,Values=running" \
                    --query 'Reservations[].Instances[].[InstanceId,Placement.AvailabilityZone,PublicIpAddress]' \
                    --output text | sed 's/\n//g'
            # ALL RUNNING :: IP to JSON :: {IP: <IP1>, IP: <IP2>, ...}
                ipJSON=$(aws ec2 describe-instances \
                        --filters "Name=instance-state-name,Values=running" \
                        --query 'Reservations[].Instances[].[PublicIpAddress]' \
                        --output text | sed 's/\n//g' | xargs printf "{\"IP\":\"%s\"},")
            # per filter by Security Group name  
                aws ec2 describe-instances 
                    --filters "Name=instance.group-name,Values=$_SGname" \
                    --query 'Reservations[].[Instances[].[State,InstanceId,InstanceType,Tags[0]]]' 
            # per filter by State; pending | running | shutting-down | terminated | stopping | stopped
                aws ec2 describe-instances \
                    --filters "Name=instance-state-name,Values=$_State" \
                    --region 'us-east-1' --output 'json' \
                    --query 'Reservations[].Instances[].StateReason.Message'  # 'StateReaon' only
                    # OR query: StateReason, InstanceId, InstanceType, Tags
                    --query 'Reservations[].[Instances[].[StateReason.Message,InstanceId,InstanceType,Tags[0]]]'  
        # Describe Instance Attribute (userData; encoded)  https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instance-attribute.html
            aws ec2 describe-instance-attribute \
                --instance-id 'i-1234567890abcdef0' \
                --attribute 'userData'  
        # Describe Images (AMI)  http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html  
            aws ec2 describe-images --owners 'amazon' \
                --filters "Name=platform,Values=windows" "Name=root-device-type,Values=ebs"  
        # ENI (Elastic Network Interface) 
            # Attach ENI (as second NIC, e.g., eth1) to EC2 instance
                aws ec2 attach-network-interface \
                    --network-interface-id 'eni-090416e04c96d0207' \
                    --instance-id 'i-097b052280ac2ece9' \
                    --device-index 1
                # Then associate EIP with ENI; then set Route53 DNS 'A' record to EIP.
                # Whatever ENI setup (Subnet, SG, ...) travels with it; ENI is portable (attach/detach), 
                # unlike an EC2 instance's Primary Network Interface (eth0) 
        # EIP (Elastic IP)  NOTE: These `export ...`-to-variable examples presume only one EIP address is allocated.
            # Get EIPs Info
            aws ec2 describe-addresses \
                --query 'Addresses[].[{EC2:InstanceId,EIP:{IP:PublicIp,AllocID:AllocationId,AssocID:AssociationId}}]'
            # Associate EIP with EC2 directly, per instance ID 
                export eipAlloc=$(aws ec2 describe-addresses --query 'Addresses[].[AllocationId]' --output text)
                aws ec2 associate-address \
                    --allocation-id $eipAlloc \
                    --instance-id $id \
                    --allow-reassociation > 'eipassoc.id.json'
                # per public IP  
                aws ec2 associate-address \
                    --public-ip $ip \
                    --instance-id $id \
                    --allow-reassociation > 'eipassoc.id.json'
            # Associate the EIP with EC2's primary ENI (eth0)  *** PREFERRED  ***
                # 1. Get ID of EC2's primary ENI (Elastic Network Interface; eth0):
                    export eniPrimary=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${ec2Name}" \
                                --query 'Reservations[*].Instances[*].NetworkInterfaces[*].[NetworkInterfaceId]' \
                                --output text) #... eni-09350fdcbd0d867b7 
                # 2. Get AllocationID of the EIP (Elastic IP) address: 
                    export eipAlloc=$(aws ec2 describe-addresses --query 'Addresses[].[AllocationId]' --output text)
                    #... eipalloc-0e97db21e288ebdd5 
                # 3. Make the association ... 
                aws ec2 associate-address \
                    --allocation-id  $eipAlloc \
                    --network-interface-id $eniPrimary \
                    --allow-reassociation > 'eipassoc.id.json'
            # Associate EIP with a detachable ENI (eth1 @ EC2)
                export eipAlloc=$(aws ec2 describe-addresses --query 'Addresses[].[AllocationId]' --output text)
                aws ec2 associate-address \
                    --allocation-id  $eipAlloc \
                    --network-interface-id $eth1ENI \
                    --allow-reassociation > 'eipassoc.id.json'
            # Disassociate 
                aws ec2 disassociate-address --association-id 'eipassoc-2bebb745'
    # VPC
        # create VPC  https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html  
            aws ec2 create-vpc --cidr-block '10.1.0.0/16' --amazon-provided-ipv6-cidr-block --dry-run 
        # create-vpc-endpoint  https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc-endpoint.html  
            export vpcID='vpc-0ae8e1beddd77fe65'
            aws ec2 create-vpc-endpoint --vpc-id $vpcID \
                --service-name 'com.amazonaws.us-east-1.s3' \
                --route-table-ids 'rtb-11aa22bb'
        # describe-vpc-endpoints 
            aws ec2 describe-vpc-endpoints
        # Subnet
            # create-subnet 
                aws ec2 create-subnet --vpc-id $vpcID --cidr-block '10.0.1.0/24'
                aws ec2 create-subnet --vpc-id $vpcID --cidr-block '10.0.0.32/28'
            # delete-subnet 
                aws ec2 delete-subnet --subnet-id 'subnet-9d4a7b6c'
            # describe-subnets  https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html
                aws ec2 describe-subnets [--filters <value>] [--subnet-ids <value>]  
        # IGW  
            # create IGW 
                aws ec2 create-internet-gateway
            # attach IGW to VPC
                aws ec2 attach-internet-gateway --vpc-id $vpcID --internet-gateway-id 'igw-1ff7a07b'  
        # (N)ACL :: Network ACL (@ VPC if GUI; @ EC2 if CLI)
            # decribe-network-acls
            # create-network-acl  (bare object ONLY; must add each rule per entry; see below)
                aws ec2 create-network-acl --vpc-id $vpcID 
            # create-network-acl-entry (Rule); See nacl-entries.public.sh
                export aclID='acl-0604073f026f91622'
                aws ec2 create-network-acl-entry \
                    --network-acl-id $aclID \
                    --egress \
                    --rule-number '100' \
                    --protocol '6' \
                    --port-range 'From=80,To=80' \
                    --cidr-block '0.0.0.0/0' \
                    --rule-action 'allow'  
# IAM  https://docs.aws.amazon.com/cli/latest/reference/iam/index.html  
    # Policy elements (keys): https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html
    # Create User
        aws iam create-user --user-name 'USERNAME'  # returns JSON user-info
    # Delete User
        aws iam delete-user --user-name 'USERNAME'  # no return if successful
    # Get User policy [JSON]  (can't get per Role, nor per Group) 
        aws iam get-user-policy --user-name 'USERNAME' --policy-name 'POLICYNAME'  
    # List all users: UserName, UserID, and ARN vals (of Users key)
        aws iam list-users --query 'Users[].[UserName,UserId,Arn]'   
    # ROLEs 
        # List roles:
            aws iam list-roles --query 'Roles[*].[{Name:RoleName,ID:RoleId,ARN:Arn}]' --output json 
        # Get Role 
            aws iam get-role --role-name $_ROLE
        # Update role 
            update-role
                --role-name <value>
                [--description <value>]
                [--max-session-duration <value>]
                [--cli-input-json <value>]
                [--generate-cli-skeleton <value>]
            # E.g., set max-session-duration to 12 hrs (max allowed)
            aws iam update-role --role-name 'admin' --max-session-duration 43200 
# STS  https://docs.aws.amazon.com/cli/latest/reference/sts/index.html#cli-aws-sts  
    # whoami 
        aws sts get-caller-identity
    # Assume Role  https://docs.aws.amazon.com/cli/latest/reference/sts/assume-role.html 
    # @ ~/config https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html#cli-configure-role-mfa
        assume-role
            --role-arn <value>
            --role-session-name <value>
            [--policy <value>]
            [--duration-seconds <value>]  # 3600-43200 sec; 1-12 hr
            [--external-id <value>]
            [--serial-number <value>]
            [--token-code <value>]
            [--cli-input-json <value>]
            [--generate-cli-skeleton <value>]  
    # Get Session Token  
        get-session-token
            [--duration-seconds <value>]
            [--serial-number <value>]
            [--token-code <value>]
            [--cli-input-json <value>]
            [--generate-cli-skeleton <value>]

# RDS  https://docs.aws.amazon.com/cli/latest/reference/rds/index.html 
# DynamoDB  
    # Ref  https://docs.aws.amazon.com/cli/latest/reference/dynamodb/index.html
    # UG   https://docs.aws.amazon.com/cli/latest/userguide/cli-dynamodb.html  

# CloudFormation  https://docs.aws.amazon.com/cli/latest/reference/cloudformation/index.html
    # Test/Validate a template 
        # @ S3  
            aws cloudformation validate-template \
                --template-url "https://s3.amazonaws.com/${_BUCKET}/${TEMPLATE}"  
        # @ local file 
            aws cloudformation validate-template \
                --template-body "file://${TEMPLATE}.json"  
    # list-stacks (yours)
        aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE

# ECS (Docker)  
    # ECS CLI Installation  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
    # Ref  https://docs.aws.amazon.com/cli/latest/reference/ecs/index.html  
    # DG   https://docs.aws.amazon.com/AmazonECS/latest/developerguide/
    aws ecs list-clusters 
    # push docker image to ECR
    aws ecr create-repository --repository-name $DOCKER_IMAGE_NAME

# CLI sans AWS-CLI
    # SSH (connect) to a running EC2 instance
        ssh $ip -l 'ec2-user' -i ~/.ssh/KEYNAME.pem 
        # OR 
        ssh "ec2-user@${ip}" -i ~/.ssh/KEYNAME.pem  # 'ec2-user' is EC2 default
        ssh ${ip} -i ~/.ssh/KEYNAME.pem             # as root, if allowed
        # if configured @ 
            ~/.ssh/config  # e.g., ... 
            #  Host ec2
            #  HostName 8659010.xyz
            #  UserKnownHostsFile /dev/null  # prevents adding to 'known_hosts' file
            #  User ec2-user
            #  RequestTTY yes 
            #  IdentityFile ~/.ssh/aws-ec2-1.pem
        # then simply ... 
            ssh ec2

    # @ EC2 instance, show EC2 Instance Meta-data, per cURL  
        curl 'http://169.254.169.254/latest/meta-data/'  # remember this URL 
        # ... lists all per option-name; rerun, w/ option-name appended to above url  

    # rsync files to running instance; upload scripts ...
        export _host='ec2-52-91-253-46.compute-1.amazonaws.com'
        rsync -at --progress -e "ssh -i ~/.ssh/aws-ec2-1.pem" ~/.bin/*  \
           "ec2-user@${_host}:/home/ec2-user"

    # SFTP 
        # sftp commands; LIMITED set; unlike ssh session    
        # First, SSH into remote, then ...
            put   # copy local    => remote machine    
            get   # copy remote => local    machine    
            lls   # ls @ LOCAL machine    
            lcd   # cd @ LOCAL machine    
            help  # show commands and formats    
        # To copy local './foo' folder(+subs) contents to remote './foo'    
            put -r foo    

    # Mount EFS   
        # @ EFS > File Systems > File system access :: EC2 mount instructions  ...  
        # https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html
        ssh ...  # into EC2 instance 
            # helpers, per AMI  
            yum install -y amazon-efs-utils  # Amazon Linux 
            yum install -y nfs-utils         # RHEL  
            apt-get install nfs-common       # Ubuntu 
        # E.g., File System ID: fs-4c6d1c07
        mkdir efs                              # Create new dir (mount point), e.g., "efs"
        mount -t efs fs-4c6d1c07:/ efs         # Using EFS mount helper
        mount -t efs -o tls fs-4c6d1c07:/ efs  # Using EFS mount helper AND encryption of data in transit  
        # Using the NFS client (Udemy Tutorial used THIS method):
        mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-4c6d1c07.efs.us-east-1.amazonaws.com:/ efs
        # ... can change mount point, e.g., from `/efs` to `/var/www/html`  
        # SUCCESS @ all filesystem mounts; efs, efs+tls, and nfs4; 
        # @ mount points (dirs) existing (/var/www/html) and new (/efs, /efs2)

    # Storage 
        # Show ESB volumes  
            lsblk    
        # Show FS info  
            file -s /dev/xvdb  
            # => '/dev/xvdb: data'  # which means no FS [unformatted]    
        # Create FS [format]  
            mkfs -t ext4 /dev/xvdb  
        # Validate ...    
            file -s /dev/xvdb  
            # => '/dev/xvdb: Linux ... UUID ...'  # which means FS created
        # Create mount point, and mount it   
            mkdir /data    
            mount /dev/xvdb /data  
        # Automount per fstab; edit/add entry ...  
            `UUID=bcf.... /data /ext4 defaults,$nofail 0 2`    
            mount -a  # remount all    

    # Apache Server; Install/Launch/Test; validate instance/server is publicly available ...    
        yum install httpd apache -y   # Apache Web Server; `httpd` 
        vi /var/www/html/index.html   # create landing page     
        service httpd start           # if AMI is "Amazon Linux"    
        chkconfig httpd on            # auto start on reboot    
        service httpd status          # Apache's status    

    # Bash scripts ("User Data" @ EC2/"Advanced Details")
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
        # Auto runs @ EC2 launch; "text file" (.txt), (gets base64 encoded); 
        # SG of EC2 must allow SSH (port 22), HTTP (port 80), and HTTPS (port 443) connections;
        # use to bootstrap AWS SDKs etc.
            # RUNs ONLY DURING the FIRST BOOT, @ EC2 launch, by default
            # Change to every boot: https://aws.amazon.com/premiumsupport/knowledge-center/execute-user-data-ec2/    
        # cloud-init app by Canonical, modified by AWS, specifies boot Linux images @ cloud environ.; 
            # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-ami-basics.html#amazon-linux-cloud-init
            /etc/cloud/cloud.cfg.d  # cloud-init config

        # Apache Server + index.html + healthy.html 
            #!/bin/bash
            yum update -y         # Update kernel 
            yum install httpd -y  # install Apache Web Server
            service httpd start   # start Apache Web Server
            chkconfig httpd on    # start Apache Web Server on boot, henceforth 
            service httpd status  # server status check
            # if apropos S3 role assumed, this EC2 instance can pull STATIC index.html, etc, from S3 ... 
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
            echo -e "<h2><pre>\n$(date)\n</pre></h2>"  >> index.html
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

        # Apache/PHP  https://aws.amazon.com/sdk-for-php/    
            #!/bin/bash    
            yum update -y    
            yum install httpd24 php56 git -y    
            service httpd start    
            chkconfig httpd on    
            cd /var/www/html    
            echo "<?php phpinfo();?>" > test.php    
            git clone https://github.com/acloudguru/s3    
            # PHP SDK via "Composer" install   
            # http://docs.aws.amazon.com/aws-sdk-php/v3/guide/getting-started/installation.html#installing-via-composer    

        # Node.js Server setup 
        # Can use generic Linux distro, but tutorial used pre-installed;
        # @ "AWS Cert. Dev+Soln.Arch+SysOps.Adm Associate" > "017..." > "intro-ec2-lab-v1.0.pdf"    
            #!/bin/bash    
            yum -y update    
            # Setup Linux Firewall :: allow TCP ports 80, 8080    
            # Node.js is setup to listen on port 8080, but web traffic is arriving on port 80, so setup IP FORWARDING: 80 => 8080
            iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080     
            iptables -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT    
            iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT    
            # INSTALL Node.js
                # AWS: Setting Up Node.js on an Amazon EC2 Instance     
                # http://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html   
                # https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/setting-up-node.html
                # per Node Version Manager; `nvm`, versioning install ...
                    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
                    . ~/.nvm/nvm.sh
                    nvm install node # latest
                # per NodeJS.org  https://github.com/nodesource/distributions  
                    curl -sL https://rpm.nodesource.com/setup_10.x | bash -  
                    yum install -y nodejs npm --enablerepo=epel  
                # Optional: install build tools
                    yum install gcc-c++ make 
                    # OR 
                    yum groupinstall 'Development Tools'
            # INSTALL Express [website framework]    
            npm install express -g    
            # INSTALL git    
            yum install git -y    
            git --version    
            # pull in BackSpaceAcademy sample app (Node/Express/Jade)  
            git clone https://github.com/BackSpaceTech/node-js-sample.git    
            pushd node-js-sample    
            npm install  # dependencies per package.json file    
            npm start    # launch app    
            # ... or in debug mode [debug info @ stdout] ...    
            DEBUG=node-js-sample:* npm start 
            # ... then browse to its Public IP to see the served website/app. 
