package kha.vr;

class TimeWarpParms {

/*	TimeWarpParms() :   SwapOptions( 0 ),
			            MinimumVsyncs( 1 ),
			            PreScheduleSeconds( 0.014f ),
			            WarpProgram( WP_SIMPLE ),
                        ProgramParms(),
			            DebugGraphMode( DEBUG_PERF_OFF ),
                        DebugGraphValue( DEBUG_VALUE_DRAW )
    {
        for ( int i = 0; i < 4; i++ ) {		// this should be unnecessary, remove?
            for ( int j = 0; j < 4; j++ ) {
                ExternalVelocity.M[i][j] = ( i == j ) ? 1.0f : 0.0f;
            }
        }
    }*/
	
		public var LeftImage: TimeWarpImage;
		public var RightImage: TimeWarpImage;
		
		public var LeftOverlay: TimeWarpImage;
		public var RightOverlay: TimeWarpImage;

	//static const int	MAX_WARP_EYES = 2;
	// static const int	MAX_WARP_IMAGES = 2;	// 0 = world, 1 = overlay screen
	//TimeWarpImage 		Images[MAX_WARP_EYES][MAX_WARP_IMAGES];
	
		//public var SwapOptions: Int;
	
	// WarpSwap will not return until at least this many vsyncs have
	// passed since the previous WarpSwap returned.
	// Setting to 2 will reduce power consumption and may make animation
	// more regular for applications that can't hold full frame rate.
		//public var MinimumVsyncs: Int;

	// Time in seconds to start drawing before each slice.
	// Clamped at 0.014 high and 0.002 low, but the very low
	// values will usually result in screen tearing.
		//public var PreScheduleSeconds: Float;

	// Which program to run with these images.
	//warpProgram_t		WarpProgram;

	// Program-specific tuning values.
	//float				ProgramParms[4];

	// Controls the collection and display of timing data.
	//debugPerfMode_t		DebugGraphMode;
	//debugPerfValue_t	DebugGraphValue;
	
	public function new() {
		
	}

	
}