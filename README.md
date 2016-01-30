# Devious Attributes
Have you ever wondered what happens in the mind of our poor Dragonborn when melting faces with fire spells, or being ravaged by creatures after humiliating defeat?
A framework that is designed to bring more immersion and consequences to various in-game events, good or bad. I always liked the idea of consequences in RPG games... and in my opinion, some really bad stuff that can happen to the Dragonborn in a very devious place that is Skyrim, should have consequences.

Note : you can read more in Wiki - eventually I will write very detailed mechanics explanation. But until then...<br/>
New character stats will be tracked:

* ''Willpower'' - regenerating stat that will be used to calculate whether the character can refuse slave master command. Each time master's command is accepted, willpower value will be lowered. For example: Master : "kneel!" -> in order to refuse, you need to have enough willpower left. If you kneel, your willpower will have lower value for some time. In time, this value will regenerate until certain threshold. Also, this value will be used to determine if the character can struggle with restraints - like armbinder, or try to escape (e.g. try to pickpocket the master). Each time the character struggles with restraints, willpower will be lowered as well.
* ''Pride'' - Will increase by winning combat, and will decrease by being defeated or by wearing openly a devious device/collar. Each time a slave character refuses master's request, will increase the pride as well. Each time a character will accept master's request, pride will be lowered. Having higher pride will regenerate willpower faster.
* ''Self-Esteem'' - Will increase slowly with time, with a constant rate. Will decrease for each humiliating act character does. (Either through modding API or through wearing "degrading" devices such as pony boots.)
Submissiveness - Calculated value, that will be used to determine how obedient and submissive the character is. This is calculated from combination of Pride and Self-Esteem
* ''Obedience'' - Signifies long-term conditioning to obey. Will decrease slowly with time, If it surpasses current Willpower value, the character Submissiveness will be considered as 100% and no longer will be able to struggle with bindings, or refuse commands/requests
