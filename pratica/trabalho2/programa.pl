/* Emmanuel Podestá Junior, Fernando Paladini, Lucas Ribeiro Neis.

   Programacao Logica - Prof. Alexandre G. Silva - 30set2015
   
   RECOMENDACOES:
   
   - O nome deste arquivo deve ser 'programa.pl'
   
   - O nome do banco de dados deve ser 'desenhos.pl'
   
   - Dicas de uso podem ser obtidas na execucação: 
     ?- menu.
     
   - Exemplo de uso:
     ?- load.
     ?- searchAll(id1).
     
   - change. Done and ready for test.
      * returning "false", I think it should return "true" instead (more friendly)
      * When we got two or more identifiers (id40, id50 and so on), this method changes
        the correct point, but "deletes" all points from different identifiers.

        How to reproduce:
          xy(id40, 0, 250).
          xy(id40, 10, 10).
          xy(id50, 30, 30).
          xy(id50, 0, -2).
          xy(id50, 40, 78).
          xy(id60, 10000, 10000).

        Then change some identifier calling change(id50, 0, -2, 10000, 10000).

   - changeFirst. Done and ready for test.
      * Not changing only the first when points with same value appears:
            xy(id40, 0, 250).
            xy(id40, 0, 250).

        This will change both values. Actually don't know if it is a real problem.
        Anyway, can be easily solved just picking up the first point and ignoring others.

   - changeLast. Done and ready for test.
      * Couldn't test because the following error:
          ?- changeLast(id50, 200, 20004).
          ERROR: lUltimo/2: Undefined procedure: l/2
          Exception: (9) l([[id50, 0, -200]], _G566) ? 

   - searchFirst. Done and ready for test.
      * It's okay, but receiving the following error after print the result:

          ?- searchFirst(id50, X).
          [id50,-150,-150]
          ERROR: between/3: Arguments are not sufficiently instantiated

   - searchLast. Done and ready for test.
      * Can't use this command, don't know if I'm calling it wrong or what. 

          ?- searchLast(id40, X).
          ERROR: is/2: Arguments are not sufficiently instantiated

   - undo.

   - remove. Done and ready for test.
      * Okay.

   - quadrado. Done and ready for test.
      * Okay.

   - figura. Done and ready for test.
      * Okay.
      
   - replica.
   - Colocar o nome e matricula de cada integrante do grupo
     nestes comentarios iniciais do programa. Done.
*/

remove(Id, X, Y) :-
    retract(xy(Id, X, Y)).

% undo :- 
%     copy('desenhos.pl','backup.pl') :- 
%     open('desenhos.pl',read,Stream1),
%     open('backup.pl',write,Stream2),
%     copy_stream_data('desenhos.pl','backup.pl'),
%     close(File1),
%     close(File2).


% Apaga os predicados 'xy' da memoria e carrega os desenhos a partir de um arquivo de banco de dados
load :-
    retractall(xy(_,_,_)),
    open('desenhos.pl', read, Stream),
    repeat,
        read(Stream, Data),
        (Data == end_of_file -> true ; assert(Data), fail),
        !,
        close(Stream).

% Ponto de deslocamento, se <Id> existente
new(Id,X,Y) :-
    xy(Id,_,_),
    assertz(xy(Id,X,Y)),
    !.

% Ponto inicial, caso contrario
new(Id,X,Y) :-
    asserta(xy(Id,X,Y)),
    !.

quadrado(Id, X, Y, Lado) :-
    new(Id, X, Y),
    new(Id, Lado, 0),
    nb_setval(lado, Lado),
    nb_getval(lado, New),
    Neg is New * -1,
    new(Id, 0, Lado),
    new(Id, Neg, 0).

figura(Id, X, Y) :-
    new(Id, X, Y),
    new(Id, 200, 0),
    new(Id, 150, 150),
    new(Id, 0, 200),
    new(Id, -150, 150),
    new(Id, -200, 0),
    new(Id, -150, -150),
    new(Id, 0, -200).

% Exibe opcoes de busca
search :-
    write('searchAll(Id).     -> Ponto inicial e todos os deslocamentos de <Id>'), nl,
    write('searchFirst(Id,N). -> Ponto inicial e os <N-1> primeiros deslocamentos de <Id>'), nl,
    write('searchLast(Id,N).  -> Lista os <N> ultimos deslocamentos de <Id>').

searchAll(Id) :-
    listing(xy(Id,_,_)).

searchFirst(Id, N) :-
    findall(Ponto, (xy(Id,X,Y), append([Id], [X], L1), append(L1, [Y], Ponto) ), All),
    nth0(0, All, M),
    write(M), nl,
    between(1, N, X),
    nth0(X, All, K),
    write(K), nl,
    false.

searchLast(Id, N) :-
    findall(Ponto, (xy(Id,X,Y), append([Id], [X], L1), append(L1, [Y], Ponto) ), All), length(All, Tam),
    Itera is Tam - N,
    between(Itera, Tam, X),
    nth0(X, All, K),
    write(K),
    false.



% Exibe opcoes de alteracao
change :-
    write('change(Id,X,Y,Xnew,Ynew).  -> Altera o ponto inicial de <Id>'), nl,
    write('changeFirst(Id,Xnew,Ynew). -> Altera o ponto inicial de <Id>'), nl,
    write('changeLast(Id,Xnew,Ynew).  -> Altera o deslocamento final de <Id>').

change(Id, X, Y, Xnew, Ynew) :-
    findall(Ponto, (xy(Id,U,W), append([Id], [U], L1), append(L1, [W], Ponto) ), All), length(All, T),
    retractall(xy(_,_,_)),
    between(0, T, K),
    nth0(K, All, V),
    nth0(0, V, Ident),
    nth0(1, V, Ex),
    nth0(2, V, Uai),
    ( Ident = Id, Ex = X, Uai = Y -> new(Ident, Xnew, Ynew);
    new(Ident, Ex, Uai)),
    false.



changeFirst(Id, Xnew, Ynew) :-
    remove(Id, _, _), !,
    asserta(xy(Id, Xnew, Ynew)).

changeLast(Id, Xnew, Ynew) :-
      findall(Ponto, (xy(Id,X,Y), append([Id], [X], L1), append(L1, [Y], Ponto) ), All), length(All, T),
      lUltimo(All, L),
      write(L),
      nth0(0, L, Ident),
      write(Ident),
      nth0(1, L, Ex),
      nth0(2, L, Uai),
      remove(Ident,Ex, Uai),
      assertz(xy(Id, Xnew, Ynew)).



% ler o ultimo, 
lUltimo([X], X).
lUltimo([H|T], L) :- l(T, L).
%ler todos
lAll([X], X, K).
lAll([H|T], L, K) :- lAll(T, L, K), H = K.
% Grava os desenhos da memoria em arquivo
commit :-
    open('desenhos.pl', write, Stream),
    telling(Screen),
    tell(Stream),
    listing(xy),
    tell(Screen),
    close(Stream).

% Exibe menu principal
menu :-
    write('load.        -> Carrega todos os desenhos do banco de dados para a memoria'), nl,
    write('new(Id,X,Y). -> Insere um deslocamento no desenho com identificador <Id>'), nl,
    write('                (se primeira insercao, trata-se de um ponto inicial)'), nl,
    write('search.      -> Consulta pontos dos desenhos'), nl,
    write('change.      -> Modifica um deslocamento existente do desenho'), nl,
    write('remove.      -> Remove um determinado deslocamento existente do desenho'), nl,
    write('undo.        -> Remove o deslocamento inserido mais recentemente'), nl,
    write('commit.      -> Grava alteracoes de todos dos desenhos no banco de dados').