﻿/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.plugins.add('format',{requires:['richcombo','styles'],init:function(a){var b=a.config,c=a.lang.format,d=b.format_tags.split(';'),e={};for(var f=0;f<d.length;f++){var g=d[f];e[g]=new CKEDITOR.style(b['format_'+g]);}a.ui.addRichCombo('Format',{label:c.label,title:c.panelTitle,voiceLabel:c.voiceLabel,className:'cke_format',multiSelect:false,panel:{css:[b.contentsCss,CKEDITOR.getUrl(a.skinPath+'editor.css')],voiceLabel:c.panelVoiceLabel},init:function(){this.startGroup(c.panelTitle);for(var h in e){var i=c['tag_'+h];this.add(h,'<'+h+'>'+i+'</'+h+'>',i);}},onClick:function(h){a.focus();a.fire('saveSnapshot');e[h].apply(a.document);a.fire('saveSnapshot');},onRender:function(){a.on('selectionChange',function(h){var i=this.getValue(),j=h.data.path;for(var k in e)if(e[k].checkActive(j)){if(k!=i)this.setValue(k,a.lang.format['tag_'+k]);return;}this.setValue('');},this);}});}});CKEDITOR.config.format_tags='p;h1;h2;h3;h4;h5;h6;pre;address;div';CKEDITOR.config.format_p={element:'p'};CKEDITOR.config.format_div={element:'div'};CKEDITOR.config.format_pre={element:'pre'};CKEDITOR.config.format_address={element:'address'};CKEDITOR.config.format_h1={element:'h1'};CKEDITOR.config.format_h2={element:'h2'};CKEDITOR.config.format_h3={element:'h3'};CKEDITOR.config.format_h4={element:'h4'};CKEDITOR.config.format_h5={element:'h5'};CKEDITOR.config.format_h6={element:'h6'};
