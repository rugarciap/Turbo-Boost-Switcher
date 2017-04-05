Turbo Boost Switcher 2.5.0
====================

Turbo Boost disabler / enabler app for Mac OS X

You can [download the binary v2.5.0 version] (http://www.rugarciap.com/turbo-boost-switcher-for-os-x/) . More info about this update on the blog: [http://www.rugarciap.com/2017/04/tbs-new-version-2-5-0/] (http://www.rugarciap.com/2017/04/tbs-new-version-2-5-0/)

Please, find additional info on [http://www.rugarciap.com/turbo-boost-switcher-for-os-x/] (http://www.rugarciap.com/turbo-boost-switcher-for-os-x/)

Support for macOS Sierra (and of course new Macbooks since the architecture has not changed)!. To run the app on sierra, just unzip and move the app to other folder. [Read more here.] (http://www.rugarciap.com/2016/08/how-to-run-turbo-boost-switcher-on-macos-sierra/)

OSX El Capitan and above Users: [Please read this] (http://www.rugarciap.com/2015/11/osx-el-capitan-tbs/) and [this] (http://www.rugarciap.com/faqs/)


Features:
====================

Turbo Boost Switcher is a little application for Mac computers that allows to enable and/or disable the Turbo Boost feature.

It installs a precompiled kernel extension (32 or 64 bits depending on your system) that updates the Turbo Boost MSR register, so It will ask for your admin password when using it.

It’s installed on your Mac status bar and allows you to:

- Visually know if Turbo Boost is enabled or disabled at any time.
- Enable / Disable Turbo Boost.
- Auto Disable on launch
- Restore Turbo Boost on Exit
- Check your CPU temp and fan speed.
- Set it to open at login.
- Translated to English & Spanish. Other languages in beta (Russina, Chinese, German, French, Polish).
- More features detailed on http://www.rugarciap.com

How to install:
====================

You can download the binary application or the source code to compile it with XCode.

Once downloaded/compiled, just unzip and double click on your “Turbo Boost Switcher.app”. If using macOS Sierra, before running move the decompressed app to other folder or it won't run.

If you see a message saying the app “can’t be opened because it is from an identified developer”, then you need to change your settings to allow not-signed apps to be installed. Go to your System Preferences->Security and Privacy and mark the option “Anyhwere”. Try again, it should work.

Depending on your user configuration, OSX may ask for root password when enabling / disabling Turbo Boost. That's because kernel extensions must be installed as root and the user privileges are stored on a system cache. To avoid this behaviour, you can follow two approaches:

 - [Buy the PRO version] (https://gumroad.com/l/YeBQUF) that installs a daemon and doesn't need to as for root since it uses IPC to communicate with the main app. It also offer another features so you can get cool things in exchange for supporting the app :).
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
- Icons by rugaciap 
- Other icons provided by fatcow (http://www.fatcow.com/free-icons)
- lavoiesl (https://github.com/lavoiesl/osx-cpu-temp)
- nanoant (https://github.com/nanoant/DisableTurboBoost.kext)
