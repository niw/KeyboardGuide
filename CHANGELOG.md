Changelog
=========

0.2.3
-----

- FIX: method visibilities.
- FIX: typo in ObjC name (#4)

0.2.2
-----

- Add iPadOS 16 support.
- Proactively remove observers to reduce leaking.
- Reset keyboard state when it can't restore first responder.
- Improve example application.

0.2.1
-----

- Add CocoaPods support. (#3)
- Clean up example application.
- Minor implementation change.

0.2.0
-----

- Change `KeyboardSafeArea`, add it to each `UIView`. It has no backward compatibility.
- Remove `KeyboardSafeAreaView`. Use `UIView`'s `keyboardSafeArea` instead.
- Add missing documentation to `README.md`.

0.1.0
-----

- Initial versioned release.
