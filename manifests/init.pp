class nmon (
        $package_rhel7 = 'nmon-rhel7',
        $package_rhel6 = 'nmon-rhel6'
){

include logrotate

file { '/var/log/nmon':
        ensure  => directory
        }

file { '/usr/local/bin/start_nmon.sh':
        source  => ['puppet:///modules/nmon/usr/local/bin/start_nmon.sh'],
        owner   => 'root',
        group   => 'root',
        mode    => '0755'
        }

case $operatingsystemmajrelease {
        '7': {
                package { $package_rhel7:
                        ensure  => latest,
                        require => File['/var/log/nmon']
                        }

		file { '/etc/systemd/system/nmon.service':
			ensure	=> present,
			source	=> ['puppet:///modules/nmon/etc/systemd/system/nmon.service'],
			owner   => 'root',
        		group   => 'root',
        		mode    => '0664',
			require	=> Package[$package_rhel7]
			}

		exec { 'reload_systemd':
			command	=> '/bin/systemctl daemon-reload',
			subscribe => File['/etc/systemd/system/nmon.service']
			}

		service { 'nmon':
        		ensure     => 'running',
        		enable     => false,
        		hasstatus  => true,
       			hasrestart => true,
			require	   => [ File["/usr/local/bin/start_nmon.sh"], File["/etc/systemd/system/nmon.service"] ]
        		}
                }
        '6': {
                package { $package_rhel6:
                        ensure  => latest,
                        require => File['/var/log/nmon']
                        }
		
		cron { start_nmon:
        		command => "/usr/local/bin/start_nmon.sh > /dev/null 2>&1",
        		user    => root,
        		hour    => 0,
        		minute  => 1,
        		require => File['/usr/local/bin/start_nmon.sh']
        		}
		
		logrotate::rule { 'nmon':
        		path            => '/var/log/nmon/*.nmon',
        		rotate          => 30,
        		rotate_every    => 'day',
        		compress        => true,
        		dateext         => true,
			missingok	=> true,
			ifempty		=> false,
			prerotate	=> '/bin/pkill nmon > /dev/null 2>&1',
			postrotate	=> '/usr/local/bin/start_nmon.sh > /dev/null 2>&1'
        		}
                }

	default: {
      		notify {'You are not using RHEL 6/7 or CentOS 6/7': }
    		}
        }

}
