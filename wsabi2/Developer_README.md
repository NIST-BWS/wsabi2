
##External libraries
   wsabi depends on some external library code (for grid layout, etc.). Whenever possible, that code is referenced as an external Xcode project. The build process for including an external library is illustrated pretty well [in this blog post][zxing]. It seems that, in order to get Xcode to find the headers, we need to reference copies of those headers, even when the included project builds a static library [^lib]. Solution found [on StackOverflow][so]. Those headers are kept in the Dependencies/Indexing Headers group, and __aren't added to any targets__. For some reason, this allows Xcode to build the project properly.
   
[zxing]: http://yannickloriot.com/2011/04/how-to-install-zxing-in-xcode-4/
[so]: http://stackoverflow.com/questions/5543854/xcode-4-cant-locate-public-header-files-from-static-library-dependancy

[^lib]: This can't be correct, but there isn't another obvious solution at the moment.

