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
	import com.greensock.loading.LoaderMax;
	
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import feathers.controls.PageIndicator;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.pixelmask.PixelMaskDisplayObject;
	import starling.textures.Texture;
	
	/**
	 * Slider de fotos para starling.
	 * 
	 * @author Carlos Bernal <bernalcarvajal@gmail.com>
	 */
	[Event(name="SCROLL", type="starling.events.Event")]
	[Event(name="SLIDER_ITEM_TAPPED", type="starling.extensions.macawslider.MacawSliderEvent"))]
	[Event(name="SLIDER_ITEM_SELECTED", type="starling.extensions.macawslider.MacawSliderEvent"))]
	public final class MacawSlider extends Sprite
	{
		/** Ancho del slider **/
		private var _sliderWidth: Number = NaN;
		/** Alto del slider **/
		private var _sliderHeight: Number = NaN;
		
		/** Fondo del slider. Hace las veces de placeholder **/
		private var _background: Quad;
		/** Moviclip de loading qie se muestra mientras se agrega el primer elemento **/
		private var _loadingMovieclip: MovieClip;
		
		/** Vector que contiene las images a mostrar **/
		private var _items: Vector.<MacawSliderItem>;
		/** La cantidad de items en el slider **/
		private var _itemsLength: uint;
		
		/** Indice de la photo actualmente mostrada **/
		private var _currentSelectedItem: int;
		/** Indice de la photo anteriormente selecionada **/
		private var _previousSelectedItem: int;
		
		/** Bandera que indica si el usuario movio el slider hacia la derecha **/
		private var _movedToTheRight: Boolean;
		/** Bandera que indica si el usuario movio el slider hacia la abajo **/
		private var _movedUp: Boolean;
		/** Bandera que indica si el usuario realizo algun moviemto al slider **/
		private var _userMovedTheSlider: Boolean;
		/** El valor de X en el ultimo toque del usuario **/
		private var _lastTouchX: Number;
		/** El valor de Y en el ultimo toque del usuario **/
		private var _lastTouchY: Number;
		/** Delta que va sumando los moviemtos del usuario para determinar,
		 *  si lo que el usuario quiere es ir al siguiente item del slider. **/
		private var _sliderMovementDelta: Number = 0;

		/** Tiempo de esperar para el pasar al siguiente item **/
		private var _autoScrollTime: Number = 5;
		/** Tiempo (en segundos) que demora la animacion del el slider en pasar de un item a otro **/
		private var _scrollSpeedTime: Number = 0.5;
		/** Determina si el slider se encuentra realizando una transición **/
		private var _isInItemTransition: Boolean = false;;
		
		/** Timer que controla el scroll automatico del slider **/
		private var _autoScrollTimer: Timer;
		
		/** Cola de carga para las imagenes **/
		private var _loadQueue: LoaderMax;
		
		/** Las texturas para la animacion de una carga **/
		private var _loadingMovieclipTextures: Vector.<Texture>;
		/** Cuadros por segundo para la animacion de carga de la imagenes **/
		private var _loadingAnimationFps: uint;
		
		/** Contenedor de los slides **/
		private var _slidesContainer: Sprite;
		
		/** Componente que muestra el numero de item en pantalla **/
		private var _itemsIndicator: PageIndicator;
		/** Fondo del _itemsIndicator **/
		private var _itemsIndicatorBackground: Quad;
		
		/** Textura normal para el indador de pagina **/
		private var _normalPageIndicator: Texture;
		/** Textura activa para el indador de pagina **/
		private var _selectedPageIndicator: Texture;
		
		/** Determina si el slider debe tener una mascara que oculte los otros items del slider **/
		private var _maskSlider: Boolean;
		/** Contenedor al cual se le puede aplicar una mascara. Sera el contenedor del contenedor de los slides **/
		private var _maskedSlidesContainer: PixelMaskDisplayObject;
		/** Es la forma de la mascara a aplicar **/
		private var _maskSpriteObject: Sprite;
		
		/** Determina si se quiere usar el indicador de pagina de Feathers **/
		private var _usePageIndicator: Boolean = true;
		/** Determina si el page indicator debe tener un fondo **/
		private var _usePageIndicatorBackgorund: Boolean = true;
		/** Determina si el page indicator debe tener un fondo **/
		private var _pageIndicatorBackgorundColor: uint = 0x414241;
		
		/** Distancia entre los indicadores de pagina **/
		private var _pageIndicatorGap: uint = 21;
		/** Padding superioir de los indicadores de pagina **/
		private var _pageIndicatorPaddingTop: uint = 9;
		/** Padding izquierdo de los indicadores de pagina **/
		private var _pageIndicatorPaddingLeft:uint = 19;
		/** Padding derecho de los indicadores de pagina **/
		private var _pageIndicatorPaddingRight:uint = 19;
		/** Padding inferior de los indicadores de pagina **/
		private var _pageIndicatorPaddingBottom:uint = 7;
		
		/** 
		 * Offset en X para el indicador de paginas.
		 * Por defecto, el indicador de paginas se ubica en la mitad del slider.
		 */ 
		private var _pageIndicatorXOffset: int = 0;
		/** 
		 * Offset en Y para el indicador de paginas.
		 * Por defecto, el indicador de paginas se sobre el limite inferior del slider.
		 */ 
		private var _pageIndicatorYOffset: int = 0;
		
		/** Determina si al llegar al final del slider, se debe saltar al primer item del slider **/
		private var _wrapSlider: Boolean = true;
		
		/** Deterina si este es un slider vertical. Si no lo es, sera horizontal **/
		private var _isVerticalSlider: Boolean;
		
		/** 
		 * Determina la cantidad de movimiento que el usaurio debe realizar en el slider,
		 * para que se suponga que lo que desea hacer, es ir al siguiente item. 
		 */
		public static var SLIDE_DELTA: Number = 10;
		/** 
		 * Determina el numero maximo de cargas simultaneas, 
		 * cuando los items deben ser cargado de una fuente externas.
		 */
		public static var MAX_SIMULTANEOUS_LOADS: uint = 2;
		
		//Variables para reutilizar
		private var _tempItem: MacawSliderItem;
		private var _touch: Touch;
		private var _gotoX: Number;
		private var _gotoY: Number;
		private var _touchDelta: Number;
		private var _i: uint;

		/**
		 * Constructor.
		 * 
		 * @param $maskSlider True si se quiere que el contenido del slider contenga una mascara. False de lo contrario (Mejor rendimeinto).
		 */
		public function MacawSlider($width: Number, $height: Number, $maskSlider: Boolean = false, $isVerticalSlider: Boolean = false,
									$loadingMovieclipTextures: Vector.<Texture> = null, $loadingAnimationFps: uint = 12,
									$normalPageIndicator: Texture = null, $selectedPageIndicator: Texture = null)
		{
			super();
			_sliderWidth = $width;
			_sliderHeight = $height;
			_items = new Vector.<MacawSliderItem>();
			_previousSelectedItem = 0;
			_currentSelectedItem = 0;
			_itemsLength = 0;
			_userMovedTheSlider = false;
			_isInItemTransition = false;
			_slidesContainer = new Sprite();
			
			_isVerticalSlider = $isVerticalSlider;
			
			_loadingMovieclipTextures = $loadingMovieclipTextures;
			_loadingAnimationFps = $loadingAnimationFps;
			
			_normalPageIndicator = $normalPageIndicator;
			_selectedPageIndicator = $selectedPageIndicator;
			
			_background = new Quad($width, $height, 0xFFFFFF);
			this.addChild(_background);

			if(_loadingMovieclipTextures != null){
				_loadingMovieclip = new MovieClip(_loadingMovieclipTextures, _loadingAnimationFps);
				Starling.juggler.add(_loadingMovieclip);
				_loadingMovieclip.x = (this.width - _loadingMovieclip.width)*0.5;
				_loadingMovieclip.y = (this.height - _loadingMovieclip.height)*0.5;
				this.addChild(_loadingMovieclip);
			}
			
			_maskSlider = $maskSlider;
			if($maskSlider){
				_maskedSlidesContainer = new PixelMaskDisplayObject();
				_maskSpriteObject = new Sprite();
				_maskSpriteObject.addChild(new Quad($width, $height, 0x000000));
			}
		}
		
		/**
		 * Agrega un item al slider en base a un sprite
		 */
		public function addItemFromSprite($sprite: Sprite, $data = null): MacawSliderItem{
			
			//Verificar si este es el primer item
			if(this.numChildren <= 2 /*&& this.contains(_loadingMovieclip)*/){
				this.removeChild(_background);
				if(_loadingMovieclip != null){
					this.removeChild(_loadingMovieclip);
					Starling.juggler.remove(_loadingMovieclip);
				}
				
				if(_maskSlider){
					_maskedSlidesContainer.addChild(_slidesContainer);
					_maskedSlidesContainer.mask = _maskSpriteObject;
					this.addChild(_maskedSlidesContainer);
				}else{
					this.addChild(_slidesContainer);
				}
			}
			
			//Crear el item
			_tempItem = MacawSliderItem.fromSprite($sprite, $data);
			_tempItem.width = _sliderWidth;
			_tempItem.height = _sliderHeight;
			
			//Only add the item to the slides container if it is the first one
			if(_itemsLength <= 0){
				_slidesContainer.addChild(_tempItem);
				if(!_isVerticalSlider){
					_tempItem.x = 0;
				}else{
					_tempItem.y = 0;
				}
			}
			
			//Add the item to the items vector
			_items.push(_tempItem);
			_itemsLength++;
			
			return _tempItem;
		}
		
		/**
		 * Agrega un item al slider en base a un bitmap
		 */
		public function addItemFromBitmap($bitmap: Bitmap, $data = null): MacawSliderItem{
			
			//Verificar si este es el primer item
			if(this.numChildren <= 2 /*&& this.contains(_loadingMovieclip)*/){
				this.removeChild(_background);
				if(_loadingMovieclip != null){
					this.removeChild(_loadingMovieclip);
					Starling.juggler.remove(_loadingMovieclip);
				}
				
				if(_maskSlider){
					_maskedSlidesContainer.addChild(_slidesContainer);
					_maskedSlidesContainer.mask = _maskSpriteObject;
					this.addChild(_maskedSlidesContainer);
				}else{
					this.addChild(_slidesContainer);
				}
			}
			
			//Crear el item
			_tempItem = MacawSliderItem.fromBitmap($bitmap, $data);
			_tempItem.width = _sliderWidth;
			_tempItem.height = _sliderHeight;
			
			//Only add the item to the slides container if it is the first one
			if(_itemsLength <= 0){
				_slidesContainer.addChild(_tempItem);
				if(!_isVerticalSlider){
					_tempItem.x = 0;
				}else{
					_tempItem.y = 0;
				}
			}
			
			//Add the item to the items vector
			_items.push(_tempItem);
			_itemsLength++;

			return _tempItem;
		}
		
		/**
		 * Agrega un item al slider en base a un bitmap
		 */
		public function addItemFromUrl($url: String, $data: Object = null, $autoLoad: Boolean = false): MacawSliderItem{

			//Verificar si este es el primer item
			if(this.numChildren <= 2 /*&& this.contains(_loadingMovieclip)*/){
				this.removeChild(_background);
				if(_loadingMovieclip != null){
					this.removeChild(_loadingMovieclip);
					Starling.juggler.remove(_loadingMovieclip);
				}
				
				if(_maskSlider){
					_maskedSlidesContainer.addChild(_slidesContainer);
					_maskedSlidesContainer.mask = _maskSpriteObject;
					this.addChild(_maskedSlidesContainer);
				}else{
					this.addChild(_slidesContainer);
				}
			}
			
			//Crear el item
			_tempItem = MacawSliderItem.fromUrl($url, _sliderWidth, _sliderHeight, _loadingMovieclipTextures, _loadingAnimationFps, $autoLoad, $data);

			//Only add the item to the slides container if it is the first one
			if(_itemsLength <= 0){
				_slidesContainer.addChild(_tempItem);
				if(!_isVerticalSlider){
					_tempItem.x = 0;
				}else{
					_tempItem.y = 0;
				}
			}
			
			//Add the item to the items vector
			_items.push(_tempItem);
			_itemsLength++;

			return _tempItem;
		}
		
		/**
		 * Inicializa el slider. Lo que implica que se inicia el auto scroll, se agregan los listeners, y se cargan las images si venian por url.
		 */
		public function initialize(): void{
			
			//Crear el timer para el scroll automatico
			if(_autoScrollTime > 0){
				_autoScrollTimer = new Timer(_autoScrollTime * 1000, 0);
				_autoScrollTimer.addEventListener(TimerEvent.TIMER, onAutoScrollTimer, false, 0, true);
				_autoScrollTimer.start();
			}
			
			//Cargar las imagenes que requieran ser cargadas
			_loadQueue = new LoaderMax({
				autoDispose: true,
				auditSize: false,
				maxConnections: MAX_SIMULTANEOUS_LOADS
			});
			for(_i = 0; _i < _itemsLength; _i++){
				if(!_items[_i].autoLoad){
					_loadQueue.append(_items[_i].imageLoader);
				}
			}
			
			if(_loadQueue.numChildren > 0){
				_loadQueue.load();
			}else{
				_loadQueue.dispose(true);
				_loadQueue = null;
			}
			
			//Agregar el indicador de bullets
			if(_usePageIndicator && _normalPageIndicator != null && _selectedPageIndicator != null){
				_itemsIndicator = new PageIndicator();
				this.addChild(_itemsIndicator);
				_itemsIndicator.validate();
				
				_itemsIndicator.pageCount = _itemsLength;
				_itemsIndicator.gap = _pageIndicatorGap;
				_itemsIndicator.paddingTop = _pageIndicatorPaddingTop;
				_itemsIndicator.paddingLeft = _pageIndicatorPaddingLeft;
				_itemsIndicator.paddingRight = _pageIndicatorPaddingRight;
				_itemsIndicator.paddingBottom = _pageIndicatorPaddingBottom;
				if(_normalPageIndicator != null){
					_itemsIndicator.normalSymbolFactory = function():DisplayObject
					{
						return new Image(_normalPageIndicator);
					};
				}
				if(_selectedPageIndicator){
					_itemsIndicator.selectedSymbolFactory = function():DisplayObject
					{
						return new Image(_selectedPageIndicator);
					};
				}
	
				_itemsIndicator.validate();
				
				if(!_isVerticalSlider){
					_itemsIndicator.x = Math.round((_sliderWidth - _itemsIndicator.width)*0.5 + _pageIndicatorXOffset);
					_itemsIndicator.y = Math.round(_sliderHeight - _itemsIndicator.height + _pageIndicatorYOffset);
				}else{
					_itemsIndicator.rotation = Math.PI*0.5;
					_itemsIndicator.x = Math.round(_sliderWidth + _pageIndicatorXOffset);
					_itemsIndicator.y = Math.round((_sliderHeight - _itemsIndicator.width)*0.5 + _pageIndicatorYOffset);
				}
				
				_itemsIndicator.addEventListener(Event.CHANGE, onItemIndicatorSelected);
	
				//Agregar el fondo del items indicator
				if(_usePageIndicatorBackgorund){
					if(!_isVerticalSlider){
						_itemsIndicatorBackground = new Quad(_itemsIndicator.width, _itemsIndicator.height, _pageIndicatorBackgorundColor);
						_itemsIndicatorBackground.x = _itemsIndicator.x;
						_itemsIndicatorBackground.y = _itemsIndicator.y;
					}else{
						_itemsIndicatorBackground = new Quad(_itemsIndicator.height, _itemsIndicator.width, _pageIndicatorBackgorundColor);
						_itemsIndicatorBackground.x = _itemsIndicator.x - _itemsIndicatorBackground.width;
						_itemsIndicatorBackground.y = _itemsIndicator.y;
					}
					
					this.addChildAt(_itemsIndicatorBackground, this.getChildIndex(_itemsIndicator));
				}
			}
			
			//Agregar el soporte para tocar el slider
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		/**
		 * Controla los tiempo de auto scroll.
		 */
		private function onAutoScrollTimer(evt: TimerEvent): void{
			if(!_isVerticalSlider){
				_slidesContainer.x = -0.1;
			}else{
				_slidesContainer.y = -0.1;
			}
			this.addAdjacentItemsToSlidesContainer(_currentSelectedItem - 1, _currentSelectedItem + 1);
			this.gotoItem(_currentSelectedItem + 1);
		}
		
		/**
		 * Muestra el slider.
		 */
		public function gotoItem($itemIndex: int): void{
			
			//Check there is a transition in motion
			if(_isInItemTransition){
				return;
			}

			_previousSelectedItem = _currentSelectedItem;
			_currentSelectedItem = $itemIndex;

			//Verificar si se debe saltar al primer o al ultimo slide
			if($itemIndex >= _itemsLength){
				if(_wrapSlider){
					_currentSelectedItem = 0;
				}else{
					_currentSelectedItem -= 1;
					return;
				}
			}
			
			if($itemIndex < 0){
				if(_wrapSlider){
					_currentSelectedItem = _itemsLength - 1;
				}else{
					_currentSelectedItem += 1;
					return;
				}
			}

			if(_itemsIndicator != null){
				_itemsIndicator.removeEventListeners()
				_itemsIndicator.selectedIndex = _currentSelectedItem;
				_itemsIndicator.addEventListener(Event.CHANGE, onItemIndicatorSelected);
			}
			
			//Flag _isInItemTransition
			_isInItemTransition = true;

			//Determinar el valor de X
			if(!_isVerticalSlider){
				if(_itemsLength != 2){
					if(_previousSelectedItem == _currentSelectedItem){
						_gotoX = 0;
					}else if(_previousSelectedItem == 0 && _currentSelectedItem == _itemsLength -1){
						_gotoX = _sliderWidth;
					}else if (_previousSelectedItem == _itemsLength -1 && _currentSelectedItem == 0){
						_gotoX = _sliderWidth * -1;
					}else{
						_gotoX = _sliderWidth * (_previousSelectedItem > _currentSelectedItem ? 1 : -1);
					}
				}else{ //2 items is a special case
					if(_previousSelectedItem == _currentSelectedItem){
						_gotoX = 0;
					}else if($itemIndex == 2){
						_gotoX = _sliderWidth * -1;
					}else if($itemIndex == -1){
						_gotoX = _sliderWidth;
					}else{
						_gotoX = _sliderWidth * (_previousSelectedItem > _currentSelectedItem ? 1 : -1);
					}
				}
				
				Starling.juggler.tween(_slidesContainer, _scrollSpeedTime, {
					x: _gotoX,
					transition: Transitions.EASE_OUT,
					onComplete: notifyItemSelection
				});
				
			}else{

				//Determinar el valor de Y
				if(_itemsLength != 2){
					if(_previousSelectedItem == _currentSelectedItem){
						_gotoY = 0;
					}else if(_previousSelectedItem == 0 && _currentSelectedItem == _itemsLength -1){
						_gotoY = _sliderHeight;
					}else if (_previousSelectedItem == _itemsLength -1 && _currentSelectedItem == 0){
						_gotoY = _sliderHeight * -1;
					}else{
						_gotoY = _sliderHeight * (_previousSelectedItem > _currentSelectedItem ? 1 : -1);
					}
				}else{ //2 items is a special case
					if(_previousSelectedItem == _currentSelectedItem){
						_gotoY = 0;
					}else if($itemIndex == 2){
						_gotoY = _sliderHeight * -1;
					}else if($itemIndex == -1){
						_gotoY = _sliderHeight;
					}else{
						_gotoY = _sliderHeight * (_previousSelectedItem > _currentSelectedItem ? 1 : -1);
					}
				}
				
				Starling.juggler.tween(_slidesContainer, _scrollSpeedTime, {
					y: _gotoY,
					transition: Transitions.EASE_OUT,
					onComplete: notifyItemSelection
				});
			}
		}
		
		/**
		 * Handler para la seleccion de los item del indicador
		 */
		private function onItemIndicatorSelected($evt: Event): void{
			gotoItem(($evt.currentTarget as PageIndicator).selectedIndex);
		}
		
		/**
		 * Notifica que un item fue seleccionado
		 */
		private function notifyItemSelection(): void{
			if(_items != null){
				//Reiniciar el contendor de slides
				this.removeAdjacentItemsInSlidesContainer();
				
				//flag _isInItemTransition
				_isInItemTransition = false;
				
				//notificar
				this.dispatchEventWith(MacawSliderEvent.ITEM_SELECTED, false, {
					item_index: _currentSelectedItem,
					item: _items[_currentSelectedItem]
				});
			}
		}

		/**
		 * Handler encargado de procesar los gestos del usuario.
		 */
		private function onTouch(evt: TouchEvent):void
		{
			//Verificar moviemientos en el baner
			_touch = evt.getTouch(this, TouchPhase.MOVED);

			if(_touch != null && !_isInItemTransition){
				
				if(!_isVerticalSlider){
					if(_lastTouchX >= 0){
	
						//Add the Adjacent items to the slides container
						this.addAdjacentItemsToSlidesContainer(_currentSelectedItem - 1, _currentSelectedItem + 1);
						
						//Mover el slider junto con el dedo del usuario
						_touchDelta = _touch.globalX - _lastTouchX;
						_slidesContainer.x += _touchDelta;
						
						//Check is allowed to wrap the slides
						if(!_wrapSlider){
							if(_slidesContainer.x > 0 && _currentSelectedItem == 0){
								_slidesContainer.x = 0;
							}
							if(_slidesContainer.x < 0 && _currentSelectedItem >= _itemsLength - 1){
								_slidesContainer.x = 0;
							}
						}
						
						//Verficar si la intencion del usaurio es ir al siguiente item del slider
						_sliderMovementDelta += Math.abs(_touch.globalX - _lastTouchX);
						if(_sliderMovementDelta > SLIDE_DELTA){
							
							//Notificar que el usario lo que quiere es nover el 
							_userMovedTheSlider = true;
							
							//Determinar las direccion del scroll
							if(_touchDelta >= 0){
								_movedToTheRight = false;
							}else{
								_movedToTheRight = true;
							}
							
							//Notificar si se esta moviendo el slider
							this.dispatchEventWith(Event.SCROLL);
						}
					}
					
					_lastTouchX = _touch.globalX;
				}else{
					
					if(_lastTouchY >= 0){
						
						//Add the Adjacent items to the slides container
						this.addAdjacentItemsToSlidesContainer(_currentSelectedItem - 1, _currentSelectedItem + 1);
						
						//Mover el slider junto con el dedo del usuario
						_touchDelta = _touch.globalY - _lastTouchY;
						_slidesContainer.y += _touchDelta;
						
						//Check is allowed to wrap the slides
						if(!_wrapSlider){
							if(_slidesContainer.y > 0 && _currentSelectedItem == 0){
								_slidesContainer.y = 0;
							}
							if(_slidesContainer.y < 0 && _currentSelectedItem >= _itemsLength - 1){
								_slidesContainer.y = 0;
							}
						}
						
						//Verficar si la intencion del usaurio es ir al siguiente item del slider
						_sliderMovementDelta += Math.abs(_touch.globalY - _lastTouchY);
						if(_sliderMovementDelta > SLIDE_DELTA){
							
							//Notificar que el usario lo que quiere es nover el 
							_userMovedTheSlider = true;
							
							//Determinar las direccion del scroll
							if(_touchDelta >= 0){
								_movedUp = false;
							}else{
								_movedUp = true;
							}
							
							//Notificar si se esta moviendo el slider
							this.dispatchEventWith(Event.SCROLL);
						}
					}
					
					_lastTouchY = _touch.globalY;
				}
			}
			
			//Verificar si ya se solto el touch
			_touch = evt.getTouch(this, TouchPhase.ENDED);
			if(_touch != null){

				if(!_isVerticalSlider){
					//Verificar si el usuario intento mover el slider
					if(_userMovedTheSlider){
						
						_sliderMovementDelta = 0;
						
						if(_movedToTheRight){
							this.gotoItem(_currentSelectedItem + 1);
						}else{
							this.gotoItem(_currentSelectedItem - 1);
						}
						
					}else{ //El usuario queire abir el item
						
						_sliderMovementDelta = 0;
						this.gotoItem(_currentSelectedItem);
						
						this.dispatchEventWith(MacawSliderEvent.ITEM_TAPPED, false, {
							item_index: _currentSelectedItem,
							item: _items[_currentSelectedItem]
						});
					}
					
					_lastTouchX = NaN;
					_userMovedTheSlider = false;
				}else{
					
					//Verificar si el usuario intento mover el slider
					if(_userMovedTheSlider){
						
						_sliderMovementDelta = 0;
						
						if(_movedUp){
							this.gotoItem(_currentSelectedItem + 1);
						}else{
							this.gotoItem(_currentSelectedItem - 1);
						}
						
					}else{ //El usuario queire abir el item
						
						_sliderMovementDelta = 0;
						this.gotoItem(_currentSelectedItem);
						
						this.dispatchEventWith(MacawSliderEvent.ITEM_TAPPED, false, {
							item_index: _currentSelectedItem,
							item: _items[_currentSelectedItem]
						});
					}
					
					_lastTouchY = NaN;
					_userMovedTheSlider = false;
				}
			}
			
			//Reiniciar el timer del auto scroll
			if(_autoScrollTimer != null){
				_autoScrollTimer.reset();
				_autoScrollTimer.start();
			}
		}
		
		///////////////////////////////
		//  Private helper functions
		///////////////////////////////
		
		/**
		 * Adds 2 items to the _slidesConatiner. One before the current selected item,
		 * and one next to it.
		 * 
		 * @param $prevItemIndex The index of the item to be displayed before the current selected item.
		 * @param $nexItemIndex The index of the item to be displayed next to the current selected item.
		 */
		private function addAdjacentItemsToSlidesContainer($prevItemIndex: int, $nexItemIndex: int): void{
			
			//Validate the input
			if($prevItemIndex < 0){
				$prevItemIndex = _itemsLength - 1;
			}
			if($nexItemIndex >= _itemsLength){
				$nexItemIndex = 0;
			}
			
			//Check if this is a veritial slider
			if(!_isVerticalSlider){
				
				if(_itemsLength != 2){
					if(_slidesContainer.numChildren <= 1){
						//Add the previous item
						_items[$prevItemIndex].x = _items[_currentSelectedItem].x - _sliderWidth;
						_slidesContainer.addChild(_items[$prevItemIndex]);
						
						//Add the next item
						_items[$nexItemIndex].x = _items[_currentSelectedItem].x + _sliderWidth;
						_slidesContainer.addChild(_items[$nexItemIndex]);
					}					
				}else{ //Where there's only 2 items, is a special case.
					
					if(_slidesContainer.x < 0){
						//Add the next item
						_items[$nexItemIndex].x = _items[_currentSelectedItem].x + _sliderWidth;
						_slidesContainer.addChild(_items[$nexItemIndex]);
						
					}else{
						//Add the previous item
						_items[$nexItemIndex].x = _items[_currentSelectedItem].x - _sliderWidth;
						_slidesContainer.addChild(_items[$nexItemIndex]);
					}
				}
			}else{
				
				if(_itemsLength != 2){
					if(_slidesContainer.numChildren <= 1){
						//Add the previous item
						_items[$prevItemIndex].y = _items[_currentSelectedItem].y - _sliderHeight;
						_slidesContainer.addChild(_items[$prevItemIndex]);
						
						//Add the next item
						_items[$nexItemIndex].y = _items[_currentSelectedItem].y + _sliderHeight;
						_slidesContainer.addChild(_items[$nexItemIndex]);
					}
				}else{ //Where there's only 2 items, is a special case.
					
					if(_slidesContainer.y < 0){
						//Add the next item
						_items[$nexItemIndex].y = _items[_currentSelectedItem].y + _sliderHeight;
						_slidesContainer.addChild(_items[$nexItemIndex]);
						
					}else{
						//Add the previous item
						_items[$prevItemIndex].y = _items[_currentSelectedItem].y - _sliderHeight;
						_slidesContainer.addChild(_items[$prevItemIndex]);
					}
				}
			}
			
		}
		
		/**
		 * Remove the items adjacent to the current selected item.
		 */
		private function removeAdjacentItemsInSlidesContainer(): void{
			//Remove all items from the container
			_slidesContainer.removeChildren();
			_slidesContainer.x = _slidesContainer.y = 0;
			
			//Add the current item
			_items[_currentSelectedItem].x = _items[_currentSelectedItem].y = 0;
			_slidesContainer.addChild(_items[_currentSelectedItem]);
		}
		
		////////////////////////
		//  Dispose Method
		////////////////////////
		
		/**
		 * Libera los recursos de este slider.
		 */
		public override function dispose():void{

			this.removeEventListener(TouchEvent.TOUCH, onTouch);
			this.removeChildren();
			
			_sliderWidth = NaN;
			_sliderHeight = NaN;
			
			if(_items != null){
				for(_i = 0; _i < _itemsLength; _i++){
					_items[_i].removeFromParent(true);
					_items[_i] = null;
				}
				_items.length = 0;
				_items = null;
			}
			
			_itemsLength = NaN;
			_previousSelectedItem = NaN;
			_currentSelectedItem = NaN;
			 _lastTouchX = NaN;
			_autoScrollTime = NaN;
			_scrollSpeedTime  = NaN;
			
			if(_autoScrollTimer != null){
				_autoScrollTimer.stop();
				_autoScrollTimer.removeEventListener(TimerEvent.TIMER, onAutoScrollTimer);
				_autoScrollTimer = null;
			}
			
			if(_loadQueue != null){
				_loadQueue.dispose(true);
				_loadQueue = null;
			}
			
			if(_loadingMovieclipTextures != null){
				_touchDelta = _loadingMovieclipTextures.length;
				for(_i = 0; _i < _touchDelta; _i++){
					_loadingMovieclipTextures[_i].dispose();
					_loadingMovieclipTextures[_i] = null;
				}
				
				_loadingMovieclipTextures.length = 0;
				_loadingMovieclipTextures = null;
			}
			_loadingAnimationFps = NaN;
			
			_tempItem = null;
			_touch = null;
			_gotoX = NaN;
			_touchDelta = NaN;
			_i = NaN;
			
			if(_background != null){
				_background.removeFromParent(true);
				_background = null;
			}

			if(_loadingMovieclip != null){
				if(Starling.juggler.contains(_loadingMovieclip)){
					Starling.juggler.remove(_loadingMovieclip);
				}
				_loadingMovieclip.removeFromParent(true);
				_loadingMovieclip = null;
			}
			
			if(_slidesContainer != null){
				_slidesContainer.removeFromParent(true);
				_slidesContainer = null;
			}
			
			if(_itemsIndicator != null){
				_itemsIndicator.removeFromParent(true);
				_itemsIndicator = null;
			}
			
			if(_itemsIndicatorBackground != null){
				_itemsIndicatorBackground.removeFromParent(true);
				_itemsIndicatorBackground = null;
			}
			
			if(_maskedSlidesContainer != null){
				_maskedSlidesContainer.removeFromParent(true);
				_maskedSlidesContainer = null;
			}
			if(_maskSpriteObject != null){
				_maskSpriteObject.removeFromParent(true);
				_maskSpriteObject = null;
			}
			
			_pageIndicatorBackgorundColor= NaN;
			
			_pageIndicatorGap = NaN;
			_pageIndicatorPaddingTop = NaN;
			_pageIndicatorPaddingLeft = NaN;
			_pageIndicatorPaddingRight = NaN;
			_pageIndicatorPaddingBottom = NaN;
			
			_pageIndicatorXOffset = NaN;
			_pageIndicatorYOffset = NaN;
			
			_lastTouchY = NaN;
			_gotoY = NaN;
			
			super.dispose();
		}
		
		////////////////////////
		//  GETTERS / SETTERS
		////////////////////////

		/** Tiempo de esperar para el pasar al siguiente item **/
		public function get autoScrollTime():Number
		{
			return _autoScrollTime;
		}

		/**
		 * @private
		 */
		public function set autoScrollTime(value:Number):void
		{
			_autoScrollTime = value;
		}

		/** Tiempo (en segundos) que demora la animacion del el slider en pasar de un item a otro **/
		public function get scrollSpeedTime():Number
		{
			return _scrollSpeedTime;
		}

		/**
		 * @private
		 */
		public function set scrollSpeedTime(value:Number):void
		{
			_scrollSpeedTime = value;
		}
		
		/** @inheritDoc **/
		public override function get width():Number{
			return _sliderWidth;
		}
		/** @inheritDoc **/
		public override function get height():Number{
			return _sliderHeight;
		}

		/** Vector que contiene las images a mostrar **/
		public function get items():Vector.<MacawSliderItem>
		{
			return _items;
		}
		
		/** Determina si se quiere usar el indicador de pagina de Feathers **/
		public function get usePageIndicator():Boolean
		{
			return _usePageIndicator;
		}
		
		/**
		 * @private
		 */
		public function set usePageIndicator(value:Boolean):void
		{
			_usePageIndicator = value;
		}

		/** Determina si el page indicator debe tener un fondo **/
		public function get usePageIndicatorBackgorund():Boolean
		{
			return _usePageIndicatorBackgorund;
		}

		/**
		 * @private
		 */
		public function set usePageIndicatorBackgorund(value:Boolean):void
		{
			_usePageIndicatorBackgorund = value;
		}

		/** Determina si el page indicator debe tener un fondo **/
		public function get pageIndicatorBackgorundColor():uint
		{
			return _pageIndicatorBackgorundColor;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorBackgorundColor(value:uint):void
		{
			_pageIndicatorBackgorundColor = value;
		}

		/** Distancia entre los indicadores de pagina **/
		public function get pageIndicatorGap():uint
		{
			return _pageIndicatorGap;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorGap(value:uint):void
		{
			_pageIndicatorGap = value;
		}
		
		/**
		 * Asigna el mismo valor a todos los padding
		 */
		public function set pageIndicatorPadding(value: uint): void{
			_pageIndicatorPaddingBottom = value;
			_pageIndicatorPaddingLeft = value;
			_pageIndicatorPaddingRight = value;
			_pageIndicatorPaddingTop = value;
		}

		/** Padding superioir de los indicadores de pagina **/
		public function get pageIndicatorPaddingTop():uint
		{
			return _pageIndicatorPaddingTop;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorPaddingTop(value:uint):void
		{
			_pageIndicatorPaddingTop = value;
		}

		/** Padding izquierdo de los indicadores de pagina **/
		public function get pageIndicatorPaddingLeft():uint
		{
			return _pageIndicatorPaddingLeft;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorPaddingLeft(value:uint):void
		{
			_pageIndicatorPaddingLeft = value;
		}

		/** Padding derecho de los indicadores de pagina **/
		public function get pageIndicatorPaddingRight():uint
		{
			return _pageIndicatorPaddingRight;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorPaddingRight(value:uint):void
		{
			_pageIndicatorPaddingRight = value;
		}

		/** Padding inferior de los indicadores de pagina **/
		public function get pageIndicatorPaddingBottom():uint
		{
			return _pageIndicatorPaddingBottom;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorPaddingBottom(value:uint):void
		{
			_pageIndicatorPaddingBottom = value;
		}

		/** 
		 * Offset en X para el indicador de paginas.
		 * Por defecto, el indicador de paginas se ubica en la mitad del slider.
		 */
		public function get pageIndicatorXOffset():int
		{
			return _pageIndicatorXOffset;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorXOffset(value:int):void
		{
			_pageIndicatorXOffset = value;
		}

		/** 
		 * Offset en Y para el indicador de paginas.
		 * Por defecto, el indicador de paginas se sobre el limite inferior del slider.
		 */
		public function get pageIndicatorYOffset():int
		{
			return _pageIndicatorYOffset;
		}

		/**
		 * @private
		 */
		public function set pageIndicatorYOffset(value:int):void
		{
			_pageIndicatorYOffset = value;
		}

		/** Determina si al llegar al final del slider, se debe saltar al primer item del slider **/
		public function get wrapSlider():Boolean
		{
			return _wrapSlider;
		}

		/**
		 * @private
		 */
		public function set wrapSlider(value:Boolean):void
		{
			_wrapSlider = value;
		}

		/** Deterina si este es un slider vertical. Si no lo es, sera horizontal **/
		public function get isVerticalSlider():Boolean
		{
			return _isVerticalSlider;
		}

		/**
		 * @private
		 */
		public function set isVerticalSlider(value:Boolean):void
		{
			_isVerticalSlider = value;
		}

		/** Indice de la photo actualmente mostrada **/
		public function get currentSelectedItem():int
		{
			return _currentSelectedItem;
		}

		/** Indice de la photo anteriormente selecionada **/
		public function get previousSelectedItem():int
		{
			return _previousSelectedItem;
		}
	}
}