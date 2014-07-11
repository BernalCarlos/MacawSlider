// =================================================================================================
//
//	Copyright 2014 Carlos Bernal <bernalcarvajal@gmail.com>. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package starling.extensions.macawslider
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.Bitmap;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * MacawSlider item.
	 * 
	 * @author Carlos Bernal <bernalcarvajal@gmail.com>
	 */
	public final class MacawSliderItem extends Sprite
	{
		/** Informacion contenida por este item **/
		private var _data: Object;
		/** Textura de este item **/
		private var _texture: Texture;
		/** Textura temporal mientas carga una imagen **/
		private var _tempQuad: Quad;
		/** Moviclip para la animacion de carga del componente **/
		private var _loadingMovieclip: MovieClip;
		/** Imagen que encapsula la textura de este item **/
		private var _image: Image;
		/** Referencia al sprite contenido por este item **/
		private var _sprite: Sprite;
		
		/** Loader de la imagen **/
		private var _imageLoader: ImageLoader;
		/** Almacena si este item debe ser cargado automaticamente **/
		private var _autoLoad: Boolean = false;
		
		//Variable temporales
		private var _tempWidth: Number;
		private var _tempHeight: Number;
		
		/**
		 * Constructor.
		 * 
		 * No se deberia usar este contructor. Se debe usar en su lugar los metodos estaticos:
		 * 1. fromBitmap
		 * 2. fromUrl
		 */
		public function MacawSliderItem()
		{
			super();
		}
		
		/**
		 * Crea un item en a un sprite.
		 */
		public static function fromSprite($sprite: Sprite, $data: Object = null): MacawSliderItem{
			
			var item: MacawSliderItem = new MacawSliderItem();
			
			item.sprite = $sprite;
			item.addChild(item.sprite);
			
			item.data = $data;
			
			return item;
		}
		
		/**
		 * Crea un item en base al bitmap otorgado.
		 */
		public static function fromBitmap($bitmap: Bitmap, $data: Object = null): MacawSliderItem{
			
			var item: MacawSliderItem = new MacawSliderItem();
			
			item.texture = Texture.fromBitmap($bitmap);
			item.image = new Image(item.texture);
			item.addChild(item.image);
			
			item.data = $data;
			
			return item;
		}
		
		/**
		 * Crea un item en base al bitmap otorgado.
		 */
		public static function fromUrl($url: String, $width: Number, $height: Number, $loadingMovieclipTextures: Vector.<Texture> = null,
									   $loadingAnimationFps: uint = 12, $autoLoad: Boolean = false, $data: Object = null): MacawSliderItem{
			
			var item: MacawSliderItem = new MacawSliderItem();
			
			item.tempQuad = new Quad($width, $height, 0xFFFFFF);
			item.addChild(item.tempQuad);
			
			if($loadingMovieclipTextures != null){
				item.loadingMovieclip = new MovieClip($loadingMovieclipTextures, $loadingAnimationFps);
				
				//Agregar el movieclip
				item.loadingMovieclip.x = (item.width - item.loadingMovieclip.width)*0.5;
				item.loadingMovieclip.y = (item.height - item.loadingMovieclip.height)*0.5;
				item.addChild(item.loadingMovieclip);
				
				//Iniciar la animacion del moviclip
				Starling.juggler.add(item.loadingMovieclip);
			}
			
			item.createLoader($url);
			item.autoLoad = $autoLoad;
			if($autoLoad){
				item.imageLoader.load();
			}
			
			item.data = $data;
			
			return item;
		}
		
		/**
		 * funcion que crea el loder del item.
		 */
		private function createLoader($url: String): void{
			if(_imageLoader != null){
				_imageLoader.dispose(true);
				_imageLoader = null;
			}
			
			_imageLoader = new ImageLoader($url, {
				onComplete: onBitmapLoaded,
				onError: onLoadError,
				autoDispose: true
			});
		}
		
		/**
		 * Handler para el momento en que se carga la imagen.
		 */
		private function onBitmapLoaded(evt: LoaderEvent): void{
			
			_tempWidth = this.width;
			_tempHeight = this.height;
			
			if(_loadingMovieclip != null && this.contains(_loadingMovieclip)){
				this.removeChild(_loadingMovieclip);
				Starling.juggler.remove(_loadingMovieclip);
				_loadingMovieclip.dispose();
				_loadingMovieclip = null;
			}
			
			if(_tempQuad != null && this.contains(_tempQuad)){
				this.removeChild(_tempQuad);
				_tempQuad.dispose();
				_tempQuad = null;
			}

			_texture = Texture.fromBitmap(_imageLoader.rawContent);
			_image = new Image(_texture);
			_image.width = _tempWidth;
			_image.height = _tempHeight;
			this.addChild(_image);
		}
		
		/**
		 * Hanlder para el caso de error en la carga de la imagen
		 */
		private function onLoadError(evt: LoaderEvent): void{
			trace('Error al intentar cargar una imagen en "PhotoSliderItem.as": '+evt.data);
		}
		
		/**
		 * Libera los recursos de este item.
		 */
		public override function dispose():void{
			
			this.removeChild(_image);
			
			if(_sprite != null){
				_sprite.dispose();
				_sprite = null;
			}
			if(_texture != null){
				_texture.dispose();
			}
			if(_image != null){
				_image.dispose();
			}
			
			_texture = null;
			_image = null;
			_data = null;
			
			if(_loadingMovieclip != null){
				if(Starling.juggler.contains(_loadingMovieclip)){
					Starling.juggler.remove(_loadingMovieclip);
				}
				_loadingMovieclip.dispose();
				_loadingMovieclip = null;
			}
			
			if(_tempQuad != null){
				_tempQuad.dispose();
				_tempQuad = null;
			}
			
			if(_imageLoader != null){
				_imageLoader.dispose(true);
				_imageLoader = null;
			}
			
			_tempWidth = NaN;
			_tempHeight = NaN;
			
			super.dispose();
		}

		////////////////////////
		//  GETTERS / SETTERS
		////////////////////////
		
		/** Informacion contenida por este item **/
		public function get data():Object
		{
			return _data;
		}

		/**
		 * @private
		 */
		public function set data(value:Object):void
		{
			_data = value;
		}

		/** Textura de este item **/
		public function get texture():Texture
		{
			return _texture;
		}

		/**
		 * @private
		 */
		public function set texture(value:Texture):void
		{
			_texture = value;
		}

		/** Imagen que encapsula la textura de este item **/
		public function get image():Image
		{
			return _image;
		}

		/**
		 * @private
		 */
		public function set image(value:Image):void
		{
			_image = value;
		}

		/** Referencia al sprite contenido por este item **/
		public function get sprite():Sprite
		{
			return _sprite;
		}
		
		/**
		 * @private
		 */
		public function set sprite(value:Sprite):void
		{
			_sprite = value;
		}
		
		/** Textura temporal mientas carga una imagen **/
		public function get tempQuad():Quad
		{
			return _tempQuad;
		}

		/**
		 * @private
		 */
		public function set tempQuad(value:Quad):void
		{
			_tempQuad = value;
		}

		/** Moviclip para la animacion de carga del componente **/
		public function get loadingMovieclip():MovieClip
		{
			return _loadingMovieclip;
		}

		/**
		 * @private
		 */
		public function set loadingMovieclip(value:MovieClip):void
		{
			_loadingMovieclip = value;
		}

		/** Loader de la imagen **/
		public function get imageLoader():ImageLoader
		{
			return _imageLoader;
		}

		/**
		 * @private
		 */
		public function set imageLoader(value:ImageLoader):void
		{
			_imageLoader = value;
		}

		/** Almacena si este item debe ser cargado automaticamente **/
		public function get autoLoad():Boolean
		{
			return _autoLoad;
		}

		/**
		 * @private
		 */
		public function set autoLoad(value:Boolean):void
		{
			_autoLoad = value;
		}
	}
}