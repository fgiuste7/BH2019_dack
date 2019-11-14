# Establish awscli profile

mkdir data; cd data/

sudo apt-get install -yq fsl-5.0-complete

aws s3 cp --recursive s3://d4ck/ . --exclude "derivatives/*"
aws s3 cp --recursive s3://d4ck/derivatives/acqparams.txt .

mkdir derivatives
mv acqparams.txt derivatives/


bash Track_1_Preproc_awsN.sh /home/ubuntu/data/sub-141119

