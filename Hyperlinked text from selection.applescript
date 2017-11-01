(* ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ
Version: 1.0

Creates hyperlinked text from a text selection in Safari (or the page title if no text is selected), and puts it on the clipboard. 
No formatting is added to the hyperlink, so it will be formatted according to the target app it is pasted into.

Useful for copying linked text to for example Evernote, OneNote etc.

ÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑÑ
*)

go()

on go()
	
	try
		
		if not verifySafariIsAlright() then return
		
		set uri to my getUrlOfActiveTab()
		set title to my getSelectedText()
		set header to "Copied SELECTED"
		
		if title is "" then
			set title to my getTitleOfActiveTab()
			set header to "Copied PAGE TITLE"
		end if
		
		-- Construct notification on format: 
		-- 'Copied PAGE TITLE' or 'Copied SELECTED'
		-- {Selected text} or {Page title}
		-- {url}
		showNotification(header, title, uri)
		
		putLinkOnClipboard(title, uri)
		
	on error message
		display dialog Â
			"Hey mate, something went horribly wrong, have a look:\n" & message Â
			buttons ("Alright") Â
			with icon stop Â
			default button "Alright"
	end try
	
end go


on verifySafariIsAlright()
	
	-- Using 'tell' in later functions will _start_ Safari if isn't already started. We don't want that.
	
	-- 'URL of front document' will throw an error if Safari is started, but has no open 
	-- windows. Typical message would be: "CanÕt get document 1. Invalid index."
	-- Since Safari isn't active, let's exit silently instead of notifying the user.
	
	-- If the active tab url doesn't contain http, we might be displaying the favorites tab (favorites://)
	
	-- If there is another error happening, let the global handler take care of it.
	
	if application "Safari" is not running then return false
	
	try
		tell application "Safari" to set uri to URL of front document
		
		if uri does not contain "http" then
			display dialog uri
			showNotification("LINK NOT COPIED", "No url is opened in the active page/tab in Safari", "")
			return false
		end if
		
	on error message
		-- Safari is running, but has no windows.
		if message contains "Invalid index" then return false
	end try
	
	return true
end verifySafariIsAlright


on showNotification(header, subheader, message)
	
	-- Format of notification:
	-- header: (bold text)
	-- subheader: (bold text, smaller)
	-- text: (plain text)
	
	set header to header
	
	display notification Â
		message with title (header as string) subtitle (subheader as string)
	delay 0.1
end showNotification


on getUrlOfActiveTab()
	tell application "Safari" to set uri to URL of front document
	return uri
end getUrlOfActiveTab


on getTitleOfActiveTab()
	tell application "Safari" to set title to name of front document
	return title
end getTitleOfActiveTab


on getSelectedText()
	set the clipboard to ""
	tell application "System Events" to keystroke "c" using {command down}
	delay 0.1 -- Without this, the clipboard may have stale data.
	set selectedText to the clipboard
	return selectedText
end getSelectedText


on putLinkOnClipboard(title, uri)
	set html to "<a href=\"" & uri & "\">" & title & "</a>"
	set htmlObject to do shell script "echo " & (quoted form of html) as Çclass HTMLÈ
	set the clipboard to htmlObject
end putLinkOnClipboard