# YouTube Downloader AHK

A simple AutoHotkey script which enables the user to select a list of YouTube video URLs and automatically download them on demand.

**Manual**

 1. Open the video you wish to download.
 2. Press *SHIFT + CTRL + ALT + S* in order to save its URL. 
 3. You may now download by pressing *SHIFT + CTRL + ALT + D*.
 4. Wait for the download site to appear.
 5. The download should start automatically.
 6. When it has finished, the script will ask you to clear the URL file.
 7. Select your preferred option and you are ready to start the process again.

**Features**

 - You can (probably) select as many videos as you want to be downloaded.
 - The download itself should be fast, depending on your internet connection.
 - The script should be able to recover from most common errors (e.g. download site slowly loading, buttons not appearing, etc.).
 - I tried to make the script as simple as possible, so feel free to take a look :)

**Planed features**

 - Adding a setup with a config file, you can define various settings and customisation for example changing the hotkeys.
 - Make the script more reliable, as it is still in beta.
 - Support for more browsers than Firefox.

## Important

 - The script may not work immediately and if that is the case, there are a few reasons .
	 - 1. The script currently only supports Firefox as your default browser.
	 - → There will be future support for example Chrome or Edge.
	 - 2. The script opens the download site, but it does not click some or all of the buttons.
	 - →  This is an error I am aware of and working on in the future (→ config file) but for now you may solve the issue by opening AHK's Window Spy utility and select the coordinates of the buttons yourself. You can go into the .ahk file and look for the three functions named **findTextBar(), findStartButton(), findDownloadButton()**, and change the coordinates for **MouseMove(x, y)** to the ones for your system. After that, you can save the .ahk file and you are done !
	 - 3. If there are any other problems or suggestions, feel free to ask :)

**Thanks to https://de.onlinevideoconverter.pro beeing such a nice and mostly add free site !**
