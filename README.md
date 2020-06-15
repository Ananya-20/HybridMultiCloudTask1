
Create/launch Application on AWS Using Terraform

1. Create the key and security group which allow port 80.
2. Launch EC2 instance.
3. In this EC2 instance use the key and security group which we have created in step1.
4. Launch one volume (EBS) and mount that volume into /var/www/html.
5. Developer have uploaded the code into github repo and the repo has some images.
6. Copy the github repo code into /var/www/html.
7. Create S3 bucket, copy/deploy the images from  github repo into the S3 bucket and change the permission to public readable.
8.Create a CloudFront using S3 bucket (which contains images) and use the 

