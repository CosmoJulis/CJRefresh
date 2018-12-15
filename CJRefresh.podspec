Pod::Spec.new do |spec|
  spec.name         = 'CJRefresh'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/CosmoJulis/CJRefresh'
  spec.authors      = { 'Cosmo Julis' => 'cosmo.julis@gmail.com' }
  spec.summary      = 'ARC for iOS.'
  spec.source       = { :git => 'https://github.com/CosmoJulis/CJRefresh.git', :branch => 'master', :tag => spec.version }
  spec.source_files = 'CJRefresh/*.{h,m}'
end