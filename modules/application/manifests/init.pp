class application {
    #install composer
    exec {
        "composer_install":
            command => "curl -s https://getcomposer.org/installer | php",
            creates => "/vagrant/composer.phar",
            cwd => "/vagrant",
            require => [Package["curl"]]
    }

    #move composer to /usr/local/bin/composer
    exec {
        "composer_move":
            command => "sudo mv /vagrant/composer.phar /usr/local/bin/composer",
            creates => "/usr/local/bin/composer",
            require => Exec["composer_install"],
    }

    #install mayflower/bibi into sites
    exec {
        "install_bibi":
            command => "composer create-project mayflower/bibi /vagrant/Sites",
            creates => "/vagrant/Sites/index.php",
            require => [Exec["composer_install"], Exec["composer_move"]],
    }

    exec {
        "update_bibi":
            command => "composer update",
            cwd => "/vagrant/Sites",
    }

    #set permissions
    file {
        "/vagrant/Sites":
            ensure => directory,
            recurse => true,
            purge => false,
            mode => 600,
            owner => "www-data",
            group => "www-data",
            require => [Exec["install_bibi"], Exec["update_bibi"]],
    }

    #run liquibase
    exec {
        "setup_db":
            command => 'java -jar build/liquibase.jar --driver=com.mysql.jdbc.Driver --classpath=build/databasedriver/mysql-connector-java-5.1.17-bin.jar --changeLogFile=data/sql/changelog.xml --url="jdbc:mysql://127.0.0.1:3306/bibi" --username=root --password="root" --contexts="test" migrate',
            require => Exec["update_bibi"],
            cwd => "/vagrant/Sites",
    }

    package {
        "php-pear":
            ensure => installed,
    }

    #install phpunit
    exec {
        "install_phpunit":
            command => "sudo pear channel-discover pear.phpunit.de && sudo pear install phpunit/PHPUnit",
            creates => "/usr/local/bin/phpunit",
            require => Package["php-pear"],
    }
}