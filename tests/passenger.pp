class{ 'puppet::passenger':
  puppet_proxy_port  => '8140',
  puppet_docroot     => '/etc/puppet/doc',
  apache_serveradmin => 'me@example.com',
  puppet_site => 'master.example.com',
  puppet_conf => '/etc/puppet/puppet.conf',
  puppet_ssldir => '/var/lib/puppet/ssl',
  certname => 'master.example.com',
  passenger_max_pool_size => '4',
  passenger_high_performance => true,
  passenger_max_requests => '1000',
  passenger_stat_throttle_rate => '30',
}
