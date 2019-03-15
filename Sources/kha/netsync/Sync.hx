package kha.netsync;

@:autoBuild(kha.network.SyncBuilder.build())
interface Sync {
	function _syncId(): Int;
}
