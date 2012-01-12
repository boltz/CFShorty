﻿<cfset served = application.api.linkCount()>

<cfif ISDefined("form.longURL")>
	<cfset jsonReturn 	= application.api.insert(longurl = form.longURL, cgi = cgi) />
	<cfset structReturn = deserializeJSON(jsonreturn) />
	<cfset shortURL 	= "http://" & structReturn.shortURL />
</cfif>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>The ColdFusion URL Shortner</title>
    <meta name="description" 	content="">
    <meta name="author" 		content="">

    <!-- Le HTML5 shim, for IE6-8 support of HTML elements -->
    <!--[if lt IE 9]>
      <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
    <![endif]-->

    <!-- Le styles -->
	<link rel="stylesheet" href="http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css">
    <style type="text/css">
      /* Override some defaults */
      html, body {
        background-color: #eee;
      }
      body {
        padding-top: 40px; /* 40px to make the container go all the way to the bottom of the topbar */
      }
      .container > footer p {
        text-align: center; /* center align it with the container */
      }
      .container {
        width: 820px; /* downsize our container to make the content feel a bit tighter and more cohesive. NOTE: this removes two full columns from the grid, meaning you only go to 14 columns and not 16. */
      }

      /* The white background content wrapper */
      .content {
        background-color: #fff;
        padding: 20px;
        margin: 0 -20px; /* negative indent the amount of the padding to maintain the grid system */
        -webkit-border-radius: 0 0 6px 6px;
           -moz-border-radius: 0 0 6px 6px;
                border-radius: 0 0 6px 6px;
        -webkit-box-shadow: 0 1px 2px rgba(0,0,0,.15);
           -moz-box-shadow: 0 1px 2px rgba(0,0,0,.15);
                box-shadow: 0 1px 2px rgba(0,0,0,.15);
      }

      /* Page header tweaks */
      .page-header {
        background-color: #f5f5f5;
        padding: 20px 20px 10px;
        margin: -20px -20px 20px;
      }

      /* Styles you shouldn't keep as they are for displaying this base example only */
      .content .span10,
      .content .span4 {
        min-height: 500px;
      }
      /* Give a quick and non-cross-browser friendly divider */
      .content .span4 {
        margin-left: 0;
        padding-left: 19px;
        border-left: 1px solid #eee;
      }

      .topbar .btn {
        border: 0;
      }

    </style>

    <!-- Le fav and touch icons -->
    <link rel="shortcut icon" 		href="images/favicon.ico">
    <link rel="apple-touch-icon" 	href="images/apple-touch-icon.png">
    <link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72x72.png">
    <link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114x114.png">
  </head>

  <body>

    <div class="topbar">
      <div class="fill">
        <div class="container">
          <a class="brand" href="#"><cfoutput>Over #served# links served!</cfoutput></a>
          <!-- <ul class="nav">
            <li class="active"><a href="#">Home</a></li>
            <li><a href="#about">About</a></li>
            <li><a href="#contact">Contact</a></li>
          </ul> -->
          <!-- <form action="" class="pull-right">
            <input class="input-small" type="text" placeholder="Username">
            <input class="input-small" type="password" placeholder="Password">
            <button class="btn" type="submit">Sign in</button>
          </form> -->
        </div>
      </div>
    </div>

    <div class="container">

      <div class="content">
        <div class="page-header">
          <h1>CFML.US <small>The ColdFusion URL Shortner.</small></h1>
        </div>
        <div class="row">
          <div class="span10">
          	<form action="index.cfm" method="post">
            	<input class="xlarge" type="text" placeholder="Link to Shorten" name="longURL"> &nbsp;&nbsp;<button class="btn primary">Do it!</button>
         	</form>
		  </div>
          <div class="span4">
          	<cfif ISDefined("form.longURL")>
            <h3>Shortened Link</h3>
			<cfoutput>
				<br>#shortURL#
			</cfoutput>		
			 </cfif>
          </div>
        </div>
      </div>

      <footer>
        <p>&copy; Tim Cunningham Wild Hair Enterprises</p>
      </footer>

    </div> <!-- /container -->

  </body>
</html>
