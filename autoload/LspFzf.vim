function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val, "lnum": 1 }'))
  copen
  cc
endfunction

function! s:handle_sink_fzf(lines)
    if len(a:lines) == 1
        let l:split_line = split(a:lines[0], ':')
        execute 'edit ' l:split_line[0] . '|' . l:split_line[1]
    endif
endfunction

function! s:handle_location_fzf(ctx, server, type, data) abort "ctx = {counter, list, last_command_id, jump_if_one, mods, in_preview}
    if a:ctx['last_command_id'] != lsp#_last_command()
        return
    endif

    let a:ctx['counter'] = a:ctx['counter'] - 1

    if lsp#client#is_error(a:data['response']) || !has_key(a:data['response'], 'result')
        call lsp#utils#error('Failed to retrieve '. a:type . ' for ' . a:server . ': ' . lsp#client#error_message(a:data['response']))
    else
        let a:ctx['list'] = a:ctx['list'] + lsp#utils#location#_lsp_to_vim_list(a:data['response']['result'])
    endif

    let l:fzf_list = []
    for l:list_item in a:ctx['list']
        call add(l:fzf_list,
                    \substitute(l:list_item['filename'], '\V'.substitute(getcwd().'\', '\\', '\\\\', 'g'), '', '').':'.
                    \l:list_item['lnum'].':'.
                    \l:list_item['col'].'|'.
                    \l:list_item['text'])
    endfor
    let l:preview_cmd = "sh C:/Users/e1432179/vimfiles/fzf-bat-preview.sh {1} {2}"
    call fzf#run(fzf#wrap({'source': l:fzf_list, 'sink*': function('s:handle_sink_fzf'),
                \'options': ['--multi', '--delimiter', ':', '--preview', l:preview_cmd]}))
endfunction

function! s:list_location_fzf(method, ctx, ...) abort
    " typeDefinition => type definition
    let l:operation = substitute(a:method, '\u', ' \l\0', 'g')

    let l:capabilities_func = printf('lsp#capabilities#has_%s_provider(v:val)', substitute(l:operation, ' ', '_', 'g'))
    let l:servers = filter(lsp#get_allowed_servers(), l:capabilities_func)
    let l:command_id = lsp#_new_command()


    let l:ctx = extend({ 'counter': len(l:servers), 'list':[], 'last_command_id': l:command_id, 'jump_if_one': 1, 'mods': '', 'in_preview': 0 }, a:ctx)
    if len(l:servers) == 0
        call s:not_supported('Retrieving ' . l:operation)
        return
    endif

    let l:params = {
        \   'textDocument': lsp#get_text_document_identifier(),
        \   'position': lsp#get_position(),
        \ }
    if a:0
        call extend(l:params, a:1)
    endif
    for l:server in l:servers
        call lsp#send_request(l:server, {
            \ 'method': 'textDocument/' . a:method,
            \ 'params': l:params,
            \ 'on_notification': function('s:handle_location_fzf', [l:ctx, l:server, l:operation]),
            \ })
    endfor

    echo printf('Retrieving %s ...', l:operation)
endfunction

function! LspFzf#ReferencesFzf(ctx) abort
    let l:ctx = extend({ 'jump_if_one': 0 }, a:ctx)
    let l:request_params = { 'context': { 'includeDeclaration': v:true } }
    call s:list_location_fzf('references', l:ctx, l:request_params)
endfunction

command! LspReferencesFzf call LspFzf#ReferencesFzf({})
