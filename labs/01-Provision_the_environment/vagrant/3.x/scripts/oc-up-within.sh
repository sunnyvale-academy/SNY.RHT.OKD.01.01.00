#!/bin/bash
#
# Copyright 2020 Denis Maggiorotto
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#!/bin/bash




cp /vagrant/keys/master_pvt_key.pem /home/vagrant/.ssh/id_rsa
cp /vagrant/keys/master_pub_key.pem /home/vagrant/.ssh/id_rsa.pub
chown vagrant:vagrant /home/vagrant/.ssh/id_rs*


readonly openshift_release=`cat /vagrant/Vagrantfile | grep '^OPENSHIFT_RELEASE' | awk -F'=' '{print $2}' | sed 's/^[[:blank:]\"]*//;s/[[:blank:]\"]*$//'`

. "/vagrant/scripts/common.sh"

export OPENSHIFT_RELEASE=$openshift_release


# Fix permission issue on Windows host (#13)
chmod 600 /home/vagrant/.ssh/*

export ANSIBLE_HOST_KEY_CHECKING=False

if [ "$(version $openshift_release)" -gt "$(version 3.7)" ]; then
    ansible-playbook --key-file "~/.ssh/id_rsa"  /home/vagrant/openshift-ansible/playbooks/prerequisites.yml && \
    ansible-playbook --key-file "~/.ssh/id_rsa"  /home/vagrant/openshift-ansible/playbooks/deploy_cluster.yml
else
    ansible-playbook --key-file "~/.ssh/id_rsa"  /home/vagrant/openshift-ansible/playbooks/byo/config.yml
fi