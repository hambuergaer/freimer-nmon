class nmon (
	$package_rhel7 = 'nmon-rhel7',
	$package_rhel6 = 'nmon-rhel6'
){

include logrotate

file { '/var/log/nmon':
	ensure	=> directory
	}

case $operatingsystemmajrelease {
	'7': {
		package { $package_rhel7:
			ensure	=> latest,
			require	=> File['/var/log/nmon']
			}
		}
	'6': {
		package { $package_rhel6:
			ensure	=> latest,
			require	=> File['/var/log/nmon']
			}
		}
	}

file { '/usr/local/bin/start_nmon.sh':
	source  => ['puppet:///modules/nmon/usr/local/bin/start_nmon.sh'],
	owner   => 'root',
	group   => 'root',
	mode    => '0755',
	require	=> Package[$package]
	}

cron { start_nmon:
	command	=> "/usr/local/bin/start_nmon.sh > /dev/null 2>&1",
	user	=> root,
	hour	=> 0,
	minute	=> 0,
	require	=> File['/usr/local/bin/start_nmon.sh']
	}

logrotate::rule { 'nmon':
	path		=> '/var/log/nmon/*.nmon',
	rotate		=> 30,
	rotate_every	=> 'day',
	compress	=> true,
	dateext		=> true
	}
}
