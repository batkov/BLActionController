#
# Be sure to run `pod lib lint BLActionController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BLActionController'
  s.version          = '0.1.0'
  s.summary          = 'BLActionController is an extension to BLListViewController to provide some actions using SwipeCellKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
BLActionController is an extension to BLListViewController to provide some actions using SwipeCellKit.
Delete, Edit, View basic actions. Also pick from dataSource.
                    DESC

  s.homepage         = 'https://github.com/batkov/BLActionController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'batkov' => 'batkov@i.ua' }
  s.source           = { :git => 'https://github.com/batkov/BLActionController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/batkov111'

  s.ios.deployment_target = '9.0'

  s.source_files = 'BLActionController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BLActionController' => ['BLActionController/Assets/*.png']
  # }

    s.dependency 'BLListViewController'
    s.dependency 'SwipeCellKit'
end
