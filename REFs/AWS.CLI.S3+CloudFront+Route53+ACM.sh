#!/usr/bin/env bash
# ----------------------------
#  aws cli :: S3 + CloudFront
# ----------------------------
exit
# INSTALL aws (awscli)
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

# ****************************************************************************
#  Some aws CLI/API endpoints require JSON that is ESCAPED (QUOTES);
#  some don't; knowable only on failed attempt: "malformed ...",
#  or per GET option/mode of a failed POST/PUT resource.
# ****************************************************************************

# @ S3  (High Level) 
# REF: https://awscli.amazonaws.com/v2/documentation/api/latest/index.html
# UG:  https://docs.aws.amazon.com/cli/latest/userguide/cli-s3.html  
# @ S3API (API Level)  https://docs.aws.amazon.com/cli/latest/reference/s3api/
# Bucket URL (endpoint); * If Route53 domain-name, THEN _BUCKET MUST be domain-name  
"https://s3-${_REGION}.amazonaws.com/${_BUCKET}"  # * 
"https://s3.amazonaws.com/${_BUCKET}"            # @ us-east-1  

export _DOMAIN='sempernow.com'
export _BUCKET="$_DOMAIN"
# Synch PWD to bucket
aws s3 sync . s3://$_BUCKET --delete
# -----------------------------------------------------------------------------
# s3  https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3/index.html

# Bucket names 
aws s3 ls | cut -d' ' -f3

# Create (make bucket)  
aws s3 mb "s3://$_BUCKET" --region 'us-east-1' 

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

# See 's3api put-bucket-policy ...''
# Delete (remove bucket) 
aws s3 rb "s3://$_BUCKET"          # if empty
aws s3 rb "s3://$_BUCKET" --force  # if not empty
# Remove file
aws s3 rm "s3://$_BUCKET/FILENAME"  
# Static Website Enable + Configure  https://docs.aws.amazon.com/cli/latest/reference/s3/website.html
aws s3 website "s3://$_BUCKET" --index-document 'index.html' --error-document 'error.html' 
# list buckets
aws s3 ls 
# list all objects in a folder of a bucket
aws s3 ls $_BUCKET/folder/ 
# Synch PWD to bucket
aws s3 sync . s3://$_BUCKET --delete 
# Upload PWD
aws s3 cp . s3://${_BUCKET}/ --recursive 
# Upload ONE file to S3 && Invalidate its CF cache
export _BUCKET='sempernow-dev-01'
export _CF_DIST='EF1719ZB5FVEG'
export _OBJECT='/md2html/md2html.css'
export _SOURCE='main-md2html.css'
_dryrun='--dryrun'
aws s3 cp $_SOURCE s3://${_BUCKET}${_OBJECT} --content-type 'text/css' $_dryrun && \
    aws cloudfront create-invalidation --distribution-id $_CF_DIST --paths ${_OBJECT} $_dryrun
# ... or, per SOURCE PATH, and to ROOT OBJECT
aws s3 cp "$_SOURCE" "s3://$_BUCKET/${_SOURCE##*/}" $_dryrun && \
    aws cloudfront create-invalidation --distribution-id $_CF_DIST --paths ${_OBJECT} $_dryrun

# -----------------------------------------------------------------------------
# @ s3api https://awscli.amazonaws.com/v2/documentation/api/latest/reference/s3api/index.html

# LIST objects in bucket; NAME (KEY) & SIZE per OBJECT  
aws s3api list-objects --bucket $_BUCKET --query "Contents[].[Key,Size]" --output text
    # TOTALs [size-total,number-of-objects]
    --query "[sum(Contents[].Size), length(Contents[])]" 

# GET object (pull) : download to file @ local path
aws s3api get-object --bucket $_BUCKET --key $_S3_FOLDER/$_FNAME_AND_EXT  $_LOCAL/$_FNAME_AND_EXT 
{
    "AcceptRanges": "bytes",
    "LastModified": "Wed, 12 Jan 2022 16:45:37 GMT",
    "ContentLength": 10636,
    "ETag": "\"db62bc3b15ce1b9bc1537985e0397b81\"",
    "ContentType": "application/font-woff",
    "Metadata": {}
}
# GET meta only
aws s3api head-object --bucket $_BUCKET --key $_KEY

#... as key:val pairs
aws s3api head-object --bucket $_BUCKET --key $_KEY \
    |jq '{ContentType: .ContentType, Mtime: .LastModified, Size: .ContentLength}'  
{
  "ContentType": "application/font-woff",
  "Mtime": "Wed, 12 Jan 2022 16:45:37 GMT",
  "Size": 10636
}
# ... natively, sans jq 
    --query "{MIME:ContentType,Mtime:LastModified,Size:ContentLength}"

# VERSIONING (Don't!)
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

# Bucket Policy 
# Add|Replace  https://docs.aws.amazon.com/cli/latest/reference/s3api/index.html
aws s3api put-bucket-policy --bucket $_BUCKET --policy file://policy.json
# Get 
aws s3api get-bucket-policy --bucket $_BUCKET    

# Block all public access to bucket but thru AWS Resource(s) delcared @ Bucket Policy (per bucket).
aws s3api put-public-access-block --bucket $_BUCKET \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

    # ... ALL BUCKETS 
    aws s3 ls |awk '{print $3}' |xargs -I{} aws s3api put-public-access-block --bucket {} \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# CORS  https://docs.aws.amazon.com/AmazonS3/latest/userguide/ManageCorsUsing.html
    _FILE='s3.cors.json'
    aws s3api put-bucket-cors --bucket $_BUCKET --cors-configuration "file://$_FILE"

# Content-Type : Set
_PATH='media/avatars/mbf/cap-A.svg'
aws s3api put-object --bucket $_BUCKET --key $_PATH --content-type 'image/svg+xml'

# Content-Type : RESET ALL of a type (.svg) @ bucket
aws s3 cp \
       s3://$_BUCKET/ \
       s3://$_BUCKET/ \
       --exclude '*' \
       --include '*.svg' \
       --no-guess-mime-type \
       --content-type="image/svg+xml" \
       --metadata-directive="REPLACE" \
       --recursive

# Content-Type : Read/Test
aws s3api head-object --bucket $_BUCKET --key $_PATH |jq .ContentType
#=> "image/svg+xml"

# -----------------------------------------------------------------------------
# @ OAI (origin-access-identity); public access thru CloudFront ONLY, not S3
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html

# LIST identities
aws cloudfront list-cloud-front-origin-access-identities > cf.list-oai.json
# GET oai CONFIG (CallerReference, Comment, ETag)
_CFr_OAI_ID='E3DRSYQX5FYO84'
aws cloudfront get-cloud-front-origin-access-identity-config --id $_CFr_OAI_ID

# CREATE
# origin-access-identity/cloudfront/ID-of-origin-access-identity
aws cloudfront create-cloud-front-origin-access-identity \
    --cloud-front-origin-access-identity-config "CallerReference=$(date "+%s"),Comment=S3-$_BUCKET"

# -----------------------------------------------------------------------------
# @ ACM (Using GUI allows for auto CNAME record creation)
# https://docs.aws.amazon.com/cli/latest/reference/acm/

# LIST Certificates
aws acm list-certificates 

# REQUEST Certificate(s)
aws acm request-certificate --domain-name $_DOMAIN \
    --validation-method 'DNS' \
    --subject-alternative-names "*.${_DOMAIN}" \
    --idempotency-token 'elrewh55' > "acm.request-cert-ALL${_DOMAIN}.json"
# VALIDATEs by adding its CNAME to DNS records @ Route53 (hosted zone)
# Easiest way to generate CNAME records is during ACM Request process, 
# else at CloudFront > Edit, else manually at Route53. 
# CNAME record required to add/use any non-CloudFront-default domain name to distribution. 

# Describe (includes CNAME Name/Value pairs; get Cert ARN from above return or `aws acm list-certificates`)
aws acm describe-certificate --certificate-arn $_CERT_ARN > "acm.describe-cert-ALL${_DOMAIN}.json"
# GET Cert (.pem) :: install per select @ CloudFront; installs automatically
aws acm get-certificate --certificate-arn $_CERT_ARN > "acm.get-cert-ALL${_DOMAIN}.pem"
# DELETE Cert 
aws acm delete-certificate --certificate-arn CERT_ARN

# -----------------------------------------------------------------------------
# @ Route53  https://docs.aws.amazon.com/cli/latest/reference/route53/index.html

# GLOBAL
export _DOMAIN='34.206.99.48.in-addr.arpa'

# Hosted Zone : Create (idempotent @ 1 min) : JSON response
aws route53 create-hosted-zone \
    --name $_DOMAIN \
    --caller-reference $(date '+%H.%m') \
    --hosted-zone-config Comment='rDNS / PTR for external SMTP server'

# Hosted Zones : Zone ID of a domain
_ZONE_ID="$(aws route53 list-hosted-zones \
    | jq -Mr ".HostedZones[] | select(.Name | contains(\"$_DOMAIN\")) | .Id")"
#_ZONE_ID="${_ZONE_ID#/hostedzone/}"
_ZONE_ID="${_ZONE_ID/\/hostedzone\//}"
echo $_ZONE_ID # Z01640621UTBMWLWZCQDG

# Hosted Zone : Get by Zone ID
aws route53 get-hosted-zone --id $_ZONE_ID

# Hosted Zone : Get by Zone ID : NameServers list (Must manually ADD trailing DOT!!!)
aws route53 get-hosted-zone --id $_ZONE_ID |jq -Mr .DelegationSet.NameServers[]

# Hosted Zone : resource records @ Zone ID
aws route53 list-resource-record-sets \
    --hosted-zone-id $_ZONE_ID > "route53.list.record-sets-${_DOMAIN}.json"

# Resource Record Sets : Create|Upsert : JSON response
_FILE_PATH="route53-change-resource-record-sets.json"
aws route53 change-resource-record-sets \
    --hosted-zone-id $_ZONE_ID \
    --change-batch \
    "file://${_FILE_PATH}"

# Test DNS 
aws route53 test-dns-answer --hosted-zone-id $_ZONE_ID \
    --record-name $_DOMAIN --record-type 'A'

# Hosted Zones : ALL : Names & IDs ("Id", not "ID")
aws route53 list-hosted-zones | jq '.HostedZones[] | .Name, .Id'

# Hosted Zones : ALL resource records @ ALL zones 
aws route53 list-hosted-zones | jq -M .HostedZones[].Id \
    | xargs -n1 aws route53 list-resource-record-sets --hosted-zone-id
# Or, sans jq 
aws route53 list-hosted-zones --query "HostedZones[].Id" --output text \
    | xargs -n1 aws route53 list-resource-record-sets --hosted-zone-id
    
# -----------------------------------------------------------------------------
# @ CloudFront  https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudfront/index.html

# LIST distributions 
aws cloudfront list-distributions --query "DistributionList.Items[*].{Bucket:Origins.Items[0].Id,OAI:Origins.Items[0].S3OriginConfig.OriginAccessIdentity,DistID:Id,Domain:DomainName}"

# GET distribution (can use existing dist as template for new)
_DIST_ID='EM5ELRXIN61EW'
aws cloudfront get-distribution --id $_DIST_ID >'cf.get-distribution.json'

# Cache Policies: Managed by AWS (Fits common use cases) 
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html?icmpid=docs_cf_help_panel

# CREATE distribution per value @ "DistributionConfig" key (of 'cf.dist.get.json')
    aws cloudfront create-distribution \
        --distribution-config file://cf.dist.create.json \
        > 'cf.dist.created.json' # Prefix is, e.g., "OriginPath: /static"

# UPDATE distribution (requires full distribution data + new/changed)
    _DIST_ID='E4RPOQUSBO3HY'
    aws cloudfront get-distribution --id $_DIST_ID >'cf.dist.get.json'
    # ... remove "Etag" key and make changes, then ...
    aws cloudfront update-distribution \
        --distribution-config file://cf.dist.update.json \
        > 'cf.dist.updated.json'

# CLEAR/INVALIDATE CACHE for object(s), e.g., all @ "${_BUCKET}/css" 
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/cloudfront/create-invalidation.html
    export _DIST_ID='EM5ELRXIN61EW' # gd9.ch
    # OMIT any CloudFront prefix; path(s) should be of HTTP client
    aws cloudfront create-invalidation --distribution-id $_DIST_ID --paths "/lan/js/*" "/lan/css/main.css"

    # Invalidate path(s)
    _DIST_ID='E2X1P5Z37ELLF0'
    _PATHS='/media/avatars/mbf/cap-A.svg'
    # Create and store the ID
    _INV_ID="$(aws cloudfront create-invalidation --distribution-id $_DIST_ID --paths $_PATHS |jq -Mr .Invalidation.Id)"
    # Check status
    aws cloudfront get-invalidation --distribution-id $_DIST_ID --id $_INV_ID
