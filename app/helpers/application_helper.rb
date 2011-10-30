# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def copy_translate_me_js_to_clipboard
    js_tag = %{<script type="text/javascript" language="javascript">document.write( '<a href="http://opent.heroku.com/posts?url=' + window.location + '">Help us translate this into other languages</a>' );</script><noscript>Note: you can turn on Javascript to see this link.</noscript>}
    html = clippy( url_escape( js_tag ) )
  end

  def clippy(text, bgcolor='#FFFFFF')
    html =
      %{<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>}
  end

  def url_escape( data )
    data = URI.escape( data )
    data.gsub!( '&', '%26' )
    data.gsub!( ';', '%3B' )
    data.gsub!( '+', '%2B' )
    data
  end

end
