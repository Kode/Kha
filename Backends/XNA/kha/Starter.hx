package kha;

@:classContents('
	public class KhaGame : Microsoft.Xna.Framework.Game {
		Microsoft.Xna.Framework.GraphicsDeviceManager graphics;
		Microsoft.Xna.Framework.Graphics.SpriteBatch spriteBatch;
		haxe.root.Array<object> images;
		public System.Collections.Generic.Dictionary<string, Microsoft.Xna.Framework.Graphics.Texture2D> imageTable;
		
		public KhaGame(haxe.root.Array<object> images, int width, int height) {
			this.images = images;
			imageTable = new System.Collections.Generic.Dictionary<string, Microsoft.Xna.Framework.Graphics.Texture2D>();
			graphics = new Microsoft.Xna.Framework.GraphicsDeviceManager(this);
			graphics.PreferredBackBufferHeight = height;
			graphics.PreferredBackBufferWidth = width;
			Content.RootDirectory = "Content";
		}

		protected override void Initialize() {
			base.Initialize();
		}

		protected override void LoadContent() {
			spriteBatch = new Microsoft.Xna.Framework.Graphics.SpriteBatch(GraphicsDevice);
			Starter.painter.spriteBatch = spriteBatch;
			for (int i = 0; i < images.length; ++i) {
				imageTable.Add((string) images[i], Content.Load<Microsoft.Xna.Framework.Graphics.Texture2D>("bin\\\\" + ((string) images[i]).Substring(0, ((string) images[i]).Length - 4)));
				((kha.xna.Image)Loader.getInstance().getImage((string) images[i])).load();
			}
			Starter.loadReallyFinished();
		}

		protected override void UnloadContent() {
		
		}
		
		bool left = false;
		bool right = false;
		bool up = false;
		bool down = false;

		protected override void Update(Microsoft.Xna.Framework.GameTime gameTime) {
			if (Microsoft.Xna.Framework.Input.GamePad.GetState(Microsoft.Xna.Framework.PlayerIndex.One).Buttons.Back == Microsoft.Xna.Framework.Input.ButtonState.Pressed)
				this.Exit();

			base.Update(gameTime);
			
			Microsoft.Xna.Framework.Input.KeyboardState keyboard = Microsoft.Xna.Framework.Input.Keyboard.GetState();

			if (keyboard.IsKeyDown(Microsoft.Xna.Framework.Input.Keys.Left)) {
				if (!left) {
					Starter.game.buttonDown(Button.LEFT);
					left = true;
				}
			}
			else {
				if (left) {
					Starter.game.buttonUp(Button.LEFT);
					left = false;
				}
			}
			if (keyboard.IsKeyDown(Microsoft.Xna.Framework.Input.Keys.Right)) {
				if (!right) {
					Starter.game.buttonDown(Button.RIGHT);
					right = true;
				}
			}
			else {
				if (right) {
					Starter.game.buttonUp(Button.RIGHT);
					right = false;
				}
			}
			if (keyboard.IsKeyDown(Microsoft.Xna.Framework.Input.Keys.Up)) {
				if (!up) {
					Starter.game.buttonDown(Button.UP);
					up = true;
				}
			}
			else {
				if (up) {
					Starter.game.buttonUp(Button.UP);
					up = false;
				}
			}
			if (keyboard.IsKeyDown(Microsoft.Xna.Framework.Input.Keys.Down)) {
				if (!down) {
					Starter.game.buttonDown(Button.DOWN);
					down = true;
				}
			}
			else {
				if (down) {
					Starter.game.buttonUp(Button.DOWN);
					down = false;
				}
			}
			
			Starter.game.update();
		}

		protected override void Draw(Microsoft.Xna.Framework.GameTime gameTime) {
			GraphicsDevice.Clear(Microsoft.Xna.Framework.Color.CornflowerBlue);

			base.Draw(gameTime);
			Starter.painter.begin();
			Starter.game.render(painter);
			Starter.painter.end();
		}
	}
	
	static KhaGame khaGame;
')
class Starter {
	static public var game : Game;
	static public var painter : kha.xna.Painter;
	
	public function new() {
		painter = new kha.xna.Painter();
		kha.Loader.init(new kha.xna.Loader());
	}
	
	public function start(game : Game) {
		Starter.game = game;
		Loader.getInstance().load();
	}
	
	@:functionBody('
		return khaGame.imageTable[filename];
	')
	public static function getTexture(filename : String) : Dynamic {
		return null;
	}
	
	public static function loadFinished() {
		var images = new Array<String>();
		var node : Xml = Loader.getInstance().getXml("data.xml");
		for (dataNode in node.elements().next().elements()) {
			switch (dataNode.nodeName) {
				case "image":
					images.push(dataNode.firstChild().nodeValue);
				default:
			}
		}
		createGame(images);
		startGame();
	}

	public function lockMouse() : Void{
		
	}
	
	public function unlockMouse() : Void{
		
	}

	public function canLockMouse() : Bool{
		return false;
	}

	public function isMouseLocked() : Bool{
		return false;
	}

	public function notifyOfMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}


	public function removeFromMouseLockChange(func : Void -> Void, error  : Void -> Void) : Void{
		
	}

	
	public static function loadReallyFinished() : Void {
		game.loadFinished();
	}
	
	@:functionBody('
		khaGame = new KhaGame(images, game.getWidth(), game.getHeight());
	')
	static function createGame(images : Array<String>) : Void {
		
	}
	
	@:functionBody('
		khaGame.Run();
	')
	static function startGame() : Void {
		
	}
}