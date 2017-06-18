Pod::Spec.new do |spec|
  spec.name = "DTMediasViewController"
  spec.version = "1.0.2"
  spec.summary = "Browse photo, gif and video."
  spec.homepage = "https://github.com/danjiang/DTMediasViewController"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Dan Jiang" => 'dan@danthought.com' }
  spec.social_media_url = "http://twitter.com/dtstudio"

  spec.platform = :ios, "8.4"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/danjiang/DTMediasViewController.git", tag: spec.version, submodules: true }
  spec.source_files = "Sources/**/*.{h,swift}"
  spec.resources = "Sources/*.bundle"

	spec.dependency "FLAnimatedImage"
end
