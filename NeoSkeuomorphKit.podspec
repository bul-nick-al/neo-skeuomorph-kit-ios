#
# Be sure to run `pod lib lint NeoSkeuomorphKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NeoSkeuomorphKit'
  s.version          = '0.1.0'
  s.summary          = 'A UI component library inspired by https://dribbble.com/alexplyuto'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A library that implements main UI components required for creating apps designed with alexpluto's (https://dribbble.com/alexplyuto)
Neoskeuomorphism. This is a learning project, where the goal is to acquire iOS development skills necessary to implement
something non-trivial, like the aforementioned designs.
                       DESC

  s.homepage = 'https://github.com/Nikolay/NeoSkeuomorphKit'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Nikolay Buldakov' => 'bul-nick-al@ya.ru', 'Bulat Khabirov' => 'khabiroff_b@me.com' }
  s.source = { :git => 'https://github.com/Nikolay/NeoSkeuomorphKit.git', :tag => s.version.to_s }

  s.platform = :ios, '11.0'
  s.swift_version = '5.1'

  s.source_files = 'NeoSkeuomorphKit/Classes/**/*.{swift,h,m}'
  s.resources = ['NeoSkeuomorphKit/Assets/*']
  s.frameworks = 'UIKit'
end
