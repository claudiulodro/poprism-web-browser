''
' Initialize and run the app
''
sub main()
	savedSites = newSavedSites()
	styleMenus()

	while true
		app = newApp()
		history = newHistory()
		whereTo = savedSites.renderScreen()
		if whereTo = "Enter new URL"
			history.push( app.urlScreen() )
			savedSites.addToSavedSites( history.peek() )
		else
			history.push( whereTo )
		end if

		while true
			if history.peek() = "{{PREVIOUS}}"
				history.pop()
				history.pop()
			end if

			if history.peek() <> ""
				print "GOING TO PAGE: " + history.peek()
				history.push( app.browserScreen( history.peek() ) )
			else
				history = newHistory()
				whereTo = savedSites.renderScreen()
				if whereTo = "Enter new URL"
					history.push( app.urlScreen() )
					savedSites.addToSavedSites( history.peek() )
				else
					history.push( whereTo )
				end if
			end if

			savedSites.cleanUp()
		end while
	end while

end sub
