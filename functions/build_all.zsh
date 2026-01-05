function build-all() {
    local dir

    for dir in */; do
        [[ "$dir" == "./" ]] && continue

        print "Building in $dir"
        pushd "$dir" >/dev/null || return $?

        _try_java_build
        _try_flutter_build
        _try_elixir_build

        popd >/dev/null
    done
}

# Try Java Maven build
function _try_java_build() {
    if [[ -f "pom.xml" ]]; then
        chmod +x ./mvnw
        ./mvnw clean install -DskipTests
    fi
}

# Try Java Gradle build
function _try_gradle_build() {
    if [[ -f "build.gradle" ]] || [[ -f "build.gradle.kts" ]]; then
        chmod +x ./gradlew
        ./gradlew build
    fi
}

# Try Flutter build
function _try_flutter_build() {
    if [[ -f "pubspec.yaml" ]]; then
        flutter pub get
    fi
}

# Try Elixir build
function _try_elixir_build() {
    if [[ -f "mix.exs" ]]; then
        mix deps.get
    fi
}
