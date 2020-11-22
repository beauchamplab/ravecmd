source "./osx/credential.sh"

PROJDIR="osx/RAVE Bundled Installer/"
PKGNAME="rave-bundled-installer"
PKGVER=$(Rscript --no-save -e "cat(rave::rave_version())")
BID="org.beauchamplab.rave-bundled-installer"

echo "Building rave-$PKGVER"

xcodebuild -project "$PROJDIR/RAVE Bundled Installer.xcodeproj" -alltargets clean install
ls "$PROJDIR/build/pkgroot/RAVE"

pkgbuild --root "$PROJDIR/build/pkgroot" \
           --identifier "$BID" \
           --version "$PKGVER" \
           --install-location "/Applications/" \
           --sign "$AU_CERT_INST" \
           "$PROJDIR/build/$PKGNAME-$PKGVER.pkg"


request=$(xcrun altool --notarize-app \
               --primary-bundle-id "$BID" \
               --username "$AU_USRENAME" \
               --password "$AU_PASSWORD" \
               --asc-provider $AU_PROVIDER \
               --file "$PROJDIR/build/$PKGNAME-$PKGVER.pkg")
               
UUID=$(echo $request | grep -o --max-count=1 "[0-9a-z]\{8\}-[0-9a-z]\{4\}-[0-9a-z]\{4\}-[0-9a-z]\{4\}-[0-9a-z]\{12\}")
echo $UUID

xcrun altool --notarization-info $UUID -u "$AU_USRENAME" -p "$AU_PASSWORD"



xcrun stapler staple "$PROJDIR/build/$PKGNAME-$PKGVER.pkg"
xcrun stapler validate "$PROJDIR/build/$PKGNAME-$PKGVER.pkg"
spctl --assess -vvv --type install "$PROJDIR/build/$PKGNAME-$PKGVER.pkg"

# Once succ, backup
# Back up old package
# cp "$PROJDIR/build/$PKGNAME-$PKGVER.pkg" "$PROJDIR/build/$PKGNAME-$PKGVER-backup.pkg"
