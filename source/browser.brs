''
' Instantiate an App object suitable for running the browser
' @return - Object - A new App object
''
function newApp() as Object
	app = createObject( "roAssociativeArray" )
	app.settings = appSettings
	app.adjustTextSize = appAdjustTextSize
	app.adjustColors = appAdjustColors
	app.drawMarker = appDrawMarker
	app.browserScreen = appBrowserScreen
	app.urlScreen = appUrlScreen
	app.drawHeader = appDrawHeader
	app.drawRow = appDrawRow
	app.errorScreen = appErrorScreen

	return app
end function


''
' Set up the settings needed to properly render the browser
''
function appSettings() as Void
	m.textColor = &h8A8A5Cff
	m.bgColor = &hffffffff
	m.linkColor = &h0000CCff

    	deviceInfo = CreateObject("roDeviceInfo")
    	if deviceInfo.GetDisplayType() = "HDTV"
		m.screen=createObject( "roScreen", false, 1280, 720 )
	else
		m.screen=createObject( "roScreen", false, 720, 480 )
	end if

    	m.port = CreateObject( "roMessagePort" )
    	m.screen.SetPort( m.port )

	m.screenWidth = m.screen.getWidth()
	m.screenHeight = m.screen.getHeight()
	m.remainingHeight = .6 * m.screenHeight
	m.remainingWidth = .8 * m.screenWidth

	m.x = .1 * m.screenWidth
	m.y = .2 * m.screenHeight
	
	m.adjustColors( m.textColor, m.bgColor )
	m.adjustTextSize( 14 )
end function


''
' Draw the browser's header navigation bar
' @param - String - The text to put in the bar
''
function appDrawHeader( headerText ) as Void
	m.screen.drawRect( 0, 0, m.screenWidth, m.y, &hd9d9d9ff )
	renderText = headerText.left( m.maxHeaderChars )
	if renderText <> headerText
		renderText = renderText + "..."
	end if

	m.screen.drawText( renderText, m.x, m.y-(2*m.lineHeight), &hb7b7b7ff, m.font )
end function


''
' Set the size of the font based on how many lines of text should be displayed
' @param - Int - The number of lines that should be rendered
''
function appAdjustTextSize( newNumLines ) as Void

	m.numLines = newNumLines

	m.lineHeight = m.remainingHeight / m.numLines
	m.lineWidth = m.remainingWidth

	m.fontRegistry = CreateObject("roFontRegistry")
	m.font = m.fontRegistry.getDefaultFont( m.lineHeight, false, false )

	maxHeaderWidth = .85 * m.lineWidth
	oneCharWidth = m.font.getOneLineWidth( "0", maxHeaderWidth )
	m.maxHeaderChars = maxHeaderWidth / oneCharWidth

end function


''
' Set the color palette of the browser
' @param - Hexadecimal integer - The color to set the text
' @param - Hexadecimal integer - The color to set the background
''
function appAdjustColors( newTextColor, newBgColor ) as Void
	m.textColor = newTextColor
	m.bgColor = newBgColor
end function


''
' Draw a line marker to show where the current line is
' @param - The line number to draw the marker at
''
function appDrawMarker( currentPosition ) as Void
	markerFont = m.fontRegistry.getDefaultFont( (m.lineHeight*.5), false, false )
	markerWidth = 1.5*markerFont.getOneLineWidth( ">", m.remainingWidth )
	positionY = m.y + (m.lineHeight * currentPosition ) + (m.lineHeight * .25)

	m.screen.drawText( ">", m.x-markerWidth, positionY, m.textColor, markerFont )
end function


''
' Render one line of text on the screen
' @param - Object - A node
' @param - Integer - The Y position to draw the line 
''
function appDrawRow( node, position ) as Void
		lineText = ""

		if node.nodeType = "link"
			textColor = m.linkColor
		else
			textColor = m.textColor
		end if

		if ( node.nodeType = "link" or node.nodeType = "text" ) and node.text <> invalid
			lineText = node.text
		end if

		m.screen.drawText( lineText, m.x, position, textColor, m.font )
end function


''
' Render an error message and tell the history to go back to the previous page
' @return - String - {{PREVIOUS}}
''
function appErrorScreen() as String
	m.screen.drawRect( 0, 0, m.screenWidth, m.screenHeight, m.bgColor )
	m.screen.drawText( "Sorry we could't handle that link", m.x, m.y, m.textColor, m.font )
	m.screen.drawText( "Press any key to go back to the previous page", m.x, m.y+m.lineHeight, m.textColor, m.font )
	m.screen.finish()

	while true
		msg = wait(0, m.screen.GetMessagePort())
       		if type(msg)="roUniversalControlEvent"
                	keypressed = msg.GetInt()
			if msg.getInt() < 100
				return "{{PREVIOUS}}"
			end if
		end if
	end while

end function


''
' Render the browser
' @param - String - The URL to render the page for
' @return - String - The URL to go to next
''
function appBrowserScreen( url ) as String

	'Loading
	m.settings()
	m.screen.drawRect( 0, 0, m.screenWidth, m.screenHeight, &he3e3e3ff )
	m.screen.drawText( "Loading . . .", m.x, m.y, m.textColor, m.font )
	m.screen.finish()

	'Go get the page
	request = CreateObject( "roUrlTransfer" )
	requestPort = createObject( "roMessagePort" )
    	request.SetMessagePort( requestPort )
	request.setUrl( url )
	request.setCertificatesFile("common:/certs/ca-bundle.crt")
	request.setMinimumTransferRate( 1000, 3 )
	html = request.getToString()
	if html.len() < 1
		return m.errorScreen()
	end if

	'Parse the page
	lexer = newLexer( html )
	lexer.remainingWidth = m.remainingWidth
	lexer.font = m.font

	'Render the initial screen
	m.screen.drawRect( 0, 0, m.screenWidth, m.screenHeight, m.bgColor )
	for i = 0 to m.numLines + 1 step 1
		lineLocation = m.y + ( m.lineHeight * i )
		lineData = lexer.getTokenAt( i )
		m.drawRow( lineData, lineLocation )
	end for
	m.drawHeader( url )
	m.drawMarker( 0 )
	m.screen.finish()

	'Handle new actions
	keypressed = ""
	currentPosition = 0
	while true
		msg = wait(0, m.screen.GetMessagePort())
       		if type(msg)="roUniversalControlEvent"
                	keypressed = msg.GetInt()
			if msg.getInt() < 100

				'0 = back
				if msg.getInt() = 0
					return "{{PREVIOUS}}"

				'2 = UP
				else if msg.getInt() = 2 and currentPosition > 0
					currentPosition = currentPosition - 1

				'3 = DOWN
				else if msg.getInt() = 3
					currentPosition = currentPosition + 1

				'4 = LEFT
				'8 = RW
				else if msg.getInt() = 4 or msg.getInt() = 8
					currentPosition = currentPosition - m.numLines - 1
					if currentPosition < 0
						currentPosition = 0
					end if

				'5 = RIGHT
				'9 = FF
				else if msg.getInt() = 5 or msg.getInt() = 9
					currentPosition = currentPosition + m.numLines + 1

				'6 = OK
				'13 = PLAY
				else if msg.getInt() = 6 or msg.getInt() = 13
					if lexer.getTokenAt( currentPosition ).nodeType = "link"
						return lexer.getTokenAt( currentPosition ).url
					end if

				'7 = return-looking-thing
				else if msg.getInt() = 7
					return ""

				end if

				if currentPosition < 0
					currentPosition = 0
				end if

				m.screen.drawRect( 0, 0, m.screenWidth, m.screenHeight, m.bgColor )

				for i = currentPosition to currentPosition + m.numLines + 1 step 1
					lineLocation = m.y + ( m.lineHeight * ( i - currentPosition ) )
					lineData = lexer.getTokenAt( i )	
					m.drawRow( lineData, lineLocation )
				end for
				if lexer.getTokenAt( currentPosition ).nodeType = "link"
					linkWidth = m.font.getOneLineWidth( lexer.getTokenAt( currentPosition ).text, m.remainingWidth )
					m.screen.drawRect( m.x, m.y+m.lineHeight-1, linkWidth, 2, m.linkColor )
					m.drawHeader( lexer.getTokenAt( currentPosition ).url )
				else
					m.drawHeader( url )
				end if

				m.drawMarker( 0 )
				m.screen.finish()
			end if
		end if
	end while

 	return ""
end function


''
' Render a screen for manually entering a URL to go to
' @return - String - The URL to go to
''
function appUrlScreen() as String
     screen = CreateObject("roKeyboardScreen")
     port = CreateObject("roMessagePort") 
     screen.SetMessagePort(port)
     screen.SetTitle("Enter URL")
     screen.SetText("http://www.")
     screen.SetDisplayText("Enter URL to go to")
     screen.SetMaxLength(30)
     screen.AddButton(1, "Go")
     screen.AddButton(2, "Back")
     screen.Show() 
  
     while true
         msg = wait(0, screen.GetMessagePort()) 
         print "message received"
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isScreenClosed()
                 return ""
             else if msg.isButtonPressed() then
                 if msg.GetIndex() = 1
                     searchText = screen.GetText()
                     print "search text: "; searchText 
                     return searchText
		else
			return ""
                 endif
             endif
         endif
     end while 
end function
