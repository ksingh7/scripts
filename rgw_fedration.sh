#!/bin/bash
set -e
set -x
#1 create pools
sudo ./create_pools.sh
#2 create a keyring
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.radosgw.keyring
sudo chmod +r /etc/ceph/ceph.client.radosgw.keyring
sudo ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.radosgw.us-east-1 --gen-key
sudo ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.radosgw.us-west-1 --gen-key
sudo ceph-authtool -n client.radosgw.us-east-1 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
sudo ceph-authtool -n client.radosgw.us-west-1 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth del client.radosgw.us-east-1 
sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth del client.radosgw.us-west-1
sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.radosgw.us-east-1 -i /etc/ceph/ceph.client.radosgw.keyring
sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.radosgw.us-west-1 -i /etc/ceph/ceph.client.radosgw.keyring
# 3 create a region
sudo radosgw-admin region set --infile us.json --name client.radosgw.us-east-1
set +e
sudo rados -p .us.rgw.root rm region_info.default
set -e
sudo radosgw-admin region default --rgw-region=us --name client.radosgw.us-east-1
sudo radosgw-admin regionmap update --name client.radosgw.us-east-1
# try don't do it
sudo radosgw-admin region set --infile us.json --name client.radosgw.us-west-1
set +e 
sudo rados -p .us.rgw.root rm region_info.default
set -e
sudo radosgw-admin region default --rgw-region=us --name client.radosgw.us-west-1
sudo radosgw-admin regionmap update --name client.radosgw.us-west-1
# 4 create zones
# try chanege us-east-no-secert.json file contents
sudo radosgw-admin zone set --rgw-zone=us-east --infile us-east-no-secert.json --name client.radosgw.us-east-1
sudo radosgw-admin zone set --rgw-zone=us-east --infile us-east-no-secert.json --name client.radosgw.us-west-1
sudo radosgw-admin zone set --rgw-zone=us-west --infile us-west-no-secert.json --name client.radosgw.us-east-1
sudo radosgw-admin zone set --rgw-zone=us-west --infile us-west-no-secert.json --name client.radosgw.us-west-1
set +e
sudo rados -p .rgw.root rm zone_info.default
set -e
sudo radosgw-admin regionmap update --name client.radosgw.us-east-1
# try don't do it
sudo radosgw-admin regionmap update --name client.radosgw.us-west-1
#5 Create Zone Users system user
sudo radosgw-admin user create --uid="us-east" --display-name="Region-US Zone-East" --name client.radosgw.us-east-1 --access_key="XNK0ST8WXTMWZGN29NF9" --secret="7VJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5" --system
sudo radosgw-admin user create --uid="us-west" --display-name="Region-US Zone-West" --name client.radosgw.us-west-1 --access_key="AAK0ST8WXTMWZGN29NF9" --secret="AAJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5" --system
sudo radosgw-admin user create --uid="us-east" --display-name="Region-US Zone-East" --name client.radosgw.us-west-1 --access_key="XNK0ST8WXTMWZGN29NF9" --secret="7VJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5" --system
sudo radosgw-admin user create --uid="us-west" --display-name="Region-US Zone-West" --name client.radosgw.us-east-1 --access_key="AAK0ST8WXTMWZGN29NF9" --secret="AAJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5" --system
#6 subuser create
#may create a user without --system?
sudo radosgw-admin subuser create --uid="us-east"  --subuser="us-east:swift" --access=full --name client.radosgw.us-east-1 --key-type swift --secret="7VJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin subuser create --uid="us-west"  --subuser="us-west:swift" --access=full --name client.radosgw.us-west-1 --key-type swift --secret="BBJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin subuser create --uid="us-east"  --subuser="us-east:swift" --access=full --name client.radosgw.us-west-1 --key-type swift --secret="7VJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin subuser create --uid="us-west"  --subuser="us-west:swift" --access=full --name client.radosgw.us-east-1 --key-type swift --secret="BBJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"

#5.5 creat zone users not system user
sudo radosgw-admin user create --uid="us-test-east" --display-name="Region-US Zone-East-test" --name client.radosgw.us-east-1 --access_key="DDK0ST8WXTMWZGN29NF9" --secret="DDJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5" 
sudo radosgw-admin user create --uid="us-test-west" --display-name="Region-US Zone-West-test" --name client.radosgw.us-west-1 --access_key="CCK0ST8WXTMWZGN29NF9" --secret="CCJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin user create --uid="us-test-east" --display-name="Region-US Zone-East-test" --name client.radosgw.us-west-1 --access_key="DDK0ST8WXTMWZGN29NF9" --secret="DDJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin user create --uid="us-test-west" --display-name="Region-US Zone-West-test" --name client.radosgw.us-east-1 --access_key="CCK0ST8WXTMWZGN29NF9" --secret="CCJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"

#6 subuser create
#may create a user without --system?
sudo radosgw-admin subuser create --uid="us-test-east"  --subuser="us-test-east:swift" --access=full --name client.radosgw.us-east-1 --key-type swift --secret="ffJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin subuser create --uid="us-test-west"  --subuser="us-test-west:swift" --access=full --name client.radosgw.us-west-1 --key-type swift --secret="ggJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin subuser create --uid="us-test-east"  --subuser="us-test-east:swift" --access=full --name client.radosgw.us-west-1 --key-type swift --secret="ffJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
sudo radosgw-admin subuser create --uid="us-test-west"  --subuser="us-test-west:swift" --access=full --name client.radosgw.us-east-1 --key-type swift --secret="ggJm8uAp71xKQZkjoPZmHu4sACA1SY8jTjay9dP5"
