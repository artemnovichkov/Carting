<p align="center">
  <img src=".github/Logo.png" width="480" max-width="90%" alt="Carting" />
</p>


<p align="center">
	<a href="https://github.com/artemnovichkov/carting/actions">
        <img src="https://github.com/artemnovichkov/carting/workflows/Build/badge.svg" />
    <img src="https://img.shields.io/badge/homebrew-compatible-brightgreen.svg?style=flat" alt="Make" />
  <a href="https://swift.org/package-manager">
    <img src="https://img.shields.io/badge/spm-compatible-briasdasal script and the 
<p align="center">
  <img src=".github/carting.png" max-width="90%" alt="Carting usage" />
</p>sadsad


## Usingl.

By default Carting searches a script named `Carthage`, but you can set a name of your script via command line arguments:

```
$ carting update -s MyBestScriptasdasd
```

If there is no script with the name, Carting will add a new one.

Since Xcode 10 Run Script Phases support declaring input and output files in a `.xcfilelist` file. This file should contain a newline-separated list of the file paths for the inputs or outputs. Carting uses it by default. If you need to work with your projects in old Xcode versions, use `-f file` option.
asdasd
**🚨Note**: be sure to have no uncommitted changes in project file to prevent project parsing errors 😱.

<p align="center">
  <img src=".github/error.png" max-width="90%" alt="Project parsing error" />
</p>

Run `carting --help` to see available commands:

```bash
OVERVIEW: 🚘 Simple tool for updating Carthage script phase

USAGE: Carting <command> <options>

SUBCOMMANDS:
  info                    Prints Carthage frameworks list with linking description.
  lint                    Lint the project for missing paths.
  update                  Adds a new script with input/output file paths or updates the script named `Carthage`.
```

## Linting

Integrate Carting into an Xcode scheme to get errors displayed in the IDE. Just add a new "Run Script Phase" with:

```bash
/usr/local/bin/carting lint
```

<p align="center">
  <img src=".github/phase.png" max-width="90%" alt="Run Script Phase" />
</p>

## Installing

### Homebrew (recommended):

```bash
$ brew tap artemnovichkov/projects
$ brew install carting
```

### [Mint](https://github.com/yonaskolb/Mint):

```bash
$ mint run artemnovichkov/Carting
```

### Make:

```bash
$ git clone https://github.com/artemnovichkov/carting.git
$ cd Carting
$ make
```

### Swift Package Manager:

```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/artemnovichkov/carting", majorVersion: 2)
    ]
)
```
## Author

Artem Novichkov, novichkoff93@gmail.com

## License

Carting is available under the MIT license. See the LICENSE file for more info.

