Image creation process
----------------------

1. Download prepared amd64 image from ubuntu site (https://cloud-images.ubuntu.com/trusty/20150728/)
2. create file with content
     cat > my-user-data <<EOF
     #cloud-config
     password: aaaaaa
     chpasswd: { expire: False }
     ssh_pwauth: True
     EOF
3. Run command 
  * cloud-localds my-seed.img my-user-data
4. Create new 20G image and copy ubuntu image into it.
  * truncate -s 20G outdisk.img
  * sudo virt-resize --expand /dev/sda1 ubuntu-14.04-server-cloudimg-amd64-disk1.img outdisk.img
5. Run virtual machine using kvm (local ssh (when started) is forwarded to port localhost:5555): 
  * sudo kvm -net nic -net user,hostfwd=tcp::5555-:22 -hda outdisk.img -hdb my-seed.img -m 3G
6. Create travis user:
  * sudo adduser travis
   *  use password travis
  * sudo visudo
   *  add line "travis ALL=(ALL) NOPASSWD:ALL" after the line "#includedir /etc/sudoers.d"
7. Copy content to /home/travis/chef (in the guest OS type:)
  * su - travis
  * mkdir ~/chef
  * scp -r your_user_name@your_ip:your_path_to_chef_directory/* ~/chef
8. Execute CHEF SOLO remotely
  * ssh travis@localhost -p 5555
  * cd ~/chef
  * sudo bash ./init.sh
9. Halt virtual machine in the remote session
  * sudo poweroff
10. Upload image into openstack.
  * glance -k image-create --progress --file outdisk.img --disk-format raw --name "Ubuntu1404-my-sample-server-image" --container-format bare
