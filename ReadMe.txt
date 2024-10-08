
== Icons ==

http://thenounproject.com
https://developer.apple.com/library/mac/documentation/userexperience/conceptual/applehiguidelines/SystemProvidedIcons/SystemProvidedIcons.html

== Build ==
- Preprocessor Macros:
	- TARGET_TOOL=0 : 0 when building iLocalize, 0 when building the command line version
	- MAC_APP_STORE: 1 to build for Mac App Store, 0 to build the regular iLocalize with the registration and update frameworks
	
- Other Linker Flags:
	- Should have "-licucore" to link against the ICU dynamic library (see http://regexkit.sourceforge.net/RegexKitLite/index.html).

- Mac App Store:
	- InfoAppStore.plist is used instead of the Info.plist because it has some entries specific to Sparkle
	- The preprocessor MAC_APP_STORE=1 is set.
	- The following files are excluded:
		- ds_pub.dem
		- ARRegister.framework
		- Sparkle.framework

== Misc ==

- http://www.arizona-software.ch/ilocalize/localization.html for instructions
- to remove certain files in the languages, use:
	$ find languages/ -path "*contents*" -name "content.html" -delete
	$ find languages/ -name "filesencoding.html" -delete

- new mail script in 'Application Support/iLocalize/Scripts/exlocemail_XXX.script'
- Help anchor: should have the format <a name="foo"> and not <a id="foo" name="bar"> (they must also be unique)

== Preferences ==

// Enable/disable repair of iLocalize document
$ defaults write ch.arizona-software.ilocalize repair YES 

// To disable concurrent operations (such as create project, rebase):
$ defaults write ch.arizona-software.ilocalize nonConcurrentOp YES 

// Interface Builder paths
$ defaults write ch.arizona-software.ilocalize ib3path "/Developer/Applications/Interface Builder.app"
$ defaults write ch.arizona-software.ilocalize ib2path "/Xcode2.5/Applications/Interface Builder.app"

// Enable/disable XML comparison of nib files (more accurate but slower)
$ defaults write ch.arizona-software.ilocalize nibcompare YES 

// Enable/disable output of all the nib commands
$ defaults write ch.arizona-software.ilocalize outputnibcommand YES 

// Specify which ibtool to use
$ defaults write ch.arizona-software.ilocalize ibtoolPath /usr/bin/ibtool 

// Debug menu
$ defaults write ch.arizona-software.ilocalize ch.arizona-software.ilocalize.debug YES

// Debug log
- In Xcode, add the environment variable EnableDebugLog=YES to the Executable

== Specs & References ==

- TMX glossary format: http://www.lisa.org/standards/tmx/tmx.html#refRFC3066
- RegexLite: http://regexkit.sourceforge.net/RegexKitLite/index.html
- [Xcode scripts] http://zathras.de/angelweb/x2005-04-18.htm
- Sparkle Automation in Xcode: http://www.entropy.ch/blog/Developer/2008/09/22/Sparkle-Appcast-Automation-in-Xcode.html