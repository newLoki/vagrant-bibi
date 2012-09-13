class application {
    #set permissions
    file {
        "/vagrant/Sites":
            ensure => directory,
            recurse => true,
            purge => false,
            owner => "www-data",
            group => "www-data",
    }

    exec {
        "create_db":
            command => 'mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS bibi"'
    }

    #run liquibase
    exec {
        "fill_db":
            command => 'java -jar build/liquibase.jar --driver=com.mysql.jdbc.Driver --classpath=build/databasedriver/mysql-connector-java-5.1.17-bin.jar --changeLogFile=data/sql/changelog.xml --url="jdbc:mysql://127.0.0.1:3306/bibi" --username=root --password="root" --contexts="test" migrate',
            cwd => "/vagrant/Sites/bibi",
            require => Exec["create_db"],
    }



    package {
        "php-pear":
            ensure => installed,
    }

    exec {
        "symfony_channel":
            command => "sudo pear channel-discover pear.symfony-project.com",
            unless => 'sudo pear list-channels | grep "pear.symfony-project.com"',
            require => Package["php-pear"],
    }

    exec {
        "phpunit_channel":
            command => "sudo pear channel-discover pear.phpunit.de",
            unless => 'sudo pear list-channels | grep "pear.phpunit.de"',
            require => Package["php-pear"],
    }

    #install phpunit
    exec {
        "install_phpunit":
            command => "sudo pear install phpunit/PHPUnit",
            creates => "/usr/bin/phpunit",
            require => [Package["php-pear"], Exec["symfony_channel"], Exec["phpunit_channel"]],
    }
}