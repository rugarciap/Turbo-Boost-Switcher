Turbo Boost Switcher 2.10.2 (December 13, 2020)
====================

Turbo Boost disabler / enabler app for Mac OS X

You can [download the binary v2.10.2 version](https://turbo-boost-switcher.s3.amazonaws.com/Turbo_Boost_Switcher_v2.10.2.dmg) or get the [pro version here](https://gumroad.com/l/YeBQUF) . More info about this update [on the blog](https://www.rugarciap.com/2020/11/tbs-new-version-2-10-0/).

Please, find additional info on [http://www.rugarciap.com/turbo-boost-switcher-for-os-x/](http://www.rugarciap.com/turbo-boost-switcher-for-os-x/). 

Supports 10.6+ up to macOS Big Sur

To run the app on macOS Sierra (and above), due to Translocation feature introduced on macOS Sierra, just unzip and move the app to other folder before running. [Read more here.](http://www.rugarciap.com/2016/08/how-to-run-turbo-boost-switcher-on-macos-sierra/)

Apple now (since macOS High Sierra) forces the user to manually allow kernel extensions to be used so, if you're running for the first time on macOS High Sierra and never granted permissions, you need to manually allow it to be used. [More details here.](https://www.rugarciap.com/2017/09/an-update-after-macos-high-sierra-release/)

OSX El Capitan Users: [Please read this](http://www.rugarciap.com/2015/11/osx-el-capitan-tbs/) and [this](http://www.rugarciap.com/faqs/)

Features:
====================

Turbo Boost Switcher is a little application for Mac computers that allows to enable and/or disable the Turbo Boost feature.

It installs a precompiled kernel extension (32 or 64 bits depending on your system) that updates the Turbo Boost MSR register, so It will ask for your admin password when using it.

It’s installed on your Mac status bar and allows you to:

- Visually know if Turbo Boost is enabled or disabled at any time.
- Enable / Disable Turbo Boost.
- Auto Disable on launch
- Restore Turbo Boost on Exit
- Check your CPU temp, load and fan speed.
- Customize sensors update time
- Charts to see how Temp and Fan speed values are affected by Turbo Boost status.
- Set it to open at login.
- Translated to English & Spanish. Other languages in beta (Russina, Chinese, German, French, Polish).
- More features detailed on http://www.rugarciap.com

How to install:
====================

You can download the binary application or the source code to compile it with XCode.

Once downloaded/compiled, just unzip and double click on your “Turbo Boost Switcher.app”. If using macOS Sierra, before running move the decompressed app to other folder or it won't run.

If you see a message saying the app “can’t be opened because it is from an identified developer”, then you need to change your settings to allow not-signed apps to be installed. Go to your System Preferences->Security and Privacy and mark the option “Anyhwere”. Try again, it should work.

Also, and just if you're running on macOS High Sierra for the first time, you'll need to allow the kernel extension to be used the first time you try to disable Turbo Boost. Just go to System Preferences -> Security and Privacy and click "allow" after trying to disable Turbo Boost for first time. [You can read more about this here.](http://www.rugarciap.com/2016/08/how-to-run-turbo-boost-switcher-on-macos-sierra/)

Depending on your user configuration, OSX may ask for root password when enabling / disabling Turbo Boost. That's because kernel extensions must be installed as root and the user privileges are stored on a system cache. To avoid this behaviour, you can follow two approaches:

 - [Buy the PRO version](https://gumroad.com/l/YeBQUF) that installs a daemon and doesn't need to as for root since it uses IPC to communicate with the main app. It also offer another features so you can get cool things in exchange for supporting the app :).
 - Just run the app as root doing something like 'sudo /Applications/Turbo\ Boost\ Switcher.app/Contents/MacOS/Turbo\ Boost\ Switcher'

Motivation:
====================

Turbo Boost is enabled by default on all Macs that support it, but why anyone should want to disable it?

Ok, here are some reasons:

- CPU Overheat: When Turbo Boost is activated, prepare to experiment high temperatures on your CPU, since it pushes till it reaches almost the Junction Tº, usually 100 ºC. This is controlled by hardware, but if you want your computer to live long, better keep it as low as possible. With Turbo Boost disabled I’ve been able to get up to 20 ºC degrees less!!!, that’s a value worth considering.

- Parallel Processing: Turbo Boost is enabled when one of the CPU cores reaches 100%, increasing the core Mhz, but It won’t do it if all or your cores are 100%, since that will create a lot of overheat. This will reduce your parallel processing performance so, in some situations, you better disable it.
If you are like me, you probably do some high cpu demanding tasks from time to time, like photoshop editing, video transcoding, casual gaming, etc. and your fans go to max speeds while your CPU keeps crazy ranges like 93 – 98 ºC.

I’ve started to look for applications, and the only thing I found was this cool kernel extension https://github.com/nanoant/DisableTurboBoost.kext created by “nanoant”. This is a very simple extension that manipulates the MSR record writing the Turbo Boost flag.

If you don’t want to always be opening your terminal, compile the code, make sure you don’t forget to re-enable it, etc. then Turbo Boost Switcher is for you.

 
How to know if Turbo Boost is enabled (or not):
====================

To see the differences between having Turbo Boost enabled or not, you can do the following tasks:

- Install smcFanControl, a cool app that will help you to set your fan speeds to desired values.
- The simplest one, do some high demanding gaming with Turbo Boost enabled and disabled, checking the CPU temperature values and see the differences.
- You can also launch some long time high demanding tasks, like the Geekbench benchmarks app. You’ll get a lower value since Turbo Boost will not be triggered. On my Macbook Air I go from 7500 to 4000 points aprox. with Turbo Boost disabled.
- Check the MSR register for yourself (0x1a0), but that could be tricky and we’re not going to go deeper here.
 

Thanks to:
===========

- Some icons provided by fatcow (http://www.fatcow.com/free-icons)
- lavoiesl (https://github.com/lavoiesl/osx-cpu-temp)
- nanoant (https://github.com/nanoant/DisableTurboBoost.kext)

Reporting Issues:
===========

Before opening issues, make sure you read the project faqs (https://www.rugarciap.com/faqs/), other issues openend and answered, etc.

A lot (if not all) of usual questions about enabling / disabling Turbo Boost are answered there, like how to allow the kext to run, installing first time, etc. Issues on Github are not ment to offer support to particular questions when installing, they're ment to register reproducible issues on all installations (like a bad translation, a feature request, etc). 

The app and kext extensions are compatible will all macOS versions released so far (Intel CPUs with Turbo Boost, of course). The app is tested against all betas before final versions are released, so if any incompatiblity is found in the future will be reported here and on the blog, like when El Capitan was released.

If you still think you found an issue and it's not a support question, please attach all info needed to reproduce (steps you follow, app configuration, screenshots, etc) so I'm able to debug and fix the bug if any. 

Thanks.

