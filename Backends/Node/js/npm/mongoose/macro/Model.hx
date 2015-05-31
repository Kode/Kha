package js.npm.mongoose.macro;

import js.npm.mongoose.Model;
import js.npm.mongoose.Mongoose;

@:autoBuild( util.Mongoose.buildModel( js.npm.mongoose.macro.Model ) )
class Model<T>
extends js.npm.mongoose.Model.TModel<T>
{}
