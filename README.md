# Constellations
An ESO addon to help you find damage-optimized champiuon points.

## Dependencies

This addon requires the following libraries:


* [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
* [LibStub](https://www.esoui.com/downloads/info44-LibStub.html)

They are included in the release and have to be enabled in the Addon panel ingame.

## Description

**Please note that the addon is still in beta so don't expect everything to be perfect.**

After all that recent changes to the Champion Point System, distributing your CP to optimize your DPS has become a rather complicated affair. Theory Crafters like [URL="http://solinur.de/AsayreCP/CPOptimisation.html"]Asayre[/URL] and [URL="https://woeler.eu/cp/"]Br1ckst0n/Woeler[/URL] have worked to make CP calculators available, but this still requires you to get a parse, analyse it and enter the data manually.

This addon aims to simplify this process by automatically reading a Combat Metrics parse and enter all data automatically. 

It then attempts to calculate a better CP distribution and shows your original and new damage factor. 

### Instructions: 

* Open Combat Metrics or the Champion Point Menu. The Constellations window will then open as well.
* On the first tab in Constellations you need to enter the ratios of the various types of Damage you cause. 
* If you want to import a parse from Combat Metrics, browse to a fight and press the import button in the Constellations Window.
* Don't forget to adjust your "Damage Bonus %" value, as this isn't determined automatically.
* You can also select units (e.g. only the boss) in Combat Metrics so damage to other targets gets neglected.
* Alternatively you can enter everything manually.
* On the second tab you can edit the original CP composition. For new Combat Metrics Parses (since 0.7.4 on 20th of June) the CP composition is saved, so it will be restored on import. Otherwise your current CP distribution is preset. 
* When everything is set, press the calculate button on the 2nd tab.
* If the new damage factor is higher (indicated by green text color) a better CP distribution has been found. 

### Current Limitations:

* The addon can not automatically detect your Damage Done values. You need to set it yourself.
* The addon can not set any CP's, you only get shown what would be optimal.
* Some abilities **including most abilities which are not rank 4** are still missing from the database, which means they won't be automatically imported. A debug message will hint at these abilities. Please report them here, so I can implement them in the future. If you have some experience in theory crafting you can also comment on this [spreadsheet](https://docs.google.com/spreadsheets/d/1AMVpTmhUMBz-7gPOwKNSBA2VnX-Wjju8xIpPk0wk1Io/edit?usp=sharing") which I (and hopefully others) will update.

Big thanks to Latin for doing most of the work to collect data for all those abilities. Addtional thanks to Asayre for his theory crafting work on all the ingame mechanics.

*Decay2 aka Solinur (Pact EU)*
