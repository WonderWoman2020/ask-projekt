# Skrypty dodatkowe - testowanie nowego kernela

## Spis treści

1. [Opis](#opis)
2. [Uruchamianie skryptów](#uruchamianie-skryptów)
3. [Dodawanie testów](#dodawanie-testów)

## Opis

Skrypt do testowania wczytuje testy do wykonania z pliku `lista_testow.txt`. Testy są w nim podzielone na grupy tj. "Pamięć", "Procesor" i w folderach o takich nazwach będą się zapisywać poszczególne wyniki testów w plikach `.csv`.

Aby testy wykonywały się bez naszego udziału i konieczności wpisywania przez użytkownika odpowiedzi dla narzędzia phoronix-test-suite, dodane zostały również skrypty `.exp` automatyzujące ten proces. Stworzono je przy użyciu narzędzi [autoexpect](https://linux.die.net/man/1/autoexpect) i [expect](https://linux.die.net/man/1/expect), które pozwalają na automatyzację wpisywania odpowiedzi do programów CLI, gdy wielokrotnie chcemy wykonywać program na takich samych danych wejściowych.

Testy do wykonania są pobierane przez narzędzie phoronix-test-suite. Skrypt usuwa zainstalowane testy po ich wykonaniu, żeby nie zajmowały miejsca - jeśli jednak chcemy pozostawić testy zainstalowane i nie pobierać ich za każdym razem, można zakomentować w skrypcie tą linijkę:

```
# gnome-terminal --command="bash -c 'cd $POLOZENIE; ./remove-test.exp $TEST; $SHELL'"
```

## Uruchamianie skryptów

Skrypty te można uruchamiać w analogiczny sposób, jak główny skrypt do kompilacji. Uruchamianie:

```
# najpierw należy wykonać skrypt instalujący narzędzie phoronix-test-suite
chmod +rwx phoronix_instalacja.sh
./phoronix_instalacja.sh

# następnie można uruchomić testy benchmark
chmod +rwx auto_testy.sh
./auto_testy.sh
```

## Dodawanie testów

Do skryptu można dodać więcej testów dostępnych w narzędziu phoronix-test-suite. Dostępne testy można sprawdzić na stronie [OpenBenchmarking.org](https://openbenchmarking.org), np. [tutaj](https://openbenchmarking.org/suite/pts/kernel) można znaleźć kilka testów do badania parametrów kerneli.

Jeśli chcemy rozszerzyć skrypt o wykonywanie większej ilości testów, możemy to zrobić w 2 krokach:
1. Używając narzędzia `autoexpect` raz wykonać test ręcznie, aby podać mu swoje odpowiedzi i skonfigurować wykonujący się test według naszych preferencji. Narzędzie `autoexpect` wygeneruje skrypt `.exp`, który będzie automatyzował za nas przyszłe wykonania tego testu. Przykłady jak działa narzędzie `autoexpect` można znaleźć [tutaj](https://www.networkworld.com/article/969513/automating-responses-to-scripts-on-linux-using-expect-and-autoexpect.html#:~:text=the%20square%20brackets.-,Autoexpect,-There%20is%20a), a dla narzędzia `expect` to samo znajdziemy [tutaj](https://phoenixnap.com/kb/linux-expect).

**Uwaga:** Może istnieć potrzeba zweryfikowania, czy skrypt działa i jego ręcznych poprawek, ponieważ autor obu narzędzi (`autoexpect` i `expect`) nie gwarantuje, że skrypty wygenerowane automatycznie przez `autoexpect` zawsze zbudują się poprawnie.

2. W pliku `lista_testow.txt` należy dodać interesujące nas testy, wpisując ich nazwę.