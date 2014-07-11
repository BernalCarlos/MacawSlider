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
	/**
	 * Eventos disparados por MacawSlider.
	 * 
	 * @author Carlos Bernal <bernalcarvajal@gmail.com>
	 */
	public final class MacawSliderEvent
	{
		/** 
		 * Enviado cuando un item del slider es seleccionado.
		 * 
		 * En el objeto data del evento se envian los siguientes 2 atributos:
		 * 1. 'item_index': Indice del item seleccionado.
		 * 2. 'item': Referencia al item que fue seleccionado.
		 * **/
		public static const ITEM_TAPPED: String = 'slider_item_tapped';
		
		/** 
		 * Enviado cuando un item del slider se posicionó actualmente en pantalla.
		 * 
		 * En el objeto data del evento se envian los siguientes 2 atributos:
		 * 1. 'item_index': Indice del item actualmente en panatalla.
		 * 2. 'item': Referencia al item actualmente en panatalla
		 */
		public static const ITEM_SELECTED: String = 'slider_item_selected';
	}
}