package js.npm.mongoose.macro;

import js.npm.mongoose.Model;
import js.npm.mongoose.Mongoose;

@:autoBuild( util.Mongoose.buildManager( js.npm.mongoose.macro.Manager ) )
class Manager<T,M:js.npm.mongoose.macro.Model<T>>
extends js.npm.mongoose.Model.TModels<T,M>
{}