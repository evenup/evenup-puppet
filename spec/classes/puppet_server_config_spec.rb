require 'spec_helper'

describe 'puppet::server::config', :type => :class do

  describe 'defaults' do
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :domain => 'example.com', :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :id => '0', :path => '/bin', :kernel => 'Linux' } }
    let(:pre_condition) { 'class { "puppet": }' }

    it { should_not contain_concat__fragment('puppet_master') }
    it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:ensure => 'absent') }
    it { should contain_file('/etc/puppetlabs/puppetserver/logback.xml').with(:ensure => 'absent') }
    it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/ca.conf').with(:ensure => 'absent') }
    it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/global.conf').with(:ensure => 'absent') }
    it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf').with(:ensure => 'absent') }
    it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf').with(:ensure => 'absent') }

    context 'redhat' do
      let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :domain => 'example.com', :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :id => '0', :path => '/bin', :kernel => 'Linux' } }
      let(:pre_condition) { 'class { "puppet": }' }
      it { should contain_file('/etc/sysconfig/puppetserver').with(:ensure => 'absent') }
    end

    context 'debian' do
      let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :domain => 'example.com', :osfamily => 'Debian', :id => '0', :path => '/bin', :kernel => 'Linux' } }
      let(:pre_condition) { 'class { "puppet": }' }
      it { should contain_file('/etc/default/puppetserver').with(:ensure => 'absent') }
    end
  end

  describe 'with server' do
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :domain => 'example.com', :osfamily => 'RedHat', :operatingsystemmajrelease => '7', :id => '0', :path => '/bin', :kernel => 'Linux' } }

    context 'all oses' do
      let(:pre_condition) { 'class { "puppet": server => true}' }

      it { should contain_file('/var/log/puppetlabs/puppetserver').with(:ensure => 'directory') }
      it { should contain_file('/var/log/puppetlabs/puppetserver').with(:mode => '0750') }
      it { should contain_concat__fragment('puppet_master').with(:content => /ca = true/) }
      it { should_not contain_concat__fragment('puppet_master').with(:content => /reports/) }
      it { should_not contain_concat__fragment('puppet_master').with( :content => /dns_alt_names/ ) }
      it { should_not contain_concat__fragment('puppet_master').with(:content => /storeconfigs/) }
      it { should contain_file('/etc/puppetlabs/puppetserver/logback.xml').with(:content => /<file>\/var\/log\/puppetlabs\/puppetserver\/puppetserver\.log<\/file>/) }
      it { should contain_file('/etc/puppetlabs/puppetserver/request-logging.xml') }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/ca.conf') }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/global.conf') }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf').with( :content => /max-active-instances: 3/ ) }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf').with( :content => /use-legacy-auth-conf: false/ ) }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/web-routes.conf') }
      it { should contain_file('/etc/puppetlabs/code/hiera.yaml').with(:ensure => 'absent') }
      it { should_not contain_firewall('500 allow inbound connections to puppetserver') }
    end

    context 'puppetserver 2.5 or earlier debian' do
      let(:pre_condition) { 'class { "puppet": server => true, server_version => "2.4.0-1puppetlabs1"}' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/web-routes.conf').without(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/ ) }
      it { should contain_file('/etc/puppetlabs/puppetserver/bootstrap.cfg').without(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/)}
      it { should contain_file('/etc/puppetlabs/puppetserver/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-service\/certificate\-authority\-service/) }
      it { should_not contain_file('/etc/puppetlabs/puppetserver/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-disabled\-service\/certificate\-authority\-disabled\-service/) }
    end

    context 'puppetserver 2.5 or earlier redhat' do
      let(:pre_condition) { 'class { "puppet": server => true, server_version => "2.3.1-1.el7"}' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/web-routes.conf').without(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/ ) }
      it { should contain_file('/etc/puppetlabs/puppetserver/bootstrap.cfg').without(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/) }
      it { should contain_file('/etc/puppetlabs/puppetserver/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-service\/certificate\-authority\-service/) }
      it { should_not contain_file('/etc/puppetlabs/puppetserver/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-disabled\-service\/certificate\-authority\-disabled\-service/) }
    end

    context 'puppetserver 2.6 or later ' do
      let(:pre_condition) { 'class { "puppet": server => true, server_version => "2.8.1-1.el7"}' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/web-routes.conf').with(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/ ) }
      it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/ ) }
      it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-service\/certificate\-authority\-service/) }
      it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-disabled\-service\/certificate\-authority\-disabled\-service/) }
    end

    context 'latest server on new install' do
      let(:pre_condition) { 'class { "puppet": server => true}' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/web-routes.conf').with(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/ ) }
      it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.trapperkeeper\.services\.status\.status\-service\/status\-service/ ) }
      it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-service\/certificate\-authority\-service/) }
      it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-disabled\-service\/certificate\-authority\-disabled\-service/) }
    end

    context 'redhat' do
      let(:pre_condition) { 'class { "puppet": server => true}' }
      it { should contain_file('/etc/sysconfig/puppetserver') }
    end

    context 'debian' do
      let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :domain => 'example.com', :osfamily => 'Debian', :id => '0', :path => '/bin', :kernel => 'Linux' } }
      let(:pre_condition) { 'class { "puppet": server => true}' }
      it { should contain_file('/etc/default/puppetserver') }
    end

    context 'set bootstrap dir' do
      let(:pre_condition) { 'class { "puppet": server => true, server_bootstrap_dir => "blah" }'}
      it { should contain_file('/etc/sysconfig/puppetserver').with(:content => /BOOTSTRAP_CONFIG="blah"/) }
    end

    context 'set java opts' do
      let(:pre_condition) { 'class { "puppet": server => true, server_java_opts => "blah" }'}
      it { should contain_file('/etc/sysconfig/puppetserver').with(:content => /JAVA_ARGS="blah"/) }
    end

    context 'set disable ca' do
      let(:pre_condition) { 'class { "puppet": server => true, server_ca_enabled => false }'}
      it { should_not contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-service\/certificate\-authority\-service/) }
      it { should contain_file('/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg').with(:content => /puppetlabs\.services\.ca\.certificate\-authority\-disabled\-service\/certificate\-authority\-disabled\-service/) }
      it { should contain_concat__fragment('puppet_master').with(:content => /ca = false/) }
    end

    context 'with hiera_source' do
      let(:pre_condition) { 'class { "puppet": server => true, hiera_source => "puppet:///data/hiera.yaml" }'}
      it { should contain_file('/etc/puppetlabs/code/hiera.yaml').with(:source => 'puppet:///data/hiera.yaml') }
    end

    context 'not managing hiera' do
      let(:pre_condition) { 'class { "puppet": server => true, manage_hiera => false }' }
      it { should_not contain_file('/etc/puppetlabs/code/hiera.yaml') }
    end

    context 'with puppetdb' do
      let(:pre_condition) { 'class { "puppet": server => true, puppetdb => true, puppetdb_server => "db.example.com" }'}
      it { should contain_file('/etc/puppetlabs/puppet/routes.yaml') }
      it { should contain_file('/etc/puppetlabs/puppet/puppetdb.conf').with(:content => /db\.example\.com/) }
      it { should contain_concat__fragment('puppet_master').with(:content => /storeconfigs/) }
    end

    context 'with puppetdb but without managed puppetdb' do
      let(:pre_condition) { 'class { "puppet": server => true, puppetdb => true, puppetdb_server => "db.example.com", manage_puppetdb => false}'}
      it { should_not contain_file('/etc/puppetlabs/puppet/routes.yaml') }
      it { should_not contain_file('/etc/puppetlabs/puppet/puppetdb.conf').with(:content => /db\.example\.com/) }
      it { should contain_concat__fragment('puppet_master').with(:content => /storeconfigs/) }
    end

    context 'with reports' do
      let(:pre_condition) { 'class { "puppet": server => true, server_reports => ["puppetdb", "hipchat"] }'}
      it { should contain_concat__fragment('puppet_master').with(:content => /reports = puppetdb, hipchat/) }
    end

    context 'with firewall' do
      let(:pre_condition) { 'class { "puppet": server => true, firewall => true }' }
      it { should contain_firewall('500 allow inbound connections to puppetserver') }
    end

    context 'with ssl-cert' do
      let(:pre_condition) { 'class { "puppet": server => true, server_ssl_cert => "/example/path" } ' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf').with(:content => /\/example\/path/) }
    end

    context 'with ssl-ssl-key' do
      let(:pre_condition) { 'class { "puppet": server => true, server_ssl_cert => "/example/path" } ' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf').with(:content => /\/example\/path/) }
    end

    context 'with ssl-ca-cert' do
      let(:pre_condition) { 'class { "puppet": server => true, server_ssl_ca_cert => "/example/path" } ' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf').with(:content => /\/example\/path/) }
    end

    context 'with ssl-cert-chain' do
      let(:pre_condition) { 'class { "puppet": server => true, server_ssl_cert_chain => "/example/path" } ' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf').with(:content => /\/example\/path/) }
    end

    context 'with ssl-crl-path' do
      let(:pre_condition) { 'class { "puppet": server => true, server_ssl_crl_path => "/example/path" } ' }
      it { should contain_file('/etc/puppetlabs/puppetserver/conf.d/webserver.conf').with(:content => /\/example\/path/) }
    end
  end

end
