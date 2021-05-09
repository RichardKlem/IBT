# IBT

## Adresářová struktura

Adresářová struktura a zároveň odevzdané soubory jsou následovné:

```
.
├── artifacts_ip.sql
├── artifacts_session.sql
├── artifacts.sql
├── artifacts_studio.sql
├── cl_environments.sql
├── cl_status.sql
├── create_indices.sql
├── data_model_transfer.sql
├── data_tables_new.sql
├── data_tables.sql
├── events.sql
├── init.sh
├── init.sql
├── load_data.sql
├── materialized_views.sql
├── performance_test.sql
├── README.md
├── refreshers_new.sql
├── refreshers.sql
├── sources.sql
├── tests_IDmod_1000.sql
└── tests_IDmod_100.sql
```

## Obecné informace

Ústav: Ústav informačních systémů (UIFS)<br>
Akademický rok: 2020/2021<br>
Číslo zadání: 24133<br>
Název česky: **Automatizované velkoobjemové zpracování testovacích
výsledků<br>**
Název anglicky: Automatic Largescale Processing of Testing Results<br>
Kategorie: Analýza a testování softwaru

Student: **Richard Klem (xklemr00)<br>**
Vedoucí práce: **Hruška Tomáš, prof. Ing., CSc.<br>**
Konzultant: Dolíhal Luděk, Ing., CODASIP<br>
Vedoucí ústavu: Kolář Dušan, doc. Dr. Ing.<br>

Datum zadání: 1. listopadu 2020<br>
Datum odevzdání: 12. května 2021<br>
Datum schválení: 24. října 2020<br>

## Zadání

1. Seznamte se s formáty výstupů z běžných testovacích nástrojů (JUnit, Jest, Go
   testing, Pytest, apod.) a s aktuálními možnostmi jejich zpracování a
   vizualizace (raw data nebo BI vizualizace).
2. Pro vybrané nástroje z bodu 1 prostudujte již existující aplikační řešení a
   tato řešení porovnejte a vyhodnoťte jejich vlastnosti.
3. Na základě poznatků z bodu 2 navrhněte vlastní řešení zpracování testovacích
   výsledků.
4. Navržené řešení implementujte za použití relační databáze a ověřte
   testovacími daty.
5. Zhodnoťte dosažené výsledky

## Prerekvizity a příprava prostředí

## Zdrojové kódy a skripty

Protože implementace řešení je v jazyce MySQL, odpovídá tomu i struktura a
formát zdrojových textů. Jedná se o sadu SQL skriptů a jednoho skriptu v jazyce
Shell. Shell skript provede jednoduché nastavení proměnných prostředí a spustí
SQL skripty ve specifickém pořadí. Výstupem tohoto procesu je pak:

- kompletně vytvořáná dvojice schémat pro původní referenční řešení i řešení
  nové,
- naplnění databází ukázkovými daty
- transformace datového modelu
- aktualizace dat po vytvoření nového modelu
- provedení indexace sloupců tabulek v obou schématech
- vytvoření materializovaných pohledů
- vytvoření uložených procedur pro aktualizace dat v materializovaných pohledech
- spuštění výkonového testu
- zobrazení statistiky výkonového testu ve schématu

## Spuštění

Pokud nemá soubor `init.sh` správně nastavená práva pro spuštění, je potřeba
tato práva udělit, např. příkazem:

- `chmod +x init.sh`
  Následné spuštění skriptu provedete příkazem:

- `./init.sh`

## Spuštění

Program obsahuje základní nastavení na experiment číslo 2 dle článku, model 1.

