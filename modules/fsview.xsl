<?xml version="1.0" encoding="ISO-8859-1" ?>
<!-- CVS Version: $Id: fsview.xsl,v 1.1.1.1 2005-04-11 21:51:00 hww3 Exp $ -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"&gt;</xsl:text>
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
      <xsl:choose>
	<xsl:when test="/page/popup = 'true'">
	  <xsl:call-template name="exif_popup" />
	</xsl:when>
	<xsl:when test="/page/admin">
	  <xsl:call-template name="directory_listing" />
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="directory_listing" />
	</xsl:otherwise>
      </xsl:choose>
    </html>
  </xsl:template>

  <xsl:template name="directory_listing">
    <head>
      <title>
	<xsl:text>[TOP]</xsl:text>
	<xsl:if test="count(/page/heading/link) &gt; 1">
	  <xsl:text> / </xsl:text>
	</xsl:if>
	<xsl:for-each select="/page/heading/link[name != '/']">
	  <xsl:value-of select="translate(name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
	  <xsl:if test="position() != last()">
	    <xsl:text> / </xsl:text>
	  </xsl:if>
	</xsl:for-each>
      </title>
      <link rel="stylesheet" title="Media Directories">
	<xsl:attribute name="href">
	  <xsl:value-of select="page/stylesheet_url" />
	</xsl:attribute>
      </link>
    </head>
    <body>
      <script language="javascript">
	<xsl:if test="/page/admin">
	  <xsl:text>
	  function confirm_remove(name, count, path) {
	    if (confirm('Are you sure you wish to remove the folder "' + name + '", which contains ' + count + ' items?'))
	      window.location = path;
	  }

	  </xsl:text>
	</xsl:if>
	<xsl:text>
	  function c_mouse_over(element, style) {
	    element.className = style + '-over';
	  }

	  function mouse_over(element) {
	    element.className = 'linkrow-over';
	  }

	  function c_mouse_out(element, style) {
	    element.className = style;
	  }

	  function mouse_out(element) {
	    element.className = 'linkrow';
	  }

	  function ahref(url) {
	    window.location.href = url;
	  }
	</xsl:text>
      </script>
      <table class="heading">
	<tr>
	  <td class="heading">
	    <a class="heading">
	      <xsl:attribute name="href">
		<xsl:value-of select="/page/heading/link[name='/']/url" />
	      </xsl:attribute>
	      [TOP]
	    </a>
	    <xsl:if test="count(/page/heading/link) &gt; 1">
	      <span class="heading"> / </span>
	    </xsl:if>
	    <xsl:for-each select="/page/heading/link[name!='/']">
	      <a class="heading">
		<xsl:attribute name="href">
		  <xsl:value-of select="url" />
		</xsl:attribute>
		<xsl:value-of select="translate(name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
	      </a>
	      <xsl:if test="position() != last()">
		<span class="heading">
		  <xsl:text> / </xsl:text>
		</span>
	      </xsl:if>
	    </xsl:for-each>
	  </td>
	  <td class="version">
	    <span class="subdir">Media Directories v1.2 on <xsl:value-of select="/page/caudium_version" /> copyright 2005 James Tyson</span>
	  </td>
	</tr>
      </table>
      <xsl:if test="count(/page/subdirectories/directory) &gt; 0">
	<table class="subdir">
	  <tr>
	    <td class="subdirheading" colspan="4">
	      <xsl:text>Folders in /</xsl:text>
	      <xsl:for-each select="/page/heading/link[name!='/']">
		<xsl:value-of select="translate(name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
		<xsl:if test="position() != last()">
		  <xsl:text>/</xsl:text>
		</xsl:if>
	      </xsl:for-each>
	      <xsl:text>: </xsl:text>
	      <span class="subdircount">
		<xsl:text>(</xsl:text>
		<xsl:value-of select="count(/page/subdirectories/directory)" />
		<xsl:choose>
		  <xsl:when test="count(/page/subdirectories/directory) &gt; 1">
		    <xsl:text> folders)</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text> folder)</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </span>
	    </td>
	  </tr>
	  <xsl:if test="/page/readme">
	    <tr>
	      <td colspan="4" class="readme">
		<xsl:value-of select="/page/readme" />
	      </td>
	    </tr>
	  </xsl:if>
	  <xsl:for-each select="/page/subdirectories/directory">
	    <xsl:if test="position() = 1">
	      <xsl:text disable-output-escaping="yes">&lt;tr&gt;</xsl:text>
	    </xsl:if>
	    <td class="subdirlinkouter">
	      <table class="linkrow" onMouseOver="mouse_over(this)" onMouseOut="mouse_out(this)">
		<xsl:attribute name="onClick">
		  <xsl:text>ahref('</xsl:text>
		  <xsl:value-of select="name" />
		  <xsl:text>')</xsl:text>
		</xsl:attribute>
		<tr>
		  <td class="subdirthumb">
		    <a class="subdirlink">
		      <xsl:attribute name="href">
			<xsl:value-of select="name" />
		      </xsl:attribute>
		      <xsl:choose>
		      <xsl:when test="icon">
			<img class="thumb">
			  <xsl:attribute name="src">
			    <xsl:value-of select="icon" />
			  </xsl:attribute>
			  <xsl:attribute name="alt">
			    <xsl:choose>
			      <xsl:when test="comment">
				<xsl:value-of select="comment" />
			      </xsl:when>
			      <xsl:otherwise>
				<xsl:value-of select="name" />
			      </xsl:otherwise>
			    </xsl:choose>
			  </xsl:attribute>
			</img>
		      </xsl:when>
		      <xsl:otherwise>
			<img class="thumb" src="/internal-gopher-menu">
			  <xsl:attribute name="alt">
			    <xsl:choose>
			      <xsl:when test="comment">
				<xsl:value-of select="comment" />
			      </xsl:when>
			      <xsl:otherwise>
				<xsl:value-of select="name" />
			      </xsl:otherwise>
			    </xsl:choose>
			  </xsl:attribute>
			</img>
		      </xsl:otherwise>
		      </xsl:choose>
		    </a>
		  </td>
		  <td class="subdirlink">
		    <a class="subdirlink">
		      <xsl:attribute name="href">
			<xsl:value-of select="name" />
		      </xsl:attribute>
		      <xsl:value-of select="name" />
		    </a>
		    <br />
		    <span class="size">
		      <xsl:value-of select="date/day" />
		      <xsl:text>/</xsl:text>
		      <xsl:value-of select="date/month" />
		      <xsl:text>/</xsl:text>
		      <xsl:value-of select="date/year" />
		      <xsl:text> </xsl:text>
		      <xsl:value-of select="date/hour" />
		      <xsl:text>:</xsl:text>
		      <xsl:value-of select="date/minute" />
		      <xsl:text>:</xsl:text>
		      <xsl:value-of select="date/year" />
		      <br />
		      <xsl:text>(</xsl:text>
		      <xsl:choose>
			<xsl:when test="items = '0'">
			  <span class="size">empty</span>
			</xsl:when>
			<xsl:when test="items = '1'">
			  <span class="size">1 item</span>
			</xsl:when>
			<xsl:otherwise>
			  <span class="size">
			    <xsl:value-of select="items" />
			    <xsl:text> items</xsl:text>
			  </span>
			</xsl:otherwise>
		      </xsl:choose>
		      <xsl:if test="remove">
			<xsl:text> </xsl:text>
			<a class="directory_remove">
			  <xsl:attribute name="href">
			    <xsl:choose>
			      <xsl:when test="items &gt; 0">
				<xsl:text>javascript:confirm_remove('</xsl:text>
				<xsl:value-of select="name" />
				<xsl:text>', '</xsl:text>
				<xsl:value-of select="items" />
				<xsl:text>', '</xsl:text>
				<xsl:value-of select="remove" />
				<xsl:text>');</xsl:text>
			      </xsl:when>
			      <xsl:otherwise>
				<xsl:value-of select="remove" />
			      </xsl:otherwise>
			    </xsl:choose>
			  </xsl:attribute>remove</a>
		      </xsl:if>
		      <xsl:text>)</xsl:text>
		    </span>
		  </td>
		</tr>
	      </table>
	    </td>
	    <xsl:choose>
	      <xsl:when test="position() mod 4 = 0">
		<xsl:text disable-output-escaping="yes">&lt;/tr&gt;&lt;tr&gt;</xsl:text>
	      </xsl:when>
	      <xsl:when test="position() = last()">
		<xsl:text disable-output-escaping="yes">&lt;/tr&gt;</xsl:text>
	      </xsl:when>
	    </xsl:choose>
	  </xsl:for-each>
	</table>
      </xsl:if>
      <xsl:if test="count(/page/media/file) &gt; 0">
	<xsl:choose>
	  <xsl:when test="count(/page/default) &gt; 0">
	    <xsl:call-template name="preview">
	      <xsl:with-param name="previewpath" select="/page/default" />
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:when test="count(/page/media/file[preview]) &gt; 0">
	    <xsl:call-template name="preview">
	      <xsl:with-param name="previewpath" select="/page/media/file[preview][1]" />
	    </xsl:call-template>
	  </xsl:when>
	</xsl:choose>
	<table class="medialinks">
	  <tr>
	    <td colspan="4" class="mediaheading">
	      <xsl:text>Media in /</xsl:text>
	      <xsl:for-each select="/page/heading/link[name!='/']">
		<xsl:value-of select="translate(name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
		<xsl:if test="position() != last()">
		  <xsl:text>/</xsl:text>
		</xsl:if>
	      </xsl:for-each>
	      <xsl:text>: </xsl:text>
	      <span class="mediacount">
		<xsl:text>(</xsl:text>
		<xsl:if test="count(/page/media/file[type='image']) &gt; 0">
		  <xsl:choose>
		    <xsl:when test="count(/page/media/file[type='image']) = 1">
		      <xsl:text>1 image</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="count(/page/media/file[type='image'])" />
		      <xsl:text> images</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:if>
		<xsl:if test="(count(/page/media/file[type='image']) &gt; 0) and (count(/page/media/file[type='audio']) &gt; 0)">
		  <xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="count(/page/media/file[type='audio']) &gt; 0">
		  <xsl:choose>
		    <xsl:when test="count(/page/media/file[type='audio']) = 1">
		      <xsl:text>1 audio file</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="count(/page/media/file[type='audio'])" />
		      <xsl:text> audio files</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:if>
		<xsl:if test="((count(/page/media/file[type='image']) &gt; 0) or (count(/page/media/file[type='audio']) &gt; 0)) and (count(/page/media/file[type='video']) &gt; 0)">
		  <xsl:text>, </xsl:text>
		</xsl:if>
		<xsl:if test="count(/page/media/file[type='video']) &gt; 0">
		  <xsl:choose>
		    <xsl:when test="count(/page/media/file[type='video']) = 1">
		      <xsl:text>1 video</xsl:text>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="count(/page/media/file[type='video'])" />
		      <xsl:text> videos</xsl:text>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:if>
		<xsl:text>)</xsl:text>
	      </span>
	    </td>
	  </tr>
	  <xsl:for-each select="/page/media/file">
	    <xsl:sort select="name" />
	    <xsl:if test="position() = 1">
	      <xsl:text disable-output-escaping="yes">&lt;tr&gt;</xsl:text>
	    </xsl:if>
	    <td class="medialinkouter">
	      <table class="linkrow" onMouseOver="mouse_over(this)" onMouseOut="mouse_out(this)">
		<xsl:attribute name="onClick">
		  <xsl:text>ahref('</xsl:text>
		  <xsl:choose>
		    <xsl:when test="preview">
		      <xsl:value-of select="preview" />
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="name" />
		    </xsl:otherwise>
		  </xsl:choose>
		  <xsl:text>')</xsl:text>
		</xsl:attribute>
		<tr>
		  <td class="medialinkthumb">
		    <a class="mediathumblink">
		      <xsl:attribute name="href">
			<xsl:choose>
			  <xsl:when test="preview">
			    <xsl:value-of select="preview" />
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:value-of select="name" />
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:attribute>
		      <img class="thumb">
			<xsl:attribute name="src">
			  <xsl:choose>
			    <xsl:when test="thumb">
			      <xsl:value-of select="thumb" />
			    </xsl:when>
			    <xsl:when test="icon">
			      <xsl:value-of select="icon" />
			    </xsl:when>
			    <xsl:when test="type = 'video'">
			      <xsl:text>/internal-gopher-binary</xsl:text>
			    </xsl:when>
			    <xsl:when test="type = 'image'">
			      <xsl:text>/internal-gopher-image</xsl:text>
			    </xsl:when>
			    <xsl:when test="type = 'audio'">
			      <xsl:text>/internal-gopher-sound</xsl:text>
			    </xsl:when>
			  </xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="alt">
			  <xsl:choose>
			    <xsl:when test="comment">
			      <xsl:value-of select="comment" />
			    </xsl:when>
			    <xsl:otherwise>
			      <xsl:value-of select="name" />
			    </xsl:otherwise>
			  </xsl:choose>
			</xsl:attribute>
		      </img>
		    </a>
		  </td>
		  <td class="medialink">
		    <a class="medialink">
		      <xsl:attribute name="href">
			<xsl:choose>
			  <xsl:when test="count(preview) &gt; 0">
			    <xsl:value-of select="preview" />
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:value-of select="name" />
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:attribute>
		      <xsl:value-of select="name" />
		    </a>
		    <br />
		    <span class="size">
		      <xsl:value-of select="date/day" />
		      <xsl:text>/</xsl:text>
		      <xsl:value-of select="date/month" />
		      <xsl:text>/</xsl:text>
		      <xsl:value-of select="date/year" />
		      <xsl:text> </xsl:text>
		      <xsl:value-of select="date/hour" />
		      <xsl:text>:</xsl:text>
		      <xsl:value-of select="date/minute" />
		      <xsl:text>:</xsl:text>
		      <xsl:value-of select="date/year" />
		      <br />
		      <xsl:text> (</xsl:text>
		      <xsl:value-of select="size" />
		      <xsl:if test="remove">
			<xsl:text> </xsl:text>
			<a class="media_remove">
			  <xsl:attribute name="href">
			    <xsl:value-of select="remove" />
			  </xsl:attribute>remove</a>
		      </xsl:if>
		      <xsl:text>)</xsl:text>
		    </span>
		  </td>
		</tr>
	      </table>
	    </td>
	    <xsl:choose>
	      <xsl:when test="position() mod 4 = 0">
		<xsl:text disable-output-escaping="yes">&lt;/tr&gt;&lt;tr&gt;</xsl:text>
	      </xsl:when>
	      <xsl:when test="position() = last()">
		<xsl:text disable-output-escaping="yes">&lt;/tr&gt;</xsl:text> 
	      </xsl:when>
	    </xsl:choose>
	  </xsl:for-each>
	</table>
      </xsl:if>
      <xsl:if test="count(/page/files/file) &gt; 0">
	<table class="othertable">
	  <tr>
	    <td colspan="4" class="otherheading">
	      <xsl:text>Other files in /</xsl:text>
	      <xsl:for-each select="/page/heading/link[name!='/']">
		<xsl:value-of select="translate(name, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')" />
		<xsl:if test="position() != last()">
		  <xsl:text>/</xsl:text>
		</xsl:if>
	      </xsl:for-each>
	      <xsl:text>: </xsl:text>
	      <span class="othercount">
		<xsl:text> (</xsl:text>
		<xsl:value-of select="count(/page/files/file)" />
		<xsl:choose>
		  <xsl:when test="count(/page/files/file) &gt; 1">
		    <xsl:text> files)</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    <xsl:text> file)</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </span>
	    </td>
	  </tr>
	  <xsl:for-each select="/page/files/file">
	    <xsl:sort select="name" />
	    <xsl:if test="position() = 1">
	      <xsl:text disable-output-escaping="yes">&lt;tr&gt;</xsl:text>
	    </xsl:if>
	    <td class="otherlinkouter">
	      <table class="linkrow" onMouseOver="mouse_over(this)" onMouseOut="mouse_out(this)">
		<xsl:attribute name="onClick">
		  <xsl:text>ahref('</xsl:text>
		  <xsl:choose>
		    <xsl:when test="preview">
		      <xsl:value-of select="preview" />
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="name" />
		    </xsl:otherwise>
		  </xsl:choose>
		  <xsl:text>')</xsl:text>
		</xsl:attribute>
		<tr>
		  <td class="otherlinkthumb">
		    <a class="otherthumblink">
		      <xsl:attribute name="href">
			<xsl:choose>
			  <xsl:when test="count(preview) &gt; 0">
			    <xsl:value-of select="preview" />
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:value-of select="name" />
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:attribute>
		      <img class="thumb" alt="Unknown file">
			<xsl:attribute name="src">
			  <xsl:choose>
			    <xsl:when test="thumb">
			      <xsl:value-of select="thumb" />
			    </xsl:when>
			    <xsl:when test="icon">
			      <xsl:value-of select="icon" />
			    </xsl:when>
			    <xsl:otherwise>
			      <xsl:text>/internal-gopher-unknown</xsl:text>
			    </xsl:otherwise>
			  </xsl:choose>
			</xsl:attribute>
		      </img>
		    </a>
		  </td>
		  <td class="otherlink">
		    <a class="otherlink">
		      <xsl:attribute name="href">
			<xsl:choose>
			  <xsl:when test="count(preview) &gt; 0">
			    <xsl:value-of select="preview" />
			  </xsl:when>
			  <xsl:otherwise>
			    <xsl:value-of select="name" />
			  </xsl:otherwise>
			</xsl:choose>
		      </xsl:attribute>
		      <xsl:value-of select="name" />
		    </a>
		    <br />
		    <span class="size">
		      <xsl:value-of select="date/day" />
		      <xsl:text>/</xsl:text>
		      <xsl:value-of select="date/month" />
		      <xsl:text>/</xsl:text>
		      <xsl:value-of select="date/year" />
		      <xsl:text> </xsl:text>
		      <xsl:value-of select="date/hour" />
		      <xsl:text>:</xsl:text>
		      <xsl:value-of select="date/minute" />
		      <xsl:text>:</xsl:text>
		      <xsl:value-of select="date/year" />
		      <br />
		      <xsl:text> (</xsl:text>
		      <xsl:value-of select="size" />
		      <xsl:if test="remove">
			<xsl:text> </xsl:text>
			<a class="file_remove">
			  <xsl:attribute name="href">
			    <xsl:value-of select="remove" />
			  </xsl:attribute>remove</a>
		      </xsl:if>
		      <xsl:text>)</xsl:text>
		    </span>
		  </td>
		</tr>
	      </table>
	    </td>
	    <xsl:choose>
	      <xsl:when test="position() = last()">
		<xsl:text disable-output-escaping="yes">&lt;/tr&gt;</xsl:text>
	      </xsl:when>
	      <xsl:when test="position() mod 4 = 0">
		<xsl:text disable-output-escaping="yes">&lt;/tr&gt;&lt;tr&gt;</xsl:text>
	      </xsl:when>
	    </xsl:choose>
	  </xsl:for-each>
	</table>
      </xsl:if>
    </body>
  </xsl:template>

  <xsl:template name="preview">
    <xsl:param name="previewpath" />
    <div xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" class="previewboxouter">
      <table class="previewbox">
	<tr>
	  <td class="previewimage" colspan="2">
	    <xsl:choose>
	      <xsl:when test="$previewpath/type = 'image'">
		<a class="previewlink" id="previewlink">
		  <xsl:attribute name="href">
		    <xsl:value-of select="$previewpath/name" />
		  </xsl:attribute>
		  <img class="image" id="theimage">
		    <xsl:attribute name="src">
		      <xsl:value-of select="$previewpath/image" />
		    </xsl:attribute>
		    <xsl:attribute name="alt">
		      <xsl:choose>
			<xsl:when test="$previewpath/comment">
			  <xsl:value-of select="$previewpath/comment" />
			</xsl:when>
			<xsl:otherwise>
			  <xsl:value-of select="$previewpath/name" />
			</xsl:otherwise>
		      </xsl:choose>
		    </xsl:attribute>
		  </img>
		</a>
	      </xsl:when> 
	      <xsl:when test="$previewpath/type = 'video'">
		<object standby="Loading video... please wait.">
		  <xsl:attribute name="data">
		    <xsl:value-of select="$previewpath/name" />
		  </xsl:attribute>
                  <xsl:attribute name="width">
                    <xsl:if test="$previewpath/x">
                      <xsl:value-of select="$previewpath/x" />
                    </xsl:if>
                  </xsl:attribute>
                  <xsl:attribute name="height">
                    <xsl:if test="$previewpath/y">
                      <xsl:value-of select="$previewpath/y" />
                    </xsl:if>
                  </xsl:attribute>
		</object>
	      </xsl:when>
	      <xsl:when test="$previewpath/type = 'audio'">
		<object standby="Loading audio... please wait.">
		  <xsl:attribute name="data">
		    <xsl:value-of select="$previewpath/name" />
		  </xsl:attribute>
		</object>
	      </xsl:when>
	    </xsl:choose>
	  </td>
	</tr>
	<tr>
	  <td class="previous">
	    <xsl:choose>
	      <xsl:when test="$previewpath/prev">
		<a class="previous">
		  <xsl:attribute name="href">
		    <xsl:value-of select="$previewpath/prev" />
		  </xsl:attribute>
		  <xsl:text>previous</xsl:text>
		</a>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text> </xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </td>
	  <td class="next">
	    <xsl:choose>
	      <xsl:when test="$previewpath/next">
		<a class="next">
		  <xsl:attribute name="href">
		    <xsl:value-of select="$previewpath/next" />
		  </xsl:attribute>
		  <xsl:text>next</xsl:text>
		</a>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:text> </xsl:text>
	      </xsl:otherwise>
	    </xsl:choose>
	  </td>
	</tr>
	<tr>
	  <td class="previewcaption" colspan="2">
	    <xsl:choose>
	      <xsl:when test="count($previewpath/exif/property) &gt; 0">
		<table class="exif">
		  <tr>
		    <td class="previewcaption">
		      <xsl:attribute name="rowspan">
			<xsl:value-of select="count($previewpath/exif/property) + 1" />
		      </xsl:attribute>
		      <a class="previewcaption">
			<xsl:attribute name="href">
			  <xsl:value-of select="$previewpath/name" />
			</xsl:attribute>
			<xsl:value-of select="$previewpath/name" />
		      </a>
		      <br />
		      <xsl:if test="$previewpath/comment">
			<div class="comment">
			  <xsl:value-of select="$previewpath/comment" />
			</div>
		      </xsl:if>
		    </td>
		    <td class="exifheading" colspan="2">
		      Photographic Information
		    </td>
		  </tr>
		  <xsl:for-each select="$previewpath/exif/property">
		    <tr>
		      <td class="exifkey">
			<xsl:value-of select="key" />
		      </td>
		      <td class="exifvalue">
			<xsl:value-of select="value" />
		      </td>
		    </tr>
		  </xsl:for-each>
		</table>
	      </xsl:when>
	      <xsl:otherwise>
		<a class="previewcaption">
		  <xsl:attribute name="href">
		    <xsl:value-of select="$previewpath/name" />
		  </xsl:attribute>
		  <xsl:value-of select="$previewpath/name" />
		</a>
		<br />
		<xsl:if test="$previewpath/comment">
		  <div class="comment">
		    <xsl:value-of select="$previewpath/comment" />
		  </div>
		</xsl:if>
	      </xsl:otherwise>
	    </xsl:choose>
	  </td>
	</tr>
      </table>
    </div>
  </xsl:template>

  <xsl:template name="exif_popup">
    <head>
      <title>Test page</title>
    </head>
    <body>
      Testing to see if this works.
    </body>
  </xsl:template>

</xsl:stylesheet>
