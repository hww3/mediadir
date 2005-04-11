

int thread_safe = 1;

#include <module.h>
inherit "module";
inherit "caudiumlib";

#if constant(Caudium.HTTP)
#define CAUDIUM14 1
#endif

constant cvs_version = "$Id: fsview.pike,v 1.1.1.1 2005-04-11 21:51:00 hww3 Exp $";
constant module_type = MODULE_DIRECTORIES;
constant module_name = "Media Directories";
constant module_doc  =
"This is a directory parsing module for Caudium 1.2/1.4 which will display "
"very pretty directory listings, including image thumbnails, image previews, "
"and audio/video streaming.<br />\n"
"<br />\n"
"This module relies heavily on XSLT processing for theming, and it is "
"recomended that you have a Pike XSL glue installed.<br />\n"
"<br />\n"
  "<ul>"
#if constant(PiXSL.Parser)
  "<li>You appear to have the Sablotron XSLT library installed, which will be used for "
  "rendering directory listings.</li>"
#elif constant(libxslt.Parser)
  "<li>You appera to have the libxslt library installed, which will be used for "
  "rendering directory listings.</li>"
#else
  "<li>You have no XSL library installed!  This module will serve the XML &amp; XSL data "
  "directly to the client, which will work with late model Mozilla's and Internet Explorers. "
  "It is stronly recomended that you install either Sablotron or libxslt and recompile "
  "Caudium to support it if you wish to use this module!"
#endif
  "</ul>";

  constant module_unique = 1;

#define EXPIRE 600
#ifdef CAUDIUM_CACHE
  // Yay!
#define MY_TTL 1200
#define MY_IMG_TTL -1
  inherit "cachelib";
  object cache;
#else
#define MY_TTL 1200
#define MY_IMG_TTL 3600
  string cache_key;
#endif
#define NEW_ICONS
#ifdef NEW_ICONS
  multiset icons;
#endif

  void create() {
    defvar(
	"indexfiles", 
	({ 
	 "index.html", "index.rxml", "index.cgi", "index.pike", "index.htm", "index.php",
	 "index.php3", "index.php4"
	 }),
	"Index Files",
	TYPE_STRING_LIST,
	"If one of these files is present in a directory, it will be returned "
	"instead of the directory listing."
	);
    defvar(
	"hiddenfiles",
	({
	 "dirstyle.css", "dirstyle.xsl"
	 }),
	"Hidden Files",
	TYPE_STRING_LIST,
	"Remove these files from the directory listings."
	);
    defvar(
	"show_readme",
	1,
	"README Files",
	TYPE_FLAG,
	"Display README files inline in directory listing."
	);
    defvar(
	"max_video_test",
	100,
	"Media Options: Max Video File Size (MB)",
	TYPE_INT,
	"This option tells Caudium the maximum video file size to allow previewing of."
	);
    defvar(
	"video_extensions",
	({ "mpg", "mpeg", "avi", "mov" }),
	"Media Options: Video Files",
	TYPE_STRING_LIST,
	"This option is available because Caudium is running in MAX_PERFORMANCE mode, which "
	"means that we will use a much faster, but less reliable method of deteching video "
	"files."
	);
    defvar(
	"video_size",
	"320x200",
	"Media Options: Target Video Size",
	TYPE_STRING,
	"The size to set the video pluging to."
	);
    defvar(
	"audio_extensions",
	({ "mp3", "wav", "ogg" }),
	"Media Options: Audio Files",
	TYPE_STRING_LIST,
	"This option helps Caudium to identify all the audio files in a directory"
	);
    defvar(
	"image_size",
	"320x200",
	"Media Options: Target Image Size",
	TYPE_STRING,
	"The size to rescale all images (keeping aspect) when displaying."
	);
    defvar(
	"thumb_size",
	"16x16",
	"Media Options: Target Thumbnail Size",
	TYPE_STRING,
	"The size to rescale all images (keeping aspect) when displaying thumbnails."
	);
    defvar(
	"max_image_test",
	10,
	"Media Options: Max Image File Size (MB)",
	TYPE_INT,
	"This option tells Caudium the maximum image file size on which it's allowed to perform an "
	"action, such as generating a thumbnail image"
	);
#if constant(Standards.EXIF)
    defvar(
	"extra_image_info",
	1,
	"Media Options: Extract EXIF Data",
	TYPE_FLAG,
	"Attempt to decode the EXIF properties from JPEG images.  EXIF is a format for embedding "
	"image meta information into images on devices like digital cameras.  Most commonly "
	"information about the camera state is stored when a picture is taken."
	);
#endif
#ifdef MAX_PERFORMANCE
    defvar(
	"image_extensions",
	({ "jpg", "jpeg", "png", "gif", "xcf" }),
	"Media Options: Image Files",
	TYPE_STRING_LIST,
	"This option is available because Caudium is running in MAX_PERFORMANCE mode, which "
	"means that we will use a much faster, but less reliable method of detecting image "
	"files."
	);
#endif
    defvar(
	"admin_mode",
	1,
	"Enable Admin Mode",
	TYPE_FLAG,
	"Enable the administration of files in the filesystem using the Media Directories "
	"module."
	);
    defvar(
	"admin_prestate",
	"admin",
	"Admin Mode: Prestate",
	TYPE_STRING,
	"The prestate used to switch Media Directories into admin mode.",
	admin_enabledp
	);
    defvar(
	"admin_user",
	({ "ANY" }),
	"Admin Mode: Valid Users",
	TYPE_STRING_LIST,
	"The name of the user who is allowed to modify the contents of the filesystem. "
	"Valid contents include, a list of usernames, ANY (which is any authenticated user) or "
	"NONE (which disallows all access). Authentication is done via  "
#ifdef CAUDIUM14
	"Caudium's in-built <a href=\"../../Master authentication and security\">Master authentication and security module</a>"
#else
	"whichever auth module you have enabled"
#endif
	"." //,
	//admin_enabledp
	);
    defvar(
	"admin_create_dirs",
	1,
	"Admin Mode: Allow Creating Directories",
	TYPE_FLAG,
	"Give the admin user(s) permission to create new directories",
	admin_enabledp
	);
    defvar(
	"admin_remove_dirs",
	1,
	"Admin Mode: Allow Removing Directories",
	TYPE_FLAG,
	"Give the admin user(s) permission to remove directories",
	admin_enabledp
	);
    defvar(
	"admin_upload_files",
	1,
	"Admin Mode: Allow Uploading Files",
	TYPE_FLAG,
	"Give the admin user(s) permission to upload new files",
	admin_enabledp
	);
    defvar(
	"admin_remove_files",
	1,
	"Admin Mode: Allow Removing Files",
	TYPE_FLAG,
	"Give the admin user(s) permission to remove files",
	admin_enabledp
	);
#ifdef NEW_ICONS
    defvar(
	"icon_dir",
	"../local/icons/",
	"Media Options: Extra Icon Directories",
	TYPE_STRING,
	"Directory to look for nice looking icons."
	);
#endif /* NEW_ICONS */
  }

void start(int c, object conf) {
#ifdef CAUDIUM_CACHE
  cache = caudium->cache_manager->get_cache(this_object());
#else
  cache_key = "fsview.pike:" + conf->name;
#endif
#ifdef NEW_ICONS
  array d = get_dir(QUERY(icon_dir));
  icons = (<>);
  if (arrayp(d) && sizeof(d)) {
    icons = mkmultiset(d);
  }
#endif /* NEW_ICONS */
}

void|mapping parse_directory(object id) {
  // Check that the URL ends with a /
  if (get_url(id)[-1] != '/')
#ifdef CAUDIUM14
    return Caudium.HTTP.redirect(Stdio.append_path(get_url(id), "/"), id);
#else
  return http_redirect(Stdio.append_path(get_url(id), "/"), id);
#endif

  // Maybe the directory has gone away... try and redirect to parent.
  if (!caudium->stat_file(id->not_query, id)) {
    string p = combine_path(get_url(id), "../");
    if (get_url(id) == p)
      return 0;
#ifdef CAUDIUM14
    return Caudium.HTTP.redirect(p, id);
#else
    return http_redirect(p, id);
#endif
  }

  if (QUERY(admin_mode)) {
    if (id->prestate[QUERY(admin_prestate)]) {
      /*
#ifdef CAUDIUM14
if (arrayp(id->auth)) {
multiset users = (multiset)QUERY(admin_user);
if (users["NONE"]) {
return Caudium.HTTP.auth_required("Media Directory Admin", 0, 1);
}
else if (users["ANY"]) {
if (!id->conf->auth_fun(id->auth[1], id->auth[2]))
return Caudium.HTTP.auth_required("Media Directory Admin", 0, 1);
}
else {
if (search(QUERY(admin_user), id->auth[1]) != -1) {
if (!id->conf->auth_fun(id->auth[1], id->auth[2]))
return Caudium.HTTP.auth_required("Media Directory Admin", 0, 1);
}
else {
return Caudium.HTTP.auth_required("Media Directory Admin", 0, 1);
}
}
}
else {
return Caudium.HTTP.auth_required("Media Directory Admin", 0, 1);
}
#else
    // how did we ever to get by without Bill?
    return http_auth_required("Media Directory Admin", 0, 1);
#endif
       */
    }
}

// Get the directory listing.
array d;
#ifdef CAUDIUM_CACHE
if (!id->pragma["no-cache"]) {
  d = cache->retrieve(get_url(id), ({ find_dir, id->not_query, id }));
  if (!d)
    d = find_dir(id->not_query, id);
}
else
d = find_dir(id->not_query, id);
#else
if (!id->pragma["no-cache"]) {
  d = cache_lookup(cache_key, id->not_query);
  if (!d)
    d = find_dir(id->not_query, id);
}
else 
d = find_dir(id->not_query, id);
#endif

// Find matching index files.
array idx = d - (d - QUERY(indexfiles));

// If there is an indexfile then return the _first_ index file returned.
if (sizeof(idx)) {
  // Rewrite not_query _safely_
  id->not_query = Stdio.append_path(get_url(id), idx[0]);
  return id->conf->low_get_file(id);
}

mapping r;
switch(id->variables->mode) {
  case "image":
    // Have we been asked for a particular image?
    if (id->variables->image && ((multiset)d)[id->variables->image]) {
      // The image would appear to exist.
      int x, y;
      sscanf(QUERY(image_size), "%dx%d", x, y);
      mapping i = get_image(id->variables->image, x, y, id);
      if (mappingp(i)) {
#ifdef CAUDIUM14
	r = Caudium.HTTP.string_answer(i->image, i->type);
	if (!r->extra_heads)
	  r->extra_heads = ([]);
	r->extra_heads["Expires"] = Caudium.HTTP.date(time() + EXPIRE);
	return r;
#else
	r = http_string_answer(i->image, i->type);
	if (!r->extra_heads)
	  r->extra_heads = ([]);
	r->extra_heads["Expires"] = http_date(time() + EXPIRE);
	return r;
#endif
      }
      else
	return 0;
    }
  break;
#ifdef NEW_ICONS
  case "icon":
    if (id->variables->icon && icons[sprintf("%s.png", id->variables->icon)]) {
      string file = Stdio.append_path(QUERY(icon_dir), sprintf("%s.png", id->variables->icon));
      /*
	 int x,y;
	 sscanf(QUERY(thumb_size), "%dx%d", x, y);
	 object img = Image.PNG.decode(Stdio.read_file(file));
	 img = safe_scale(img, x, y);
	 string i = Image.PNG.encode(img);
       */
      string i = Stdio.read_file(file);
      mapping r;
#ifdef CAUDIUM14
      r = Caudium.HTTP.string_answer(i, "image/png");
      if (!r->extra_heads)
	r->extra_heads = ([]);
      r->extra_heads["Expires"] = Caudium.HTTP.date(time() + EXPIRE);
      return r;
#else /* CAUDIUM14 */
      r = http_string_answer(i, "image/png");
      if (!r->extra_heads)
	r->extra_heads = ([]);
      r->extra_heads["Expires"] = http_date(time() + EXPIRE);
      return r;
#endif /* CAUDIUM14 */
    }
    else
      return 0;
  break;
#endif /* NEW_ICONS */
  case "thumb":
    // Have we been asked for a particular image?
    if (id->variables->image && ((multiset)d)[id->variables->image]) {
      // The image would appear to exist.
      int x,y;
      sscanf(QUERY(thumb_size), "%dx%d", x, y);
      mapping i = get_thumb(id->variables->image, x, y, id);
      if (mappingp(i)) {
#ifdef CAUDIUM14
	r = Caudium.HTTP.string_answer(i->image, i->type);
	if (!r->extra_heads)
	  r->extra_heads = ([]);
	if (!id->pragma["no-cache"])
	  r->extra_heads["Expires"] = Caudium.HTTP.date(time() + EXPIRE);
	return r;
#else
	r = http_string_answer(i->image, i->type);
	if (!r->extra_heads)
	  r->extra_heads = ([]);
	if (!id->pragma["no-cache"])
	  r->extra_heads["Expires"] = http_date(time() + EXPIRE);
	return r;
#endif
      }
      else
	return 0;
    }
  break;
  case "stylesheet":
#ifdef CAUDIUM14
    r = Caudium.HTTP.string_answer(get_stylesheet(get_url(id), id), "text/css");
  if (!r->extra_heads)
    r->extra_heads = ([]);
  if (!id->pragma["no-cache"])
    r->extra_heads["Expires"] = Caudium.HTTP.date(time() + EXPIRE);
  return r;
#else
  r = http_string_answer(get_stylesheet(get_url(id), id), "text/css");
  if (!r->extra_heads)
    r->extra_heads = ([]);
  if (!id->pragma["no-cache"])
    r->extra_heads["Expires"] = http_date(time() + EXPIRE);
  return r;
#endif
  break;
  case "xsl":
#ifdef CAUDIUM14
    return Caudium.HTTP.string_answer(get_xsl(get_url(id), id), "text/xml");
#else
  return http_string_answer(get_xsl(get_url(id), id), "text/xml");
#endif
  break;
  case "xml":
#ifdef CAUDIUM14
    return Caudium.HTTP.string_answer(get_xml(get_url(id), id, d), "text/xml");
#else
  return http_string_answer(get_xml(get_url(id), id, d), "text/xml");
#endif
  break;
  default:
  string s = get_page(get_url(id), id, d);
  string type = "text/html";
  if (!stringp(s)) {
    s = get_xml(get_url(id), id, d);
    type = "text/xml";
  }
#ifdef CAUDIUM14
  r = Caudium.HTTP.string_answer(s, type);
  if (!r->extra_heads)
    r->extra_heads = ([]);
  if (!id->pragma["no-cache"])
    r->extra_heads["Expires"] = Caudium.HTTP.date(time() + EXPIRE);
  return r;
#else
  r = http_string_answer(s, type);
  if (!r->extra_heads)
    r->extra_heads = ([]);
  if (!id->pragma["no-cache"])
    r->extra_heads["Expires"] = http_date(time() + EXPIRE);
  return r;
#endif
  break;
}
}

static int|array find_dir(string path, object id) {
  // Quick wrapper to cache directory listings if possible.
  array d = id->conf->find_dir(path, id);
  if (!arrayp(d))
    d = ({});

  // Remove hidden files.
  d -= QUERY(hiddenfiles);
#ifdef CAUDIUM_CACHE
  cache->store(cache_pike(d, path, MY_TTL));
#else
  //cache_set(cache_key, path, d, MY_TTL);
#endif
  return d;
}

static int|string get_file(string path, object id) {
  string s;
  catch (s = id->conf->try_get_file(path, id));

#ifdef CAUDIUM_CACHE
  cache->store(cache_pike(s, path, MY_TTL));
#else
  // cache_set(cache_key, path, s, MY_TTL);
#endif
  return s;
}

static void|string get_page(string path, object id, array d) {
  string retval;
#ifdef CAUDIUM_CACHE
  if (!id->pragma["no-cache"]) {
    retval = cache->retrieve(sprintf("xsl_rendered=%s", id->raw_url));
    if (stringp(retval))
      return retval;
  }
#else
  if (!id->pragma["no-cache"]) {
    retval = cache_lookup(cache_key, sprintf("xsl_rendered=%s", id->raw_url));
    if (stringp(retval))
      return retval;
  }
#endif
#if constant(PiXSL.Parser)
  object parser = PiXSL.Parser();
#elif constnat(libxslt.Parser)
  object parser = libxslt.Parser();
#endif
#if constant(PiXSL.Parser) || constant(libxslt.Parser)
  retval = get_xml(path, id, d);
  parser->set_xsl_data(get_xsl(path, id));
  parser->set_xml_data(retval);
  parser->set_variables(id->variables);
  string|mapping res;
  mixed err;
  if (err = catch(res = parser->run())) {
    res = parser->error();

    if(mappingp(res)) {
      int line = (int)res->line, sline, eline;
      string line_emph="";
      array lines;
      if(!res->URI) res->URI = "unknown file";
      if(search(res->URI, "xsl") != -1) {
	res->URI = "XSLT input <i>" + get_url(id) + "?mode=xsl</i>";
	if(line) lines = get_xsl(path, id) / "\n";
      }
      else if(search(res->URI, "xml") != -1) {
	res->URI = "XML source data";
	if(line) lines = retval / "\n";
      }
      if(lines) {
	line--;
	sline = max(line - 3, 0);
	eline = min(sizeof(lines), sline + 7);
	line_emph="<h3>Extract of incorrect line</h3>";
	for(int i = sline; i < eline; i++) {
	  if(i == line) {
	    line_emph += "<b>"+(i+1)+": <font size=+3>"+
	      _Roxen.html_encode_string(lines[i])+"</font></b><br>";
	  }
	  else {
	    line_emph += "<b>"+(i+1)+"</b>: "+
	      _Roxen.html_encode_string(lines[i])+"<br>";
	  }
	}
      }
      else if ( !objectp(res) ) 
      {
	werror("Error on XSL:\n"+sprintf("%O\n", err)+"\n");
	return "<b>ERROR:</b><XSLT Parsing failed with unknown error.<false>";
      }

      return 
	sprintf("<b>%s:</b> XSLT Parsing failed with %serror code %s on<br>\n"
	    "line %s in %s:<br>\n%s<p>%s<br>\n<false>",
	    res->level||upper_case(res->msgtype||"ERROR"), 
	    (res->module ? res->module + " " : ""),
	    res->code || "???",
	    res->line || "???",
	    res->URI || "unknown file",
	    res->msg || "Unknown error", line_emph);
    }
  }
#ifdef CAUDIUM_CACHE
  cache->store(cache_string(res, sprintf("xsl_rendered=%s", id->raw_url), MY_TTL));
#else
  // cache_set(cache_key, sprintf("xsl_rendered=%s", id->raw_url), res, MY_TTL);
#endif
  return res||"<b>ERROR:</b> Nothing returned by the XSLT parser";
#else
  return 0;
#endif
}

static string get_xml(string path, object id, array d) {
  string readme;
  if (((multiset)d)["README"]) {
    catch(readme = id->conf->try_get_file(Stdio.append_path(path, "README"), id));
    d -= ({ "README" });
  }
  mapping list = ponder(d, id->not_query, id);
  string retval =
    "<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>\n"
    //"<?xml-stylesheet type=\"text/xsl\" href=\"" + get_url(id) + "?mode=xsl\" ?>\n\n"
    "<page>\n"
    "<caudium_version>" + encode_entities(caudium->version()) + "</caudium_version>\n"
    "<stylesheet_url>" + encode_entities(sprintf("%s?mode=stylesheet", get_url(id))) + "</stylesheet_url>\n"
    "<heading>\n";
  if (sizeof(id->prestate))
    retval +=
      "<link>\n<name>/</name>\n<url>/(" + ((array)id->prestate * ",") + ")/</url>\n</link>\n";
  else
    retval +=
      "<link>\n<name>/</name>\n<url>/</url>\n</link>\n";
  array tmp = explode_path(id->not_query) - ({ "" });
  for(int i = 0; i < sizeof(tmp); i++) {
    string part = tmp[i];
    string url;
    array p = ({ "/" });
    if (sizeof(id->prestate)) {
      p += ({ "(" + ((array)id->prestate * ",") + ")" });
    }
    if (i)
      p += tmp[0..i];
    else
      p += ({ tmp[0] });
    p+= ({ "/" });
    url = Stdio.append_path(@p);
    retval +=
      "<link>\n<name>" + encode_entities(part) + "</name>\n<url>" + encode_entities(url) + "</url>\n</link>\n";
  }
  retval += "</heading>\n";
  retval += "<subdirectories>\n";
  mapping i = mkmapping(list->images, allocate(sizeof(list->images), "image"));
  mapping v = mkmapping(list->videos, allocate(sizeof(list->videos), "video"));
  mapping a = mkmapping(list->audio, allocate(sizeof(list->audio), "audio"));
  mapping media = i + v + a;
  foreach(sort(list->directories), string dir) {
    array d = find_dir(Stdio.append_path(id->not_query, dir), id);
    array s = caudium->stat_file(Stdio.append_path(id->not_query, dir), id);
    mapping l = localtime(s[4]);
    retval += 
      "<directory>\n"
      "<name>" + encode_entities(dir) + "</name>\n"
      "<items>" + (string)sizeof(d) + "</items>\n";
#ifdef NEW_ICONS
    retval +=
      "<icon>" + sprintf("%s?mode=icon&amp;icon=_folder", id->not_query) + "</icon>\n";
#endif
    retval += sprintf(
	"<date>\n"
	"<second>%02d</second>\n"
	"<minute>%02d</minute>\n"
	"<hour>%02d</hour>\n"
	"<day>%02d</day>\n"
	"<year>%d</year>\n"
	"<month>%02d</month>\n"
	"<unix>%d</unix>\n"
	"</date>\n", l->sec, l->min, l->hour, l->mday, l->year + 1900, l->mon + 1, s[4]);
    if (QUERY(admin_mode) && id->prestate[QUERY(admin_prestate)]) {
      retval += 
	"<remove>" + encode_entities(get_url(id)) + "?mode=remove_dir&amp;dir=" +
	encode_entities(dir) + "</remove>\n";
    }
    retval += "</directory>\n";
  }
  retval += "</subdirectories>\n";

  // Add the readme file to the document
  if (stringp(readme))
    retval += "<readme>" + encode_entities(readme) + "</readme>";

  // Admin permissions
  if (QUERY(admin_mode) && id->prestate[QUERY(admin_prestate)]) {
    // We're in admin mode.
    retval +=
      "<admin>\n"
      "<permissions>\n"
      "<priv name=\"create_dirs\">" + (QUERY(admin_create_dirs)?"TRUE":"FALSE") + "</priv>\n"
      "<priv name=\"remove_dirs\">" + (QUERY(admin_remove_dirs)?"TRUE":"FALSE") + "</priv>\n"
      "<priv name=\"upload_files\">" + (QUERY(admin_upload_files)?"TRUE":"FALSE") + "</priv>\n"
      "<priv name=\"remove_files\">" + (QUERY(admin_remove_files)?"TRUE":"FALSE") + "</priv>\n"
      "</permissions>\n"
      "</admin>\n";
  }

  if (id->variables->mode && (id->variables->mode == "preview")) {
    array _m = sort(indices(media));
    int pos = search(_m, (id->variables->image||id->variables->audio||id->variables->video));
    int next, prev;
    next = prev = -1;
    if (pos == 0) {
      if (sizeof(_m) > 1)
	next = 1;
    }
    else if (pos == sizeof(_m) -1) {
      if (pos - 1 >= 0)
	prev = pos - 1;
    }
    else if (pos > 0) {
      if (pos + 1 < sizeof(_m))
	next = pos + 1;
      if (pos - 1 >= 0)
	prev = pos - 1;
    }
    if (id->variables->image && (((multiset)list->images)[id->variables->image])) {
      array s = caudium->stat_file(Stdio.append_path(get_url(id), id->variables->image), id);
      if (!arrayp(s)) {
	m_delete(media, id->variables->image);
      }
      else {
	if (!QUERY(max_image_test) || (s[1] < QUERY(max_image_test) * 1048576)) {
	  string c = get_comment(Stdio.append_path(get_url(id), id->variables->image), id);
	  retval += 
	    "<default>\n"
	    "<name>" + encode_entities(id->variables->image) + "</name>\n"
	    "<type>" + encode_entities(media[id->variables->image]) + "</type>\n"
	    "<size>" + encode_entities(size(s)) + "</size>\n"
	    "<preview>" + encode_entities(get_url(id) + "?mode=preview&image=" + id->variables->image) + "</preview>\n"
	    "<image>" + encode_entities(get_url(id) + "?mode=image&image=" + id->variables->image) + "</image>\n"
	    "<thumb>" + encode_entities(get_url(id) + "?mode=thumb&image=" + id->variables->image) + "</thumb>\n";
	  if (stringp(c))
	    retval += 
	      "<comment>" + encode_entities(c) + "</comment>"; 
	  if (next != -1) 
	    retval +=
	      "<next>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[next]] + "=" + _m[next]) + "</next>\n";
	  if (prev != -1)
	    retval +=
	      "<prev>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[prev]] + "=" + _m[prev]) + "</prev>\n";
#if constant(Standards.EXIF)
	  mapping exif = get_exif(Stdio.append_path(get_url(id), id->variables->image), id);
	  if (mappingp(exif)) {
	    retval += "<exif>\n";
	    foreach(sort(indices(exif)), string exifkey) {
	      retval += 
		"<property>\n"
		"<key>" + encode_entities(exifkey) + "</key>\n"
		"<value>" + encode_entities((string)exif[exifkey]) + "</value>\n"
		"</property>\n";
	    }
	    retval += "</exif>\n";
	  }
#endif
	  retval +=
	    "</default>\n";
	}
      }
    }
    else if (id->variables->video && (((multiset)list->videos)[id->variables->video])) {
      array s = caudium->stat_file(Stdio.append_path(get_url(id), id->variables->video), id);
      if (!arrayp(s)) {
	m_delete(media, id->variables->video);
      }
      else {
	if (!QUERY(max_video_test) || (s[1] < QUERY(max_video_test) * 1048576)) {
	  string format = (id->conf->type_from_filename(id->variables->video, id)[0] / "/")[1];
	  int x, y;
	  sscanf(QUERY(video_size), "%dx%d", x, y);
	  retval += 
	    "<default>\n"
	    "<name>" + encode_entities(id->variables->video) + "</name>\n"
	    "<type>" + encode_entities(media[id->variables->video]) + "</type>\n"
	    "<size>" + encode_entities(size(s)) + "</size>\n"
	    "<format>" + encode_entities(format) + "</format>\n"
	    "<preview>" + encode_entities(get_url(id) + "?mode=preview&video=" + id->variables->video) + "</preview>\n";
	  if (next != -1) 
	    retval +=
	      "<next>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[next]] + "=" + _m[next]) + "</next>\n";
	  if (prev != -1)
	    retval +=
	      "<prev>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[prev]] + "=" + _m[prev]) + "</prev>\n";
	  if (x && y)
	    retval +=
	      "<x>" + (string)x + "</x>\n<y>" + (string)y + "</y>\n";
	  retval +=
	    "</default>\n";
	}
      }
    }
    else if (id->variables->audio && (((multiset)list->audio)[id->variables->audio])) {
      array s = caudium->stat_file(Stdio.append_path(get_url(id), id->variables->audio), id);
      if (!arrayp(s)) {
	m_delete(media, id->variables->audio);
      }
      else {
	string format = (id->conf->type_from_filename(id->variables->audio, id)[0] / "/")[1];
	retval += 
	  "<default>\n"
	  "<name>" + encode_entities(id->variables->audio) + "</name>\n"
	  "<type>" + encode_entities(media[id->variables->audio]) + "</type>\n"
	  "<size>" + encode_entities(size(s)) + "</size>\n"
	  "<format>" + encode_entities(format) + "</format>\n"
	  "<preview>" + encode_entities(get_url(id) + "?mode=preview&audio=" + id->variables->audio) + "</preview>\n";
	if (next != -1) 
	  retval +=
	    "<next>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[next]] + "=" + _m[next]) + "</next>\n";
	if (prev != -1)
	  retval +=
	    "<prev>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[prev]] + "=" + _m[prev]) + "</prev>\n";
	retval +=
	  "</default>\n";
      }
    }
  }
  retval += "<media>\n";
  foreach(sort(indices(media)), string idx) {
    array s = caudium->stat_file(Stdio.append_path(id->not_query, idx), id);
    if (!arrayp(s)) {
      m_delete(media, idx);
      continue;
    }
    array _m = sort(indices(media));
    int pos = search(_m, idx);
    int next, prev;
    next = prev = -1;
    if (pos == 0) {
      if (sizeof(_m) > 1)
	next = 1;
    }
    else if (pos == sizeof(_m) -1) {
      if (pos - 1 >= 0)
	prev = pos - 1;
    }
    else if (pos > 0) {
      if (pos + 1 < sizeof(_m))
	next = pos + 1;
      if (pos - 1 >= 0)
	prev = pos - 1;
    }
    retval +=
      "<file>\n"
      "<name>" + encode_entities(idx) + "</name>\n"
      "<type>" + encode_entities(media[idx]) + "</type>\n"
      "<size>" + encode_entities(size(s)) + "</size>\n";
#ifdef NEW_ICONS
    array _ext = idx / ".";
    string ext = lower_case(_ext[sizeof(_ext)-1]);
    if (icons[sprintf("%s.png", ext)])
      retval +=
	"<icon>" + sprintf("%s?mode=icon&amp;icon=%s", id->not_query, ext) + "</icon>\n";
    else
      retval += 
	"<icon>" + sprintf("%s?mode=icon&amp;icon=_image", id->not_query) + "</icon>\n";
#endif
    if (media[idx] == "image") { 
      if (!QUERY(max_image_test) || (s[1] < QUERY(max_image_test) * 1048576))
	retval +=
	  "<preview>" + encode_entities(id->not_query + "?mode=preview&image=" + idx) + "</preview>\n"
	  "<image>" + encode_entities(id->not_query + "?mode=image&image=" + idx) + "</image>\n"
	  "<thumb>" + encode_entities(id->not_query + "?mode=thumb&image=" + idx) + "</thumb>\n";
      string c = get_comment(Stdio.append_path(id->not_query, idx), id);
      if (stringp(c))
	retval +=
	  "<comment>" + encode_entities(c) + "</comment>\n";
#if constant(Standards.EXIF)
      mapping exif = get_exif(Stdio.append_path(get_url(id), idx), id);
      if (mappingp(exif)) {
	retval += "<exif>\n";
	foreach(sort(indices(exif)), string exifkey) {
	  retval += 
	    "<property>\n"
	    "<key>" + encode_entities(exifkey) + "</key>\n"
	    "<value>" + encode_entities((string)exif[exifkey]) + "</value>\n"
	    "</property>\n";
	}
	retval += "</exif>\n";
      }
#endif
    }
    if (media[idx] == "video") {
      string format = (id->conf->type_from_filename(idx, id)[0] / "/")[1];
      retval += 
	"<format>" + encode_entities(format) + "</format>\n";
      if (!QUERY(max_video_test) || (s[1] < QUERY(max_video_test) * 1048576)) {
	int x, y;
	sscanf(QUERY(video_size), "%dx%d", x, y);
	if (x && y)
	  retval +=
	    "<x>" + (string)x + "</x>\n<y>" + (string)y + "</y>\n";
	retval +=
	  "<preview>" + encode_entities(get_url(id) + "?mode=preview&video=" + idx) + "</preview>\n";
      }
    }
    if (media[idx] == "audio") {
      string format = (id->conf->type_from_filename(idx, id)[0] / "/")[1];
      retval +=
	"<format>" + encode_entities(format) + "</format>\n"
	"<preview>" + encode_entities(get_url(id) + "?mode=preview&audio=" + idx) + "</preview>\n";
    }
    mapping l = localtime(s[4]);
    retval += sprintf(
	"<date>\n"
	"<second>%02d</second>\n"
	"<minute>%02d</minute>\n"
	"<hour>%02d</hour>\n"
	"<day>%02d</day>\n"
	"<year>%d</year>\n"
	"<month>%02d</month>\n"
	"<unix>%d</unix>\n"
	"</date>\n", l->sec, l->min, l->hour, l->mday, l->year + 1900, l->mon + 1, s[4]);

    if (next != -1) 
      retval +=
	"<next>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[next]] + "=" + _m[next]) + "</next>\n";
    if (prev != -1)
      retval +=
	"<prev>" + encode_entities(get_url(id) + "?mode=preview&" + media[_m[prev]] + "=" + _m[prev]) + "</prev>\n";
    if (QUERY(admin_mode) && id->prestate[QUERY(admin_prestate)]) {
      retval +=
	"<remove>" + encode_entities(get_url(id)) + "?mode=remove_file&amp;file=" + 
	encode_entities(idx) + "</remove>\n";
    }
    retval += "</file>\n";
  }
  retval += "</media>\n<files>\n";
  foreach(list->others, string idx) {
    array s = caudium->stat_file(Stdio.append_path(id->not_query, idx), id);
    mapping l = localtime(s[4]);
    retval +=
      "<file>\n"
      "<name>" + encode_entities(idx) + "</name>\n"
      "<size>" + encode_entities(size(s)) + "</size>\n"
      "<type>" + encode_entities(id->conf->type_from_filename(idx, id)[0]) + "</type>\n";
#ifdef NEW_ICONS
    array _ext = idx / ".";
    string ext = lower_case(_ext[sizeof(_ext)-1]);
    if (icons[sprintf("%s.png", ext)])
      retval += 
	"<icon>" + sprintf("%s?mode=icon&amp;icon=%s", id->not_query, ext) + "</icon>\n";
    else
      retval +=
	"<icon>" + sprintf("%s?mode=icon&amp;icon=_other", id->not_query) + "</icon>\n";
#endif
    retval += sprintf(
	"<date>\n"
	"<second>%02d</second>\n"
	"<minute>%02d</minute>\n"
	"<hour>%02d</hour>\n"
	"<day>%02d</day>\n"
	"<year>%d</year>\n"
	"<month>%02d</month>\n"
	"<unix>%d</unix>\n"
	"</date>\n", l->sec, l->min, l->hour, l->mday, l->year + 1900, l->mon + 1, s[4]);

    if (QUERY(admin_mode) && id->prestate[QUERY(admin_prestate)]) {
      retval +=
	"<remove>" + encode_entities(get_url(id)) + "?mode=remove_file&amp;file=" +
	encode_entities(idx) + "</remove>\n";
    }
    retval +=
      "</file>\n";
  }
  retval += "</files>\n";
  retval += "</page>\n";
  return retval;
}

void|string get_comment(string path, object id) {
  string s;
  mapping img;
  string comment;
#ifdef CAUDIUM_CACHE
  if (!id->pragma["no-cache"])
    img = cache->retrieve(sprintf("comment=%s", path));
  if (!mappingp(img)) {
#else
    if (!id->pragma["no-cache"])
      img = cache_lookup(cache_key, sprintf("comment=%s", path));
    if (!mappingp(img)) {
#endif
      catch(s = id->conf->try_get_file(path, id));
      if (!stringp(s))
	return 0;
      catch(img = Image.ANY.decode_header(s));
      if (mappingp(img) && img->comment)
	comment = img->comment;
      if (!stringp(comment))
	return 0;
#ifdef CAUDIUM_CACHE
    }
    cache->store(cache_string(comment, sprintf("comment=%s", path), MY_TTL));
#else
  }
  // cache_set(cache_key, sprintf("comment=%s", path), comment, MY_TTL);
#endif
  return comment;
}

#if constant(Standards.EXIF)
  void|mapping get_exif(string path, object id) {
    if (!QUERY(extra_image_info))
      return 0;
    string s;
    mapping exif;
#ifdef CAUDIUM_CACHE
    if (!id->pragma["no-cache"])
      exif = cache->retrieve(sprintf("exif=%s", path));
    if (!mappingp(exif)) {
#else
      if (!id->pragma["no-cache"])
	exif = cache_lookup(cache_key, sprintf("exif=%s", path));
      if (!mappingp(exif)) {
#endif
	catch(s = id->conf->try_get_file(path, id));
	if (!stringp(s))
	  return 0;
#if constant(Stdio.FakeFile)
	object f = Stdio.FakeFile(s);
#else
	object in = Stdio.File();
	object f = in->pipe();
	in->set_nonblocking();
	in->write(s);
	in->close();
#endif
	mapping _exif;
	catch(_exif = Standards.EXIF.get_properties(f));
	if (!mappingp(_exif))
	  return 0;

	if (_exif["UserComment"] && (sizeof(_exif["UserComment"] / "\0") > 1))
	  m_delete(_exif, "UserComment");

	exif = ([]);
	if (_exif["DateTime"])
	  exif["Capture Time"] = _exif["DateTime"];
	if (_exif["ExposureMode"])
	  exif["ExposureMode"] = _exif["ExposureMode"];
	if (_exif["ExposureTime"])
	  exif["ExposureTime"] = _exif["ExposureTime"];
	if (_exif["Flash"])
	  exif["Flash"] = _exif["Flash"];
	if (_exif["Make"])
	  exif["Camera Make"] = _exif["Make"];
	if (_exif["Model"])
	  exif["Camera Model"] = _exif["Model"];
	if (_exif["ISOSpeedRating"])
	  exif["Film Speed"] = _exif["ISOSpeedRating"];
	if (_exif["WhiteBalance"])
	  exif["White Balance"] = _exif["WhiteBalance"];

#ifdef CAUDIUM_CACHE
      }
      cache->store(cache_string(exif, sprintf("exif=%s", path), MY_TTL));
#else
    }
    // cache_set(cache_key, sprintf("exif=%s", path), exif, MY_TTL);
#endif
    return exif;
  }
#endif

static int|mapping get_thumb(string path, int x, int y, object id) {
#ifdef NEW_ICONS
  mapping r;
  if (!id->pragma["no-cache"]) {
#ifdef CAUDIUM_CACHE
    r = cache->retrieve(Stdio.append_path(get_url(id), path, "thumb"));
#else
    r = cache_lookup(cache_key, Stdio.append_path(get_url(id), path, "thumb"));
#endif /* CAUDIUM_CACHE */
    if (mappingp(r))
      return r;
  }

  int _x, _y;
  string file = Stdio.append_path(QUERY(icon_dir), "_image_template.png");
  object template = Image.PNG.decode(Stdio.read_file(file));
  _x = template->xsize();
  _y = template->ysize();
  mapping i = get_image(path, 32, 30, id);
  object thumb = i->obj;
  object bg = Image.Image(_x, _y);
  int posx, posy;
  if (thumb->xsize() < _x)
    posx = (_x - thumb->xsize()) / 2;
  if (thumb->ysize() < _y)
    posy = (_y - thumb->ysize()) / 2;
  bg->paste(template);
  object border = Image.Image(thumb->xsize() + 4, thumb->ysize() + 4, Image.Color("black"));
  border->line(0, 1, 0, border->ysize() - 1, 171, 171, 171);
  border->line(0, 0, 0, 0, 156, 156, 156);
  border->line(1, 0, border->xsize() -1, 0, 171, 171, 171);
  border->line(border->xsize() - 1, 1, border->xsize() - 1, border->ysize() - 1, 255, 255, 255);
  border->line(1, border->ysize() - 1, border->xsize() - 1, border->ysize() - 1, 255, 255, 255);
  if (border->xsize() < _x)
    posx = (_x - border->xsize()) / 2;
  if (border->ysize() < _y)
    posy = (_y - border->ysize()) / 2;
  border->paste(thumb, 2, 2);
  bg->paste(border, posx -1, posy -2);
  string png = Image.PNG.encode(bg);
  r = ([ "type" : "image/png", "obj" : bg, "image" : png ]);
#ifdef CAUDIUM_CACHE
  cache->store(cache_pike(r, Stdio.append_path(get_url(id), path, "thumb"), MY_IMG_TTL));
#else
  // cache_set(cache_key, Stdio.append_path(get_url(id), path, "thumb"), r, MY_IMG_TTL);
#endif /* CAUDIUM_CACHE */
  return r;
#else
  return get_image(path, x, y, id);
#endif
}

static int|mapping get_image(string path, int x, int y, object id) {
  // First, get the image from the filesystem.
  string s;
  object img;
#ifdef CAUDIUM_CACHE
  if (!id->pragma["no-cache"])
    img = cache->retrieve(Stdio.append_path(get_url(id), path, sprintf("%dx%d", x, y)));
  if (!objectp(img)) {
#else
    if (!id->pragma["no-cache"])
      img = cache_lookup(cache_key, Stdio.append_path(get_url(id), path, sprintf("%dx%d", x, y)));
    if (!objectp(img)) {
#endif
      catch(s = id->conf->try_get_file(Stdio.append_path(get_url(id), path), id));
      if (!stringp(s))
	return 0;
      catch(img = Image.ANY.decode(s));
      if (!objectp(img))
	return 0;

      if (x && y)
	img = safe_scale(img, x, y);

#ifdef CAUDIUM_CACHE
    }
    cache->store(cache_image(img, Stdio.append_path(get_url(id), path, sprintf("%dx%d", x, y)), MY_IMG_TTL));
#else
  }
  // cache_set(cache_key, Stdio.append_path(get_url(id), path, sprintf("%dx%d", x, y)), img, MY_IMG_TTL);
#endif

  string m = id->conf->type_from_filename(Stdio.append_path(get_url(id), path), id)[0];
  mapping r = ([ "type" : m, "obj" : img ]);
  switch(m) {
    case "image/jpeg":
      r->image = Image.JPEG.encode(img);
    break;
#if constant(Image.GIF)
    case "image/gif":
      r->image = Image.GIF.encode(img);
    break;
#endif
    case "image/png":
    default:
      r->image = Image.PNG.encode(img);
      r->type = "image/png";
      break;
  }

  if (r->image)
    return r;
  else
    return 0;
}

static object safe_scale(object img, int x, int y) {
  if (img->xsize() == img->ysize()) {
    // Image is square.
    if (x < y)
      if (img->xsize() <= x)
	return img;
      else
	img = img->scale(x, x);
    else 
      if (img->ysize() <= y)
	return img;
      else
	img = img->scale(y, y);
  }

  if (img->xsize() > img->ysize()) {
    // Image is landscape.

    if (img->xsize() <= x)
      // Don't rescale, it's already smaller than the target size.
      return img;

    float ratio;
    int newx, newy;
    if (x < y) {
      // Target is portrait.
      ratio = (float)y / (float)img->ysize();
      newy = y;
      newx = (int)(img->xsize() * ratio);
    }
    else {
      // Target is landscape or square.
      ratio = (float)x / (float)img->xsize();
      newy = (int)(img->ysize() * ratio);
      newx = x;
    }
    img = img->scale(newx, newy);
  }

  if (img->ysize() > img->xsize()) {
    // Image is portrait.

    if (img->ysize() <= y)
      // Don't rescale, it's already smaller than the target size.
      return img;

    float ratio;
    int newx, newy;
    if (x > y) {
      // Target is landscape.
      ratio = (float)y / (float)img->ysize();
      newy = y;
      newx = (int)(img->xsize() * ratio);
    }
    else {
      // Target is portrait or square.
      ratio = (float)x / (float)img->xsize();
      newy = (int)(img->ysize() * ratio);
      newx = x;
    }
    img = img->scale(newx, newy);
  }
  return img;
}

string get_stylesheet(string path, object id) {
  array p = explode_path(path);
  string s;
  for(int i = sizeof(p) - 1; i >= 0; i--) {
    array tmp = p[0..i] + ({ "dirstyle.css" });
    s = id->conf->try_get_file(Stdio.append_path(@tmp), id);
    if (stringp(s))
      break;
  }
  if (stringp(s))
    return s;
  else
    return (#string "fsview.css");
}

string get_xsl(string path, object id) {
  array p = explode_path(path);
  string s;
  for (int i = sizeof(p) - 1; i >= 0; i--) {
    array tmp = p[0..i] + ({ "dirstyle.xsl" });
    s = id->conf->try_get_file(Stdio.append_path(@tmp), id);
    if (stringp(s))
      break;
  }
  if (stringp(s))
    return s;
  else
    return (#string "fsview.xsl");
}

void|string image_detect(string path, object id) {
  string cpath = sprintf("type=%s", path);
  if (!id->pragma["no-cache"]) {
#ifdef CAUDIUM_CACHE
    string result = cache->retrieve(cpath);
#else
    string result = cache_lookup(cache_key, cpath);
#endif
    if (stringp(result) && sizeof(result)) {
      switch(result) {
	case "image":
	  return path;
	default:
	  return 0;
      }
    }
  }
#ifdef MAX_PERFORMANCE
  if (!sizeof(path)) {
    return 0;
  }
  array tmp = path / ".";
  if (!sizeof(tmp))
    return 0;
  string ext = lower_case(tmp[sizeof(tmp) - 1]);
  if (!((multiset)QUERY(image_extensions))[ext])
    return 0;
#else
  if (QUERY(max_image_test) && (caudium->stat_file(path, id)[1] > QUERY(max_image_test) * 1049600))
    return 0;
  string s = get_file(path, id);
  if (!stringp(s))
    return 0;
  mixed i;
  if ((catch(i = Image.ANY.decode_header(s))) &&
      (catch(i = Image.ANY.decode(s))))
    return 0;
  if (mappingp(i) && i->comment)
#ifdef CAUDIUM_CACHE
    cache->store(cache_string(i->comment, sprintf("comment=%s", path), MY_TTL));
#else
  // cache_set(cache_key, sprintf("comment=%s", path), i->comment, MY_TTL);
#endif /* CAUDIUM_CACHE */
#endif /* MAX_PERFORMANCE */
#ifdef CAUDIUM_CACHE
  cache->store(cache_string("image", cpath, MY_TTL));
#else
  cache_set(cache_key, cpath, "image", MY_TTL);
#endif
  return path;
}

void|string video_detect(string path, object id) {
  string cpath = sprintf("type=%s", path);
  if (!id->pragma["no-cache"]) {
#ifdef CAUDIUM_CACHE
    string result = cache->retrieve(cpath);
#else
    string result = cache_lookup(cache_key, cpath);
#endif
    if (stringp(result) && sizeof(result)) {
      switch(result) {
	case "video":
	  return path;
	default:
	return 0;
      }
    }
  }
  if (!sizeof(path))
    return 0;
  array tmp = path / ".";
  if (!sizeof(tmp))
    return 0;
  string ext = lower_case(tmp[sizeof(tmp) - 1]);
  if (!((multiset)QUERY(video_extensions))[ext])
    return 0;
#ifdef CAUDIUM_CACHE
  cache->store(cache_string("video", cpath, MY_TTL));
#else
  // cache_set(cache_key, cpath, "video", MY_TTL);
#endif
  return path;
}

void|string audio_detect(string path, object id) {
  string cpath = sprintf("type=%s", path);
  if (!id->pragma["no-cache"]) {
#ifdef CAUDIUM_CACHE
    string result = cache->retrieve(cpath);
#else
    string result = cache_lookup(cache_key, cpath);
#endif
    if (stringp(result) && sizeof(result)) {
      switch (result) {
	case "audio":
	  return path;
	default:
	return 0;
      }
    }
  }
  if (!sizeof(path))
    return 0;
  array tmp = path / ".";
  if (!sizeof(tmp))
    return 0;
  string ext = lower_case(tmp[sizeof(tmp) - 1]);
  if (!((multiset)QUERY(audio_extensions))[ext])
    return 0;
#ifdef CAUDIUM_CACHE
  cache->store(cache_string("audio", cpath, MY_TTL));
#else
  // cache_set(cache_key, cpath, "audio", MY_TTL);
#endif
  return path;
}

void|string directory_detect(string path, object id) {
  string cpath = sprintf("type=%s", path);
  if (!id->pragma["no-cache"]) {
#ifdef CAUDIUM_CACHE
    string result = cache->retrieve(cpath);
#else
    string result = cache_lookup(cache_key, cpath);
#endif
    if (stringp(result) && sizeof(result)) {
      switch(result) {
	case "directory":
	  return path;
	default:
	return 0;
      }
    }
  }
  array stat = caudium->stat_file(path, id);
  if ((stat[1] == -3) || (stat[1] == -2)) {
#ifdef CAUDIUM_CACHE
    cache->store(cache_string("directory", cpath, MY_TTL));
#else
    // cache_set(cache_key, cpath, "directory", MY_TTL);
#endif
    return path;
  }
  return 0;
}

string size(mixed s) {
  int size;
  if (arrayp(s) && s[1]) {
    size = s[1];
  }
  if (intp(s) && s) {
    size = s;
  }
#if constant(String.int2size)
  return String.int2size(size);
#endif
  if (size > 1073741824)
    return sprintf("%.1f Gb", size / 1073741824.0);
  else if (size > 1048576)
    return sprintf("%.1f Mb", size / 1048756.0);
  else if (size > 1024)
    return sprintf("%.1f Kb", size / 1024.0);
  else if (size > 0)
    return sprintf("%d b", size);
  else
    return "";
}

mapping ponder(array dir, string path, object id) {
  array dirs, images, videos, others, audio;
  dirs = images = videos = others = audio = ({});
  foreach(dir, string f) {
    string fpath = Stdio.append_path(path, f);
    array stat = caudium->stat_file(fpath, id);
    if (directory_detect(fpath, id))
      dirs += ({ f });
    else if (image_detect(fpath, id))
      images += ({ f });
    else if (audio_detect(fpath, id))
      audio += ({ f });
    else if (video_detect(fpath, id))
      videos += ({ f });
    else
      others += ({ f });
  }
  return
    ([
     "directories" : dirs,
     "images" : images,
     "videos" : videos,
     "others" : others,
     "audio"  : audio
     ]);
}

string encode_entities(string in) {
  return replace(in, ({ "&", "<", ">", "\"" }), ({ "&amp;", "&lt;", "&gt;", "&quot;" }));
}

int admin_enabledp() {
  return !QUERY(admin_mode);
}

string get_url(object id) {
  array u = ({ });
  array p = (array)id->prestate;
  if (sizeof(p)) {
    u += ({ "/", "(" + (p * ",") + ")" });
  }
  u += ({ id->not_query });
  return Stdio.append_path(@u);
}

