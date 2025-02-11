# minecraft-discord-webhook

This was forked from the bash version [here](https://github.com/saadbruno/minecraft-discord-webhook).
I then ran it through Deepseek and made some minor modifications to make a powershell version.
There's definitely some jank to it, but it does functionally work! YMMV. 
 
A small, server agnostic, way to push your Minecraft server updates to Discord

![image](https://user-images.githubusercontent.com/23201434/120118752-7e06c880-c16a-11eb-84fb-cce9fb123b38.png)

This script will push your easily push:

- Server joins and leaves
- Deaths
- Advancements, challenges and goals

to a Discord Webhook easily, with minimal configuration, and without needing server-side mods or plugins such as Spigot, Paper, etc (although it works with those servers as well!), meaning it also works with a vanilla server.

This script works by reading your server log file, parsing and formatting it using Discord rich embeds, and pushing it to the webhook endpoint.


### Without Docker

- Clone the repo
- In Powershell, run: 
$env:WEBHOOK_URL='YourDiscordWebhookURL'
$env:SERVERLOG='C:\Path\To\Your\MC\Folder\For\logs'

- run `WEBHOOK_URL=<discord webhook> SERVERLOG=</path/to/server/logs> FOOTER=<optional footer> LANGUAGE=<optional language> ./minecraft-discord.webook.sh`

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
