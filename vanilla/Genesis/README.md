# About
Genesis is a powerful healing addon for World of Warcraft (v1.12.1).
It scales spells to avoid overhealing and wasting mana. When target healing, spells will not be scaled down.
Healing can be bound to mouse or keyboard buttons.
Users can create custom healing classes where healing spell is chosen depending on the health of the target.
The addon allows a fair amount of customization, but is easy to use and works well without any configuration.

# Usage
To display the user interface type this command in the chat window:
```
/genesis
```

To display more command line options for Genesis:
```
/genesis help
```

# Custom heal class
To add spells to a custom heal class (first tab in user interface), drag spells from your spellbook and to the user interface. Then select the highest rank allowed for the spell, and the max health of the target for that spell to be used (if the target health is above the given percent, the spell will not be used). Do note that when you're target healing, the percent values are ignored, but if the target has a heal-over-time active then this won't be replaced by a new one.

# Heal macro
For advanced users it's possible to create macros casting healing spells:
```
/run Genesis_ActionHeal(spellOrClass, rank)
```
Where "spellOrClass" may be the name of a spell (such as "Healing Touch") or a class (such as "default", "myclass"). If a class is to be used then "rank" should not be specified, if a spell name is given then the "rank" parameter must be given. This is a number corresponding to the max allowed rank of the healing spell. If the value of "rank" is set to 0, then this means that the highest known rank of the spell is allowed. Do note that the rank is the max allowed rank of the spell, spell will still be scaled down if it's not necessary to use the highest rank.
