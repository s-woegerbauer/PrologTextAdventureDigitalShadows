:- dynamic(player_location/1).
:- dynamic(player_inventory/1).
:- dynamic(item_location/2).
:- dynamic(npc_location/2).
:- dynamic(discovered/1).
:- dynamic(current_time/1).
:- dynamic(day_count/1).
:- dynamic(player_stats/4).
:- dynamic(quest_status/2).
:- dynamic(game_over/0).

init_game :-
    retractall(player_location(_)),
    retractall(player_inventory(_)),
    retractall(item_location(_, _)),
    retractall(npc_location(_, _)),
    retractall(discovered(_)),
    retractall(current_time(_)),
    retractall(day_count(_)),
    retractall(player_stats(_, _, _, _)),
    retractall(quest_status(_, _)),
    retractall(game_over),
    
    asserta(player_location('classroom')),
    asserta(current_time(8)),
    asserta(day_count(1)),
    asserta(player_stats(100, 100, 100, 0)),  
    
    asserta(item_location('student_id', 'classroom')),
    asserta(item_location('usb_drive', 'computer_lab')),
    asserta(item_location('encryption_tool', 'hidden')),
    asserta(item_location('professor_keycard', 'teachers_lounge')),
    asserta(item_location('mysterious_file', 'server_room')),
    asserta(item_location('energy_drink', 'cafeteria')),
    asserta(item_location('sandwich', 'cafeteria')),
    asserta(item_location('school_map', 'hallway')),
    
    asserta(npc_location('lena', 'computer_lab')),
    asserta(npc_location('max', 'cafeteria')),
    asserta(npc_location('guard', 'hallway')),
    asserta(npc_location('leon', 'system')),
    asserta(npc_location('professor_finsterbach', 'teachers_lounge')),
    
    asserta(quest_status('main_quest', 'not_started')),
    asserta(quest_status('find_evidence', 'not_started')),
    asserta(quest_status('recruit_allies', 'not_started')),
    asserta(quest_status('access_lab', 'not_started')),
    
    asserta(discovered('classroom')),
    asserta(discovered('hallway')),
    asserta(discovered('computer_lab')),
    asserta(discovered('cafeteria')),
    asserta(discovered('home')).

start :-
    init_game,

    write('DIGITAL SHADOWS: FLUCHT AUS LEONDING'), nl,
    write('Ein spannendes Text Adventure, in dem du eine Verschwörung an der HTL Leonding aufdeckst.'), nl, nl,
    write('Du bist ein brillanter, aber rebellischer Schüler der HTL Leonding.'), nl,
    write('In letzter Zeit hast du bemerkt, dass einige der Top-Schüler sich seltsam verhalten...'), nl,
    write('Was ist hier los? Du musst herausfinden, was hinter "Projekt Digitaler Schatten" steckt.'), nl, nl,

    nl, write('Willkommen!'), nl,
    write('Du befindest dich im Klassenzimmer. Der Unterricht hat noch nicht begonnen.'), nl,
    write('Tippe "hilfe." für eine Liste der Befehle.'), nl,
    prompt.

help :-
    nl,
    write('Verfügbare Befehle:'), nl,
    write('  schau         - Umgebung untersuchen'), nl,
    write('  inventar      - Zeigt dein Inventar'), nl,
    write('  nimm(Objekt)  - Nimm ein Objekt auf'), nl,
    write('  gehe(Ort)     - Zu einem anderen Ort gehen'), nl,
    write('  benutze(Obj)  - Benutze ein Objekt aus deinem Inventar'), nl,
    write('  rede(Person)  - Mit einer Person sprechen'), nl,
    write('  status        - Zeigt deine aktuellen Werte'), nl,
    write('  zeit          - Zeigt die aktuelle Zeit'), nl,
    write('  warte         - Eine Stunde warten'), nl,
    write('  schlafe       - Schlafen gehen (nur zuhause möglich)'), nl,
    write('  orte          - Verfügbare Orte anzeigen'), nl,
    write('  hilfe         - Diese Hilfe anzeigen'), nl,
    write('  ende          - Spiel beenden'), nl,
    prompt.

status :-
    player_stats(Energy, Mental, Hunger, Suspicion),
    nl,
    write('Status:'), nl,
    write('  Energie:       '), write(Energy), write('/100'), nl,
    write('  Ment. Gesund.: '), write(Mental), write('/100'), nl,
    write('  Sättigung:     '), write(Hunger), write('/100'), nl,
    write('  Verdacht:      '), write(Suspicion), write('/100'), nl,
    
    nl, write('Aktive Quests:'), nl,
    quest_status('main_quest', MainStatus),
    write('  Hauptquest: '), write(MainStatus), nl,
    
    quest_status('find_evidence', EvidenceStatus),
    write('  Beweise finden: '), write(EvidenceStatus), nl,
    
    quest_status('recruit_allies', AllyStatus),
    write('  Verbündete finden: '), write(AllyStatus), nl,
    
    quest_status('access_lab', LabStatus),
    write('  Zugang zum Labor: '), write(LabStatus), nl,
    
    (Energy < 30 -> write('WARNUNG: Du bist erschöpft und brauchst Erholung!'), nl ; true),
    (Mental < 30 -> write('WARNUNG: Deine mentale Gesundheit leidet!'), nl ; true),
    (Hunger < 30 -> write('WARNUNG: Du bist hungrig und brauchst etwas zu essen!'), nl ; true),
    (Suspicion > 70 -> write('WARNUNG: Du weckst zu viel Aufmerksamkeit!'), nl ; true),
    
    prompt.

show_time :-
    current_time(Hour),
    day_count(Day),
    nl, write('Tag '), write(Day), write(', '),
    write(Hour), write(':00 Uhr'),
    
    (Hour >= 8, Hour =< 15 -> write(' (Schulzeit)') ;
     Hour >= 16, Hour =< 21 -> write(' (Freizeit)') ;
     write(' (Nacht)')),
    
    nl, prompt.

wait :-
    current_time(Hour),
    day_count(Day),
    NewHour is Hour + 1,
    
    player_stats(Energy, Mental, Hunger, Suspicion),
    NewEnergy is max(0, Energy - 5),
    NewHunger is max(0, Hunger - 5),
    NewSuspicion is max(0, Suspicion - 2),
    
    retract(player_stats(Energy, Mental, Hunger, Suspicion)),
    asserta(player_stats(NewEnergy, Mental, NewHunger, NewSuspicion)),
    
    (NewHour >= 24 ->
        NewDay is Day + 1,
        FinalHour is 0,
        retract(current_time(Hour)),
        retract(day_count(Day)),
        asserta(current_time(FinalHour)),
        asserta(day_count(NewDay)),
        nl, write('Es ist Mitternacht. Ein neuer Tag beginnt.'), nl
    ;
        retract(current_time(Hour)),
        asserta(current_time(NewHour)),
        nl, write('Eine Stunde vergeht...'), nl
    ),
    
    check_timed_events,
    
    check_player_state,
    
    prompt.

check_timed_events :-
    current_time(Hour),
    day_count(Day),
    
    (Day =:= 1, Hour =:= 9 ->
        nl, write('HINWEIS: Der Unterricht beginnt. Professor Finsterbach betritt den Raum.'), nl,
        asserta(npc_location('professor_finsterbach', 'classroom'))
    ; true),
    
    (Day =:= 1, Hour =:= 12 ->
        nl, write('HINWEIS: Mittagspause. Die meisten Schüler gehen zur Cafeteria.'), nl
    ; true),
    
    (Day =:= 1, Hour =:= 15 ->
        nl, write('HINWEIS: Der Unterricht ist vorbei. Zeit, die Schule zu erkunden.'), nl
    ; true),
    
    (Hour >= 22, Hour =< 6 ->
        nl, write('WARNUNG: Nachtwächter patrouillieren in der Schule.'), nl,
        update_security_patrol
    ; true).

blind_spot('server_room').
blind_spot('teachers_lounge').

forbidden_location('restricted_area').
forbidden_location('secret_lab').

forbidden_time :-
    current_time(Hour),
    (Hour < 8 ; Hour > 15).

leon_surveillance :-
    player_location(Loc),
    \+ blind_spot(Loc),
    (forbidden_location(Loc) ; forbidden_time),
    random(1, 4, X),
    X =:= 1,
    nl, write('LEON entdeckt dich auf den Kameras! Alarm wird ausgelöst!'), nl,
    call_leon_alarm,
    !;
    true.

call_leon_alarm :-
    player_stats(E, M, H, S),
    NewS is min(100, S + 20),
    retract(player_stats(E, M, H, S)),
    asserta(player_stats(E, M, H, NewS)),
    nl, write('Dein Verdachtslevel steigt! Wächter werden alarmiert.'), nl,
    update_security_patrol.

update_security_patrol :-
    retract(npc_location('guard', _)),
    Locations = ['hallway', 'computer_lab', 'cafeteria', 'server_room'],
    length(Locations, Len),
    random(0, Len, Index),
    nth0(Index, Locations, Location),
    asserta(npc_location('guard', Location)),

    player_location(PlayerLoc),
    (PlayerLoc = Location ->
        player_stats(Energy, Mental, Hunger, Suspicion),
        NewSuspicion is min(100, Suspicion + 30),
        retract(player_stats(Energy, Mental, Hunger, _)),
        asserta(player_stats(Energy, Mental, Hunger, NewSuspicion)),
        nl, write('ALARM! Ein Wächter hat dich entdeckt! Dein Verdachtslevel steigt!'), nl
    ; true).

check_player_state :-
    player_stats(Energy, Mental, Hunger, Suspicion),
    
    (Energy =< 0 ->
        nl, write('GAME OVER: Du bist völlig erschöpft zusammengebrochen.'), nl,
        asserta(game_over)
    ; Hunger =< 0 ->
        nl, write('GAME OVER: Du kannst dich vor Hunger nicht mehr konzentrieren.'), nl,
        asserta(game_over)
    ; Mental =< 0 ->
        nl, write('GAME OVER: Der Stress war zu viel. Du hast aufgegeben.'), nl,
        asserta(game_over)
    ; Suspicion >= 100 ->
        nl, write('GAME OVER: Du wurdest erwischt und von der Schule verwiesen.'), nl,
        asserta(game_over)
    ; true).

inventory :-
    nl, write('Dein Inventar:'), nl,
    (bagof(Item, player_inventory(Item), Items) ->
        print_list(Items)
    ;
        write('  Dein Inventar ist leer.')
    ),
    nl, prompt.

print_list([]) :- nl.
print_list([H|T]) :-
    write('  - '), write(H), nl,
    print_list(T).

take(Object) :-
    player_location(Location),
    (item_location(Object, Location) ->
        retract(item_location(Object, Location)),
        asserta(player_inventory(Object)),
        nl, write('Du nimmst '), write(Object), write('.'), nl,
        leon_surveillance,
        
        (Object = 'mysterious_file' ->
            nl, write('HINWEIS: Du hast eine mysteriöse Datei gefunden! Vielleicht enthält sie Hinweise?'), nl,
            retract(quest_status('find_evidence', _)),
            asserta(quest_status('find_evidence', 'in_progress'))
        ; true),
        
        (Object = 'student_id' ->
            nl, write('HINWEIS: Mit deinem Studentenausweis kannst du dich im Schulgebäude bewegen.'), nl
        ; true)
    ;
        nl, write('Hier gibt es kein '), write(Object), write('.'), nl
    ),
    prompt.

use(Object) :-
    (player_inventory(Object) ->
        nl, write('Du benutzt '), write(Object), write('.'), nl,
        leon_surveillance,
        
        (Object = 'energy_drink' ->
            player_stats(Energy, Mental, Hunger, Suspicion),
            NewEnergy is min(100, Energy + 30),
            retract(player_stats(Energy, Mental, Hunger, Suspicion)),
            asserta(player_stats(NewEnergy, Mental, Hunger, Suspicion)),
            retract(player_inventory('energy_drink')),
            write('Du fühlst dich energiegeladener!'), nl
        ; Object = 'sandwich' ->
            player_stats(Energy, Mental, Hunger, Suspicion),
            NewHunger is min(100, Hunger + 40),
            retract(player_stats(Energy, Mental, Hunger, Suspicion)),
            asserta(player_stats(Energy, Mental, NewHunger, Suspicion)),
            retract(player_inventory('sandwich')),
            write('Das hat gut getan! Du bist nicht mehr so hungrig.'), nl
        ; Object = 'usb_drive' ->
            player_location(Location),
            (Location = 'computer_lab' ->
                write('Du steckst den USB-Stick in einen Computer.'), nl,
                write('Du entdeckst verschlüsselte Dateien über "Projekt Digitaler Schatten"!'), nl,
                retract(quest_status('main_quest', _)),
                asserta(quest_status('main_quest', 'in_progress'))
            ;
                write('Du brauchst einen Computer, um den USB-Stick zu benutzen.'), nl
            )
        ; Object = 'professor_keycard' ->
            player_location(Location),
            (Location = 'restricted_area' ->
                write('Du benutzt die Keycard, um Zugang zum geheimen Labor zu erhalten!'), nl,
                asserta(discovered('secret_lab')),
                retract(quest_status('access_lab', _)),
                asserta(quest_status('access_lab', 'completed'))
            ;
                write('Die Keycard könnte dir Zugang zu gesperrten Bereichen verschaffen.'), nl
            )
        ; Object = 'school_map' ->
            write('Du studierst die Schulkarte und entdeckst neue Bereiche!'), nl,
            asserta(discovered('teachers_lounge')),
            asserta(discovered('server_room')),
            asserta(discovered('restricted_area'))
        ; Object = 'mysterious_file' ->
            write('Du studierst die mysteriöse Datei...'), nl,
            write('Sie enthält Hinweise auf geheime Experimente mit Schülern!'), nl,
            write('Es scheint, als ob Professor Finsterbach die Schüler mit KI-Implantaten kontrolliert.'), nl,
            retract(quest_status('find_evidence', _)),
            asserta(quest_status('find_evidence', 'completed'))
        ;
            write('Nichts Besonderes passiert.')
        )
    ;
        nl, write('Du hast kein '), write(Object), write(' in deinem Inventar.'), nl
    ),
    prompt.

talk(Person) :-
    player_location(Location),
    (npc_location(Person, Location) ->
        nl, write('Du sprichst mit '), write(Person), write('.'), nl,
        
        (Person = 'lena' ->
            write('Lena: "Hey! Ich habe auch komische Dinge in der Schule bemerkt.'), nl,
            write('       Ich kann dir mit dem Hacken von Sicherheitssystemen helfen.'), nl,
            write('       Suche nach einem USB-Stick im Computerraum. Er könnte nützlich sein."'), nl,

            (quest_status('recruit_allies', 'in_progress') ->
               retract(quest_status('recruit_allies', _)),
               asserta(quest_status('recruit_allies', 'completed'))
            ; true)
        ; Person = 'max' ->
            write('Max: "Alter, gut dass du hier bist! Die neuen Schüler benehmen sich total seltsam.'), nl,
            write('      Wie Roboter! Ich kann für Ablenkung sorgen, wenn du in gesperrte Bereiche willst.'), nl,
            write('      Übrigens, schau mal in der Lehrerloge nach. Finsterbach hat dort immer seine Keycard."'), nl,
            
            retract(quest_status('recruit_allies', _)),
            asserta(quest_status('recruit_allies', 'in_progress'))
        ; Person = 'guard' ->
            write('Wächter: "Hey du! Was machst du hier? Der Unterricht ist vorbei.'), nl,
            write('          Du solltest nicht hier sein. Mach dass du wegkommst!"'), nl,
            
            player_stats(Energy, Mental, Hunger, Suspicion),
            NewSuspicion is min(100, Suspicion + 10),
            retract(player_stats(Energy, Mental, Hunger, Suspicion)),
            asserta(player_stats(Energy, Mental, Hunger, NewSuspicion))
        ; Person = 'professor_finsterbach' ->
            write('Professor Finsterbach: "Ah, einer meiner Schüler. Was kann ich für dich tun?'), nl,
            write('                        Der Unterricht ist vorbei, du solltest nach Hause gehen.'), nl,
            write('                        Oder interessierst du dich für unser... Spezialprogramm?"'), nl,
            
            current_time(Hour),
            (quest_status('find_evidence', 'completed'), player_inventory('encryption_tool') ->
                write('Seine Augen verengen sich. "Du weißt zu viel. Das werde ich nicht zulassen."'), nl,
                write('Er drückt einen Knopf unter seinem Tisch. Alarm! Du musst fliehen!'), nl,
                player_stats(Energy, Mental, Hunger, Suspicion),
                NewSuspicion is min(100, Suspicion + 30),
                retract(player_stats(Energy, Mental, Hunger, Suspicion)),
                asserta(player_stats(Energy, Mental, Hunger, NewSuspicion))
            ; true)
        ; 
            write('Diese Person hat dir nichts zu sagen.')
        )
    ;
        nl, write('Diese Person ist nicht hier.'), nl
    ),
    prompt.

show_locations :-
    nl, write('Verfügbare Orte:'), nl,
    (bagof(Location, discovered(Location), Locations) ->
        print_list(Locations)
    ;
        write('  Keine bekannten Orte.')
    ),
    nl, prompt.

look :-
    player_location(Location),
    nl, write('Du befindest dich in/im: '), write(Location), nl,
    
    (Location = 'classroom' ->
        write('Ein typisches Klassenzimmer mit Tischen, Stühlen und einer elektronischen Tafel.'), nl,
        write('Der Raum ist momentan leer, abgesehen von dir.')
    ; Location = 'hallway' ->
        write('Ein langer Korridor mit Spinden an den Wänden.'), nl,
        write('Von hier aus kannst du verschiedene Räume der Schule erreichen.')
    ; Location = 'computer_lab' ->
        write('Ein Raum voller Computer-Arbeitsplätze.'), nl,
        write('Die meisten Rechner sind aus, aber einige laufen noch.')
    ; Location = 'cafeteria' ->
        write('Der Speisesaal der Schule. Hier gibt es Essen und Getränke.'), nl,
        write('Ein guter Ort, um andere Schüler zu treffen oder zu belauschen.')
    ; Location = 'teachers_lounge' ->
        write('Der Aufenthaltsraum der Lehrer. Du solltest hier eigentlich nicht sein!'), nl,
        write('Du musst vorsichtig sein, um nicht erwischt zu werden.')
    ; Location = 'server_room' ->
        write('Ein kühler Raum voller Server und blinkender Lichter.'), nl,
        write('Hier werden alle Daten der Schule gespeichert und verarbeitet.')
    ; Location = 'restricted_area' ->
        write('Ein abgesperrter Bereich, der nur mit Keycard zugänglich ist.'), nl,
        write('Kameras überwachen den Eingang zum geheimen Labor.')
    ; Location = 'secret_lab' ->
        write('Ein verstecktes Labor unter der Schule!'), nl,
        write('Hier entdeckst du die schreckliche Wahrheit über "Projekt Digitaler Schatten".')
    ; Location = 'home' ->
        write('Dein Zuhause. Ein sicherer Ort zum Ausruhen und Nachdenken.'), nl,
        write('Hier kannst du schlafen und dich erholen.')
    ;
        write('Ein unbekannter Ort.')
    ),
    
    nl, write('Du siehst:'),
    (bagof(Item, item_location(Item, Location), Items) ->
        nl, print_list(Items)
    ;
        write(' nichts Besonderes.')
    ),
    
    nl, write('Anwesende Personen:'),
    (bagof(NPC, npc_location(NPC, Location), NPCs) ->
        nl, print_list(NPCs)
    ;
        write(' niemand.')
    ),
    
    current_time(Hour),
    (Location = 'server_room', Hour >= 22 ->
        nl, write('HINWEIS: Nachts ist der Serverraum ideal, um unentdeckt zu bleiben.'), nl
    ; true),
    
    nl, prompt.

epic_showdown :-
    nl, write('*** EPIC SHOWDOWN ***'), nl,
    write('Professor Finsterbach steht im geheimen Labor und erwartet dich.'), nl,
    write('Er: "Du bist also bis hierher gekommen... Beeindruckend. Aber hier endet deine Reise!"'), nl,
    write('Ein dramatischer Kampf entbrennt zwischen dir und dem Professor!'), nl,
    player_stats(Energy, Mental, Hunger, Suspicion),
    NewEnergy is max(0, Energy - 30),
    NewMental is max(0, Mental - 20),
    NewSuspicion is min(100, Suspicion + 40),
    retract(player_stats(Energy, Mental, Hunger, Suspicion)),
    asserta(player_stats(NewEnergy, NewMental, Hunger, NewSuspicion)),
    write('Du setzt all deine Kräfte ein, um dich zu verteidigen...'), nl,
    write('Nach einem harten Kampf gelingt es dir, den Professor zu überwältigen!'), nl,
    write('Die Wahrheit über das Projekt kommt ans Licht.'), nl,
    retract(quest_status('main_quest', _)),
    asserta(quest_status('main_quest', 'completed')),
    check_win_condition,
    ende.
epic_showdown :- true.

go(Destination) :-
    player_location(CurrentLocation),
    
    (discovered(Destination) ->
        (Destination = 'restricted_area', 
         \+ player_inventory('professor_keycard'),
         \+ quest_status('recruit_allies', 'completed') ->
            nl, write('Dieser Bereich ist gesperrt! Du benötigst eine Keycard und Verbündete.'), nl
        ; Destination = 'secret_lab',
          \+ quest_status('access_lab', 'completed') ->
            nl, write('Du kannst das Labor erst betreten, wenn du Zugang erhalten hast.'), nl
        ;
            retract(player_location(CurrentLocation)),
            asserta(player_location(Destination)),
            player_stats(Energy, Mental, Hunger, Suspicion),
            NewEnergy is max(0, Energy - 5),
            retract(player_stats(Energy, Mental, Hunger, Suspicion)),
            asserta(player_stats(NewEnergy, Mental, Hunger, Suspicion)),
            nl, write('Du gehst zu: '), write(Destination), nl,
            (Destination = 'secret_lab' -> epic_showdown ; true),
            leon_surveillance,
            look
        )
    ;
        nl, write('Diesen Ort kennst du nicht oder er ist nicht von hier aus erreichbar.'), nl,
        prompt
    ).

sleep :-
    player_location(Location),
    (Location = 'home' ->
        nl, write('Du legst dich hin und schläfst...'), nl,
        
        player_stats(_, Mental, Hunger, Suspicion),
        NewEnergy is 100,
        NewMental is min(100, Mental + 20),
        NewHunger is max(0, Hunger - 20),
        
        retract(player_stats(_, Mental, Hunger, Suspicion)),
        asserta(player_stats(NewEnergy, NewMental, NewHunger, Suspicion)),
        
        current_time(Hour),
        day_count(Day),
        NewDay is Day + 1,
        
        retract(current_time(Hour)),
        retract(day_count(Day)),
        asserta(current_time(8)),
        asserta(day_count(NewDay)),
        
        write('Du wachst erfrischt auf. Es ist 8:00 Uhr morgens am nächsten Tag.'), nl
    ;
        nl, write('Du kannst nur zu Hause schlafen.'), nl
    ),
    prompt.

prompt :-
    game_over ->
        nl, write('Das Spiel ist vorbei. Tippe "start." um neu zu beginnen.'), nl
    ;
        nl, write('> ').

schau :- look.
inventar :- inventory.
nimm(X) :- take(X).
gehe(X) :- go(X).
benutze(X) :- use(X).
rede(X) :- talk(X).
zeit :- show_time.
orte :- show_locations.
schlafe :- sleep.
warte :- wait.
hilfe :- help.
ende :- 
    write('Spiel beendet. Danke fürs Spielen!'), nl,
    halt.

check_win_condition :-
    player_location('secret_lab'),
    player_inventory('mysterious_file'),
    quest_status('main_quest', 'completed'),
    quest_status('find_evidence', 'completed'),
    quest_status('recruit_allies', 'completed'),
    quest_status('access_lab', 'completed'),
    !,
    nl, write('GLÜCKWUNSCH! Du hast es geschafft!'), nl,
    write('Du hast alle Beweise gesammelt und die Wahrheit über Projekt Digitaler Schatten aufgedeckt.'), nl,
    write('Professor Finsterbach und seine Komplizen werden zur Rechenschaft gezogen.'), nl,
    write('Die Schüler werden von der Gedankenkontrolle befreit und die HTL Leonding ist gerettet!'), nl,
    write('ENDE DES SPIELS'), nl,
    asserta(game_over).

look :- check_win_condition.

connected('classroom', 'hallway').
connected('hallway', 'computer_lab').
connected('hallway', 'cafeteria').
connected('hallway', 'classroom').
connected('hallway', 'home').
connected('hallway', 'teachers_lounge'). 
connected('hallway', 'server_room'). 
connected('hallway', 'restricted_area').
connected('computer_lab', 'hallway').
connected('cafeteria', 'hallway').
connected('teachers_lounge', 'hallway').
connected('server_room', 'hallway').
connected('restricted_area', 'hallway').
connected('restricted_area', 'secret_lab'). 
connected('secret_lab', 'restricted_area').
connected('home', 'hallway').

can_go(From, To) :-
    connected(From, To),
    (To \= 'teachers_lounge' ; discovered('teachers_lounge')),
    (To \= 'server_room' ; discovered('server_room')),
    (To \= 'restricted_area' ; discovered('restricted_area')),
    (To \= 'secret_lab' ; quest_status('access_lab', 'completed')).

random_event :-
    random(1, 10, Event),
    (Event =:= 1 ->
        player_stats(Energy, Mental, Hunger, Suspicion),
        NewMental is max(0, Mental - 10),
        retract(player_stats(Energy, Mental, Hunger, Suspicion)),
        asserta(player_stats(Energy, NewMental, Hunger, Suspicion)),
        nl, write('Du hörst seltsame Stimmen in deinem Kopf. Deine mentale Gesundheit leidet!'), nl
    ; Event =:= 2 ->
        player_location(Location),
        (Location \= 'home', Location \= 'secret_lab' ->
            nl, write('Ein Lehrer geht vorbei und sieht dich misstrauisch an.'), nl
        ; true)
    ; Event =:= 3 ->
        current_time(Hour),
        (Hour >= 12, Hour =< 14 ->
            player_stats(Energy, Mental, Hunger, Suspicion),
            asserta(item_location('sandwich', 'cafeteria')),
            nl, write('Die Cafeteria hat frische Sandwiches!'), nl
        ; true)
    ; true).

gameloop :-
    read(Command),
    call(Command),
    (game_over -> true ; gameloop).
