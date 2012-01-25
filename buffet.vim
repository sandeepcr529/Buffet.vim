" Buffet Plugin for VIM > 7.3 version 1.15
"
" A fast, simple and easy to use pluggin for switching and managing buffers.
"
" Usage:
"
" Copy the file buffet.vim to the plugins directory.
" The command to open the buffer list is 
" :Bufferlist
"
" A horizontal window is opened with a list of buffer. the buffer numbers are
" also displayed along side. The user select a buffer by
"
" 1.Entering the buffer number using keyboard. Just start typing the number using keyboard.
" The plugin will search for the buffer with that number and will keep going to the matching
" buffers. Entered number will be shown at the top you can use backspace to edit it.When you 
" are in the desired buffer, press enter or any control keys that are
" displayed at the bottom to execute any command available, on that buffer
"
" Available commands
" 
" Enter(Replace current buffer) 
" o - make window fill with selected buffer 
" h - (Horizontal Split) 
" v - (Vertical Split) 
" - - (Vertical Diff Split) 
" g - (Go to buffer window if it is visible) 
" d - (Delete selected buffer) 
"
" 2.Move up or down using the navigation keys to reach the buffer line.
"
" 3.Doubleclick on a buffer line using the mouse. Will immediatly switch to
" that buffer
"
" To make this plugin really useful you have to assign a shortcut key for it, 
" say you want F2 key to open the buffer list. you can add the following line in your .vimrc file. 
"
" map <F2> :Bufferlist<CR>
"
" Last Change:	2012 Jan
" Maintainer:	Sandeep.c.r<sandeepcr2@gmail.com>
"
"
function! s:open_new_window(dim)
	exe s:currentposition. ' '.a:dim . 'new buflisttempbuffer412393'  
	set nonu
	setlocal bt=nofile
	setlocal modifiable
	setlocal bt=nowrite
	setlocal bufhidden=hide
	setlocal noswapfile
	setlocal nowrap
	return bufnr('%')
endfunction 
function! s:open_new_vertical_window(dim)
	exe a:dim . 'vnew' 
	set nonu
	setlocal bt=nofile
	setlocal bt=nowrite
	setlocal bufhidden=hide
	setlocal noswapfile
	return bufnr('%')
endfunction 	
function! s:cursormove()
	let l:line = line('.')
	if(l:line >len(s:bufrecent)+1)
		call cursor(2,3)
	elseif(l:line ==1 )
		call cursor(len(s:bufrecent)+1,3)
	endif
endfunction
function! s:display_buffer_list(gotolastbuffer)
	let l:line = 2
	if(len(s:bufrecent) == 0)
		let s:bufrecent = s:bufferlistlite
	endif

	call filter(s:bufrecent,'exists("s:bufferlistlite[v:val]") && v:val!=t:tlistbuf' )
	let l:maxlen = 0
	for l:i in s:bufrecent
		let l:temp = strlen(fnamemodify(s:bufferlistlite[l:i],':t'))
		if(l:temp > l:maxlen) 
			let l:maxlen = l:temp
		endif
	endfor
	call setline(1,"Buffet-1.15 ( Enter Number to search for a buffer number )")
	for l:i in s:bufrecent
			let l:thisbufno = str2nr(l:i)
			let l:bufname = s:bufferlistlite[l:i]
			let l:buftailname =fnamemodify(l:bufname,':t')
			let l:bufheadlname =fnamemodify(l:bufname,':h')
			if(getbufvar(l:thisbufno,'&modified')) 
				let l:modifiedflag = " (+) "
			else 
				let l:modifiedflag = "     "
			endif
			let l:padlength = l:maxlen - strlen(l:buftailname) + 2
			let l:short_file_name = " ".repeat(' ',2-strlen(l:i)).l:i .'  '. l:buftailname.repeat(' ',l:padlength) .l:modifiedflag. l:bufheadlname 

			let l:short_file_name = l:short_file_name ." [".getbufvar(l:thisbufno,'&ff')."][".getbufvar(l:thisbufno,'&fileencoding').']'
			if(exists("s:buftotabwindow[l:thisbufno]"))
				let l:short_file_name = l:short_file_name .", Tab:".s:buftotabwindow[l:thisbufno][0]." Window:".s:buftotabwindow[l:thisbufno][1]
			endif
			call setline(l:line,l:short_file_name)
			if(l:i==s:sourcebuffer)
				let l:fg = synIDattr(hlID('Statement'),'fg','gui')
				let l:bg = synIDattr(hlID('CursorLine'),'bg','gui')
				if(l:fg!='' )
					exe 'highlight currenttab guifg=lightgreen'
					exe 'highlight currenttab guibg='.l:bg
					exe 'match currenttab /\%'.l:line.'l.\%>1c/'
				endif
			endif
			let l:line += 1
	endfor
	call setline(l:line,"")
	let l:line+=1
	call setline(l:line,"Enter(Replace current buffer) | h/v/-/c (Horizontal/Vertical/Vertical Diff Split/Clear Diff) | o(Maximize buffer) | t(Open buffer in a new tab) | g(Go to buffer window) | d(Delete buffer) ")
	let l:fg = synIDattr(hlID('Statement'),'fg','Question')
	exe 'highlight buffethelpline guibg=black'
	exe 'highlight buffethelpline guifg=orange'
	exe '2match buffethelpline /\%1l\|\%'.l:line.'l.\%>1c/'
	if(a:gotolastbuffer==1)
		call cursor(3,3)
	else
		if(s:lineonclose >len(s:bufrecent)+1) 
			let s:lineonclose -=1
		endif
		call cursor(s:lineonclose,3)
	endif
endfunction

function! s:close()
	if(exists("t:tlistbuf"))
		unlet t:tlistbuf
		let s:lineonclose = line('.')
		:bdelete buflisttempbuffer412393
		echo ''
		exe s:sourcewindow. ' wincmd w'
	endif
endfunction

function! s:place_sign()
	setlocal cursorline
	return
	exec "sign unplace *"
	exec "sign define lineh linehl=Search texthl=Search" 
	exec "sign place 10 name=lineh line=".line('.')." buffer=" . t:tlistbuf
endfunction

function! s:getallbuffers()
	let l:buffers = filter(range(1,bufnr('$')), 'buflisted(v:val)')
	let l:return = {}
	for i in l:buffers
		let l:bufname = bufname(i)
			if(strlen(l:bufname)==0) 	
				continue	
			endif
		let l:return[i] = l:bufname
	endfor
	return l:return
endfunction

function! s:printmessage(msg)
	setlocal modifiable
	call setline(len(s:bufrecent)+2,a:msg)
	setlocal nomodifiable
endfunction

function! s:press(num)
	if(a:num==-1)
		let s:keybuf = strpart(s:keybuf,0,len(s:keybuf)-1)
	else
		let s:keybuf = s:keybuf . a:num
	endif
	setlocal modifiable
	call setline(1 ,'Buffet-1.15 - Searching for buffer:'.s:keybuf.' (Use backspace to edit)')
	let l:index = index(s:bufrecent,s:keybuf)
	"echo l:index
	"echo s:bufrecent
	if(l:index != -1)
		let l:index += 2
		exe "normal "+l:index+ "gg"
	endif
	setlocal nomodifiable
endfunction

function! s:togglesw()
	let s:currentposition = ''
	call s:toggle(1)
endfunction

function! s:toggletop()
	let s:currentposition = 'topleft'
	call s:toggle(1)
endfunction
function! s:toggle(gotolastbuffer)

	let s:keybuf = ''
	if(exists("t:tlistbuf"))
		call s:close()
		return 0
	endif

	let s:bufferlistlite = s:getallbuffers()
	if(len(s:bufrecent) == 0 )
		for x in keys(s:bufferlistlite)
			call add(s:bufrecent,x)
		endfor
	endif
	let s:sourcebuffer = bufnr('%')
	let s:sourcewindow = winnr()
	let s:buftotabwindow = {}
	for l:i in range(tabpagenr('$'))
	   let l:windowno = 1
	   for l:bufno in tabpagebuflist(l:i + 1)
		let s:buftotabwindow[l:bufno] = [l:i+1,l:windowno]
		let l:windowno += 1
	   endfor
	endfor
	let t:tlistbuf = s:open_new_window(len(s:bufrecent)+4)
	set nodiff
	set noscrollbind
	let s:buflistwindow = winnr()
	setlocal cursorline
	call s:display_buffer_list(a:gotolastbuffer)
	"call matchadd('String','[\/\\][^\/\\]*$')  
	if(a:gotolastbuffer==1)
		call cursor(3,3)
	endif
	setlocal nomodifiable
	map <buffer> <silent> <2-leftrelease> :call <sid>gototab(0)<cr>
	map <buffer> <silent> <C-R> :call <sid>gototab(0)<cr>
	map <buffer> <silent> <C-M> :call <sid>gototab(0)<cr>
	map <buffer> <silent> c :call <sid>cleardiff()<cr>
	map <buffer> <silent> C :call <sid>cleardiff()<cr>
	map <buffer> <silent> d :call <sid>deletebuffer(0)<cr>
	map <buffer> <silent> D :call <sid>deletebuffer(1)<cr>
	map <buffer> <silent> o :call <sid>gototab(1)<cr>
	map <buffer> <silent> O :call <sid>gototab(1)<cr>
	map <buffer> <silent> g :call <sid>gotowindow()<cr>
	map <buffer> <silent> G :call <sid>gotowindow()<cr>
	map <buffer> <silent> s :call <sid>split('h')<cr>
	map <buffer> <silent> S :call <sid>split('h')<cr>
	map <buffer> <silent> t :call <sid>openintab()<cr>
	map <buffer> <silent> T :call <sid>openintab()<cr>
	map <buffer> <silent> h :call <sid>split('h')<cr>
	map <buffer> <silent> H :call <sid>split('h')<cr>
	map <buffer> <silent> v :call <sid>split('v')<cr>
	map <buffer> <silent> V :call <sid>split('v')<cr>
	map <buffer> <silent> r :call <sid>refresh()<cr>
	map <buffer> <silent> 0 :call <sid>press(0)<cr>
	map <buffer> <silent> 1 :call <sid>press(1)<cr>
	map <buffer> <silent> 2 :call <sid>press(2)<cr>
	map <buffer> <silent> 3 :call <sid>press(3)<cr>
	map <buffer> <silent> 4 :call <sid>press(4)<cr>
	map <buffer> <silent> 5 :call <sid>press(5)<cr>
	map <buffer> <silent> 6 :call <sid>press(6)<cr>
	map <buffer> <silent> 7 :call <sid>press(7)<cr>
	map <buffer> <silent> 8 :call <sid>press(8)<cr>
	map <buffer> <silent> 9 :call <sid>press(9)<cr>
	map <buffer> <silent> - :call <sid>diff_split('v')<cr>
	map <buffer> <silent> <BS> :call <sid>press(-1)<cr>
	map <buffer> <silent> <Esc> :call <sid>close()<cr>
	augroup  Tlistaco1
			autocmd!
			au  BufLeave <buffer> call <sid>close()
			au  CursorMoved <buffer> call <sid>cursormove()
	augroup END
endfunction
function! s:cleardiff()
	for i in range(1,winnr('$'))
		call setwinvar(i,"&diff",0)
		call setwinvar(i,"&scrollbind",0)
	endfor
endfunction
function! s:deletebuffer(force)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]") )
		let l:selectedbuffer = str2nr(s:bufrecent[l:llindex])
			if(getbufvar(str2nr(l:selectedbuffer),'&modified') && a:force == 0 ) 
				call s:printmessage("Buffer contents modified. Use 'D' to force delete.")
			else
				call s:toggle(0)
				exe "bdelete! ".l:selectedbuffer
				call s:toggle(0)
			endif
	else
		call s:close()
	endif
endfunction

function! s:openintab()
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
			exe s:buflistwindow . ' wincmd w'
			let l:target = s:bufrecent[l:llindex]
			call s:close()
			exe "tabnew"
			exe l:target. ' buf!'
	else
		call s:close()
	endif
endfunction

function! s:gotowindow()
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		if(exists("s:buftotabwindow[s:bufrecent[l:llindex]]"))
			exe s:buflistwindow . ' wincmd w'
			let l:target = s:bufrecent[l:llindex]
			call s:close()
			call s:goto_buffer(l:target)
		else
			call s:printmessage("Buffer not showing in any tab.")
		endif
	else
		call s:close()
	endif
endfunction

function! s:gototab(isonly)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		let l:target = s:bufrecent[l:llindex]
		call s:close()
		call s:switch_buffer(l:target)
		if(a:isonly == 1 && winnr('$')>1)
			exe 'only!'
		endif
	else
		call s:close()
	endif
endfunction

function! s:diff_split(mode)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		let l:target = s:bufrecent[l:llindex]
		call s:close()
		call s:diff_split_buffer(l:target,a:mode)
	else
		call s:close()
	endif
endfunction


function! s:split(mode)
	let l:llindex= line('.') - 2
	if(exists("s:bufrecent[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		let l:target = s:bufrecent[l:llindex]
		call s:close()
		call s:split_buffer(l:target,a:mode)
	else
		call s:close()
	endif
endfunction

function! s:goto_buffer(bufferno)
	if(exists("s:buftotabwindow[a:bufferno]"))
		let l:tabno = s:buftotabwindow[a:bufferno][0]
		let l:winno = s:buftotabwindow[a:bufferno][1]
		exe "tabn" .l:tabno 
		exe l:winno. ' wincmd w'
	endif
endfunction
function! s:removedifforsource()
	if(exists("b:buffet_sourcewindowfordiff"))
		call setwinvar(b:buffet_sourcewindowfordiff,"&diff",0)
		call setwinvar(b:buffet_sourcewindowfordiff,"&scrollbind",0)
	endif
endfunction

function! s:diff_split_buffer(bufferno,mode)
	if(a:mode == 'v')
		exe 'belowright vert '.a:bufferno. ' sbuf'
	elseif(a:mode == 'h')
		exe 'belowright ' .a:bufferno. ' sbuf'
	endif
	if(exists("s:buflinenos[a:bufferno]"))
		exe "normal "+s:buflinenos[a:bufferno] + "gg"
	endif
	call setwinvar(s:sourcewindow,"&diff",1)
	call setwinvar(s:sourcewindow,"&scrollbind",1)
	let b:buffet_sourcewindowfordiff = s:sourcewindow
	augroup  Tlistaco2
			autocmd!
			au  BufWinLeave <buffer> call <sid>removedifforsource()
	augroup END

	setlocal diff
	setlocal scrollbind
endfunction


function! s:split_buffer(bufferno,mode)
	if(a:mode == 'v')
		exe 'belowright vert '.a:bufferno. ' sbuf'
	elseif(a:mode == 'h')
		exe 'belowright ' .a:bufferno. ' sbuf'
	endif
	if(exists("s:buflinenos[a:bufferno]"))
		exe "normal "+s:buflinenos[a:bufferno] + "gg"
	endif
	set nodiff
	set noscrollbind
endfunction

function! s:switch_buffer(bufferno)
	exe a:bufferno. ' buf!'
	set nodiff
	set noscrollbind
	if(exists("s:buflinenos[a:bufferno]"))
		exe "normal "+s:buflinenos[a:bufferno] + "gg"
	endif
endfunction

function! s:updaterecent()
		let l:bufname = bufname("%")
		let l:j = bufnr('%')
		if(strlen(l:bufname) > 0 && getbufvar(l:j,'&modifiable')  ) 
			call filter(s:bufrecent, 'v:val !='. l:j)
			call insert(s:bufrecent,l:j.'')
		endif
endfunction

function! s:savelineno()
	let s:buflinenos[bufnr('%')] = line('.')
endfunction

let s:bufrecent = []
let s:buflinenos = {}
let s:bufferlistlite =  {}
let s:bufliststatus  = 0
let s:keybuf  = ''
let s:lineonclose  = 3
let s:currentposition  = ''
augroup Tlistacom
		autocmd!
		au  BufEnter * call <sid>updaterecent()
		au  BufLeave * call <sid>savelineno()
augroup END

command! Bufferlist :call <sid>toggletop()
command! Bufferlistsw :call <sid>togglesw()
