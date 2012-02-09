" Buffet Plugin for VIM > 7.3 version 2.10
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
" hh - (Horizontal Split) 
" v - (Vertical Split) 
" - - (Vertical Diff Split) 
" g - (Go to buffer window if it is visible in any tab) 
" d - (Delete selected buffer) 
" x - (Close window) 
" c - (Clear diff flags for all windows) 
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
	setlocal ft=buffet
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
	let s:lineonclose = line('.')
	if(s:lineonclose >len(s:displayed)+1)
		call cursor(2,3)
	elseif(s:lineonclose ==1 )
		call cursor(len(s:displayed)+1,3)
	endif
endfunction
function! s:buffet_pathshorten(str)
	if(s:detail == 1) 
		return a:str
	else
		return pathshorten(a:str)
	endif
endfunction
function! s:display_buffer_list(gotolastbuffer)
	let l:line = 2
	let l:fg = synIDattr(hlID('Statement'),'fg','gui')
	let l:bg = synIDattr(hlID('CursorLine'),'bg','gui')
	call filter(s:bufrecent,'exists("s:bufferlistlite[v:val]") && v:val!=t:tlistbuf' )
	let l:maxlen = 0
	let l:headmaxlen = 0
	for l:i in keys(s:bufferlistlite)
		if(index(s:bufrecent,l:i)==-1) 
			call add(s:bufrecent,l:i)
		endif
		let l:temp = strlen(fnamemodify(s:bufferlistlite[l:i],':t'))
		let l:headtemp = strlen(s:buffet_pathshorten(fnamemodify(s:bufferlistlite[l:i],':h')))
		if(l:headtemp > l:headmaxlen) 
			let l:headmaxlen = l:headtemp
		endif
		if(l:temp > l:maxlen) 
			let l:maxlen = l:temp
		endif
	endfor
	call setline(1,"Buffet-2.10 ( Enter Number to search for a buffer number )")
	let s:displayed = []
	let s:last_buffer_line = 0
	for l:i in s:bufrecent
			let l:thisbufno = str2nr(l:i)
			let l:bufname = s:bufferlistlite[l:i]
			let l:buftailname =fnamemodify(l:bufname,':t')
			let l:bufheadlname =s:buffet_pathshorten(fnamemodify(l:bufname,':h'))
			if(getbufvar(l:thisbufno,'&modified')) 
				let l:modifiedflag = " (+) "
			else 
				let l:modifiedflag = "     "
			endif
			let l:padlength = l:maxlen - strlen(l:buftailname) + 2
			let l:padlengthhead= l:headmaxlen - strlen(l:bufheadlname) + 2
			let l:short_file_name = repeat(' ',2-strlen(l:i)).l:i .'  '. l:buftailname.repeat(' ',l:padlength) .l:modifiedflag. l:bufheadlname .repeat(' ',l:padlengthhead)
			let l:padstring = repeat(' ',len(l:short_file_name))
			if(exists("s:buftotabwindow[l:thisbufno]"))
				let l:thistab = s:buftotabwindow[l:thisbufno][0][0]
				let l:thiswindow = s:buftotabwindow[l:thisbufno][0][1]
				let l:short_file_name = l:short_file_name ." Tab:".l:thistab." Window:".l:thiswindow
				call add(s:displayed,[l:thisbufno,l:thistab,l:thiswindow])
				if(l:thistab == s:sourcetab && l:thiswindow == s:sourcewindow)
					let l:short_file_name = '>'.l:short_file_name ." <"
				else
					let l:short_file_name = ' '.l:short_file_name
				endif
			else
				let l:short_file_name = ' '.l:short_file_name
				call add(s:displayed,[l:thisbufno])
			endif
			call setline(l:line,l:short_file_name)
			let l:subwindow = 1
			while(exists("s:buftotabwindow[l:thisbufno][l:subwindow]"))
				let l:thistab = s:buftotabwindow[l:thisbufno][l:subwindow][0]
				let l:thiswindow = s:buftotabwindow[l:thisbufno][l:subwindow][1]
				let l:line += 1
				if(l:thistab == s:sourcetab && l:thiswindow == s:sourcewindow)
					call setline(l:line,'> '.l:padstring."Tab:".l:thistab." window:".l:thiswindow." <")
				else 
					call setline(l:line,'  '.l:padstring."Tab:".l:thistab." window:".l:thiswindow)
				endif
				call add(s:displayed,[l:thisbufno,l:thistab,l:thiswindow])
				let l:subwindow += 1
			endwhile
			if(s:last_buffer_line == 0)
				let s:last_buffer_line = l:line+1
			endif
			let l:line += 1
	endfor
	exe "resize ".(len(s:displayed)+4)
	call setline(l:line,"")
	let l:line+=1
	call setline(l:line,"Enter(Load buffer) | hh/v/-/c (Horizontal/Vertical/Vertical Diff Split/Clear Diff) | o(Maximize) | t(New tab) | m(Toggle detail) | g(Go to window) | d(Delete buffer) | x(Close window) ")
	let l:fg = synIDattr(hlID('Statement'),'fg','Question')
	exe 'highlight buffethelpline guibg=black'
	exe 'highlight buffethelpline guifg=orange'
	exe '2match buffethelpline /\%1l\|\%'.l:line.'l.\%>1c/'
	if(a:gotolastbuffer==1)
		call cursor(s:last_buffer_line,3)
	else
		if(s:lineonclose >len(s:displayed)+1) 
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
				let l:bufname = "[No Name]"
			endif
		let l:return[i] = l:bufname
	endfor
	return l:return
endfunction

function! s:printmessage(msg)
	setlocal modifiable
	call setline(len(s:displayed)+2,a:msg)
	setlocal nomodifiable
endfunction

function! s:press(num)
	if(a:num==-1)
		let s:keybuf = strpart(s:keybuf,0,len(s:keybuf)-1)
	else
		let s:keybuf = s:keybuf . a:num
	endif
	setlocal modifiable
	call setline(1 ,'Buffet-2.10 - Searching for buffer:'.s:keybuf.' (Use backspace to edit)')
	let l:index =  0
	for l:i in s:displayed
		if(l:i[0] == s:keybuf)
			let l:index += 2
			exe "normal "+l:index+ "gg"
			break
		endif
		let l:index += 1
	endfor
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
	let s:sourcebuffer = bufnr('%')
	let s:sourcewindow = winnr()
	let s:sourcetab = tabpagenr()
	let s:buftotabwindow = {}
	for l:i in range(tabpagenr('$'))
	   let l:windowno = 1
	   for l:bufno in tabpagebuflist(l:i + 1)
		if(!exists("s:buftotabwindow[l:bufno]"))
			let s:buftotabwindow[l:bufno] = []
		endif
		call add(s:buftotabwindow[l:bufno], [l:i+1,l:windowno])
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
	setlocal nomodifiable
	map <buffer> <silent> <2-leftrelease> :call <sid>loadbuffer(0)<cr>
	nnoremap <buffer> <silent> <C-R> :call <sid>loadbuffer(0)<cr>
	nnoremap <buffer> <silent> <C-M> :call <sid>loadbuffer(0)<cr>
	nnoremap <buffer> <silent> x :call <sid>closewindow(0)<cr>
	nnoremap <buffer> <silent> X :call <sid>closewindow(1)<cr>
	nnoremap <buffer> <silent> c :call <sid>cleardiff()<cr>
	nnoremap <buffer> <silent> C :call <sid>cleardiff()<cr>
	nnoremap <buffer> <silent> d :call <sid>deletebuffer(0)<cr>
	nnoremap <buffer> <silent> D :call <sid>deletebuffer(1)<cr>
	nnoremap <buffer> <silent> o :call <sid>loadbuffer(1)<cr>
	nnoremap <buffer> <silent> O :call <sid>loadbuffer(1)<cr>
	nnoremap <buffer> <silent> g :call <sid>gotowindow()<cr>
	nnoremap <buffer> <silent> G :call <sid>gotowindow()<cr>
	nnoremap <buffer> <silent> s :call <sid>split('h')<cr>
	nnoremap <buffer> <silent> S :call <sid>split('h')<cr>
	nnoremap <buffer> <silent> t :call <sid>openintab()<cr>
	nnoremap <buffer> <silent> T :call <sid>openintab()<cr>
	nnoremap <buffer> <silent> hh :call <sid>split('h')<cr>
	nnoremap <buffer> <silent> HH :call <sid>split('h')<cr>
	nnoremap <buffer> <silent> v :call <sid>split('v')<cr>
	nnoremap <buffer> <silent> V :call <sid>split('v')<cr>
	nnoremap <buffer> <silent> r :call <sid>refresh()<cr>
	nnoremap <buffer> <silent> 0 :call <sid>press(0)<cr>
	nnoremap <buffer> <silent> 1 :call <sid>press(1)<cr>
	nnoremap <buffer> <silent> 2 :call <sid>press(2)<cr>
	nnoremap <buffer> <silent> 3 :call <sid>press(3)<cr>
	nnoremap <buffer> <silent> 4 :call <sid>press(4)<cr>
	nnoremap <buffer> <silent> 5 :call <sid>press(5)<cr>
	nnoremap <buffer> <silent> 6 :call <sid>press(6)<cr>
	nnoremap <buffer> <silent> 7 :call <sid>press(7)<cr>
	nnoremap <buffer> <silent> 8 :call <sid>press(8)<cr>
	nnoremap <buffer> <silent> 9 :call <sid>press(9)<cr>
	nnoremap <buffer> <silent> - :call <sid>diff_split('v')<cr>
	nnoremap <buffer> <silent> m :call <sid>toggle_detail()<cr>
	nnoremap <buffer> <silent> M :call <sid>toggle_detail()<cr>
	nnoremap <buffer> <silent> <BS> :call <sid>press(-1)<cr>
	nnoremap <buffer> <silent> <Esc> :call <sid>close()<cr>
	augroup  Tlistaco1
			autocmd!
			au  BufLeave <buffer> call <sid>close()
			au  CursorMoved <buffer> call <sid>cursormove()
	augroup END
endfunction
function! s:toggle_detail()
	let s:detail = !s:detail
	setlocal modifiable
	call s:display_buffer_list(0)
	setlocal nomodifiable
endfunction
function! s:cleardiff()
	for i in range(1,winnr('$'))
		call setwinvar(i,"&diff",0)
		call setwinvar(i,"&scrollbind",0)
	endfor
endfunction
function! s:deletebuffer(force)
	let l:llindex= line('.') - 2
	if(exists("s:displayed[l:llindex]") )
		let l:selectedbuffer = str2nr(s:displayed[l:llindex][0])
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
	if(exists("s:displayed[l:llindex]"))
			exe s:buflistwindow . ' wincmd w'
			let l:target = s:displayed[l:llindex][0]
			call s:close()
			exe "tabnew"
			exe l:target. ' buf!'
	else
		call s:close()
	endif
endfunction

function! s:closewindow(force)
	let l:llindex= line('.') - 2
	if(exists("s:displayed[l:llindex]"))
		if(exists("s:displayed[l:llindex][1]"))
			if(getbufvar(str2nr(s:displayed[l:llindex][0]),'&modified') && a:force == 0 ) 
				call s:printmessage("Buffer contents modified. Use 'X' to force close.")
			else
				if(tabpagenr('$')==1 && winnr('$')==2)
					call s:printmessage("Not closing last window of the last tab.")
				else
					exe s:buflistwindow . ' wincmd w'
					call s:close()
					exe "tabn" .s:displayed[l:llindex][1]
					exe s:displayed[l:llindex][2]. ' wincmd w'
					:q!
					exe "tabn". s:sourcetab
					call s:toggle(0)
				endif
			endif
		else
			call s:printmessage("Buffer not showing in any tab.")
		endif
	else
		call s:close()
	endif
endfunction


function! s:gotowindow()
	let l:llindex= line('.') - 2
	if(exists("s:displayed[l:llindex]"))
		if(exists("s:displayed[l:llindex][1]"))
			exe s:buflistwindow . ' wincmd w'
			call s:close()
			exe "tabn" .s:displayed[l:llindex][1]
			exe s:displayed[l:llindex][2]. ' wincmd w'
		else
			call s:printmessage("Buffer not showing in any tab. Use Enter,v,hh,t or o to open buffer in a window.")
		endif
	else
		call s:close()
	endif
endfunction

function! s:loadbuffer(isonly)
	let l:llindex= line('.') - 2
	if(exists("s:displayed[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		let l:target = s:displayed[l:llindex][0]
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
	if(exists("s:displayed[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		let l:target = s:displayed[l:llindex][0]
		call s:close()
		call s:diff_split_buffer(l:target,a:mode)
	else
		call s:close()
	endif
endfunction


function! s:split(mode)
	let l:llindex= line('.') - 2
	if(exists("s:displayed[l:llindex]"))
		exe s:buflistwindow . ' wincmd w'
		let l:target = s:displayed[l:llindex][0]
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
let s:firstrun  =  1
let s:detail  =  0
augroup Tlistacom
		autocmd!
		au  BufEnter * call <sid>updaterecent()
		au  BufLeave * call <sid>savelineno()
augroup END

command! Bufferlist :call <sid>toggletop()
command! Bufferlistsw :call <sid>togglesw()

