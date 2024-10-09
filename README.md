## Flatpak for Pocket Casts

#### Check out the upstream project here: https://github.com/FelicianoTech/pocket-casts-desktop-app

### Build the Flatpak locally
1. Clone this repo
2. Install flatpak and flatpak-builder for your distro
3. Run the build script with: `./local-build.sh`
4. Install the test build with: `flatpak install ./tech.feliciano.pocket-casts.flatpak`

### Getting NPM generated sources manually
1. Clone this repo
2. Install `git`, `pipx`, `jq`, and `curl` for your distro
3. Run `./generate_deps.sh`
4. Verify the updates and commit the updated `generated-sources.json`
