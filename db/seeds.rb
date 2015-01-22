# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
statuses = Status.create([{name: 'started'}, { name: 'finished'}, {name: 'failed'}])
products = Product.create([{name: 'openshift'}, {name: 'heroku'}])
gearprofiles = GearProfile.create([{name: 'small'}, {name: 'medium'}, {name: 'large'}, {name: 'small.highcpu'}])
apptypes = AppType.create([{name: 'jbossas-7', product_id: '1'},
{name: 'jboss-dv-6.0.0', product_id: '1'},
{name: 'jbosseap-6', product_id: '1'},
{name: 'jenkins-1', product_id: '1'},
{name: 'mock-0.1', product_id: '1'},
{name: 'mock-0.2', product_id: '1'},
{name: 'mock-0.3', product_id: '1'},
{name: 'mock-0.4', product_id: '1'},
{name: 'nodejs-0.10', product_id: '1'},
{name: 'perl-5.10', product_id: '1'},
{name: 'php-5.3', product_id: '1'},
{name: 'php-5.4', product_id: '1'},
{name: 'zend-6.1', product_id: '1'},
{name: 'python-2.6', product_id: '1'},
{name: 'python-2.7', product_id: '1'},
{name: 'python-3.3', product_id: '1'},
{name: 'ruby-1.8', product_id: '1'},
{name: 'ruby-1.9', product_id: '1'},
{name: 'ruby-2.0', product_id: '1'},
{name: 'jbossews-1.0', product_id: '1'},
{name: 'jbossews-2.0', product_id: '1'},
{name: 'jboss-vertx-2.1.1', product_id: '1'},
{name: 'diy-0.1', product_id: '1'}
])
addons = Addon.create([{name: '10gen-mms-agent-0.1', product_id: '1'},
{name: 'cron-1.4', product_id: '1'},
{name: 'jenkins-client-1', product_id: '1'},
{name: 'mock-plugin-0.1', product_id: '1'},
{name: 'mock-plugin-0.2', product_id: '1'},
{name: 'mongodb-2.4', product_id: '1'},
{name: 'mysql-5.1', product_id: '1'},
{name: 'mysql-5.5', product_id: '1'},
{name: 'phpmyadmin-4', product_id: '1'},
{name: 'postgresql-8.4', product_id: '1'},
{name: 'postgresql-9.2', product_id: '1'},
{name: 'rockmongo-1.1', product_id: '1'},
{name: 'switchyard-0', product_id: '1'},
{name: 'haproxy-1.4', product_id: '1'},
{name: 'postresql', product_id: '2'}])
dockerservers = Dockerserver.create([{name: 'local', url: 'http://localhost:4243'}])
