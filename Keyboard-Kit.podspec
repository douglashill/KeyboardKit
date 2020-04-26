Pod::Spec.new do |spec|
    spec.name = 'Keyboard-Kit'
    spec.module_name = 'KeyboardKit'
    spec.version = '2.0.0'
    spec.license = { :type => 'MIT', :file => 'License.txt' }
    spec.homepage = 'https://github.com/douglashill/KeyboardKit'
    spec.authors = { 'Douglas Hill' => 'https://twitter.com/qdoug' }
    spec.summary = 'A framework that makes it easy to add hardware keyboard control to iOS and Mac Catalyst apps.'

    spec.description = <<-DESC
KeyboardKit makes it easy to add hardware keyboard control to iOS and Mac Catalyst apps.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

Apps created with AppKit tend to have better support for keyboard control compared to UIKit-based apps. I believe the principal reason for this is that most AppKit components respond to key input out of the box, while most UIKit components do not. KeyboardKit aims to narrow this gap by providing subclasses of UIKit components that respond to key commands.
                       DESC

    spec.source = { :git => 'https://github.com/douglashill/KeyboardKit.git', :tag => spec.version.to_s }
    spec.swift_version = '5.0'
    spec.ios.deployment_target  = '11.0'
    spec.source_files = 'KeyboardKit/*.{h,m,swift}'
    spec.public_header_files = [
      'KeyboardKit/KeyboardKit.h',
      'KeyboardKit/BarButtonItem.h',
    ]
    spec.exclude_files = [
      'KeyboardKit/Info.plist',
      'KeyboardKit/ResponderChainDebugging.m',
      'KeyboardKit/UpdateLocalisedStringKeys.swift'
    ]
    spec.resources = "KeyboardKit/Localised/*.lproj"

end
