/*
  This file is used to generate Macros.h and DynamicImpl.h.
  To change the number of "fast" args, you will also need to change numbers in the tpl files.
  Usage: haxe -x GenMacro.hx
*/

import haxe.Template;
import neko.io.File;
import neko.io.FileOutput;

class GenMacro
{
   static var warning = "// DO NOT EDIT\n// This file is generated from the .tpl file\n";

   public function new()
   {
      var context = { };
      var params = new Array<Dynamic>();
      var arr_list = new Array<String>();
      var arg_list = new Array<String>();
      var dynamic_arg_list = new Array<String>();
      var dynamic_in_args = new Array<String>();
      var dynamic_var_args = new Array<String>();
      var dynamic_adds = new Array<String>();

      for(arg in 0...21)
      {
         if (arg>0)
         {
            arr_list.push( "inArgs[" + (arg-1) + "]");
            arg_list.push( "inArg" + (arg-1));
            dynamic_arg_list.push("const Dynamic &inArg" + (arg-1) );
            dynamic_adds.push( "->Add(inArg" + (arg-1) + ")" );
         }

         params.push( {
             ARG : arg,
             ARR_LIST : arr_list.join(","),
             DYNAMIC_ARG_LIST : dynamic_arg_list.join(","),
             ARG_LIST : arg_list.join(","),
             DYNAMIC_ADDS : dynamic_adds.join("")
            } );
      }

      var locals = new Array<Dynamic>();
      var marks = new Array<String>();
      var type_vars = new Array<String>();
      var type_args = new Array<String>();
      var construct_args = new Array<String>();
      var construct_vars = new Array<String>();
      for(arg in 1...15)
      {
         var vid = arg-1;
         if (vid>=0)
         {
            marks.push( "HX_MARK_MEMBER(v" + vid +");" );
            type_args.push( "t" + vid +",v" + vid  );
            type_vars.push( "t" + vid +" v" + vid  );
            construct_args.push( "t" + vid +" __" + vid  );
            construct_vars.push( "v" + vid +"(__" + vid + ")"  );
         }
         locals.push( {
             ARG : arg,
             MARKS : marks.join(" "),
             TYPE_VARS : type_vars.join(","),
             TYPE_ARGS : type_args.join(","),
             TYPE_DECL : type_vars.join(";"),
             CONSTRUCT_VARS : construct_vars.join(","),
             CONSTRUCT_ARGS : construct_args.join(",")
            } );
      }

      Reflect.setField(context, "PARAMS", params);
      Reflect.setField(context, "LOCALS", locals);
      Reflect.setField(context, "NS", "::");

      var fileContents:String = File.getContent("Macros.tpl");
      fileContents = fileContents.split("").join("");

      var template:Template = new Template(fileContents);
      var result:String = template.execute(context);
      var fileOutput:FileOutput = File.write("Macros.h", true);
      fileOutput.writeString(warning);
      fileOutput.writeString(result);

      var fileContents:String = File.getContent("DynamicImpl.tpl");
      fileContents = fileContents.split("").join("");
      var template:Template = new Template(fileContents);
      var result:String = template.execute(context);
      var fileOutput:FileOutput = File.write("DynamicImpl.h", true);
      fileOutput.writeString(warning);
      fileOutput.writeString(result);


      fileOutput.close();
   }

   public static function main() { new GenMacro(); }
}
