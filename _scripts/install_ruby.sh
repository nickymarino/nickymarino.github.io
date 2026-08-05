#!/usr/bin/env bash
#
# Install RVM (if needed), the Ruby this site pins, and the gems.
# Run via `make install`.
#
# Bash, not sh: RVM's loader script is bash-only.

# No `-u`: RVM's own scripts reference unset variables freely, so sourcing the
# loader under `set -u` dies with "_system_name: unbound variable".
set -eo pipefail

cd "$(dirname "$0")/.."

# NOT named RUBY_VERSION: RVM exports that itself (as "ruby-3.3.11") whenever it
# activates a Ruby, so sourcing the loader below would silently clobber ours.
TARGET_RUBY="$(sed 's/^ruby-//' .ruby-version)"
RVM_LOADER="$HOME/.rvm/scripts/rvm"

say() { printf '\n==> %s\n' "$1"; }

#### RVM ####

if [ ! -s "$RVM_LOADER" ]; then
    # The installer verifies its tarball against two RVM signing keys and
    # aborts if they aren't in the keyring. Import them first.
    #
    # RVM's own error message suggests `--keyserver hkp://pool.sks-keyservers.net`,
    # which no longer works — the SKS pool shut down in 2021. Fetching the keys
    # over HTTPS from rvm.io is the route that still works.
    if command -v gpg >/dev/null; then
        # gpg refuses to use a world-readable homedir.
        [ -d "$HOME/.gnupg" ] && chmod 700 "$HOME/.gnupg"

        for key in mpapis pkuczynski; do
            say "Importing RVM signing key: $key"
            curl -sSL "https://rvm.io/$key.asc" | gpg --quiet --import - || true
        done
    else
        say "gpg not found — the RVM installer may fail its signature check"
    fi

    say "RVM not found — installing"
    curl -sSL https://get.rvm.io | bash -s stable
else
    say "RVM already installed"
fi

# Load RVM into *this* shell. Make runs each recipe in a fresh non-interactive
# shell that never sources ~/.zshrc, so `rvm use` only works if we do this —
# regardless of what the user's profile says.
# shellcheck source=/dev/null
. "$RVM_LOADER"

# Add the loader to ~/.zshrc if it isn't there. Match on `scripts/rvm` rather
# than a bare "rvm" — the installer's `export PATH=...$HOME/.rvm/bin` line is a
# common false positive, and it only makes the binary callable, not the shell
# function that `rvm use` needs. Nothing above depends on this; it's purely so
# interactive `rvm use` (and auto-switching on cd) works later.
if [ -f "$HOME/.zshrc" ] && ! grep -q 'scripts/rvm' "$HOME/.zshrc"; then
    say "Adding the RVM loader to ~/.zshrc"
    {
        echo ''
        echo '# Load RVM as a shell function (required for `rvm use`)'
        echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"'
    } >>"$HOME/.zshrc"
fi

#### Build dependencies ####

if ! command -v brew >/dev/null; then
    echo "ERROR: Homebrew is required. See https://brew.sh" >&2
    exit 1
fi

# libyaml is needed for psych, which stopped vendoring it in Ruby 3.2.
for formula in openssl@3 libyaml; do
    brew list --formula "$formula" >/dev/null 2>&1 || brew install "$formula"
done

OPENSSL_DIR="${OPENSSL_DIR:-$(brew --prefix openssl@3)}"

say "Using OpenSSL at $OPENSSL_DIR"

export PATH="$OPENSSL_DIR/bin:$PATH"
export LDFLAGS="-L$OPENSSL_DIR/lib"
export CPPFLAGS="-I$OPENSSL_DIR/include"
export PKG_CONFIG_PATH="$OPENSSL_DIR/lib/pkgconfig"

#### Ruby ####

rvm autolibs disable

if rvm list strings | grep -q "^ruby-$TARGET_RUBY\$"; then
    say "Ruby $TARGET_RUBY already installed"
else
    say "Installing Ruby $TARGET_RUBY"
    rvm install "$TARGET_RUBY" --with-openssl-dir="$OPENSSL_DIR"
fi

rvm --ruby-version use "$TARGET_RUBY"

#### Gems ####

say "Installing gems"
BUNDLER_VERSION="$(awk '/BUNDLED WITH/ {getline; gsub(/[[:space:]]/, ""); print; exit}' Gemfile.lock)"
if [ -n "$BUNDLER_VERSION" ]; then
    gem install bundler -v "$BUNDLER_VERSION"
fi
bundle install

say "Done. Run \`make up\` to serve the site."
