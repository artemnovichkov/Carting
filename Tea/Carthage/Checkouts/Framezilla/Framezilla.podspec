Pod::Spec.new do |spec|
    spec.name           = "Framezilla"
    spec.version        = "2.9.1"
    spec.summary        = "Comfortable syntax for working with frames."

    spec.homepage       = "https://github.com/Otbivnoe/Framezilla"
    spec.license        = { type: 'MIT', file: 'LICENSE' }
    spec.authors        = { "Nikita Ermolenko" => 'gnod94@gmail.com' }
    spec.platform       = :ios
    spec.requires_arc   = true

    spec.ios.deployment_target  = '8.4'
    spec.source                 = { git: "https://github.com/Otbivnoe/Framezilla.git", tag: "#{spec.version}"}
    spec.source_files           = "Sources/*.{h,swift}"
end
