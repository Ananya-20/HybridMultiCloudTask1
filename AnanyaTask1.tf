provider "aws" {
	region = "ap-south-1"
	profile = "myprofile"
}

resource "aws_security_group" "SecurityGrp1" {
  name        = "SecurityGrp1"

  ingress {
    description = "Allowing http from port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allowing SSH from port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    Name = "SecurityGrp1"
  }
}

resource "aws_instance" "MyTaskOS1" {
	ami                         =     "ami-0447a12f28fddb066"
	instance_type       =     "t2.micro"
	key_name              =     "mykey20"
	security_groups   =      ["${aws_security_group.SecurityGrp1.name}"]

connection {
	type = "ssh"
	user = "ec2-user"
	private_key = file("C:/Users/hp/Downloads/mykey20.pem")
	host = aws_instance.MyTaskOS1.public_ip
}
provisioner "remote-exec" {
	inline= [
		"sudo yum install httpd   php git-y",
		" sudo systemctl restart httpd",
		"sudo systemctl enable httpd"
]
}
tags = {
	Name ="MyTaskOS1"
           }
}


resource "aws_ebs_volume" "myebs1" {
	availability_zone = aws_instance.MyTaskOS1.availability_zone
	size = 1
	tags = {
	    Name = " myebs1"
	           }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.myebs1.id}"
  instance_id = "${aws_instance.MyTaskOS1.id}"
}

output "MyOS_IP"  {
	value = aws_instance.MyTaskOS1.public_ip
}



resource "null_resource" "nulllocal2" {
	provisioner "local-exec" {
		command = "echo  ${aws_instance.MyTaskOS1.public_ip} > PublicIP.txt"
}
}

resource "null_resource" "nullremote3" {
	depends_on = [
		aws_volume_attachment.ebs_att,
	]
 
connection {
	type = "ssh"
	user = "ec2-user"
	private_key = file("C:/Users/hp/Downloads/mykey20.pem")
	host = aws_instance.MyTaskOS1.public_ip
} 

provisioner "remote-exec" {
	inline = [
	    "sudo mkfs.ext4  /dev/xvdh",
	    "sudo mount  /dev/xvdh  /var/www/html",
	    "sudo rm -rf   /var/www/html/*",
	     "sudo git clone  https://github.com/Ananya-20/CloudTask1.git   /var/www/html/"
]
}
}
  



resource "aws_s3_bucket" "AnanyaTask1" {
  bucket = "my-tf-test-bucket"
  acl    = "private"

  tags = {
    Name        = "AnanyaTask1"
    
  }
}
locals {
  s3_origin_id = "${ aws_s3_bucket.AnanyaTask1.bucket}"
}



resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.AnanyaTask1.id
  key    = "new_object_key"
  source =  "${file("C:/Users/hp/Documents/watch.jpg")}"
  acl = "public-read"
  content_type = "image/jpg"
  depends_on = [
        aws_s3_bucket.AnanyaTask1
        ]
}


resource "aws_cloudfront_distribution" "mycloudfront1" {
	 origin {
   		 domain_name ="${aws_s3_bucket.AnanyaTask1.bucket_regional_domain_name}"
    		 origin_id   = local.s3_origin_id
	}
    custom_origin_config {
        http_port = 80
        https_port = 80
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols= ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
        }

	enabled = true
  	
	default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
	cached_methods   = ["GET", "HEAD"]
  	target_origin_id = "local.s3_origin_id"

    		forwarded_values {
      			query_string = false

			      cookies {
        				forward = "none"
      			}
		    }
	viewer_protocol_policy = "allow-all"
 		   min_ttl                = 0
    	   default_ttl            = 3600
   		   max_ttl                = 86400
  }



restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN","US"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  
}

provisioner "remote-exec"  {
        inline = [
            "sudo su << EOF",
            "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.object1.key}' width='500' height='500'>\" >> /var/www/html/ana.html",
            "EOF"
            ]
            }
          }
            
             
connection {
	type = "ssh"
	user = "ec2-user"
	private_key = file("C:/Users/hp/Downloads/mykey20.pem")
	host = aws_instance.MyTaskOS1.public_ip
} 


 resource "null_resource" "local-exec"  {
  	depends_on = [
		null_resource.nullremote3 ,
		]
			provisioner "local-exec"  {
				command=" start chrome  ${aws_instance.MyTaskOS1.public_ip}"
			}
}

		



	
