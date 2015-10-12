''
' Instantiate a History object suitable for keeping a stack of the current sessions history
' @return - Object - A History object
''
function newHistory() as Object
	history = createObject( "roAssociativeArray" )
	history.data = []
	history.push = historyPush
	history.pop = historyPop
	history.peek = historyPeek
	history.sanitizeUrl = historySanitizeUrl
	return history
end function


''
' Push a url onto the session history
' @param - String - The URL of a page
''
function historyPush( url ) as Void
	m.data.push( m.sanitizeUrl( url ) )
end function


''
' Pop the most recent URL off of the history
' @return - String - The URL of the most recent page or "" if none
''
function historyPop() as String
	if m.data.count() = 0
		return ""
	else
		last = m.data.pop()
		if last <> invalid
			return ""
		end if
		return last
	end if		
end function


''
' Get the URL of the most recent/current page
' @return - String - The URL
''
function historyPeek() as String
	if m.data.count() = 0
		return ""
	else
		return m.data.peek()
	end if
end function


''
' Format and make a URL suitable for going to pages
' @param - String - URL to format
' @return - String - formatted URL
''
function historySanitizeUrl( url ) as String	
	url = url.trim()
	if url = ""
		return ""
	end if

	mainUrl = url.tokenize("?")
	url = mainUrl[0]

	if url.mid( 0, 3 ) = "www"
		url = "http://" + url
	else if url.mid( 0, 5 ) = "javas"
		url = m.peek()
	else if url.mid( 0, 2 ) = "//"
		url = "http:" + url
	else if url.mid( 0, 1 ) = "/"
		currentURL = m.peek()
		base = currentURL.tokenize( "/" )
		url = base[1] + url
	else if url.mid( 0, 2 ) = "{{"
		return url
	else if url.mid( 0, 4 ) <> "http"
		url = m.peek() + url
	end if

	if url.mid( 0, 4 ) <> "http" and url.mid( 0, 2 ) <> "{{"
		url = "http://" + url
	end if

	return url
end function
