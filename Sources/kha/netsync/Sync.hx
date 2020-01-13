package kha.netsync;

@:autoBuild(kha.netsync.SyncBuilder.build())
interface Sync {
	function _syncId(): Int;
}
