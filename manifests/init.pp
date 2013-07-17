######################################################################
# Usage :
#   Because each server needs monit, so put the following in site.pp
#   and inside the node definition::
#
#   class { 'monit::monit':
#           server_types => $server_types,
#  		      monit_account,
#			      monit_passwd,
#			      data_volumes => ['XXX', 'YYY', 'ZZZ'],
#   )
#
#
######################################################################



class monit::monit($server_types=['',],
  		$monit_account,
			$monit_passwd,
			$monit_interval = 120,
      $data_volumes=['sdb1','sdc1','sdd1','sde1','sdf1','sdg1','sdh1','sdi1','sdj1','sdk1','sdl1','sdm1','sdn1','sdo1','sdp1','sdq1','sdr1','sds1','sdt1','sdu1','sdv1','sdw1']
){
	package { 'monit':
        ensure => present,
        #before => Package['monitplugins'],
    }
	#package { 'monitplugins':
        #ensure => present,
        #before => File['/etc/monit/'],
	#}
	#file { '/opt/monit':
        #notify => Service['monit'], 
        #ensure => directory,
        #mode => 0644,
        #before => File["/etc/monit/"],
	#}

	file { '/etc/monit/':
        notify => Service['monit'],
        ensure => directory,
        mode => 0644,
        }

	file { '/etc/monit/plugins':
        notify => Service['monit'], 
        ensure => directory,
        mode => 0644,
	}

	file { 'monitrc':
        notify => Service['monit'], 
        path => "/etc/monit/monitrc",
        ensure => file,
        content => template("monit/monitrc.erb"),
	}

	file { '/etc/monit/conf.d': 
        ensure => directory,
        mode => 0644,
	}

        file { '/etc/logrotate.d/monit':
        ensure => 'present',
        source => 'puppet:///modules/monit/monit_logrotate',
        owner => 'root',
        group => 'root',
        mode => 644,
        require => [Package['monit']],
        }
	
        file { '/etc/monit/plugins/latestrrmsg':
        ensure => 'present',
        source => 'puppet:///modules/monit/latestrrmsg',
        owner => 'root',
        group => 'root',
        mode => 755,
        }

	monit::rcfile { $server_types: }
	
	service { 'monit':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
    }

        file { '/usr/local/mon2nagios':
        ensure => directory,
        mode => 0644,
       }

       file { 'notifier':
        path => "/usr/local/mon2nagios/notifier",
        ensure => file,
        content => template("monit/notifier.erb"),
	mode => 0755
        }

       file { 'mon2nagios_conf':
        path => "/usr/local/mon2nagios/mon2nagios.conf",
        ensure => file,
        content => template("monit/mon2nagios_conf.erb"),
        }

       file { 'trap2nagios':
        path => "/usr/local/mon2nagios/trap2nagios",
        ensure => file,
        content => template("monit/trap2nagios.erb"),
	mode => 0755
        }



       file { 'healthcheck.py':
        path => '/usr/lib/python2.7/dist-packages/keystone/middleware/healthcheck.py',
        ensure => file,
        source => 'puppet:///modules/monit/healthcheck.py',
	owner => 'root',
        group => 'root',
        mode => 644,
        }

#       file { '/usr/lib/python2.7/dist-packages/keystone/middleware/healthcheck.py':
#        ensure => 'present',
#        source => 'puppet:///modules/monit/healthcheck.py',
#	owner => 'root',
#        group => 'root',
#        mode => 644,
#        }

}
