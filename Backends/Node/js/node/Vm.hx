package js.node;

typedef VmScript = {
  function runInThisContext():Dynamic;
  function runInNewContext(?sandbox:Dynamic):Void;
}

extern class Vm
implements npm.Package.Require<"vm","*"> 
 {  
    static function runInThisContext(code:String,?fileName:String):Dynamic;
    static function runInNewContext(?sandbox:Dynamic):Void;
    static function createScript(code:Dynamic,?fileName:String):VmScript;
}