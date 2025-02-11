#!/usr/bin/env pwsh

# Minecraft Discord Webhook. A simple, server agnostic, way to push your Minecraft server updates to discord.
# Converted from Bash to PowerShell
# MIT License
# Documentation available at: https://github.com/saadbruno/appendhook
# Usage:
#    $env:WEBHOOK_URL="<discord webhook>"; $env:SERVERLOG="</path/to/server/logs>"; $env:FOOTER="<optional footer>"; $env:LANGUAGE="<optional language>"; .\minecraft-discord-webhook.ps1
# Docker usage instructions in original repository

# Check required variables
if (-not $env:WEBHOOK_URL) {
    Write-Host ":: WARNING: Missing arguments. USAGE:"
    Write-Host "   \$env:WEBHOOK_URL='<discord webhook>'; \$env:SERVERLOG='</path/to/server/logs>'; .\minecraft-discord-webhook.ps1"
    Write-Host ":: If using Docker, ensure WEBHOOK_URL is set"
    exit 1
}

if (-not (Test-Path "$env:SERVERLOG/latest.log")) {
    Write-Host ":: WARNING: Couldn't find server log. Ensure $env:SERVERLOG/latest.log exists."
    Write-Host ":: Docker users: Mount log with '-v /path/to/logs:/logs:ro'"
    exit 1
}

$DIR = $PSScriptRoot
$CACHE = Get-Date -Format "yyyyMMdd"

# Set defaults
if (-not $env:LANGUAGE) { $env:LANGUAGE = "en-US" }
if (-not $env:BOTNAME) { $env:BOTNAME = "Minecraft" }
if (-not $env:AVATAR) { $env:AVATAR = "https://www.minecraft.net/etc.clientlibs/minecraft/clientlibs/main/resources/android-icon-192x192.png" }

$LANGFILE = "$DIR/lang/$($env:LANGUAGE).ps1"

Write-Host @"
=================================================
Starting webhooks script with:
:: Language: $env:LANGUAGE
:: URL: $env:WEBHOOK_URL
:: Footer: $env:FOOTER
:: Log: $env:SERVERLOG/latest.log
=================================================
"@

function webhook_compact {
    param(
        [string]$authorName,
        [string]$color,
        [string]$iconUrl
    )

    $content = if ($env:PREVIEW) { $authorName } else { "" }
    
    $embed = @{
        color = $color
        author = @{
            name = $authorName
            icon_url = $iconUrl
        }
        footer = @{
            text = $env:FOOTER
        }
    }

    $body = @{
        username = $env:BOTNAME
        avatar_url = $env:AVATAR
        content = $content
        embeds = @($embed)
    }

    $jsonBody = $body | ConvertTo-Json -Depth 5
    try {
        Invoke-RestMethod -Uri $env:WEBHOOK_URL -Method Post -Body $jsonBody -ContentType 'application/json'
    } catch {
        Write-Host "Webhook Error: $_"
    }
}

# Initial startup message
webhook_compact "Monitoring started for the MC Server" 9737364 $env:AVATAR

# Main log monitoring loop
Get-Content -Path "$env:SERVERLOG/latest.log" -Tail 0 -Wait | ForEach-Object {
    $line = $_
    switch -Wildcard ($line) {
        '*<*>*' { Write-Host "Chat message"; break }
        
        '*EntityVillager*' { Write-Host "Skipping Villager death"; break }
        
        '*joined the game*' {
            $afterColon = $line -replace '^.*: ',''
            $player = ($afterColon -split ' ')[0]
            . $LANGFILE
            $player = $player + " logged in"
            Write-Host "$player"
            webhook_compact $player 6473516 "https://minotar.net/helm/$player?v=$CACHE"
            break
        }
        
        '*left the game*' {
            $afterColon = $line -replace '^.*: ',''
            $player = ($afterColon -split ' ')[0]
            . $LANGFILE
            Write-Host "$player left"
            $player = $player + " logged out like a nerd."
            webhook_compact $player 9737364 "https://minotar.net/helm/$player?v=$CACHE"
            break
        }
        
        # Death messages
        '*was*by*'      { $type = 'death'; break }
        '*was burnt*'   { $type = 'death'; break }
        '*whilst trying to escape*' { $type = 'death'; break }
        # ... other death patterns ...
        
        { $_ -match 'was|fell|drowned|death' } {  # Simplified death detection
            $afterColon = $line -replace '^.*: ',''
            $player = ($afterColon -split ' ')[0]
            . $LANGFILE
            Write-Host "$player died"
            webhook_compact $afterColon 10366780 "https://minotar.net/helm/$player?v=$CACHE"
            break
        }
        
        '*made the advancement*' {
            $afterColon = $line -replace '^.*: ',''
            $player = ($afterColon -split ' ')[0]
            . $LANGFILE
            webhook_compact $afterColon 2842864 "https://minotar.net/helm/$player?v=$CACHE"
            break
        }
        
        # Geyser messages
        '*main/INFO]*' {
            $message = ($line -split '\]', 2)[1].Trim()
            . $LANGFILE
            webhook_compact $message 3447003 "https://geysermc.org/img/icons/geyser.png"
            break
        }
        
        '*main/WARN]*' {
            $message = ($line -split '\]', 2)[1].Trim()
            . $LANGFILE
            webhook_compact $message 10366780 "https://geysermc.org/img/icons/geyser.png"
            break
        }
        
        '*tried to connect*' {
            $message = ($line -split '\]', 2)[1].Trim()
            . $LANGFILE
            webhook_compact $message 3447003 "https://geysermc.org/img/icons/geyser.png"
            break
        }
        
        # ... Add other message patterns following same structure
    }
}
