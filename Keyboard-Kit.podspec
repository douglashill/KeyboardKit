Pod::Spec.new do |spec|
    spec.name = 'Keyboard-Kit'
    spec.module_name = 'KeyboardKit'
    spec.version = '7.1.0'
    spec.license = { :type => 'MIT', :file => 'License.txt' }
    spec.homepage = 'https://github.com/douglashill/KeyboardKit'
    spec.authors = { 'Douglas Hill' => 'https://twitter.com/qdoug' }
    spec.summary = 'The easiest way to add comprehensive hardware keyboard control to an iPad, iPhone, or Mac Catalyst app.'

    spec.description = <<-DESC
The easiest way to add comprehensive hardware keyboard control to an iPad, iPhone, or Mac Catalyst app.

Keyboard control is a standard expectation of Mac apps. It’s important on iOS too because a hardware keyboard improves speed and ergonomics, which makes an iPad an even more powerful productivity machine.

KeyboardKit is designed to integrate with the UIKit focus system when available, and it provides similar arrow and tab key navigation on OS versions where the focus system is not available.
                       DESC

    spec.source = { :git => 'https://github.com/douglashill/KeyboardKit.git', :tag => spec.version.to_s }
    spec.swift_version = '5.5'
    spec.ios.deployment_target  = '13.0'
    spec.source_files = 'KeyboardKit/**/*.{h,m,swift}'
    spec.public_header_files = [
      'KeyboardKit/KeyboardKit.h',
      'KeyboardKit/ObjC/BarButtonItem.h',
    ]
    spec.exclude_files = [
      'KeyboardKit/Info.plist',
      'KeyboardKit/ObjC/ResponderChainDebugging.m',
      'KeyboardKit/UpdateLocalisedStringKeys.swift',
      'KeyboardKit/Documentation.docc'
    ]
    spec.resources = "KeyboardKit/Localised/*.lproj"

end
