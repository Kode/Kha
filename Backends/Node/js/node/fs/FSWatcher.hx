package js.node.fs;

import js.node.events.EventEmitter;

/*
  Emits: error,change
 */
extern class FSWatcher 
extends EventEmitter 
implements npm.Package.RequireNamespace<"fs","*"> 
{
   function close():Void;
}