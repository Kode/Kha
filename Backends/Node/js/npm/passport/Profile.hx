package js.npm.passport;

typedef Profile = {
	provider : String,
	id : String,
	displayName : String,
	name : {
		familyName : String,
		givenName : String,
		middleName : String
	},
	email : Array<{	
		value : String,
		type : String
	}>,
	photos : Array<{
		value : String
	}>
}