---
layout: post
title: "docker machine and aws in combination with ansible"
date: 2015-06-13
categories: docker docker-machine ansible aws
---

Initial setup with ansible and `docker-machine`. In this case i have been using aws to run a docker host for me created with `docker-machine`. I had a goal to provision a ec2 box and have a few docker containers running in that ec2 vm. A note here is that the same way should work on any of the `docker-machine` driver there is nothing unique with aws in the way i have done this. From what i know you cant NOT use ansible on boot2docker, i have assumed that there is a full linux vm running. 

Since ansible is using a ssh-key i had to add that key to the `docker-machine` ec2 vm after it’s created. There is a option to run remote command line commands on a remote docker-machine driver. 

first lets create the a driver on amazon ec2. This will create a vm of the type "t2.micro" which is the default type on aws. If you like to change the instance type you can use this "--amazonec2-instance-type"
{% highlight bash%}
docker-machine create \
--driver amazonec2 \
--amazonec2-access-key <key> \
--amazonec2-secret-key <key> \
--amazonec2-subnet-id <key> \
--amazonec2-region eu-west-1 \
box \ 
{% endhighlight %}

It can look like this to add your public ssh key to the ec2 vm. I am taking the output of my public ssh key and assigning it to a variable localKey. Then running a remote command with `docker-machine` on the driver named 'box'. The localKey variable is added to the remote box ssh authorized_keys.
{% highlight bash%}
localKey=$(cat ~/.ssh/id_rsa.pub) \
&& docker-machine ssh box "echo "$localKey" >> .ssh/authorized_keys" \
&& eval "$(docker-machine env box)"
{% endhighlight %}

To get ansible working now i just have to add the ip of the driver. i am taking the ip of the driver box and assigns it to the variable driverIP that variable it then used to echo the ip in to the configured ansible inventory file.
{% highlight bash%}
driverIP=$(docker-machine ip box) \
&& echo "\n[box]\nroot"@$driverIP >> $ANSIBLE_INVENTORY
{% endhighlight %}

Now that you have done the basic setup to be able to run ansible on the remote system. We have to install a few packets to be able to start docker with ansible. Here is a example ansible playbook. Ansible will need to have docker-py installed on the target host to be able to start docker containers. The file is saved as "ansible-docker-host.yml" due to a issue in pip the docker-py version had to be 1.1.0 .
{% highlight yaml%}
---
- hosts: box
  remote_user: root
  sudo: yes
  tasks:
    - name: apt install python-setuptools
      apt: name=python-setuptools

    - name: apt install python-dev
      apt: name=python-dev

    - name: apt install python-pip
      apt: name=python-pip

    - name: pip install docker-py
      pip: name=docker-py version=1.1.0
{% endhighlight %}

Lets run the playbook to get the remote system installed with the needed to start docker with ansible
{% highlight bash%}
ansible-playbook ansible-docker-host.yml
{% endhighlight %}

The image used have have sshd installed username:root password:foobar. What will be done is to start a container named testing with image mad01/sshlab found on the docker hub, and the state of the docker container is started, the container port 22 will be mapped to the ec2 vm port 2222. A note here is that the docker-machine setup function will not have created a fireawall rule for that 2222 port on amazon, that is outside the scope of docker-machine atm. 
{% highlight yaml%}
---
- hosts: box
  remote_user: root
  sudo: yes
  tasks:
    - name: testing container
      docker:
        name: testing
        image: mad01/sshlab
        state: started
        pull: always
        ports:
          - "2222:22"
{% endhighlight %}

Lets now start the docker container on the remote vm. 
{% highlight bash%}
ansible-playbook ansible-docker-start.yml
{% endhighlight %}

you can check that the docker container is running with "docker ps" on the local machine. to remove the aws ec2 vm you just run.
{% highlight bash%}
docker-machine rm box
{% endhighlight %}
