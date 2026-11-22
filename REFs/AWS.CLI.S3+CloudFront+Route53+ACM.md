## S3 Bucket Setup
```bash
export _DOMAIN='uqrate.org'
export _BUCKET="uqrate.org"
export _OAI='E3E32ST6ZZJXB0'
export _CERT_ARN='arn:aws:acm:us-east-1:971733315851:certificate/6fa27e32-1d84-4c2b-911b-1c0ffacb7b71'
export _DIST_ID='E2I1ETCIRQ3PLX' # d2z2qif30xj0ym.cloudfront.net
export _ZONE_ID='Z03607433CJ17NGTHYTYE'

_DOMAIN='gd9.ch'
_BUCKET="gd9.ch"
_OAI='E2HAZADACQ2G1'
_CERT_ARN='arn:aws:acm:us-east-1:971733315851:certificate/2bce3bf8-5d83-4f9e-b0bf-91eb574a350d'
_DIST_ID='EM5ELRXIN61EW' # 'd191omt5dusrvf.cloudfront.net'
_ZONE_ID='Z03661092A3ARWLAMYFZE'

# -----------------------------------------------------------------------------
# @ S3 
# CREATE (make bucket from folder having name of bucket)  
aws s3 mb "s3://${PWD##*/}" --region 'us-east-1' 
# UPLOAD/SYNC (from folder having name of bucket and subdir ./bucket)
aws s3 sync ./bucket s3://${PWD##*/} --delete
# STATIC Website ENABLE + CONFIGure  
#  https://docs.aws.amazon.com/cli/latest/reference/s3/website.html
aws s3 website s3://$_BUCKET/ --index-document 'index.html' --error-document 'error.html'
# SETUP www. subdomain-name bucket for naked-domain-name bucket 
aws s3 mb s3://www.$_BUCKET  --region 'us-east-1' 
# REDIRECT www. subdomain-name bucket to naked-domain-name bucket 
printf '{"RedirectAllRequestsTo":{"HostName": "%s"}}\n' $_BUCKET > 'redirect.json'
aws s3api put-bucket-website --bucket www.$_BUCKET --website-configuration file://bucket/redirect.json

# ADD Bucket POLICY (create per template @ aws/policy.templates)
aws s3api put-bucket-policy --bucket $_BUCKET --policy file://s3api.policy.json 
# GET Bucket POLICY (unescape "Policy" key)
aws s3api get-bucket-policy --bucket $_BUCKET | jq -r .Policy | jq . > 's3api.policy.got.json'

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
# @ CloudFront

# CREATE OAI (@ CloudFront dist key "OriginAccessIdentity") 
# (OAI is a user-id;  static site configured such that OAI is lone user allowed S3 access)
aws cloudfront create-cloud-front-origin-access-identity \
    --cloud-front-origin-access-identity-config \
    "CallerReference=$(date "+%s"),Comment=S3-$_BUCKET" \
    > 'cf.oai.created.json'

# LIST distributions 
aws cloudfront list-distributions --query "DistributionList.Items[*].{Bucket:Origins.Items[0].Id,OAI:Origins.Items[0].S3OriginConfig.OriginAccessIdentity,DistID:Id,Domain:DomainName}"
# GET distribution (can use existing dist as template for new)
aws cloudfront get-distribution --id $_DIST_ID > 'cf.dist.get.json'
# CREATE distribution per value @ "DistributionConfig" key (of 'cf.dist.get.json')
aws cloudfront create-distribution \
    --distribution-config file://cf.dist.create.json \
    > 'cf.dist.created.json'

# UPDATE distribution (requires full distribution data + new/changed)
aws cloudfront update-distribution --id $_DIST_ID \
    --distribution-config  file://cf.dist.update.json > 'cf.dist.updated.json'
# ... remove "Etag" key.

# -----------------------------------------------------------------------------
# @ Route53  https://docs.aws.amazon.com/cli/latest/reference/route53/  

# LIST hosted zones [and get zone-id of $_DOMAIN]
aws route53 list-hosted-zones --query "HostedZones[].[Name,Id]" --output text 
aws route53 list-hosted-zones > 'route53.list.hosted-zones.json'

# CREATE hosted zone
aws route53 create-hosted-zone --name $_DOMAIN \
    --caller-reference $(date +%H.%M) > "route53.create.json"
# LIST records
aws route53 list-resource-record-sets \
    --hosted-zone-id $_ZONE_ID > 'route53.list.json'
# LIST nameservers 
aws route53 list-resource-record-sets \
    --hosted-zone-id $_ZONE_ID \
    --query "ResourceRecordSets[0].ResourceRecords[]" --output text 

# TEST DNS 
aws route53 test-dns-answer --hosted-zone-id $_ZONE_ID \
    --record-name $_DOMAIN --record-type 'A'

# CHANGE record-sets (Add 'A' records for CloudFront dist)
aws route53 change-resource-record-sets \
    --hosted-zone-id $_ZONE_ID \
    --change-batch file://route53.add.cf.A.json
```

## "Custom Domain" (any website domain name)

- _Any public-usable domain name_, &mdash;that is, anything other than the AWS-default, e.g., `d2z2qif30xj0ym.cloudfront.net` &mdash;___requires SSL___, which is requested/issued per ACM (Certificate Manager) service.  
    - During the ACM Certificate Request process, click on each domain name and then on the button to add CNAME to Route53. 
    - Else, do similarly at CloudFront whilst editing the distribution to add those _custom_ domain names, e.g., `foo.com`, `www.foo.com`. 
    - Else do so manually at Route53; the required CNAME Name/Value pairs are obtained per &hellip;
        ```bash
        aws acm describe-certificate --certificate-arn $_CERT_ARN
        ```
- See `CNAMES.DNS_Configuration.csv`, a consolidation of `DNS_Configuration.csv` files, which may be downloaded during SSL/TLS certificate requests at ACM service (GUI).
- Can create AWS-Alias ('A') records whereof source is CloudFront distribution, but doesn't take affect until TLS Cert. 

(foo.com) Setup and HTTPS (S3/CloudFront/ACM/Route53)  
http://docs.aws.amazon.com/AmazonS3/latest/dev/website-hosting-custom-domain-walkthrough.html    

- @ ACM, request/validate public SSL Certificate 
    - use GUI 
    - ONE CERT FOR ALL "Alternate Domain Names" @ CloudFront distro 
        - See "AWS.IAM.txt" and "AWS.CLI.sh"
    - Add CNAME record by clicking on the domain name(s) listed @ ACM Request process
        - It handles the Route53 record(s) creation.
- @ CloudFront > (select the certified-domain distro) > Edit 
    - "Alternative Domain Names (CNAMEs)"
        - ADD ALL certified (sub)domains;
            - foo.com *.foo.com; one per line
    - SSL Certificate > Custom SSL Certificate (select-box)
        - Select the proper (domainname-bound) cert, per its Identifier
- @ Route 53, create a DNS record for EACH of "Alternate Domain Names" specified @ CloudFront distro: 
    - Type: A > Alias: Yes > "Alias Target" > CloudFront endpoint (hhh...hhh.cloudfront.net)
        - The CloudFront distro/endpoint appears @ select-box ONLY IF the
          domainname is specified at distro's "Alternate Domain Names".

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

