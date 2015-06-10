##Kha

Kha is a super portable Software Development kit Based on Haxe and GLSL.
With Kha you can build applications and games that run with native performance in different target devices.

# Index
- [About](#about)
- [Getting Started](#getting-started)
- [Features](#features)
- [Games made with Kha](#games)
- [Engines using with Kha](#engines)
- [Bugs?](#bugs)
- [License](#license)


<a name="#about"></a>
##About
Kha is a super portable Software Development kit Based on Haxe and GLSL.
With Kha you can build applications and games that run with native performance in different target devices.

The main development is held by [Robert Konrad](http://tech.ktxsoftware.com/)

Things you can do now:
* Why not following me on [Twitter](https://twitter.com/robdangerous)?
* You can check out the [examples](https://github.com/KTXSoftware/Kha/wiki/Examples)!
* Also why not reading the [wiki](https://github.com/KTXSoftware/Kha/wiki/)?

<a name="#features"></a>
##Features

Kha apps run natively on:
* HTML5 (Canvas or WebGL)
* Windows (Direct3D 9, Direct3D 11 or OpenGL)
* OSX
* Linux
* Android
* iOS
* Tizen
* PlayStation Vita (PlayStationMobile)
* Xbox 360 (XNA)
* Flash

Kha apps can also be compiled to C# or Java libraries.

<a name="#getting-started"></a>
##Getting Started
***Installing NodeJS***

You can get a copy of NodeJS on its site <a target="_blank" href="http://nodejs.org/">here</a> and install it.


***Update NodeJS***

If you have NodeJS already installed make sure it's updated!
You can do so with the following commands.
<pre lang="bash">
sudo npm cache clean -f
node --version
sudo npm install -g n
sudo n stable
node --version
</pre>


***Starting with Kha***

Kha projects are usually handled using git submodules so that every dependency is properly versioned.
Even the Haxe compiler itself is just a submodule.

If you want to add Kha as a submodule for your git project just use
<pre lang="bash">
git submodule add https://github.com/KTXSoftware/Kha
git submodule update --init --recursive
</pre>

You can also clone the [Empty project](https://github.com/KTXSoftware/Empty) and start from it!
<pre lang="bash">>
git clone --recursive https://github.com/KTXSoftware/Empty.git
</pre>

<a name="games"></a>
## Games made with Kha
Kha is still the new in the school but it got already a few toy!

[![Game](http://i.imgur.com/I2L3y2e.png)][game1]


<a name="games"></a>
## Engines using with Kha
In addition to making games Kha has been used as well for a few game engines!
So if Kha is still too low level for you, or you are used to another engine check our list and you may find one that fit your needs!

- [KhaPunk](engine1): Port of HaxePunk/FlashPunk to Kha.
- [Zblend](engine2): 3D game engine that integrates into Blender.


<a name="bugs"></a>
## Bugs?
If you find any kind of bug, or weird problems with the library add them to the [Issue Tracker][issues].
Add as much information as possible, also upload the source code that causes the problem if you can :)!

<a name="license"></a>
## License
You can check Kha license [here](https://github.com/KTXSoftware/Kha/blob/master/license.txt).


[issues]: https://github.com/KTXSoftware/Kha/issues
[contribute]: https://github.com/KTXSoftware/Kha/blob/master/CONTRIBUTING.md

[game1]: http://luboslenco.com/spiralride/

[engine1]: https://bitbucket.org/stalei/khapunk
[engine2]: https://github.com/luboslenco/zblend