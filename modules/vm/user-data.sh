#! /bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Hello from user-data!"
sudo apt update
sudo apt install -y apache2 unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
AWS_INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
REGION=us-east-1
EC2_NAME=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)

echo "<html>" > index.html
echo "<p>Instance ID: $(curl http://169.254.169.254/latest/meta-data/instance-id)</p>" >> index.html
echo "<p>Host: $(curl http://169.254.169.254/latest/meta-data/hostname)</p>" >> index.html
echo "<p>EC2 Instance Name: $EC2_NAME</p>" >> index.html
echo "<p>AMI: $(curl http://169.254.169.254/latest/meta-data/ami-id)</p>" >> index.html
echo "<p>Public IP: $(curl http://169.254.169.254/latest/meta-data/public-ipv4)</p>" >> index.html

echo "</html>" >> index.html

sudo cp index.html /var/www/html/index.html