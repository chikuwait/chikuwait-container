Namespace.unshare(Namespace::CLONE_NEWPID) 
pid = Process.fork do
    rate = Cgroup::CPU.new "chikuwait"
    core = Cgroup::CPUSET.new "chikuwait"    
    rate.cfs_quota_us = 200000
    rate.cfs_period_us = 1000000
    core.cpus = "0-3"
    core.mems = "0"

    rate.create
    core.create
    rate.attach
    core.attach

 
    Namespace.unshare(Namespace::CLONE_NEWUTS)
    Namespace.unshare(Namespace::CLONE_NEWIPC)
    Namespace.unshare(Namespace::CLONE_NEWNS)
    #Namespace.unshare(Namespace::CLONE_NEWNET)
    Namespace.setns(Namespace::CLONE_NEWNET, fd: File.open("/var/run/netns/chikuwait").fileno)

    c = Capability.new
    cap = [Capability::CAP_CHOWN, Capability::CAP_DAC_OVERRIDE, Capability::CAP_FSETID, Capability::CAP_FOWNER, Capability::CAP_MKNOD, Capability::CAP_NET_RAW, Capability::CAP_SETGID, Capability::CAP_SETUID, Capability::CAP_SETPCAP, Capability::CAP_NET_BIND_SERVICE, Capability::CAP_SYS_CHROOT, Capability::CAP_KILL, Capability::CAP_AUDIT_WRITE]
    c.set Capability::CAP_PERMITTED, cap
    c.set_flag Capability::CAP_EFFECTIVE, cap, Capability::CAP_SET
    
    Dir.chdir("/home/ubuntu/debian/jessie-sample/") 
    Dir.chroot("/home/ubuntu/debian/jessie-sample/")

    system 'hostname debian'
    system 'ip link set lo up'    
    system "mount -t proc proc /proc"
    Kernel.exec '/bin/bash'

end
Process.waitpid2(pid)
