Buffet is a plugin for the vim editor for listing and switching buffers, windows and tabs.([vim.org](http://www.vim.org/scripts/script.php?script_id=3896))

New in version 2.10[(Screenshot)](http://i43.tinypic.com/33kadsx.png)

* Layout change for buffer list.Made columns to correctly align on top of each other.
* Removed the highlight for current window/buffer. Current window is enclosed in a >  < instead.[(Screenshot)](http://i43.tinypic.com/33kadsx.png)
* Made a shorter version of path to show initially, Can toggle detail view using 'm' key.

In version 2.0

*  Added support for multiple windows showing same buffer.
* Removed file type and file encoding information from buffer list.
* Fixed an issue when vim is invoked from command line with multiple arguments
* Added 'x' command to close a window in what ever tab it is displayed.
* Changed the 'h' command to 'hh' to prevent accidental opening when moving across the list.


Screenshot: [http://i43.tinypic.com/33kadsx.png](http://i43.tinypic.com/33kadsx.png)

When the plugin is invoked, it opens a horizontal window at the top. This window contains a list of buffers, sorted in the most recently used order. The cursor is placed on the line of the buffer that user accessed before the current buffer. This is to make switching between two buffers very fast.

If a buffer is displayed in more than one window, those windows are listed below the buffer entry with tab number and window number. 

The window and tab from which the plugins was invoked is shown enclosed in a pair of > ... <

Please see [screenshot](http://i40.tinypic.com/nv1iqa.png)

User can move up or down in the list using navigation keys to select a buffer/window. 

When user is on a buffer/window, there is a set of commands he can execute on the buffer by pressing the corresponding key. The available commands are,

### Enter(Replace current buffer) 

Pressing the enter key loads the selected buffer into the window from which the plugin was called.
### hh (Was originally h,changed to hh in version 2)

Splits the window from which the plugin was invoked horizontally , and loads the selected buffer into the new window. 

### v

Splits the window from which the plugin was invoked vertically, and loads the selected buffer into the new window. 
### \-

Loads a diff view of the selected buffer with the buffer from which the plugin was called. The two windows will be 
    scroll binded.
### c 

The above - command may cause some windows to retain the diff flag even after the paired window is closed. The 'c'   
    command clears the diff flag for all windows in the current tab.  

### o

This command maximizes the window to fill the current tab page, hiding all the windows of the current tab.

### g

This command switches focus to the selected window if it is visible in any of the tabs. This is different from the 'enter' command in the sense that it does not loads the contents of the buffer into the current window. If a buffer is being displayed in more than a window, then all those windows will be represented by the lines under the entry for that buffer.
Executing the g command on those entries switches the user to the corresponding window and tab.

### d

This command deletes the selected buffer from the buffer list. Buffer list window is not closed.

### x

This command closes the selected window. It does not matter if the window is open in another tab. Buffer is not removed from the list. The buffer list window remains open. With this you can use the buffer list window as a remote control to navigate to or close any window in any tab.

### m

Toggles the detailed view for file paths.
