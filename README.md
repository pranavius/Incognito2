
# Incognito2

Updated version of the popular World of Warcraft AddOn *Incognito*. I do not take any credit for creating this AddOn, but am simply extending its functionality and updating to be up-to-date with WoW's latest patch. The original AddOn's functionality remains intact for the most part; I have only made some modifications which I feel will improve its usability.

**Original Developers**
-  <!-- -->daniel@pew.cc
- nyyr

## Summary
Incognito adds you name in front of your chat messages. Can be enabled for guild (and officer), party, raid, and chat channel messages.

**Example**
<span  style="color:#1eff00">[Guild][Pranavius]: Hello, world!</span>
becomes
<span  style="color:#1eff00">[Guild][Pranavius]: (Pran): Hello, world!

## Usage
You can use the options window to modify all available options. Alternatively, you can utilize the slash commands `/incognito` or `/inc` to make quick changes.

### Options Window
#### General Options
- **Enable**: Enables AddOn functionality
- **Name**: The name you want to appear in your chat messages
- **Hide Name for Matching Characters**: When the current character's name is any of the ones listed, Incognito2 will not add your name to chat messages
  - *This is a new feature available in Incognito2*
  - Character names should be entered separated by commas
  - By default, Incognito2 will not add your name to messages if it matches the current character's name

#### Chat Options
- **Guild**: Adds your name to guild and officer chat messages (`/g` and `/o`)
- **Party**: Adds your name to party chat messages (`/p`)
- **Raid**: Adds your name to raid chat messages (`/raid`)
- **Instance**: Adds your name to any instance chat messages (LFR, Battlegrounds, Arena, etc.)
  - Enabling this option should also add your name to party and raid chat messages
- **Channel**: Custom channel to add your name when sending messages to
  - Names cannot be added to certain channels such as `/s`, `/y`, etc.
  - This will be updated to be more comprehensive later

There is also an option called **Debug** which enables debugging messages, though its usage is currently very minimal. No one should ever need to enable this at this point in time.

### Slash Commands
- `/inc config`: Opens the Options window
- `/inc enable`: Enables or disables AddOn functionality
  - This is the same as clicking the **Enable** checkbox in the Options window
- `/inc name`: Sets the name to add to chat messages
  - This is the same as entering text in the **Name** field in the Options window
- `/inc exclude`: Adds a character name to not add your name to in chat messages
  - *New to Incognito2*
  - This is the same as entering a name in the **Hide Name for Matching Characters** field in the Options window

## Development
To report any bugs or request additional features, please open a new issue in the [GitHub repository](https://github.com/pranavius/Incognito2/issues). Before doing so, please review the list of currently open issues to see if there is already one that matches yours.

If you would like to contribute to development, please clone the repository locally and open a pull request with your proposed changes.

This is my first foray into creating and updating WoW AddOns, so any feedback is greatly appreciated.

## Contact
**Twitter/X**: [PranaviusWoW](https://x.com/pranaviuswow)

**GitHub**: [Pranavius](https://github.com/pranavius)

**Email**: [pranavius1@gmail.com](mailto:pranavius1@gmail.com)

**Discord**: [Pranlabs](https://discord.gg/Vj3D5GeQZh)
