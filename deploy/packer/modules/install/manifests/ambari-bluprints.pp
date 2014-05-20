class install::ambari-bluprints{

  if $nodecount==3{
    file{"/tmp/install/bluprint.json":
      source => "puppet:///modules/install/bluprint-3-nodes.json"
    }
    file{"/tmp/install/cluster.json":
      source => "puppet:///modules/install/3-nodes-bluprint-cluster.json"
    }    
  } 
  else {
    file{"/tmp/install/bluprint.json":
      source => "puppet:///modules/install/bluprint-1-nodes.json"
    }
    file{"/tmp/install/cluster.json":
      source => "puppet:///modules/install/1-nodes-bluprint-cluster.json"
    }
  }

  file{"/tmp/install/check_status.py":
    source => "puppet:///modules/install/check_status.py" 
  }

  file{"/tmp/install/check_status.sh":
    source => "puppet:///modules/install/check_status.sh" 
  }

  exec {"add bluprint":
    command => "curl -f -H 'X-Requested-By: ambari' -u admin:admin http://127.0.0.1:8080/api/v1/blueprints/sandbox -d @/tmp/install/bluprint.json",
    require => [File["/tmp/install/bluprint.json"],Class["install::ambari-server"]],
    logoutput => true
  }

  exec {"add cluster":
    command => "curl -f -H 'X-Requested-By: ambari' -u admin:admin http://127.0.0.1:8080/api/v1/clusters/Sandbox -d @/tmp/install/cluster.json",
    require => [File["/tmp/install/cluster.json"],Exec["add bluprint"]],
    logoutput => true
  }

  exec {"install cluster":
    command => "/bin/bash /tmp/install/check_status.sh",
    cwd => "/tmp/install",
    timeout => 0,
    logoutput => true,
    require => [File["/tmp/install/check_status.py"], File["/tmp/install/check_status.sh"], Exec["add cluster"]]
  }
  
}
