function! ale_linters#c#pc_lint#Handle(buffer, lines) abort
    let l:output = []

    for l:err in a:lines
        let l:spliterr = split(l:err, ';')

        if l:spliterr[4] == 830
            let l:spliterr[5] = l:output[-1]['text'] . '(Error referenced elsewhere)' 
        endif
        call add(l:output, {
                    \'filename': l:spliterr[0],
                    \'lnum': l:spliterr[1],
                    \'col': l:spliterr[2],
                    \'type': l:spliterr[3][0],
                    \'code': l:spliterr[4],
                    \'text': l:spliterr[5]
                \})
    endfor

    return l:output
endfunction

" Create a variable for the path to the editor.lnt which is in this file
let g:editor_lnt = expand('<sfile>:p:h').'/editor.lnt'
echom g:editor_lnt

call ale#linter#Define('c', {
\   'name': 'pc_lint',
\   'executable': finddir('Tools', getcwd().";").'/Lint/LINT-NT.EXE',
\   'command': 'LINT-NT.EXE +ffn -v -b std.lnt ' . g:editor_lnt . ' %s',
\   'callback': 'ale_linters#c#pc_lint#Handle',
\   'cwd': finddir('Tools', getcwd().";").'/Lint',
\   'output_stream': 'stdout',
\   'lint_file': 1,
\})
