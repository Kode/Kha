[![Build Status](https://travis-ci.org/KTXSoftware/Kha.svg?branch=master)](https://travis-ci.org/KTXSoftware/Kha) [![Build status](https://ci.appveyor.com/api/projects/status/qk7bx2l38ch2t1pr?svg=true)](https://ci.appveyor.com/project/RobDangerous/kha) [![Stories in Ready](https://badge.waffle.io/KTXSoftware/Kha.png?label=ready&title=Ready)](https://waffle.io/KTXSoftware/Kha)
##Kha

Kha is a low level SDK for building games and media applications in a portable way, based on Haxe and GLSL.
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
Kha is a low level SDK for building games and media applications in a portable way. Think SDL, but super-charged.

Based on the Haxe programming language and the Krafix shader-compiler it can cross-compile your code and optimize
your assets for even the most obscure systems.

Kha is so portable, it can in fact run on top of other game engines and its generational graphics and audio API design
gets the best out of every target, supporting super fast 2D graphics just as well as high end 3D graphics.

The main development is held by [Robert Konrad](http://tech.ktxsoftware.com/)

Things you can do now:
* Why not following me on [Twitter](https://twitter.com/robdangerous)?
* You can check out the [examples](https://github.com/KTXSoftware/Kha/wiki/Examples)!
* Also why not reading the [wiki](https://github.com/KTXSoftware/Kha/wiki/)?

<a name="#features"></a>
##Features

***Kha Features***
* Great performance in different target devices
* Generational graphical API design
* Generational audio API design
* Support super fast 2D graphics
* Support high end 3D graphics
* Can sun on top of other game engines
* Support GLSL shaders


***Even more Features***
* Kha apps can also be compiled to C# or Java libraries
* Only one way to do things
* No legacy code
* Support for VR technology
* Networking multiplayer support


***Platforms supported by Kha***
* HTML5 (Canvas or WebGL)
* Flash
* Windows (Direct3D 9, Direct3D 11 or OpenGL)
* OSX
* Linux
* Android
* iOS (OpenGL or Metal)
* Tizen
* Unity 3D
* PlayStation Vita (PlayStationMobile)
* Xbox 360 (XNA)


![Game](http://robdangero.us/wwx2015/slide40.png)

The complete structure of Kha looks something like this.


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
<pre lang="bash">
git clone --recursive https://github.com/KTXSoftware/Empty.git
</pre>


***Updating Kha***

If you want to update the Kha and it's submodules in your repository you can do it with just this command!

<pre lang="bash">
git submodule foreach --recursive git pull origin master
</pre>


<a name="games"></a>
## Games made with Kha
Kha is still the new in the school but it got already a few toys!

[![Game](http://i.imgur.com/I2L3y2e.png)][game1]


<a name="engines"></a>
## Engines using with Kha
In addition to making games Kha has been used as well for a few game engines!
So if Kha is still too low level for you, or you are used to another engine check our list and you may find one that fit your needs!

- [KhaPunk]: Port of HaxePunk/FlashPunk to Kha.
- [ZBlend]: 3D game engine that integrates into Blender.
- [Komponent2D]: A component based game engine with Kha.
- [Kha2D]: A simple 2D engine built using Kha.


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

[KhaPunk]: https://bitbucket.org/stalei/khapunk
[ZBlend]: https://github.com/luboslenco/zblend
[Komponent2D]: https://github.com/Marc010/Komponent2D
[Kha2D]: https://github.com/KTXSoftware/Kha2D
