#!/bin/bash
set -e
set -x

root=$(pwd)
path="."

while [ -n "$1" ]; do
	case "$1" in
    -path)
        path="$2"
        shift;;
	-test) test=True;;
    -drive)
        drive_target="$2"
        shift;;
    -android) android=True;;
    -ios) ios=True;;
    -web) web=True;;
	*) echo "Option $1 not recognized" ;;
	esac
	shift
done

cd "$path" && flutter packages pub get || true
cd "$root"

if [ $test ]
then
    printf "\n\nTEST\n\n"
    cd "$path" && flutter test || true
    cd "$root"
fi

if [ $drive_target ]
then
    printf "\n\nDRIVE\n\n"
    flutter emulators --launch apple_ios_simulator
    cd "$path" && flutter drive --target="$drive_target" || true
    cd "$root"
fi

if [ $android ]
then
    printf "\n\nANDROID\n\n"
    rm -f ~/.android/debug.keystore
    keytool -genkeypair \
    -alias androiddebugkey \
    -keypass android \
    -keystore ~/.android/debug.keystore \
    -storepass android \
    -dname 'CN=Android Debug,O=Android,C=US' \
    -keyalg 'RSA' \
    -keysize 2048 \
    -validity 10000
    echo "flutter.sdk=$HOME/programs/flutter" > "$FCI_BUILD_DIR/$path/android/local.properties"
    cd "$path" && flutter build apk --debug || true
    cd "$root"
fi

if [ $ios ]
then
    printf "\n\nIOS\n\n"
    find . -name "Podfile" -execdir pod install \;
    cd "$path" && flutter build ios --debug --no-codesign || true
    cd "$root"
fi

if [ $web ]
then
    printf "\n\nWEB\n\n"
    cd "$path"
    flutter config --enable-web
    flutter build web --release || true
    cd "$root"
fi
