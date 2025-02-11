This was forked from the original bash version [here](https://github.com/saadbruno/minecraft-discord-webhook).
I then ran it through Deepseek for initial conversion and made some minor modifications thereafter to make a powershell version for any windows-based MC hosts.

There's definitely some jank to it, but it does functionally work! YMMV. 

PSA: I'm making zero commitment to keeping this updated/improved, it was a 10 minute hack effort that I'm putting here in case someone else also wants a mod-less way to integrate some MC events into discord via webhook on a windows-based host. 



# minecraft-discord-webhook



 
A small, server agnostic, way to push your Minecraft server updates to Discord

![image](https://user-images.githubusercontent.com/23201434/120118752-7e06c880-c16a-11eb-84fb-cce9fb123b38.png)

This script will push your easily push:

- Server joins and leaves
- Deaths
- Advancements, challenges and goals

to a Discord Webhook easily, with minimal configuration, and without needing server-side mods or plugins such as Spigot, Paper, etc (although it works with those servers as well!), meaning it also works with a vanilla server.

This script works by reading your server log file, parsing and formatting it using Discord rich embeds, and pushing it to the webhook endpoint.


### How to run:

- Clone the repo
- Place lang folder and minecraft-discord-webhook.ps1 in root folder of your MC Server
- In Powershell, run: 
```
$env:WEBHOOK_URL='YourDiscordWebhookURL'
$env:SERVERLOG='C:\Path\To\Your\MC\Folder\For\logs'
.\minecraft-discord-webhook.ps1
```

## Variables

- WEBHOOK_URL: it's the discord webhook you want the notifications posted to. Read more at [Discord Support](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)
- LANGUAGE: The language of the notifications. This only supports joins and leaves. Advancements and death messages are posted "as is", meaning they'll be posted using the language of your server. Check the [lang directory](https://github.com/saadbruno/minecraft-discord-webhook/tree/main/lang) for currently supported languages. Contributions are welcome!
- FOOTER: An optional footer text that will be included with the notifications, you can put your server name, server address or anything else. You can also ommit this for a more compact notification.
 ![image](https://user-images.githubusercontent.com/23201434/120119109-44cf5800-c16c-11eb-9ce1-8927629c805f.png)
- AVATAR: URL of an image to use as the bot-avatar.  Defaults to https://www.minecraft.net/etc.clientlibs/minecraft/clientlibs/main/resources/android-icon-192x192.png
- BOTNAME: Name of the bot in the Discord channel. Defaults to "Minecraft"
- PREVIEW: If set - will also add a preview of the message in the Discord channel

## Notes on logs

You have to pass the **entire logs diretory path** to the script, rather than just the `latest.log`. This is due to how Docker volumes work. If we're mounting just the `latest.log` file, when the Minecraft server rotates that log, Docker will not mount the new file automatically.
