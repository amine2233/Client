Pod::Spec.new do |s|
  s.name = 'Client'
  s.version = '1.1.2'
  s.summary = 'Client lib.'
  s.description = <<-DESC
  Client is a request api lib.
                   DESC

  s.license = { type: 'MIT', file: 'LICENSE' }
  s.authors = { 'Amine Bensalah' => 'amine.bensalah@outlook.com' }
  s.requires_arc = true
  s.source = { git: 'https://github.com/amine2233/Client.git', tag: s.version.to_s }
  s.swift_version = '5.0'
  s.homepage     = 'https://github.com/amine2233/Client.git'

  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => s.swift_version
  }

  s.ios.deployment_target = '12.0'
  s.watchos.deployment_target = '5.0'
  s.tvos.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'

  s.module_name = s.name
  s.source_files = 'Sources/**/*.{swift}'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
  end

end
