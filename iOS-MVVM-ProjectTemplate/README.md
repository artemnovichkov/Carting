# iOS MVVM Project Template

**This is just installation guide, for detailed description check [wiki](https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate/wiki).**

## Installation

### Prepare environment
To use project template you will need Ruby [Bundler](http://bundler.io) and [Carthage](https://github.com/Carthage/Carthage).

We recommend always running on latest Carthage version. Carthage could be installed by running

```bash
brew update
brew install carthage
```

Bundler should be a part of your Ruby installation. We recommend ruby version greater than 2.4.x. If you don't have bundler than it can be installed by running

```bash
sudo gem install bundler
```

### Download template
If you have your environment ready, **download content of this repo as [ZIP archive](https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate/archive/master.zip)** and unpack to folder where you want to have your new project (recommended).

...or you can do standard git clone of course
```bash
git clone https://github.com/AckeeCZ/iOS-MVVM-ProjectTemplate.git
```
In that case don't forget to remove `.git` directory after clone, otherwise you will have whole template history in your new repository. I guess you don't want that.
```bash
rm -rf .git
```

### Project setup

1. In the project root folder call
```bash
bundle install
```
This will install all needed gems to run the skeleton and maintain their versions appropriately.

2. rename template
```bash
bundle exec fastlane rename name:NewProject
```
if the `name` argument is ommitted, the script will prompt for it.

3. Run installation of cocoapods
```bash
bundle exec pod install
```

4. Run carthage
```bash
carthage bootstrap --platform ios --cache-builds
```

Now your new project is ready to use :tada:

In the first place check `FirebaseAppDelegate.swift` and uncomment cofiguration code, it's easy to forget that and pretty hard to find afterwards :smirk:
