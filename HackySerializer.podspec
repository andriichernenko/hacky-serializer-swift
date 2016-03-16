Pod::Spec.new do |spec|
  spec.name = "HackySerializer"
  spec.version = "0.1.0"
  spec.summary = "Protocol-based serialization which works with almost any Swift type without subclassing"
  spec.homepage = "https://github.com/jakecraige/RGB"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Andrii Chernenko" => 'mail@andrii.ch' }
  spec.social_media_url = "http://twitter.com/andrii_ch"

  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/deville/hacky-serializer-swift.git", tag: "v#{spec.version}" }
  spec.source_files = "HackySerializer/**/*.{h,swift}"

end