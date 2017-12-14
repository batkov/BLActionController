#
# Be sure to run `pod lib lint BLActionController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BLActionController'
  s.version          = '0.1.2'
  s.summary          = 'BLActionController is an extension to BLListViewController to provide some actions using SwipeCellKit'

  s.description      = <<-DESC
BLActionController is an extension to BLListViewController to provide some actions using SwipeCellKit.
Delete, Edit, View basic actions. Also pick from dataSource.
BLMapListController will display items on map and on the list.
                    DESC

  s.homepage         = 'https://github.com/batkov/BLActionController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'batkov' => 'batkov@i.ua' }
  s.source           = { :git => 'https://github.com/batkov/BLActionController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/batkov111'

  s.platform     = :ios, '9.0'
  s.framework    = 'MapKit'

  s.source_files = 'BLActionController/Classes/**/*.{swift}'
  s.resource_bundles = {
    'BLActionControllerUI' => ['BLActionController/Classes/**/*.{storyboard,xib}']
  }
  s.dependency 'BLListViewController'
  s.dependency 'SwipeCellKit'
  s.dependency 'FBAnnotationClustering'
end
