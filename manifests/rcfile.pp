define monit::rcfile {
  file { $title:
 		path => "/etc/monit/conf.d/$title.rc",
 		ensure => file,
		content => template("monit/$title.rc.erb"),
		before => Service['monit'],
		require => File['/etc/monit/conf.d'],
		notify => Service['monit'],
	}
}
