(*
 * Copyright (c) 2006 Anil Madhavapeddy <anil@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

open Lexing
open Printf

(* Keep track of our location *)
type t = {
    file_name: string option;
    line_num: int;
    column_num: int;
}

exception Syntax_error of t

let start = ref 1
let line = ref 1
let file_name = ref None

let initial_location = { file_name=None; line_num=0; column_num=0 }
let current_location = ref initial_location
let cmd_location c = { file_name=Some c; line_num= -1; column_num= -1 }

let start_parse f =
    start := 1;
    line := 1;
    file_name := Some f

let new_line lexbuf =
    start := lexeme_end lexbuf;
    incr line

let next_token lexbuf =
    let col = lexeme_start lexbuf - !start in
    let l = {file_name= !file_name; line_num= !line; column_num=col} in
    current_location := l;
    l
        
let string_of_location l =
    let filestr = match l.file_name with |None ->"" |Some x -> sprintf " (%s)" x in
    let c = if l.column_num > 0 then sprintf " char %d" l.column_num else
        "" in
    if l.line_num >= 0 then
        sprintf " at line %d%s%s:" l.line_num c filestr
    else
        sprintf " in command line%s: " filestr
