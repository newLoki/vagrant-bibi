class mysql {
  $mysqlPassword = "root"
 
  package { "mysql-server":
    ensure => present,
  }

  service { "mysql":
    enable => true,
    ensure => running,
    require => Package["mysql-server"],
  }

  exec { "set-mysql-password":
    unless => "mysqladmin -uroot -p$mysqlPassword status",
    command => "mysqladmin -uroot password $mysqlPassword",
    require => Service["mysql"],
  }

}