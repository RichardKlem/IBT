# IBT

Dokumentace k práci i zdrojovým kódům.

## Technická zpráva

### Obecné informace

Ústav: Ústav informačních systémů (UIFS)<br>
Akademický rok: 2020/2021<br>
Číslo zadání: 24133<br>
Název česky: **Automatizované velkoobjemové zpracování testovacích výsledků<br>**
Název anglicky: Automatic Largescale Processing of Testing Results<br>
Kategorie: Analýza a testování softwaru

Student: **Richard Klem (xklemr00)<br>**
Vedoucí práce: **Hruška Tomáš, prof. Ing., CSc.<br>**
Konzultant: Dolíhal Luděk, Ing., CODASIP<br>
Vedoucí ústavu: Kolář Dušan, doc. Dr. Ing.<br>

Datum zadání: 1. listopadu 2020<br>
Datum odevzdání: 12. května 2021<br>
Datum schválení: 24. října 2020<br>

### Zadání

1. Seznamte se s formáty výstupů z běžných testovacích nástrojů (JUnit, Jest, Go<br>
   testing, Pytest, apod.) a s aktuálními možnostmi jejich zpracování a<br>
   vizualizace (raw data nebo BI vizualizace).
2. Pro vybrané nástroje z bodu 1 prostudujte již existující aplikační řešení a<br>
   tato řešení porovnejte a vyhodnoťte jejich vlastnosti.
3. Na základě poznatků z bodu 2 navrhněte vlastní řešení zpracování testovacích<br>
   výsledků.
4. Navržené řešení implementujte za použití relační databáze a ověřte<br>
   testovacími daty.
5. Zhodnoťte dosažené výsledky.

## Implementace řešení - zdrojové kódy

### Prerekvizity

Pro spuštění skriptů a testování je nutné mít nainstalovaný a plně funkční<br>
MySQL verze 5.7.x. Řešení bylo testováno na verzi 5.7.34. Pro spuštění skriptů<br>
je nutné pouštět skripty jako takový užovatel, který má právo na vytváření<br>
uživatelů, přidělování práv apod. Je možné, že bude nunté použít uživatele root.

Dále je potřeba mít nainstalovaný unixový nástroj `bash` a mít správně nastavné<br>
proměnné prostředí. Spuštění v jiném programu typu Shell je pravděpodobně možné,<br>
ale nebylo testováno. Předpokládá se, že se nacházíte v kořenovém adresáři<br>
odevzdaného projektu.

### Popis skriptů a jejich výstupu

Protože implementace řešení je v jazyce MySQL, odpovídá tomu i struktura <br>
a formát zdrojových textů. Jedná se o sadu SQL skriptů a jednoho skriptu<br>
v jazyce Shell. Shell skript provede jednoduché nastavení proměnných prostředí<br>
a spustí SQL skripty ve specifickém pořadí. Výstupem tohoto procesu je pak:

- vytvoření testovácího uživatele `test_user` s heslem `12test5user`,
- kompletní vytvoření dvojice schémat pro původní referenční řešení i řešení nové,
- naplnění databází ukázkovými daty,
- transformace datového modelu,
- aktualizace dat po úpravě nového modelu,
- provedení indexace sloupců tabulek v obou schématech,
- vytvoření materializovaných pohledů,
- vytvoření uložených procedur pro aktualizace dat v materializovaných pohledech,
- spuštění výkonového testu a
- zobrazení statistiky výkonového testu ve schématu.

Se schématy i skripty lze dále pracovat pomocí užvatele `test_user` a výše<br>
zmíněného hesla.

Celý proces je plně zautomatizován. Jako výchozí skript slouží skript `run.sh`<br>
umístěný ve složce `source_codes`.

### Spuštění

1. Přesuňte se do složky `source_codes`.
2. Pokud nemá soubor `run.sh` správně nastavená práva pro spuštění, je potřeba<br>
   tato práva udělit, např. příkazem: `chmod +x run.sh`.
3. V základním nastavení se databáze naplní daty o objemu jedné tisíciny<br>
   testovacího datasetu. V případě, že máte zájem naplnit data o objemu jedné<br>
   setiny, otevřete soubor `run.sh` a upravte řádek 41 a 42 a zvolte požadovanou<br>
   verzi datasetu. Testovací dataset poskytnutý firmou Codasip není <br>
   z kapacitních důvodů k dispozici.
4. Následné spuštění výchozího skriptu provedete příkazem: `./run.sh`.

### Výstup

V průběhu vykonávání je uživatel informován o průbehu vytváření databázových<br>
objektů, manipulace s daty, spouštění testování apod.

Po doběhutí všech skriptů se zobrazí výsledek statistik. Ten má však omezenou<br>
vypovídající hodnotu, protože řešení je navrženo pro velké objemy dat a pro malé<br>
objemy nemusí generovat prezentované výsledky. Dostupné datasety slouží spíše<br>
k ověření funkčnosti implementace.
   
