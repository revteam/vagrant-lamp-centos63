# Puppet manifest for my PHP dev machine
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
class phpdevweb
{
    File {
        owner   => "root",
        group   => "root",
        mode    => 644,
        require => Package["httpd"],
        notify  => Service["httpd"]
    }

    host { "mysql-fuelinteractive.edgewebhosting.net":
        ip => "10.10.146.22",
        ensure => present
    }

    exec { "grap-epel":
        command => "/bin/rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm",
        creates => "/etc/yum.repos.d/epel.repo",
        alias   => "grab-epel",
    }

    service { "iptables":
        ensure => stopped,
        hasstatus => true,
        status => true
    }

    exec { "disable_iptables":
        command => "sudo chkconfig iptables off"
    }

    package { "vim-enhanced":
        ensure  => present,
    }

    package { "git":
        ensure  => present,
    }

    package { "httpd":
        ensure => present
    }

    package { "httpd-devel":
        ensure  => present
    }

    package { "mod_ssl":
        ensure  => present
    }

    service { 'httpd':
        name      => 'httpd',
        require   => Package["httpd"],
        ensure    => running,
        enable    => true
    }

    file { "/etc/httpd/conf.d/vhost.conf":
        replace => true,
        ensure  => present,
        source  => "/vagrant/files/httpd/conf.d/vhost.conf",
    }

    file { "/etc/httpd/vhosts_ssl":
        ensure => "directory",
    }

    file { "/etc/httpd/vhosts":
        replace => true,
        ensure  => present,
        source  => "/vagrant/files/httpd/vhosts",
        recurse => true,
    }

    $mysql_password = "fueldev"

    package { "mysql-server": ensure => installed }
    package { "mysql": ensure => installed }

    service { "mysqld":
        enable => true,
        ensure => running,
        require => Package["mysql-server"]
    }

    file { "/var/lib/mysql/my.cnf":
        owner => "mysql", group => "mysql",
        source => "/vagrant/files/mysql/my.cnf",
        notify => Service["mysqld"],
        require => Package["mysql-server"]
    }

    file { "/etc/my.cnf":
        require => File["/var/lib/mysql/my.cnf"],
        ensure => "/var/lib/mysql/my.cnf"
    }

    file { "/var/lib/mysql/create_dbs.sh":
        replace => true,
        ensure  => present,
        source  => "/vagrant/files/mysql/create_dbs.sh",
        require => Package["mysql-server"]
    }

    #exec { "create_dbs":
     #   path => ["/bin", "/usr/bin"],
     #   command => "bash /var/lib/mysql/create_dbs.sh",
     #   require => Service["mysqld"]
    #}

    exec { "set-mysql-password":
        unless => "mysqladmin -uroot -p$mysql_password status",
        path => ["/bin", "/usr/bin"],
        command => "mysqladmin -uroot password $mysql_password",
        require => Service["mysqld"]
    }

    package { "php":
        ensure  => present,
    }

    package { "php-cli":
        ensure  => present,
    }

    package { "php-common":
        ensure  => present,
    }

    package { "php-devel":
        ensure  => present,
    }

    package { "php-gd":
        ensure  => present,
    }

    package { "php-mcrypt":
        ensure  => present,
    }

    package { "php-intl":
        ensure  => present,
    }

    package { "php-mbstring":
        ensure  => present,
    }

    package { "php-mysql":
        ensure  => present,
    }

    package { "php-pdo":
        ensure  => present,
    }

    package { "php-pear":
        ensure  => present,
    }

    package { "php-soap":
        ensure  => present,
    }

    package { "php-xml":
        ensure  => present,
    }

    package { "uuid-php":
        ensure  => present,
    }

    package { "php-pecl-memcache":
        ensure  => present,
    }

    package { "php-pecl-xdebug":
        ensure  => present,
        require => Exec["grab-epel"]
    }

    package { "php-pecl-apc":
        ensure  => present,
    }

    file { "/etc/php.ini":
        replace => true,
        ensure  => present,
        source  => "/vagrant/files/php.ini",
    }

    file { "/etc/php.d/apc.ini":
        replace => true,
        ensure  => present,
        source  => "/vagrant/files/php.d/apc.ini",
    }
}
include phpdevweb
